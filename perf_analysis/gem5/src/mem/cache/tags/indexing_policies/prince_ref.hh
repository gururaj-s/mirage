// Obtained from https://github.com/sebastien-riou/prince-c-ref/blob/master/include/prince_ref.h
// Modified to add test-cases.

/*
Copyright 2016 Sebastien Riou
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

/*! \file prince_ref.hh
    \brief Reference implementation of the Prince block cipher, complient to C99.
    'Reference' here means straightforward, unoptimized, and checked against the few test vectors provided in the original paper (http://eprint.iacr.org/2012/529.pdf).
    By defining the macro PRINCE_PRINT, one can print out all successive internal states.
*/

#ifndef __PRINCE_REF_H__
#define __PRINCE_REF_H__

#include <stdint.h>
#include <string.h>

#ifndef PRINCE_PRINT
#define PRINCE_PRINT(a) do{}while(0)
#endif

/**
 * Converts a byte array into a 64 bit integer
 * byte at index 0 is placed as the most significant byte.
 */
static uint64_t bytes_to_uint64(const uint8_t in[8]){
  uint64_t out=0;
  unsigned int i;
  for(i=0;i<8;i++) 
    out = (out<<8) | in[i];  
  return out;
}

/**
 * Converts a 64 bit integer into a byte array
 * The most significant byte is placed at index 0.
 */
static void uint64_to_bytes(const uint64_t in, uint8_t out[8]){
  unsigned int i;
  for(i=0;i<8;i++)
    out[i]=in>>((7-i)*8);
}

/**
 * Compute K0' from K0
 */
static uint64_t prince_k0_to_k0_prime(const uint64_t k0){
  uint64_t k0_ror1 = (k0 >> 1) | (k0 << 63);
  uint64_t k0_prime = k0_ror1 ^ (k0 >> 63);
  return k0_prime;
}

static uint64_t prince_round_constant(const unsigned int round){
  uint64_t rc[] = {
    UINT64_C(0x0000000000000000),
    UINT64_C(0x13198a2e03707344),
    UINT64_C(0xa4093822299f31d0),
    UINT64_C(0x082efa98ec4e6c89),
    UINT64_C(0x452821e638d01377),
    UINT64_C(0xbe5466cf34e90c6c),
    UINT64_C(0x7ef84f78fd955cb1),
    UINT64_C(0x85840851f1ac43aa),
    UINT64_C(0xc882d32f25323c54),
    UINT64_C(0x64a51195e0e3610d),
    UINT64_C(0xd3b5a399ca0c2399),
    UINT64_C(0xc0ac29b7c97c50dd)
  };
  return rc[round];
}

/**
 * The 4 bit Prince sbox. Only the 4 lsb are taken into account.
 */
static unsigned int prince_sbox(unsigned int nibble){
  const unsigned int sbox[] = {
    0xb, 0xf, 0x3, 0x2,
    0xa, 0xc, 0x9, 0x1, 
    0x6, 0x7, 0x8, 0x0,
    0xe, 0x5, 0xd, 0x4
  };
  return sbox[nibble & 0xF];
}

/**
 * The 4 bit Prince inverse sbox. Only the 4 lsb are taken into account.
 */
static unsigned int prince_sbox_inv(unsigned int nibble){
  const unsigned int sbox[] = {
    0xb, 0x7, 0x3, 0x2,
    0xf, 0xd, 0x8, 0x9, 
    0xa, 0x6, 0x4, 0x0,
    0x5, 0xe, 0xc, 0x1
  };
  return sbox[nibble & 0xF];
}

/**
 * The S step of the Prince cipher.
 */
static uint64_t prince_s_layer(const uint64_t s_in){
  uint64_t s_out = 0;
  for(unsigned int i=0;i<16;i++){
    const unsigned int shift = i*4;
    const unsigned int sbox_in = s_in>>shift;
    const uint64_t sbox_out = prince_sbox(sbox_in);
    s_out |= sbox_out<<shift;
  }
  return s_out;
}

/**
 * The S^-1 step of the Prince cipher.
 */
