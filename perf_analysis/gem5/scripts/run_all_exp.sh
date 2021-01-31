#!/bin/bash

####### Create Checkpoints #######
echo "Creating Checkpoints for 15 Benchmarks"
for bmk in  lbm soplex milc mcf sphinx3 libquantum cactusADM bzip2 perlbench hmmer gromacs sjeng gobmk gcc h264ref ; do
./ckptscript.sh $bmk ; 
done


## Wait for completion of all experiments.
exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`
while [ $exp_count -gt 0 ]
do
    sleep 300
    exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`    
done



####### Run Baseline #######
echo "Running Baseline (non-secure) for 15 Benchmarks"
for bmk in  lbm soplex milc mcf sphinx3 libquantum cactusADM bzip2 perlbench hmmer gromacs sjeng gobmk gcc h264ref ; do
./runscript.sh $bmk ARTIFACT_RESULTS BaselineRRIP; 
done

## Wait for completion of all experiments.
exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`
while [ $exp_count -gt 0 ]
do
    sleep 300
    exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`    
done


####### Run Scatter-Cache #######
echo "Running Scatter-Cache for 15 Benchmarks"
for bmk in  lbm soplex milc mcf sphinx3 libquantum cactusADM bzip2 perlbench hmmer gromacs sjeng gobmk gcc h264ref ; do
./runscript.sh $bmk ARTIFACT_RESULTS scatter-cache; 
done


## Wait for completion of all experiments.
exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`
while [ $exp_count -gt 0 ]
do
    sleep 300
    exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`    
done


####### Run MIRAGE #######
echo "Running MIRAGE for 15 Benchmarks"
for bmk in  lbm soplex milc mcf sphinx3 libquantum cactusADM bzip2 perlbench hmmer gromacs sjeng gobmk gcc h264ref ; do
./runscript.sh $bmk ARTIFACT_RESULTS skew-vway-rand; 
done


## Wait for completion of all experiments.
exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`
while [ $exp_count -gt 0 ]
do
    sleep 300
    exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`    
done


## Generate Results
echo "Generating Performance Results (Normalized Slowdown vs Non-Secure Set-Associative Baseline)"
cd stats_scripts;
./data_perf.sh
