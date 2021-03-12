#!/bin/bash

############ NOTE: This script sets up the following variables and then runs the command below ############

# **(modify these as needed)**
# OUTPUT_DIR: Where the results will be written
# GEM5_PATH: path for current cleanupspec directory
# BENCHMARK: name of the benchmark being run
# CKPT_OUT_DIR: directory in which Checkpoint being restored for current benchmark
# INST_TAKE_CHECKPOINT: instruction at which to restore checkpoint
# SCHEME: Scheme name to simulate (Baseline, scatter-cache, skew-vway-rand i.e. MIRAGE)
# NUM_CORES: select number of cores
# LLCSZ: LLC-Size
# ENCRLATL   Encryptor Latency
# MAX_INSTS: Number of instructions to simulate
# SCRIPT_OUT: Log file

#$GEM5_PATH/build/X86/gem5.opt \
#    --outdir=$OUTPUT_DIR \
#    $GEM5_PATH/configs/example/spec06_config_multiprogram.py \
#    --benchmark=$BENCHMARK \
#    --benchmark_stdout=$OUTPUT_DIR/$BENCHMARK.out \
#    --benchmark_stderr=$OUTPUT_DIR/$BENCHMARK.err \
#    --num-cpus=$NUM_CORES --mem-size=8GB --mem-type=DDR4_2400_8x8 \
#    --checkpoint-dir=$CKPT_OUT_DIR \
#    --checkpoint-restore=$INST_TAKE_CHECKPOINT --at-instruction \
#    --cpu-type TimingSimpleCPU \
#    --caches --l2cache \
#    --l1d_size=32kB --l1i_size=32kB --l2_size=$LLCSZ \
#    --l1d_assoc=8  --l1i_assoc=8 --l2_assoc=16 \
#    --mirage_mode=$SCHEME --l2_numSkews=2 --l2_TDR=1.75 --l2_EncrLat=$ENCRLAT \
#    --maxinsts=$MAX_INSTS \
#    --prog-interval=300Hz \
#    >> $SCRIPT_OUT 2>&1 &