static uint64_t prince_s_inv_layer(const uint64_t s_inv_in){
  uint64_t s_inv_out = 0;
  for(unsigned int i=0;i<16;i++){
    const unsigned int shift = i*4;
    const unsigned int sbox_in = s_inv_in>>shift;
    const uint64_t sbox_out = prince_sbox_inv(sbox_in);
    s_inv_out |= sbox_out<<shift;
  }
  return s_inv_out;
}

static uint64_t gf2_mat_mult16_1(const uint64_t in, const uint64_t mat[16]){
  uint64_t out = 0;
  for(unsigned int i=0;i<16;i++){
    if((in>>i) & 1)
      out ^= mat[i];
  }
  return out;
}

/**
 * Build Prince's 16 bit matrices M0 and M1.
 */
// static void prince_m16_matrices(uint64_t m16[2][16]){
//   //4 bits matrices m0 to m3 are stored in array m4
//   const uint64_t m4[4][4] = {
//     //m0
//     {0x0,0x2,0x4,0x8},
//     //m1
//     {0x1,0x0,0x4,0x8},
//     //m2
//     {0x1,0x2,0x0,0x8},
//     //m3
//     {0x1,0x2,0x4,0x0}
//   };
//   //build 16 bits matrices
//   for(unsigned int i=0;i<16;i++){
//     const unsigned int base = i/4;
//     m16[0][i] = (m4[(base+3)%4][i%4]<<8) | (m4[(base+2)%4][i%4]<<4) | (m4[(base+1)%4][i%4]<<0) | (m4[(base+0)%4][i%4]<<12);
//     m16[1][i] = (m16[0][i]>>12) | (0xFFFF & (m16[0][i]<<4));//m1 is just a rotated version of m0
//   }
// }

/**
 * The M' step of the Prince cipher.
 */
static uint64_t prince_m_prime_layer(const uint64_t m_prime_in){
  //16 bits matrices M0 and M1, generated using the code below
  //uint64_t m16[2][16];prince_m16_matrices(m16);
  //for(unsigned int i=0;i<16;i++) PRINCE_PRINT(m16[0][i]);
  //for(unsigned int i=0;i<16;i++) PRINCE_PRINT(m16[1][i]);
  static const uint64_t m16[2][16] = {
    {   0x0111,                                                                                                                                                                        
        0x2220,                                                                                                                                                                        
        0x4404,                                                                                                                                                                        
        0x8088,                                                                                                                                                                        
        0x1011,                                                                                                                                                                        
        0x0222,                                                                                                                                                                        
        0x4440,                                                                                                                                                                        
        0x8808,                                                                                                                                                                        
        0x1101,                                                                                                                                                                        
        0x2022,                                                                                                                                                                        
        0x0444,                                                                                                                                                                        
        0x8880,                                                                                                                                                                        
        0x1110,                                                                                                                                                                        
        0x2202,                                                                                                                                                                        
        0x4044,                                                                                                                                                                        
        0x0888},
    
    {   0x1110,                                                                                                                                                                        
        0x2202,                                                                                                                                                                        
        0x4044,                                                                                                                                                                        
        0x0888,                                                                                                                                                                        
        0x0111,                                                                                                                                                                        
        0x2220,                                                                                                                                                                        
        0x4404,                                                                                                                                                                        
        0x8088,                                                                                                                                                                        
        0x1011,                                                                                                                                                                        
        0x0222,                                                                                                                                                                        
        0x4440,                                                                                                                                                                        
        0x8808,                                                                                                                                                                        
        0x1101,                                                                                                                                                                        
        0x2022,                                                                                                                                                                        
        0x0444,                                                                                                                                                                        
        0x8880} 
  };
  const uint64_t chunk0 = gf2_mat_mult16_1(m_prime_in>>(0*16),m16[0]);
  const uint64_t chunk1 = gf2_mat_mult16_1(m_prime_in>>(1*16),m16[1]);
  const uint64_t chunk2 = gf2_mat_mult16_1(m_prime_in>>(2*16),m16[1]);
  const uint64_t chunk3 = gf2_mat_mult16_1(m_prime_in>>(3*16),m16[0]);
  const uint64_t m_prime_out = (chunk3<<(3*16)) | (chunk2<<(2*16)) | (chunk1<<(1*16)) | (chunk0<<(0*16));
  return m_prime_out;
}

