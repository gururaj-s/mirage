#!/bin/bash

######----------------------------------------------------- ######
######------------- CHECKPOINTS FOR 4/1-CORE EXPERIMENTS -- ######
######----------------------------------------------------- ######

####### 4-Core Experiments #######
echo "Creating 4-Core Checkpoints for 28 Benchmarks"
for bmk in lbm soplex milc sphinx3 libquantum cactusADM bzip2 perlbench hmmer gromacs sjeng gobmk\
 gcc h264ref mix1 mix2 mix3 mix4 mix5 mix6 mix7 mix8 mix9 mix10 mix11 mix12 mix13 mix14 ; do 
./ckptscript.sh $bmk 4 ; 
done

####### 1-Core Experiments #######
echo "Creating 1-Core Checkpoints for 14 Benchmarks"
for bmk in lbm soplex milc sphinx3 libquantum cactusADM bzip2 perlbench hmmer gromacs sjeng gobmk gcc h264ref ; do 
./ckptscript.sh $bmk 1 ; 
done

## Wait for completion of all experiments.
exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`
while [ $exp_count -gt 0 ]
do
    sleep 300
    exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`    
done

###----------------------------------------------------- ######
###------------- RUNNING 4-CORE EXPERIMENTS ------------ ######
###----------------------------------------------------- ######

####### Run Baseline #######
echo "Running Baseline (non-secure) for 28 Benchmarks"
for bmk in lbm soplex milc sphinx3 libquantum cactusADM bzip2 perlbench hmmer gromacs sjeng gobmk\
 gcc h264ref mix1 mix2 mix3 mix4 mix5 mix6 mix7 mix8 mix9 mix10 mix11 mix12 mix13 mix14 ; do 
./runscript.sh $bmk ARTIFACT_RESULTS Baseline 4 8MB 3; 
done

#### Wait for completion of all experiments.
##exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`
##while [ $exp_count -gt 0 ]
##do
##    sleep 300
##    exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`    
##done

####### Run Scatter-Cache #######
echo "Running Scatter-Cache for 28 Benchmarks"
for bmk in lbm soplex milc sphinx3 libquantum cactusADM bzip2 perlbench hmmer gromacs sjeng gobmk\
 gcc h264ref mix1 mix2 mix3 mix4 mix5 mix6 mix7 mix8 mix9 mix10 mix11 mix12 mix13 mix14 ; do 
./runscript.sh $bmk ARTIFACT_RESULTS scatter-cache 4 8MB 3; 
done

#### Wait for completion of all experiments.
##exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`
##while [ $exp_count -gt 0 ]
##do
##    sleep 300
##    exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`    
##done

####### Run MIRAGE #######
echo "Running MIRAGE for 28 Benchmarks"
for bmk in lbm soplex milc sphinx3 libquantum cactusADM bzip2 perlbench hmmer gromacs sjeng gobmk\
 gcc h264ref mix1 mix2 mix3 mix4 mix5 mix6 mix7 mix8 mix9 mix10 mix11 mix12 mix13 mix14 ; do 
./runscript.sh $bmk ARTIFACT_RESULTS skew-vway-rand 4 8MB 3; 
done

## Wait for completion of all experiments.
exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`
while [ $exp_count -gt 0 ]
do
    sleep 300
    exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`    
done


######----------------------------------------------------- ######
######-- RUNNING 1-CORE EXPERIMENTS FOR WEIGHTED SPEEDUP -- ######
######----------------------------------------------------- ######

echo "Running Baseline (non-secure) 1-Core for 14 Benchmarks"
for bmk in  lbm soplex milc sphinx3 libquantum cactusADM bzip2 perlbench hmmer gromacs sjeng gobmk gcc h264ref; do
./runscript.sh $bmk ARTIFACT_RESULTS.1C.8MBLLC Baseline 1 8MB 3; 
done

## Wait for completion of all experiments.
exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`
while [ $exp_count -gt 0 ]
do
    sleep 300
    exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`    
done


######----------------------------- ######
######-- Get Performance Results -- ######
######----------------------------- ######

echo "Generating Performance Results (Normalized Performance of MIRAGE vs Non-Secure Set-Associative Baseline)"
cd stats_scripts;
./data_perf.sh
echo "Main Performance Results Done"
