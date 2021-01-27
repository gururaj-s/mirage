/*
 * Copyright (c) 2012-2014,2017 ARM Limited
 * All rights reserved.
 *
 * The license below extends only to copyright in the software and shall
 * not be construed as granting a license to any other intellectual
 * property including but not limited to intellectual property relating
 * to a hardware implementation of the functionality of the software
 * licensed hereunder.  You may use the software subject to the license
 * terms below provided that you ensure that this notice is replicated
 * unmodified and in its entirety in all distributions of the software,
 * modified or unmodified, in source code or in binary form.
 *
 * Copyright (c) 2003-2005,2014 The Regents of The University of Michigan
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
 * Authors: Erik Hallnor
 */

/**
 * @file
 * Declaration of a base set associative tag store.
 */

#ifndef __MEM_CACHE_TAGS_VWAY_TAGS_HH__
#define __MEM_CACHE_TAGS_VWAY_TAGS_HH__

#include <cstdint>
#include <functional>
#include <string>
#include <vector>
#include <queue>
#include <random>

#include "base/logging.hh"
#include "base/types.hh"
#include "mem/cache/base.hh"
#include "mem/cache/cache_blk.hh"
#include "mem/cache/replacement_policies/base.hh"
#include "mem/cache/replacement_policies/replaceable_entry.hh"
#include "mem/cache/tags/base.hh"
#include "mem/cache/tags/indexing_policies/base.hh"
#include "mem/packet.hh"
#include "params/VwayTags.hh"
#include "debug/VwayTags.hh"

#define DATA_REPL_RANDOM (0)
#define DATA_REPL_REUSE  (1)

#define DATAREUSE_MIN   (0)
#define DATAREUSE_MAX   (3)


/**
 * A basic cache tag store.
 * @sa  \ref gem5MemorySystem "gem5 Memory System"
 *
 * -- The Vway_Tags placement policy divides the a s*w data-store cache into 
 * tag-store with s*TDR sets of w ways.
 * -- Pointer from Tag to Data and back, required for decoupled tag-data.
 * -- Serialized look up & Global Replacement (Random) required. Local Repl is backup.
 */
class VwayTags : public BaseTags
{
  protected:
    /** The Tag-to-Data ratio. */
    double TDR;

    /** The tag-store associativity. */
    unsigned assoc;

    /** The cache associativity. */
    unsigned cache_assoc;

    /** The cache size. */
    const unsigned cache_size;

    /** The tag-store. */    
    std::vector<CacheBlk> blks;

    
    /** The datablkID allocated to a blk. */    
    std::vector<uint64_t> blk_dataID;
    
    /** The reverse ptr from data-store to_tag-store. */    
    std::vector<uint64_t> datablk_tagID;

    /** Data-Repl Re-use Bits*/    
    std::vector<uint64_t> datablk_reuse;
    uint64_t  datablk_reuse_victimID;
    
    /** The number of blocks in data-store. */    
    const unsigned numDataBlocks;
    
    //TODO
    /** Whether tags and data are accessed sequentially. */
    const bool sequentialAccess;

    /** Replacement policy */
    BaseReplacementPolicy *replacementPolicy;

    CacheBlk* saved_repl_tag_victim = NULL;
    
  public:
    /** Convenience typedef. */
    typedef VwayTagsParams Params;

    /**
     * Construct and initialize this tag store.
     */
    VwayTags(const Params *p);

    /**
     * Destructor
     */
    virtual ~VwayTags() {};

    /**
     * Initialize blocks as CacheBlk instances.
     */
    void tagsInit() override;

    /**
     * This function updates the tags when a block is invalidated. It also
     * updates the replacement data.
     *
     * @param blk The block to invalidate.
     */
    void invalidate(CacheBlk *blk) override;


    /**
     * This function returns the index in Tag-Store 
     * of particular cacheblk
     *
     * @param blk The block to whose index is needed.
     */
    uint64_t
    get_blk_tagID(ReplaceableEntry *blk)
    {
        return (blk->getSet()*assoc+blk->getWay());
    }