/**
 * The shift row and inverse shift row of the Prince cipher.
 */
static uint64_t prince_shift_rows(const uint64_t in, int inverse){
  const uint64_t row_mask = UINT64_C(0xF000F000F000F000);
  uint64_t shift_rows_out = 0;
  for(unsigned int i=0;i<4;i++){
    const uint64_t row = in & (row_mask>>(4*i));
    const unsigned int shift = inverse ? i*16 : 64-i*16;
    shift_rows_out |= (row>>shift) | (row<<(64-shift));
  }
  return shift_rows_out;
}

/**
 * The M step of the Prince cipher.
 */
static uint64_t prince_m_layer(const uint64_t m_in){
  const uint64_t m_prime_out = prince_m_prime_layer(m_in);
  const uint64_t shift_rows_out = prince_shift_rows(m_prime_out,0);
  return shift_rows_out;
}

/**
 * The M^-1 step of the Prince cipher.
 */
static uint64_t prince_m_inv_layer(const uint64_t m_inv_in){
  const uint64_t shift_rows_out = prince_shift_rows(m_inv_in,1);
  const uint64_t m_prime_out = prince_m_prime_layer(shift_rows_out);
  return m_prime_out;
}

/**
 * The core function of the Prince cipher.
 */
static uint64_t prince_core(const uint64_t core_input, const uint64_t k1){
  PRINCE_PRINT(core_input);
  PRINCE_PRINT(k1);
  uint64_t round_input = core_input ^ k1 ^ prince_round_constant(0);
  for(unsigned int round = 1; round < 6; round++){
    PRINCE_PRINT(round_input);
    const uint64_t s_out = prince_s_layer(round_input);
    PRINCE_PRINT(s_out);
    const uint64_t m_out = prince_m_layer(s_out);
    PRINCE_PRINT(m_out);
    round_input = m_out ^ k1 ^ prince_round_constant(round);
  }
  const uint64_t middle_round_s_out = prince_s_layer(round_input);
  PRINCE_PRINT(middle_round_s_out);
  const uint64_t m_prime_out = prince_m_prime_layer(middle_round_s_out);
  PRINCE_PRINT(m_prime_out);
  const uint64_t middle_round_s_inv_out = prince_s_inv_layer(m_prime_out);
  round_input = middle_round_s_inv_out;  
  for(unsigned int round = 6; round < 11; round++){
    PRINCE_PRINT(round_input);
    const uint64_t m_inv_in = round_input ^ k1 ^ prince_round_constant(round);
    PRINCE_PRINT(m_inv_in);
    const uint64_t s_inv_in = prince_m_inv_layer(m_inv_in);
    PRINCE_PRINT(s_inv_in);
    const uint64_t s_inv_out = prince_s_inv_layer(s_inv_in);
    round_input = s_inv_out;
  }
  const uint64_t core_output = round_input ^ k1 ^ prince_round_constant(11);
  PRINCE_PRINT(core_output);
  return core_output;
}

/**
 * Top level function for Prince encryption/decryption.
 * enc_k0 and enc_k1 must be the same for encryption and decryption, the handling of decryption is done internally.
 */
static uint64_t prince_enc_dec_uint64(const uint64_t input,const uint64_t enc_k0, const uint64_t enc_k1, int decrypt){
  const uint64_t prince_alpha = UINT64_C(0xc0ac29b7c97c50dd);
  const uint64_t k1 = enc_k1 ^ (decrypt ? prince_alpha : 0);
  const uint64_t enc_k0_prime = prince_k0_to_k0_prime(enc_k0);
  const uint64_t k0       = decrypt ? enc_k0_prime : enc_k0;
  const uint64_t k0_prime = decrypt ? enc_k0       : enc_k0_prime;
  PRINCE_PRINT(k0);
  PRINCE_PRINT(input); 
  const uint64_t core_input = input ^ k0;
  const uint64_t core_output = prince_core(core_input,k1);
  const uint64_t output = core_output ^ k0_prime; 
  PRINCE_PRINT(k0_prime);
  PRINCE_PRINT(output);
  return output;
}

/**
 * Byte oriented top level function for Prince encryption/decryption.
 * key_bytes 0 to 7 must contain K0
 * key_bytes 8 to 15 must contain K1
 */
