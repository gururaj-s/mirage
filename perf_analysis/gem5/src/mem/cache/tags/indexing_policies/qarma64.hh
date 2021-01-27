/* QARMA64 Encryptor */
/* Usage: u64 qarma64_enc(u64 key[2], u64 plaintext, u64 tweak,int NUM_ROUNDS=5); */
/* Sources: 
   1. Cipher Design    - https://eprint.iacr.org/2016/444.pdf
   2. C implementation - https://github.com/plutooo/qarma 
*/

#ifndef __MEM_CACHE_TAGS_QARMA64_HH__
#define __MEM_CACHE_TAGS_QARMA64_HH__


typedef unsigned char u8;
typedef unsigned long long u64;
typedef unsigned int uint;

#define ROTR64(x, n)                            \
  ((x) >> (n) | ((x) << (64-(n))))

#define ROTR4(x, n) \
  (((x) >> (n) | ((x) << (4-(n)))) & 0xF)

#define ROTL4(x, n) \
  (((x) << (n) | ((x) >> (4-(n)))) & 0xF)

//#define NUM_ROUNDS 7

static const u64 c[] = {
  0x0000000000000000, 0x13198A2E03707344,
  0xA4093822299F31D0, 0x082EFA98EC4E6C89,
  0x452821E638D01377, 0xBE5466CF34E90C6C,
  0x3F84D5B5B5470917, 0x9216D5D98979FB1B
};

static const u64 alpha = 0xC0AC29B7C97C50DD;

static const uint tau[] = {
  0, 11, 6, 13, 10, 1, 12, 7, 5, 14, 3, 8, 15, 4, 9, 2
};

static const uint tau_inv[] = {
  0, 5, 15, 10, 13, 8, 2, 7, 11, 14, 4, 1, 6, 3, 9, 12
};

static const uint sigma[] = {
  0, 14, 2, 10, 9, 15, 8, 11, 6, 4, 3, 7, 13, 12, 1, 5
};

static const uint h[] = {
  6, 5, 14, 15, 0, 1, 2, 3, 7, 12, 13, 4, 8, 9, 10, 11
};

static const uint h_inv[] = {
  4, 5, 6, 7, 11, 1, 0, 8, 12, 13, 14, 15, 9, 10, 2, 3
};

static const u8 m[] = {
  0, 1, 2, 1,
  1, 0, 1, 2,
  2, 1, 0, 1,
  1, 2, 1, 0
};

static inline void to_cells(u8 out[16], u64 in)
{
  uint i;
  for (i=0; i<16; i++)
    out[15-i] = (in >> (4*i)) & 0xF;
}

static inline u64 from_cells(u8 in[16])
{
  u64 ret = 0;

  uint i;
  for (i=0; i<16; i++)
    ret |= ((u64) in[15-i]) << (4*i);

  return ret;
}

static inline void mul_matrix(u8 dst[16], const u8 a[16], const u8 b[16])
{
  uint x, y;

  for (x=0; x<4; x++)
  {
    for (y=0; y<4; y++)
    {
      uint s = 0;

      uint i;
      for (i=0; i<4; i++)
      {
        if (a[4*y + i])
          s ^= ROTL4(b[4*i + x], a[4*y + i]);
      }

      dst[4*y + x] = s;
    }
  }
}

static inline u64 round_fwd(u64 s, u64 tk, int full)
{
  uint i;

  // AddRoundKey
  s ^= tk;

  u8 tmp[16];
  to_cells(tmp, s);

  if (full)
  {
    // ShuffleCells
    u8 tmp2[16];
    for (i=0; i<16; i++)
      tmp2[i] = tmp[tau[i]];

    // MixColumns
    mul_matrix(tmp, m, tmp2);
  }

  // SubCells
  for (i=0; i<16; i++)
    tmp[i] = sigma[tmp[i]];

  return from_cells(tmp);
}

static inline u64 round_bwd(u64 s, u64 tk, int full)
{
  u8 tmp[16];
  to_cells(tmp, s);

  // SubCells inverted
  uint i;
  for (i=0; i<16; i++)
    tmp[i] = sigma[tmp[i]];

  if (full)
  {
    // MixColumns inverted
    u8 tmp2[16];
    mul_matrix(tmp2, m, tmp);

    // ShuffleCells inverted
    for (i=0; i<16; i++)
      tmp[i] = tmp2[tau_inv[i]];
  }

  // AddRoundKey
  s = from_cells(tmp);
  return s ^ tk;
}

