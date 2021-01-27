/*
 * Copyright (c) 2012-2014 ARM Limited
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
 * Definitions of Vway Tags.
 */

#include "mem/cache/tags/vway_tags.hh"

#include <string>

#include "base/intmath.hh"

VwayTags::VwayTags(const Params *p)
    :BaseTags(p),
     TDR(p->TDR), assoc(p->assoc), cache_assoc(p->cache_assoc),
     cache_size(p->cache_size),
     blks(p->size / p->block_size),
     blk_dataID(p->size / p->block_size),
     datablk_tagID(p->cache_size / p->block_size),
     datablk_reuse(p->cache_size / p->block_size),
     datablk_reuse_victimID(0),
     numDataBlocks(p->cache_size / p->block_size),
     sequentialAccess(p->sequential_access),
     replacementPolicy(p->replacement_policy),
     mt_rand(42)
{

  //Initialize the data-replacement policy
  if(p->data_repl_policy == "random")
    data_repl_policy = DATA_REPL_RANDOM;
  else if(p->data_repl_policy == "reuse")
    data_repl_policy = DATA_REPL_REUSE;
  else
    panic("Undefined Data Replacement Policy\n");
  
  // Re-initialize dataBlks size according to cache_size
  dataBlks =  std::unique_ptr<uint8_t[]>(new uint8_t[p->cache_size]);

  // Reset warmup bounds initialized in base.cc (not really used).
  warmupBound = (p->warmup_percentage/100.0) * (p->cache_size / p->block_size);
    
  // Check parameters
  if (blkSize < 4 || !isPowerOf2(blkSize)) {
    fatal("Block size must be at least 4 and a power of 2");
  }
        
  DPRINTFN("Size of Tag-Store for Vway-Tags is %d lines, with assoc:%d and size %d Bytes\n",numBlocks,assoc,size);
  DPRINTFN("Actual Size of Cache seen from Vway-Tags is %d lines, with assoc:%d and size %d Bytes\n",numDataBlocks,cache_assoc,cache_size);
  DPRINTFN("Data Repl Policy: %d (0-Random,1-Reuse).\n",data_repl_policy);
  
  // Check that TDR*capAssoc == assoc.
  assert(((double)((double)TDR*(double)cache_assoc) == (double)assoc) && \
         "Ensure that TDR increases the assoc by a whole number ");
  assert(((double)((double)TDR*(double)cache_size) == (double)size) && \
         "Ensure that TDR increases the size by a whole number ");

  assert( ((TDR >= 1.0) && (TDR <=2.0)) &&                            \
          "Ensure that TDR does not increase assoc beyond reasonable number of ways");
    
  // TODO: Set data-latency=1 and sequential access so that stats are correct and latency is too. 
  // assert(sequentialAccess && "V-Way Cache needs to be sequential access. \n");
}

void
VwayTags::tagsInit()
{
  // Initialize all blocks
  for (unsigned blk_index = 0; blk_index < numBlocks; blk_index++) {
    // Locate next cache block
    CacheBlk* blk = &blks[blk_index];

    // Link block to indexing policy
    indexingPolicy->setEntry(blk, blk_index);
    assert((get_blk_tagID(blk) == blk_index)  &&                    \
           "Ensuring math of tagID to set/way is correct\n");
        
    //Associate a data chunk to the block
    //blk->data = &dataBlks[blkSize*blk_index];
    //**DONE-TODO**: Initialize the data-chunk in block
    blk->data = NULL;
    blk_dataID[blk_index] = (uint64_t)-1;
        
    // Associate a replacement data entry to the block
    blk->replacementData = replacementPolicy->instantiateEntry();
  }

  for (unsigned datablk_index = 0; datablk_index < numDataBlocks; datablk_index++) {
        
    //**DONE-TODO**:Initialize the dataBlk_tagID to -1.
    datablk_tagID[datablk_index] = (uint64_t)-1;
    datablk_reuse[datablk_index] = DATAREUSE_MIN ;

    //**DONE-TODO**:Initialize the dataBlk_repl class to ensure all data-blocks are currently available.
    datarepl_add_vacant(datablk_index);
  }
}

void
VwayTags::invalidate(CacheBlk *blk)
{
  BaseTags::invalidate(blk);

  // Decrease the number of tags in use
  stats.tagsInUse--;

  // Invalidate replacement data
  replacementPolicy->invalidate(blk->replacementData);

  uint64_t tagID = get_blk_tagID(blk);
  uint64_t dataID = blk_dataID[tagID];
    
  //**DONE-TODO**: reset the blk-> data.
  blk->data = NULL;
  blk_dataID[tagID] = (uint64_t)-1;
    
  //**DONE-TODO**: reset the tag-pointer in data-store (corrsponding to blk->data)
  datablk_tagID[dataID] = (uint64_t)-1;
  datablk_reuse[dataID] = DATAREUSE_MIN ;

  //**DONE-TODO**: signal that this data blk is vacant.
  datarepl_add_vacant(dataID);
}

VwayTags *
VwayTagsParams::create()
{
  // There must be a indexing policy
  fatal_if(!indexing_policy, "An indexing policy is required");

  return new VwayTags(this);
}