static void prince_enc_dec(const uint8_t in_bytes[8],const uint8_t key_bytes[16], uint8_t out_bytes[8], int decrypt){
  const uint64_t input = bytes_to_uint64(in_bytes);
  const uint64_t enc_k0 = bytes_to_uint64(key_bytes);
  const uint64_t enc_k1 = bytes_to_uint64(key_bytes+8);
  const uint64_t output = prince_enc_dec_uint64(input,enc_k0,enc_k1,decrypt);
  uint64_to_bytes(output,out_bytes);
}

/**
 * Byte oriented top level function for Prince encryption.
 * key_bytes 0 to 7 must contain K0
 * key_bytes 8 to 15 must contain K1
 */
static void prince_encrypt(const uint8_t in_bytes[8],const uint8_t key_bytes[16], uint8_t out_bytes[8]){
  prince_enc_dec(in_bytes,key_bytes,out_bytes,0);
}

/**
 * Byte oriented top level function for Prince decryption.
 * key_bytes 0 to 7 must contain K0
 * key_bytes 8 to 15 must contain K1
 */
// static void prince_decrypt(const uint8_t in_bytes[8],const uint8_t key_bytes[16], uint8_t out_bytes[8]){
//   prince_enc_dec(in_bytes,key_bytes,out_bytes,1);
//   uint64_t m16[2][16];
// }



/* Following code is test-case taken from https://github.com/sebastien-riou/prince-c-ref/blob/master/test/main.cpp */

