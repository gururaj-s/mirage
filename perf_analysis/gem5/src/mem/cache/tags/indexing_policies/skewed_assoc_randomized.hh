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
 * Authors: Daniel Carvalho
 */

/**
 * @file
 * Declaration of a skewed associative indexing policy.
 */

#ifndef __MEM_CACHE_INDEXING_POLICIES_SKEWED_ASSOC_RANDOM_HH__
#define __MEM_CACHE_INDEXING_POLICIES_SKEWED_ASSOC_RANDOM_HH__

#include <vector>

#include "mem/cache/tags/indexing_policies/base.hh"

#include "params/SkewedAssocRand.hh"
#include "debug/Cache.hh"

class ReplaceableEntry;

/**
 * A skewed associative randomized indexing policy.
 * @sa  \ref gem5MemorySystem "gem5 Memory System"
 *
 * The skewed indexing policy has a variable mapping based on a hash function,
 * so a value x can be mapped to different sets, based on the way being used.
 *
 * For example, let's assume address A maps to set 3 on way 0. It will likely
 * have a different set for every other way. Visually, the possible locations
 * of A are, for a table with 4 ways and 8 sets (arbitrarily chosen sets; these
 * locations depend on A and the hashing function used):
 *    Way 0   1   2   3
 *  Set   _   _   _   _
 *    0  |_| |_| |X| |_|
 *    1  |_| |_| |_| |X|
 *    2  |_| |_| |_| |_|
 *    3  |X| |_| |_| |_|
 *    4  |_| |_| |_| |_|
 *    5  |_| |X| |_| |_|
 *    6  |_| |_| |_| |_|
 *    7  |_| |_| |_| |_|
 *
 * Only supports ways that are multiples of number of skew-functions. 
 * So ways/skew is a whole number >=1
 * 
 * Requires full tags to support regeneration of address from a 
 * one-way hash function (like Scatter-Cache) used for skewed-indexing.
 */

class SkewedAssocRand : public BaseIndexingPolicy
{
  private:
    /** [Skewed Randomized Cache] */
    /**
     * The number of skewing functions implemented. This will be decided by 
     * number of skews and ways/skews
     */    
    const int NUM_SKEWING_FUNCTIONS ; //number of skews
    const int NUM_WAYS_PER_SKEW ;    //number of ways per skew (Assoc/NumSkews)

    // Other constants inherited from cache config
    const uint64_t mem_size; //size of memory used
    const bool randomizedIndexing; // enabled randomized indexing
    const bool skewedCache; //enabled skewed cache design

    // used for rand-table, to mask out bits of
    // address that arent part of memory-addr
    uint64_t lines_in_mem; 
    
    /** Randomization-Table for mapping PLA->ELA */    
    std::vector<std::vector<int64_t>> rand_table_vec; 

  public:
    /**
     * Apply a skewing function to calculate address' set given a way.
     *
     * @param addr The address to calculate the set for.
     * @param way The way to get the set from.
     * @return The set index for given combination of address and way.
     */
    uint32_t extractSet(const Addr addr, const uint32_t way) const override;

  public:
    /** Convenience typedef. */
    typedef SkewedAssocRandParams Params;

    /**
     * Construct and initialize this policy.
     */
    SkewedAssocRand(const Params *p);

    /**
     * Destructor.
     */
    ~SkewedAssocRand() {};

    /**
     * Find all possible entries for insertion and replacement of an address.
     * Should be called immediately before ReplacementPolicy's findVictim()
     * not to break cache resizing.
     *
     * @param addr The addr to a find possible entries for.
     * @return The possible entries.
     */
    std::vector<ReplaceableEntry*> getPossibleEntries(const Addr addr) const
                                                                   override;
    /**
     * Generates the tag as line-addr, from the given byte-addr.
     *
     * @param addr The address to get the tag from.
     * @return The tag (line-addr) of the address.
     */
    Addr extractTag(const Addr addr) const override
    {
        DPRINTF(Cache,"extractTag=> Address %lld, Tag %lld \n", \
                addr,addr >> setShift);
        
        return (addr >> setShift);
    }
    
    /**
     * Regenerate an entry's address from its tag and assigned set and way.
     * Uses the inverse of the skewing function.
     *
     * @param tag The tag bits.
     * @param entry The entry.
     * @return the entry's address.
     */
    Addr regenerateAddr(const Addr tag, const ReplaceableEntry* entry) const
                                                                   override;

    /** [Skewed Randomized Cache] **/
    /* Initializes the skewed randomized cache indexing.
     * i.e. generate randomization table for each skew.
     */
    void init_cache_indexing();
     
    /** [Skewed Randomized Cache] **/
    /* Generates the randomization table used 
     * to calculate the hash-value for skewing function.
     * @param m_ela_table The pointer to the table for a particular skewing function.
     * @param num_lines_in_mem The number of lines in memory.
     * @param seed_rand The seed to create different skewing functions.
     * @return Nothing.
     */    
    void gen_rand_table (std::vector<int64_t> &m_ela_table, \
                         uint64_t num_lines_in_mem, int seed_rand);

    /** [Skewed Randomized Cache] **/
    /** Generates a 64-bit cipher-text for a line-number using QARMA64 
     * @param phy_line_num The line number of the physical addr.
     * @param seed A seed to change the randomization (added to key)
     * @return The 64-bit cipher-text.    
     */
    uint64_t calcQARMA64(uint64_t phy_line_num,uint64_t seed);

    /** [Skewed Randomized Cache] **/
    /** Generates a 64-bit cipher-text for a line-number using PRINCE64 
     * @param phy_line_num The line number of the physical addr.
     * @param seed A seed to change the randomization (added to key)
     * @return The 64-bit cipher-text.    
     */
    uint64_t calcPRINCE64(uint64_t phy_line_num, uint64_t seed);
    //Provides bytevec in big-endian format (MSB first as needed by PRINCE)
    void uint64_to_bytevec(uint64_t  input, uint8_t output[8]){
      uint8_t* input_le = (uint8_t*)&input;
      for(int i=0; i<8; i++){
	output[i] = input_le[7-i];
      }
    }
    //Provides uint64_t in little-endian format (converting from big-endian output of  PRINCE)
    uint64_t bytevec_to_uint64(uint8_t input[8]){
      uint64_t output;
      uint8_t* output_le = (uint8_t*)&output;
      for(int i=0; i<8; i++){
	output_le[i] = input[7-i];
      }
      return output;
    }
};

#endif //__MEM_CACHE_INDEXING_POLICIES_SKEWED_ASSOC_RANDOM_HH__
