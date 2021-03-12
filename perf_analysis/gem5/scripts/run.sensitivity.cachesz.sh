#!/bin/bash

######################################
##### CACHE SIZE SENSITIVITY #########
######################################

#####################################
##---------------2MB---------------##
#####################################
echo "Running LLCSz:2MB Baseline (non-secure), Scatter-Cache, MIRAGE for 28 Benchmarks"
for bmk in  lbm soplex milc sphinx3 libquantum cactusADM bzip2 perlbench hmmer gromacs sjeng gobmk gcc h264ref mix1 mix2 mix3 mix4 mix5 mix6 mix7 mix8 mix9 mix10 mix11 mix12 mix13 mix14; do
###### Run Baseline #######
./runscript.sh $bmk ARTIFACT_RESULTS.2MB Baseline 4 2MB 3; 
###### Run Scatter-Cache #######
./runscript.sh $bmk ARTIFACT_RESULTS.2MB scatter-cache 4 2MB 3; 
######## Run MIRAGE #######
./runscript.sh $bmk ARTIFACT_RESULTS.2MB skew-vway-rand 4 2MB 3; 
done

##### Wait for completion of all experiments.
##exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`
##while [ $exp_count -gt 0 ]
##do
##   sleep 300
##   exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`    
##done

#####################################
##---------------4MB---------------##
#####################################
echo "Running LLCSz:4MB Baseline (non-secure), Scatter-Cache, MIRAGE for 28 Benchmarks"
for bmk in  lbm soplex milc sphinx3 libquantum cactusADM bzip2 perlbench hmmer gromacs sjeng gobmk gcc h264ref mix1 mix2 mix3 mix4 mix5 mix6 mix7 mix8 mix9 mix10 mix11 mix12 mix13 mix14; do
###### Run Baseline #######
./runscript.sh $bmk ARTIFACT_RESULTS.4MB Baseline 4 4MB 3; 
###### Run Scatter-Cache #######
./runscript.sh $bmk ARTIFACT_RESULTS.4MB scatter-cache 4 4MB 3; 
######## Run MIRAGE #######
./runscript.sh $bmk ARTIFACT_RESULTS.4MB skew-vway-rand 4 4MB 3; 
done

##### Wait for completion of all experiments.
##exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`
##while [ $exp_count -gt 0 ]
##do
##   sleep 300
##   exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`    
##done

#####################################
##---------------16MB--------------##
#####################################
echo "Running LLCSz:16MB Baseline (non-secure), Scatter-Cache, MIRAGE for 28 Benchmarks"
for bmk in  lbm soplex milc sphinx3 libquantum cactusADM bzip2 perlbench hmmer gromacs sjeng gobmk gcc h264ref mix1 mix2 mix3 mix4 mix5 mix6 mix7 mix8 mix9 mix10 mix11 mix12 mix13 mix14; do
###### Run Baseline #######
./runscript.sh $bmk ARTIFACT_RESULTS.16MB Baseline 4 16MB 3; 
###### Run Scatter-Cache #######
./runscript.sh $bmk ARTIFACT_RESULTS.16MB scatter-cache 4 16MB 3; 
######## Run MIRAGE #######
./runscript.sh $bmk ARTIFACT_RESULTS.16MB skew-vway-rand 4 16MB 3; 
done

done
### Wait for completion of all experiments.
exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`
while [ $exp_count -gt 0 ]
do
   sleep 300
   exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`    
done

#####################################
##---------------32MB--------------##
#####################################
###### Run Baseline #######
echo "Running LLCSz:32MB Baseline (non-secure), Scatter-Cache, MIRAGE for 28 Benchmarks"
for bmk in  lbm soplex milc sphinx3 libquantum cactusADM bzip2 perlbench hmmer gromacs sjeng gobmk gcc h264ref mix1 mix2 mix3 mix4 mix5 mix6 mix7 mix8 mix9 mix10 mix11 mix12 mix13 mix14; do
###### Run Baseline #######
./runscript.sh $bmk ARTIFACT_RESULTS.32MB Baseline 4 32MB 3; 
###### Run Scatter-Cache #######
./runscript.sh $bmk ARTIFACT_RESULTS.32MB scatter-cache 4 32MB 3; 
######## Run MIRAGE #######
./runscript.sh $bmk ARTIFACT_RESULTS.32MB skew-vway-rand 4 32MB 3; 
done

##### Wait for completion of all experiments.
##exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`
##while [ $exp_count -gt 0 ]
##do
##   sleep 300
##   exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`    
##done

#####################################
##---------------64MB--------------##
#####################################
echo "Running LLCSz:64MB Baseline (non-secure), Scatter-Cache, MIRAGE for 28 Benchmarks"
for bmk in  lbm soplex milc sphinx3 libquantum cactusADM bzip2 perlbench hmmer gromacs sjeng gobmk gcc h264ref mix1 mix2 mix3 mix4 mix5 mix6 mix7 mix8 mix9 mix10 mix11 mix12 mix13 mix14; do
###### Run Baseline #######
./runscript.sh $bmk ARTIFACT_RESULTS.64MB Baseline 4 64MB 3; 
###### Run Scatter-Cache #######
./runscript.sh $bmk ARTIFACT_RESULTS.64MB scatter-cache 4 64MB 3; 
######## Run MIRAGE #######
./runscript.sh $bmk ARTIFACT_RESULTS.64MB skew-vway-rand 4 64MB 3; 
done

### Wait for completion of all experiments.
exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`
while [ $exp_count -gt 0 ]
do
   sleep 300
   exp_count=`ps aux | grep -i "gem5.opt" | grep -v "grep" | wc -l`    
done



######----------------------------------------------------- ######
######-- RUNNING 1-CORE EXPERIMENTS FOR WEIGHTED SPEEDUP -- ######
######----------------------------------------------------- ######

echo "Running LLCSz:2MB-64MB for Baseline (non-secure) 1-Core 14 Benchmarks"
for bmk in  lbm soplex milc sphinx3 libquantum cactusADM bzip2 perlbench hmmer gromacs sjeng gobmk gcc h264ref; do
./runscript.sh $bmk ARTIFACT_RESULTS.1C.2MBLLC Baseline 1 2MB 3; 
./runscript.sh $bmk ARTIFACT_RESULTS.1C.4MBLLC Baseline 1 4MB 3; 
./runscript.sh $bmk ARTIFACT_RESULTS.1C.16MBLLC Baseline 1 16MB 3; 
./runscript.sh $bmk ARTIFACT_RESULTS.1C.32MBLLC Baseline 1 32MB 3;
./runscript.sh $bmk ARTIFACT_RESULTS.1C.64MBLLC Baseline 1 64MB 3;  
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
echo "Generating Sensitivity Results for Performance vs LLCSz"
cd stats_scripts;
./data_LLCSz.sh
echo "Sensitivity for LLCSz Done"