/*
#include "stdio.h"
#include "time.h"
#include <random>
#include <stdlib.h>
 
#include <string.h>
#define TEST_FAIL 0
#define TEST_PASS 1

#include <stdio.h>
#include <stdint.h>

static void print_bytes_sep(const char *msg,const unsigned char *buf, unsigned int size, const char m2[], const char sep[]){
  unsigned int i;
  printf("%s",msg);
  for(i=0;i<size-1;i++) printf("%02X%s",buf[i],sep);
  if(i<size) printf("%02X",buf[i]);
  printf("%s", m2);
}
static void print_bytes(const char m[],const uint8_t *buf, unsigned int size, const char m2[]){print_bytes_sep(m,buf,size,m2," ");}
static void println_bytes(const char m[],const uint8_t *buf, unsigned int size){print_bytes(m,buf,size,"\n");}
static void print_128(const char m[], const uint8_t a[16], const char m2[]){
  print_bytes_sep( m,a   ,4,"_","");
  print_bytes_sep("",a+4 ,4,"_","");
  print_bytes_sep("",a+8 ,4,"_","");
  print_bytes_sep("",a+12,4,m2 ,"");
}
static void print_64 (const char m[], const uint8_t a[ 8], const char m2[]){
  print_bytes_sep( m,a   ,4,"_","");
  print_bytes_sep("",a+4 ,4,m2 ,"");
}
static void println_128(const char m[], const uint8_t a[16]){print_128(m,a,"\n");}
static void println_64 (const char m[], const uint8_t a[ 8]){print_64 (m,a,"\n");}


int hexdigit_value(char c){
  int nibble = -1;
  if(('0'<=c) && (c<='9')) nibble = c-'0';
  if(('a'<=c) && (c<='f')) nibble = c-'a' + 10;
  if(('A'<=c) && (c<='F')) nibble = c-'A' + 10;
  return nibble;
}

int is_hex_digit(char c){
  return -1!=hexdigit_value(c);
}

void hexstr_to_bytes(unsigned int size_in_bytes, void *dst, const char * const hexstr){
  unsigned int char_index = 0;
  unsigned int hexdigit_cnt=0;
  uint8_t* dst_bytes = (uint8_t*)dst;
  memset(dst,0,size_in_bytes);
  while(hexdigit_cnt<size_in_bytes*2){
    char c = hexstr[char_index++];
    if(0==c) {
      printf("\nERROR: could not find %d hex digits in string '%s'.\n",size_in_bytes*2,hexstr);
      printf("char_index=%d, hexdigit_cnt=%d\n",char_index,hexdigit_cnt);
      exit(-1);
    }
    if(is_hex_digit(c)) {
      unsigned int shift = 4 - 4*(hexdigit_cnt & 1);
      uint8_t nibble = hexdigit_value(c);
      dst_bytes[hexdigit_cnt/2] |= nibble << shift;
      hexdigit_cnt++;
    }
  }
}

void bytes_to_hexstr(char *dst,uint8_t *bytes, unsigned int nBytes){
  unsigned int i;
  for(i=0;i<nBytes;i++){
    sprintf(dst+2*i,"%02X",bytes[i]);
  }
}

void assert_equal_bytes(const uint8_t *const a, const uint8_t *const b, unsigned int size_in_bytes){
  for(unsigned int i=0;i<size_in_bytes;i++){
    if(a[i]!=b[i]){
      printf("\nERROR: assertion failed.\n");
      print_bytes_sep("a=",a,size_in_bytes,"\n"," ");
      print_bytes_sep("b=",b,size_in_bytes,"\n"," ");
      printf("a[%u]=0x%02X\nb[%u]=0x%02X\n",i,a[i],i,b[i]);
      exit(-2);
    }
  }
}

typedef struct testvector_struct {
  uint8_t plain [8];
  uint8_t k0    [8];
  uint8_t k1    [8];
  uint8_t cipher[8];
} testvector_t;

static const char * testvectors[] = {
  //test vectors from original Prince paper (http://eprint.iacr.org/2012/529.pdf)
  "     plain              k0               k1             cipher     ",
  "0000000000000000 0000000000000000 0000000000000000 818665aa0d02dfda",
  "ffffffffffffffff 0000000000000000 0000000000000000 604ae6ca03c20ada",
  "0000000000000000 ffffffffffffffff 0000000000000000 9fb51935fc3df524",
  "0000000000000000 0000000000000000 ffffffffffffffff 78a54cbe737bb7ef",
  "0123456789abcdef 0000000000000000 fedcba9876543210 ae25ad3ca8fa9ccf",
  //custom test vectors from here, cipher values generated with prince_ref.hh !
  "0123456789ABCDEF 0011223344556677 8899AABBCCDDEEFF D6DCB5978DE756EE",
  "0123456789ABCDEF 0112233445566778 899AABBCCDDEEFF0 392F599F46761CD3",
  "F0123456789ABCDE 0112233445566778 899AABBCCDDEEFF0 4FB5E332B9B409BB",
  "69C4E0D86A7B0430 D8CDB78070B4C55A 818665AA0D02DFDA 43C6B256D79DE7E8"
};   

#define STR_EXPAND(tok) #tok
#define STR(tok) STR_EXPAND(tok)
#define __STDC_FORMAT_MACROS
#include <inttypes.h>
//#define PRINCE_PRINT(a) printf("\t%016" PRIx64 " %s\n",a,STR(a));
#define PRINCE_PRINT(a) do{\
  uint8_t raw_bytes[8];\
  uint64_to_bytes(a,raw_bytes);\
  print_64("\t",raw_bytes," " STR(a) "\n");\
  }while(0)

#include "prince_ref.hh"
int basic_test(void){
  for(int i=1;i<sizeof(testvectors)/sizeof(char*);i++){
    testvector_t tv;
    hexstr_to_bytes(sizeof(tv), &tv, testvectors[i]);
    printf("test vector %d\n",i);
    print_64  ( "plain:",tv.plain ," ");
    print_64  (    "k0:",tv.k0    ," ");
    print_64  (    "k1:",tv.k1    ," ");
    println_64("cipher:",tv.cipher);
    printf("encryption:\n");
    uint8_t result[8];
    uint8_t key[16];
    memcpy(key  ,tv.k0,8);
    memcpy(key+8,tv.k1,8);
    println_128("key:",key);
    prince_encrypt(tv.plain,key,result);
o    assert_equal_bytes(tv.cipher,result,8);
    printf("decryption:\n");
    prince_decrypt(tv.cipher,key,result);
    assert_equal_bytes(tv.plain,result,8);
  }
  return TEST_PASS;
}

int main(void){
  if(TEST_PASS==basic_test()){
    printf("Basic Test PASS\n");
  } else {
    printf("Basic Test FAIL\n");
    return -1;
  }
  return 0;
}

*/
#endif //__PRINCE_REF_H__