######################### CONFIG OPTIONS #########################################
# To be modified as required
if [ $# -gt 5 ]; then
    BENCHMARK=$1  #select benchmark
    RUN_CONFIG=$2 #specify output folder name
    SCHEME=$3     #specify scheme [Baseline, scatter-cache, skew-vway-rand]
    NUM_CORES=$4 #select number of cores
    LLCSZ=$5     #LLC-Size
    ENCRLAT=$6   #Encryptor Latency
else
    echo "Your command line contains <6 arguments"
    exit
    BENCHMARK=perlbench                    # Benchmark name, e.g. perlbench
    RUN_CONFIG="Test"                      # Name of configuration being run (will decide output directory name)
    SCHEME="Baseline"                      # Decides the scheme being simulated
    NUM_CORES=4                            # Select number of cores
    LLCSZ="8MB"                            # LLC-Size
    ENCRLAT=3                              # Encryptor Latency
fi

#RUN CONFIG
MAX_INSTS=500000                      # Number of instructions to be simulated
CHECKPOINT_CONFIG="multiprogram_8Gmem_100K"    # Name of directory inside CKPT_PATH
INST_TAKE_CHECKPOINT=100000           # Instruction count after which checkpoint was taken

############ DIRECTORY PATHS TO BE EXPORTED #############

#Need to export GEM5_PATH
if [ -z ${GEM5_PATH+x} ];
then
    echo "GEM5_PATH is unset";
    exit
else
    echo "GEM5_PATH is set to '$GEM5_PATH'";
fi
#Need to export SPEC_PATH
if [ -z ${SPEC_PATH+x} ];
then
    echo "SPEC_PATH is unset";
    exit
else
    echo "SPEC_PATH is set to '$SPEC_PATH'";
fi
#Need to export CKPT_PATH
if [ -z ${CKPT_PATH+x} ];
then
    echo "CKPT_PATH is unset";
    exit
else
    echo "CKPT_PATH is set to '$CKPT_PATH'";
fi

######################### BENCHMARK FOLDER NAMES ####################
PERLBENCH_CODE=400.perlbench
BZIP2_CODE=401.bzip2
GCC_CODE=403.gcc
BWAVES_CODE=410.bwaves
GAMESS_CODE=416.gamess
MCF_CODE=429.mcf
MILC_CODE=433.milc
ZEUSMP_CODE=434.zeusmp
GROMACS_CODE=435.gromacs
CACTUSADM_CODE=436.cactusADM
LESLIE3D_CODE=437.leslie3d
NAMD_CODE=444.namd
GOBMK_CODE=445.gobmk
DEALII_CODE=447.dealII
SOPLEX_CODE=450.soplex
POVRAY_CODE=453.povray
CALCULIX_CODE=454.calculix
HMMER_CODE=456.hmmer
SJENG_CODE=458.sjeng
GEMSFDTD_CODE=459.GemsFDTD
LIBQUANTUM_CODE=462.libquantum
H264REF_CODE=464.h264ref
TONTO_CODE=465.tonto
LBM_CODE=470.lbm
OMNETPP_CODE=471.omnetpp
ASTAR_CODE=473.astar
WRF_CODE=481.wrf
SPHINX3_CODE=482.sphinx3
XALANCBMK_CODE=483.xalancbmk
SPECRAND_INT_CODE=998.specrand
SPECRAND_FLOAT_CODE=999.specrand
##################################################################


################## DIRECTORY NAMES (CHECKPOINT, OUTPUT, RUN DIRECTORY)  ###################
#Set up based on path variables & configuration

# Ckpt Dir
CKPT_OUT_DIR=$CKPT_PATH/${CHECKPOINT_CONFIG}.C${NUM_CORES}/$BENCHMARK-1-ref-x86
echo "checkpoint directory: " $CKPT_OUT_DIR

# Output Dir
OUTPUT_DIR=$GEM5_PATH/output/${CHECKPOINT_CONFIG}.C${NUM_CORES}/$RUN_CONFIG/${SCHEME}/$BENCHMARK
echo "output directory: " $OUTPUT_DIR
if [ -d "$OUTPUT_DIR" ]
then
    rm -r $OUTPUT_DIR
fi
mkdir -p $OUTPUT_DIR

# File log used for stdout
SCRIPT_OUT=$OUTPUT_DIR/runscript.log

#Report directory names 
echo "Command line:"                                | tee $SCRIPT_OUT
echo "$0 $*"                                        | tee -a $SCRIPT_OUT
echo "================= Hardcoded directories ==================" | tee -a $SCRIPT_OUT
echo "GEM5_PATH:                                     $GEM5_PATH" | tee -a $SCRIPT_OUT
echo "SPEC_PATH:                                     $SPEC_PATH" | tee -a $SCRIPT_OUT
echo "==================== Script inputs =======================" | tee -a $SCRIPT_OUT
echo "BENCHMARK:                                    $BENCHMARK" | tee -a $SCRIPT_OUT
echo "OUTPUT_DIR:                                   $OUTPUT_DIR" | tee -a $SCRIPT_OUT
echo "==========================================================" | tee -a $SCRIPT_OUT
##################################################################


#################### LAUNCH GEM5 SIMULATION ######################
echo ""

echo "" | tee -a $SCRIPT_OUT
echo "" | tee -a $SCRIPT_OUT
echo "--------- Here goes nothing! Starting gem5! ------------" | tee -a $SCRIPT_OUT
echo "" | tee -a $SCRIPT_OUT
echo "" | tee -a $SCRIPT_OUT

# Launch Gem5:
$GEM5_PATH/build/X86/gem5.opt \
    --outdir=$OUTPUT_DIR \
    $GEM5_PATH/configs/example/spec06_config_multiprogram.py \
    --benchmark=$BENCHMARK \
    --benchmark_stdout=$OUTPUT_DIR/$BENCHMARK.out \
    --benchmark_stderr=$OUTPUT_DIR/$BENCHMARK.err \
    --num-cpus=$NUM_CORES --mem-size=8GB --mem-type=DDR4_2400_8x8 \
    --checkpoint-dir=$CKPT_OUT_DIR \
    --checkpoint-restore=$INST_TAKE_CHECKPOINT --at-instruction \
    --cpu-type TimingSimpleCPU \
    --caches --l2cache \
    --l1d_size=32kB --l1i_size=32kB --l2_size=$LLCSZ \
    --l1d_assoc=8  --l1i_assoc=8 --l2_assoc=16 \
    --mirage_mode=$SCHEME --l2_numSkews=2 --l2_TDR=1.75 --l2_EncrLat=$ENCRLAT \
    --maxinsts=$MAX_INSTS \
    --prog-interval=300Hz \
    >> $SCRIPT_OUT 2>&1 &