    /**
     * Access block and update replacement data. May not succeed, in which case
     * nullptr is returned. This has all the implications of a cache access and
     * should only be used as such. Returns the tag lookup latency as a side
     * effect.
     *
     * @param addr The address to find.
     * @param is_secure True if the target memory space is secure.
     * @param lat The latency of the tag lookup.
     * @return Pointer to the cache block if found.
     */
    CacheBlk* accessBlock(Addr addr, bool is_secure, Cycles &lat) override
    {
        CacheBlk *blk = findBlock(addr, is_secure);

        // Access all tags in parallel, hence one in each way.  The data side
        // either accesses all blocks in parallel, or one block sequentially on
        // a hit.  Sequential access with a miss doesn't access data.
        stats.tagAccesses += assoc;
        if (sequentialAccess) {
            if (blk != nullptr) {
                stats.dataAccesses += 1;
            }
        } else {
            stats.dataAccesses += assoc;
        }

        // If a cache hit
        if (blk != nullptr) {
            // Update number of references to accessed block
            blk->refCount++;

            // Update replacement data of accessed block
            replacementPolicy->touch(blk->replacementData);

            // Increment data-reuse bits for datablk
            uint64_t tagID = get_blk_tagID(blk);
            uint64_t dataID = blk_dataID[tagID];
            if(datablk_reuse[dataID] < DATAREUSE_MAX)
                datablk_reuse[dataID]++;
        }

        // The tag lookup latency is the same for a hit or a miss
        lat = lookupLatency;

        return blk;
    }

    /**
     * Find replacement victim based on address. The list of evicted blocks
     * only contains the victim.
     *
     * @param addr Address to find a victim for.
     * @param is_secure True if the target memory space is secure.
     * @param size Size, in bits, of new block to allocate.
     * @param evict_blks Cache blocks to be evicted.
     * @return Cache block to be replaced.
     */
    CacheBlk* findVictim(Addr addr, const bool is_secure,
                         const std::size_t size,
                         std::vector<CacheBlk*>& evict_blks) override
    {
        CacheBlk* victim;

        // Get possible entries to be victimized
        const std::vector<ReplaceableEntry*> entries =
            indexingPolicy->getPossibleEntries(addr);

        // Choose replacement victim from replacement candidates (tag-victim)
        CacheBlk* tag_victim = static_cast<CacheBlk*>(replacementPolicy->getVictim(
                                                          entries));

        assert( (tag_victim != NULL)  && "Tag-Victim is not NULL\n");

        //Scenario-A: INVALID-TAGDATA
        //**DONE-TODO**: If tag-victim is invalid, and there is an available data-victim 
        if(!tag_victim->isValid() && (datarepl_get_vacant() != ((uint64_t)-1)) ){
            //**DONE-TODO**: return victim = invalid tag-victim
            victim = tag_victim;            
            DPRINTF(VwayTags,"findVictim (Invalid) Scenario-A for Addr:%llx Victim:%llx \n",addr,victim->isValid()?regenerateBlkAddr(victim):-1);

            stats.replInvtagdata++;

        }

        //Scenario-B: LOCAL-REPL
        //**DONE-TODO**: If tag-victim is valid: 
        else if (tag_victim->isValid()) {            
            //No space in tag-set            
            //**DONE-TODO**: return victim =  valid tag-victim
            victim = tag_victim;
            DPRINTF(VwayTags,"findVictim (Local-ValidTag) Scenario-B for Addr:%llx Victim:%llx \n",addr,victim->isValid()?regenerateBlkAddr(victim):-1);

            stats.replLocal++;
        }
        
        //Scenario-C: GLOBAL-REPL
        //**DONE-TODO**: If tag-victim is invalid, and no vacant dataBlk:
        else if(!tag_victim->isValid() && (datarepl_get_vacant() == ((uint64_t)-1)) ){

            //**DONE-TODO**: select random dataBlk for replacement (select_repl_datablk()).
            uint64_t data_victim_index = datarepl_select_victim();
            assert(data_victim_index != ((uint64_t)-1));
            
            //**DONE-TODO**: -- Get tagID of valid data-victim, and corresponding valid cacehBlk
            uint64_t data_victim_tagID = datablk_tagID[data_victim_index];
            assert((data_victim_tagID != ((uint64_t)-1)) && (data_victim_tagID < numBlocks));
            CacheBlk* data_victim = &blks[data_victim_tagID] ;
            assert(data_victim->isValid());
            
            //**DONE-TODO**: save invalid tag-victim to local variable.
            assert(saved_repl_tag_victim == NULL);
            saved_repl_tag_victim = tag_victim;
            
            //**DONE-TODO**: return victim = data-victim.
            victim = data_victim;
            DPRINTF(VwayTags,"findVictim (Global-ValidData) Scenario-C for Addr:%llx. Victim:%llx \n",addr,victim->isValid()?regenerateBlkAddr(victim):-1);

            stats.replGlobal++;
        }
        else{
            panic("Should not reach here!\n");
        }
        
        // There is only one eviction for this replacement
        evict_blks.push_back(victim);

        //Return data-victim or tag-victim as appropriate.
        return victim;
    }