static inline uint lfsr_fwd(uint x)
{
  uint b0 = (x >> 0) & 1;
  uint b1 = (x >> 1) & 1;
  uint b2 = (x >> 2) & 1;
  uint b3 = (x >> 3) & 1;

  return ((b0^b1) << 3) | (b3 << 2) | (b2 << 1) | (b1 << 0);
}

static inline uint lfsr_bwd(uint x)
{
  uint b0 = (x >> 0) & 1;
  uint b1 = (x >> 1) & 1;
  uint b2 = (x >> 2) & 1;
  uint b3 = (x >> 3) & 1;

  return ((b0^b3) << 0) | (b0 << 1) | (b1 << 2) | (b2 << 3);
}

static inline u64 tweak_fwd(u64 s)
{
  u8 tmp[16];
  to_cells(tmp, s);

  u8 tmp2[16];
  uint i;
  for (i=0; i<16; i++)
    tmp2[i] = tmp[h[i]];

  tmp2[0] = lfsr_fwd(tmp2[0]);
  tmp2[1] = lfsr_fwd(tmp2[1]);
  tmp2[3] = lfsr_fwd(tmp2[3]);
  tmp2[4] = lfsr_fwd(tmp2[4]);
  tmp2[8] = lfsr_fwd(tmp2[8]);
  tmp2[11] = lfsr_fwd(tmp2[11]);
  tmp2[13] = lfsr_fwd(tmp2[13]);

  return from_cells(tmp2);
}

static inline u64 tweak_bwd(u64 s)
{
  u8 tmp[16];
  to_cells(tmp, s);

  tmp[0] = lfsr_bwd(tmp[0]);
  tmp[1] = lfsr_bwd(tmp[1]);
  tmp[3] = lfsr_bwd(tmp[3]);
  tmp[4] = lfsr_bwd(tmp[4]);
  tmp[8] = lfsr_bwd(tmp[8]);
  tmp[11] = lfsr_bwd(tmp[11]);
  tmp[13] = lfsr_bwd(tmp[13]);

  u8 tmp2[16];
  uint i;
  for (i=0; i<16; i++)
    tmp2[h[i]] = tmp[i];

  return from_cells(tmp2);
}

static inline u64 pseudo_reflect(u64 s, u64 tk)
{
  u8 tmp[16];
  to_cells(tmp, s);

  // ShuffleCells
  u8 tmp2[16];
  uint i;
  for (i=0; i<16; i++)
    tmp2[i] = tmp[tau[i]];

  // Multiply by Q
  mul_matrix(tmp, m, tmp2);

  // Xor with tk
  for (i=0; i<16; i++)
    tmp[i] ^= (tk >> (4 * (15-i))) & 0xF;

  // ShuffleCells inverted
  for (i=0; i<16; i++)
    tmp2[i] = tmp[tau_inv[i]];

  return from_cells(tmp2);
}

u64 qarma64_enc(u64 key[2], u64 plaintext, u64 tweak, int NUM_ROUNDS=5)
{
  u64 k0 = key[0];
  u64 k1 = k0;
  u64 w0 = key[1];
  u64 w1 = ROTR64(w0, 1) ^ (w0 >> 63);

  u64 s = plaintext ^ w0;
  u64 t = tweak;

  uint i;
  for (i=0; i<NUM_ROUNDS; i++)
  {
    s = round_fwd(s, k0 ^ t ^ c[i], i>0);
    t = tweak_fwd(t);
  }

  s = round_fwd(s, w1 ^ t, 1);
  s = pseudo_reflect(s, k1);
  s = round_bwd(s, w0 ^ t, 1);

  for (i=NUM_ROUNDS-1; i<NUM_ROUNDS; i--)
  {
    t = tweak_bwd(t);
    s = round_bwd(s, k0 ^ t ^ c[i] ^ alpha, i>0);
  }

  return s ^ w1;
}


/*
  int main()
  {
  // Test vector from Appendix A.1
  u64 key[2] =
  {
  0xec2802d4e0a488e9,
  0x84be85ce9804e94b
  };

  u64 c7 = qarma64_enc(key, 0xfb623599da6e8127, 0x477d469dec0b8762, 7);
  u64 c5 = qarma64_enc(key, 0xfb623599da6e8127, 0x477d469dec0b8762, 5);

  printf("Num Rounds: %d, %016llx == bcaf6c89de930765\n",7, c7);
  printf("Num Rounds: %d, %016llx == 3ee99a6c82af0c38\n",7, c5);

  return 0;
  }
*/
#endif //__MEM_CACHE_TAGS_QARMA64_HH__
