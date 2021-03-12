#!/bin/bash

########################################
####### ENCR-LATENCY SENSITIVITY #######
########################################

######## Run for Encr-Latency=1 #######
echo "Running Scatter-Cache and MIRAGE for 28 Benchmarks for Encr-Latency 1"
for bmk in  lbm soplex milc sphinx3 libquantum cactusADM bzip2 perlbench hmmer gromacs sjeng gobmk gcc h264ref mix1 mix2 mix3 mix4 mix5 mix6 mix7 mix8 mix9 mix10 mix11 mix12 mix13 mix14; do
./runscript.sh $bmk ARTIFACT_RESULTS.EL1 scatter-cache  4 8MB 1; 
./runscript.sh $bmk ARTIFACT_RESULTS.EL1 skew-vway-rand 4 8MB 1; 
done

##### Wait for completion of all experiments.
exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`
while [ $exp_count -gt 16 ]
do
   sleep 300
   exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`    
done

######## Run for Encr-Latency=2 #######
echo "Running Scatter-Cache and MIRAGE for 28 Benchmarks for Encr-Latency 2"
for bmk in  lbm soplex milc sphinx3 libquantum cactusADM bzip2 perlbench hmmer gromacs sjeng gobmk gcc h264ref mix1 mix2 mix3 mix4 mix5 mix6 mix7 mix8 mix9 mix10 mix11 mix12 mix13 mix14; do
./runscript.sh $bmk ARTIFACT_RESULTS.EL2 scatter-cache  4 8MB 2; 
./runscript.sh $bmk ARTIFACT_RESULTS.EL2 skew-vway-rand 4 8MB 2; 
done

##### Wait for completion of all experiments.
exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`
while [ $exp_count -gt 16 ]
do
   sleep 300
   exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`    
done

######## Run for Encr-Latency=4 #######
echo "Running Scatter-Cache and MIRAGE for 28 Benchmarks for Encr-Latency 4"
for bmk in  lbm soplex milc sphinx3 libquantum cactusADM bzip2 perlbench hmmer gromacs sjeng gobmk gcc h264ref mix1 mix2 mix3 mix4 mix5 mix6 mix7 mix8 mix9 mix10 mix11 mix12 mix13 mix14; do
./runscript.sh $bmk ARTIFACT_RESULTS.EL4 scatter-cache  4 8MB 4; 
./runscript.sh $bmk ARTIFACT_RESULTS.EL4 skew-vway-rand 4 8MB 4; 
done

##### Wait for completion of all experiments.
exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`
while [ $exp_count -gt 16 ]
do
   sleep 300
   exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`    
done

######## Run for Encr-Latency=5 #######
echo "Running Scatter-Cache and MIRAGE for 28 Benchmarks for Encr-Latency 5"
for bmk in  lbm soplex milc sphinx3 libquantum cactusADM bzip2 perlbench hmmer gromacs sjeng gobmk gcc h264ref mix1 mix2 mix3 mix4 mix5 mix6 mix7 mix8 mix9 mix10 mix11 mix12 mix13 mix14; do
./runscript.sh $bmk ARTIFACT_RESULTS.EL5 scatter-cache  4 8MB 5; 
./runscript.sh $bmk ARTIFACT_RESULTS.EL5 skew-vway-rand 4 8MB 5; 
done

### Wait for completion of all experiments.
exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`
while [ $exp_count -gt 0 ]
do
   sleep 300
   exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`    
done


#####################################
##------- Generate Results --------##
#####################################
echo "Generating Sensitivity Results for Performance vs Encryption Latency"
cd stats_scripts;
./data_EncrLat.sh
echo "Sensitivity for LLC Encryptor Latency Done"