    /**
     * Insert the new block into the cache and update replacement data.
     *
     * @param pkt Packet holding the address to update
     * @param blk The block to update.
     */
    
    //**TODO**: make blk passed by reference!
    void insertBlock(const PacketPtr pkt, CacheBlk* &blk) override
    {        
        //**DONE-TODO** Scenario-C: GLOBAL-REPL (blk=Data-Victim), Cache-Fill occurs in saved-tag-blk, not victim-blk
        if(saved_repl_tag_victim != NULL){
            DPRINTF(VwayTags,"insertBlock Scenario-C for Addr:%llx. \n",pkt->getAddr());

            //Ensure saved tag-victim is in a valid set,way for pkt->addr
            assert(saved_repl_tag_victim->getSet() ==                   \
                   indexingPolicy->extractSet(pkt->getAddr(),saved_repl_tag_victim->getWay()) );

            //**DONE-TODO**: Check there is a invalidated data-victim
            assert(datarepl_get_vacant()!=((uint64_t)-1));
           
            //**DONE-TODO**: Switch the blk(data-victim) and tag-victim
            blk = saved_repl_tag_victim;
            saved_repl_tag_victim = NULL;
        }
        // Scenario-A/B: INVALID-TAGDATA or LOCAL-REPL (blk=Tag-Victim)
        else {
            //**DONE-TODO**: Check that tag-victim invalid and blk->data == NULL 
            assert(!blk->isValid() && (blk->data == NULL) );            

            //**DONE-TODO**:  Ensure there is vacant datablk
            assert(datarepl_get_vacant() != ((uint64_t)-1));

            //**DONE-TODO**: Ensure that pkt->addr has Set-Match with victim (tag-victim)
            assert(blk->getSet() == indexingPolicy->extractSet(pkt->getAddr(),blk->getWay()));
            
        }

        //**DONE-TODO**: ALLOCATE DATA:  blk should not have a datablk
        assert(( blk->data == NULL) && (blk_dataID[get_blk_tagID(blk)] == ((uint64_t)-1)) );
        
        //**DONE-TODO** Get a vacant datablk (should have been evicted already)
        uint64_t vacant_datablk_index = datarepl_get_vacant();
        assert((vacant_datablk_index != (uint64_t)-1) &&                \
               "Vacancy should've been created already by getVictim()\n");
        assert((datablk_tagID[vacant_datablk_index] == (uint64_t)-1) && \
               "Vacant datablk should not have a tag-blk pointing to it. \n" );

        //**DONE-TODO** Set data-blk pointer in tag-blk.
        blk->data = &dataBlks[blkSize*vacant_datablk_index];
        blk_dataID[get_blk_tagID(blk)] = vacant_datablk_index;            
        //**DONE-TODO** Set tagID pointer in datablk
        datablk_tagID[vacant_datablk_index] = get_blk_tagID(blk);
        datablk_reuse[vacant_datablk_index] = DATAREUSE_MIN ;
        
        //**DONE-TODO** Remove the vacant datablk from data_repl queues
        datarepl_remove_vacant(vacant_datablk_index);            

        
        // Insert block
        BaseTags::insertBlock(pkt, blk);

        // Increment tag counter
        stats.tagsInUse++;

        // Update replacement policy
        replacementPolicy->reset(blk->replacementData);
    }

