/*
 * Copyright (c) 2018 Inria
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met: redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer;
 * redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution;
 * neither the name of the copyright holders nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Adapted from Original Implementation of Indexing Policy by Authors: Daniel Carvalho
 */

/**
 * @file
 * Definitions of a skewed associative randomized indexing policy.
 */

/* Authors: Gururaj Saileshwar, Moinuddin Qureshi.
*/

#include "mem/cache/tags/indexing_policies/skewed_assoc_randomized.hh"

#include "base/bitfield.hh"
#include "base/intmath.hh"
#include "base/logging.hh"
#include "mem/cache/replacement_policies/replaceable_entry.hh"
#include "debug/Cache.hh"
#include "mem/cache/tags/indexing_policies/prince_ref.hh"
#include "mem/cache/tags/indexing_policies/qarma64.hh"

SkewedAssocRand::SkewedAssocRand(const Params *p)
  : BaseIndexingPolicy(p),NUM_SKEWING_FUNCTIONS(p->numSkews),
    NUM_WAYS_PER_SKEW(assoc/p->numSkews), mem_size(p->mem_size),
    randomizedIndexing(p->randomizedIndexing), skewedCache(p->skewedCache)
{

  DPRINTFN("Size of Tag-Store for Skewed-Assoc-Randomized - Sets:%d, with Assoc:%d \n",numSets,assoc);
  
  fatal_if( (assoc % NUM_SKEWING_FUNCTIONS) != 0, "Ways per skew "  \
            "needs to an integer."  );

  
  // Initialize the randomization tables for each skew.
  init_cache_indexing();
}

uint32_t
SkewedAssocRand::extractSet(const Addr addr, const uint32_t way) const
{

  // Get physical line address and line number
  int64_t phy_lineaddress = addr >> setShift; //setShift = log(blksize)
  int64_t physical_line_num = phy_lineaddress % lines_in_mem;

  // Get skew-id from the way & encryption table
  int skew_id = way / NUM_WAYS_PER_SKEW;
  const std::vector<int64_t>* m_ela_table = &rand_table_vec[skew_id];

  // Lookup table to get encrypted line number
  int64_t encrypted_line_num = (*m_ela_table)[physical_line_num];

  // Cacheset is modulo setMask (num_sets -1)
  int64_t cacheset = encrypted_line_num & setMask;
  DPRINTF(Cache, "extractSet=> Skew:%d, Address %lld, Line-Addr: %lld, PLN %lld, ELN %lld, Set %lld \n", \
          skew_id, addr,phy_lineaddress, physical_line_num,encrypted_line_num,cacheset);
  
  return  cacheset;
}

Addr
SkewedAssocRand::regenerateAddr(const Addr tag,
                                const ReplaceableEntry* entry) const
{
  //Check that tag stores physical line address.
  Addr addr = tag << setShift ; 
  assert( (extractTag(addr) == tag) && \
          "Check that tag stores physical line address ");
  return addr;
}

std::vector<ReplaceableEntry*>
SkewedAssocRand::getPossibleEntries(const Addr addr) const
{
  std::vector<ReplaceableEntry*> entries;
    
  // Parse all ways
  for (uint32_t way = 0; way < assoc; ++way) {
    // Apply hash to get set, and get way entry in it
    entries.push_back(sets[extractSet(addr, way)][way]);
  }
    
  return entries;
}

SkewedAssocRand *
SkewedAssocRandParams::create()
{
  return new SkewedAssocRand(this);
}


// [Skewed Randomized Cache]: Initialize the cache indexing
void SkewedAssocRand::init_cache_indexing (){
  // Set the max-physical cachelines in memory
  lines_in_mem = (mem_size >> setShift);
  DPRINTF(Cache,"For LLC: Mem_Size %ld, MaxLines in Memory %ld",mem_size, lines_in_mem);
  assert(lines_in_mem > 0);
        
  // Allocate size for the rand-table vector.
  assert((skewedCache || (NUM_SKEWING_FUNCTIONS == 1) ) &&              \
         "Either a explicitly skewedCache, or numSkews should be 1");
  assert(randomizedIndexing && "Randomized Indexing should be enabled.");
  rand_table_vec.resize(NUM_SKEWING_FUNCTIONS); 
        
  // Generate skewing functions
  srand(42);
  for (int i=0; i< NUM_SKEWING_FUNCTIONS; i++){
    gen_rand_table(rand_table_vec[i],lines_in_mem,rand());
  }
}


// [Skewed Randomized Cache]: Generate random mapping table for a skew
void SkewedAssocRand::gen_rand_table (std::vector<int64_t>  &m_ela_table,
                                      uint64_t num_lines_in_mem,    \
                                      int seed_rand){
  m_ela_table.resize(0);
  m_ela_table.resize(num_lines_in_mem,-1);
  
  //Ensure the size of uint64 used by gem5 & QARMA is the same (needed only if QARMA used)
  //assert(sizeof(uint64_t) == sizeof(u64));
  
  //Encr-Index = Index(PRINCE64(PLN))
  //Encr-Tag   = PLN
  //PLN = Encr-Tag
  for (int64_t i=0;i <num_lines_in_mem; i++){
    m_ela_table[i] = calcPRINCE64(i,seed_rand) % num_lines_in_mem ;
  }
}

// [Skewed Randomized Cache]: Randomized Indexing (IDF) Using QARMA Cipher-based Hashing
uint64_t SkewedAssocRand::calcQARMA64(uint64_t phy_line_num,uint64_t seed){

  //u64 and uint64_t are 8-bytes unsigned. Not a problem.
  
  u64 key[2] = {
    0xec2802d4e0a488e9,
    0x84be85ce9804e94b
  };

  uint64_t tweak = 0x477d469dec0b8762;

  key[0] = key[0] + seed;

  uint64_t enc64_hash = qarma64_enc(key,phy_line_num,tweak);
  return enc64_hash;    
}

// [Skewed Randomized Cache]: Randomized Indexing (IDF) Using PRINCE Cipher-based Hashing
uint64_t SkewedAssocRand::calcPRINCE64(uint64_t phy_line_num,uint64_t seed){

  //Variables for keys, input, output.
  uint8_t plaintext[8];
  uint8_t ciphertext[8];
  uint8_t key[16];

  //Key Values  
  uint64_t k0 = 0x0011223344556677;
  uint64_t k1 = 0x8899AABBCCDDEEFF;
  //Add seed to keys for each skew.
  k0 = k0 + seed;
  k1 = k1 + seed;
  
  //Set up keys, plaintext
  uint64_to_bytevec(k0,key);
  uint64_to_bytevec(k1,key+8);
  uint64_to_bytevec(phy_line_num,plaintext);

  //TEST PLAINTEXT
  //uint64_t test_plaintext = 0x0123456789ABCDEF; 
  //uint64_to_bytevec(test_plaintext,plaintext);

  //Prince encrypt.
  prince_encrypt(plaintext,key,ciphertext);

  //Convert output
  uint64_t enc64_hash = bytevec_to_uint64(ciphertext);
  
  //PRINT TEST
  //cprintf("PT: %llx, K0: %llx, K1 %llx, CT:%llx\n", /*test_plaintext*/phy_line_num, k0,k1,enc64_hash);

  return enc64_hash;    
}