    /**
     * Regenerate the block address from the tag and indexing location.
     *
     * @param block The block.
     * @return the block address.
     */
    Addr regenerateBlkAddr(const CacheBlk* blk) const override
    {
        return indexingPolicy->regenerateAddr(blk->tag, blk);
    }

    void forEachBlk(std::function<void(CacheBlk &)> visitor) override {
        for (CacheBlk& blk : blks) {
            visitor(blk);
        }
    }

    bool anyBlk(std::function<bool(CacheBlk &)> visitor) override {
        for (CacheBlk& blk : blks) {
            if (visitor(blk)) {
                return true;
            }
        }
        return false;
    }

    //TODO
  private:
    
    //Define data_repl: Maintains a queue of vacant indices.
    std::queue<uint64_t> datarepl_vacant_queue;
    
    //**DONE-TODO**: add_vacant: adds index to the end of this queue.
    void datarepl_add_vacant(uint64_t datablk_index){
        datarepl_vacant_queue.push(datablk_index);
        DPRINTF(VwayTags,"Datablk_index:%llu, numDataBlocks:%llu, vacantQueue_sz:%llu\n",datablk_index, numDataBlocks,datarepl_vacant_queue.size());
        assert(datarepl_vacant_queue.size() <= numDataBlocks);        
    }

    //**DONE-TODO**: get_vacant: gets the index at the top of this queue.
    // Returns (uint64_t)-1 if there is no available index in the queue.
    uint64_t datarepl_get_vacant(){

        if(datarepl_vacant_queue.empty()){
            assert(datarepl_vacant_queue.size() == 0);
            return ((uint64_t)-1);
        } else {
            return datarepl_vacant_queue.front();
        }
    }

    //**DONE-TODO**: Removes the top-of-the-queue
    void datarepl_remove_vacant(uint64_t datablk_index){
        assert(datarepl_vacant_queue.front() == datablk_index);
        datarepl_vacant_queue.pop();
        return;
    }

    // Random number generator for replacement
    std::mt19937_64 mt_rand;

    //Policy for selecting data-victim (0-random,1-reuse)
    unsigned data_repl_policy;
    
    //**DONE-TODO**: Select random dataBlk for replacement
    // Returns random victim data-blk index. Makes sure that datablk_tagID[victimindex] != -1.
    uint64_t datarepl_select_victim(){
        assert(datarepl_vacant_queue.empty());
        
        uint64_t data_victim_index = (uint64_t)-1;

        if(data_repl_policy == DATA_REPL_RANDOM)
            data_victim_index = mt_rand() % numDataBlocks;
        else if(data_repl_policy == DATA_REPL_REUSE){
            uint64_t num_attempts=0;
            //Check until datablk_reuse[victimID] is 0
            while(datablk_reuse[datablk_reuse_victimID]){
                assert(datablk_reuse[datablk_reuse_victimID] <= DATAREUSE_MAX);                
                //Decrement the reuse_count
                datablk_reuse[datablk_reuse_victimID]--;

                //Check next data-victimID
                datablk_reuse_victimID = (datablk_reuse_victimID+1) % numDataBlocks;
                num_attempts++;
                //assert(num_attempts <= (numDataBlocks*DATAREPL_MAX)) ;
                if(num_attempts >=40)
                    break;                
            }
            //Pick found victim
            data_victim_index = datablk_reuse_victimID;
            //Increment victimID PTR to point to next loc.
            datablk_reuse_victimID = (datablk_reuse_victimID+1) % numDataBlocks;
        } else
            panic("Undefined Data Replacement Policy\n");
        
        assert(data_victim_index < numDataBlocks);
        assert(datablk_tagID[data_victim_index] != ((uint64_t)-1));

        return data_victim_index;
    }
    
};

#endif //__MEM_CACHE_TAGS_BASE_SET_ASSOC_HH__
