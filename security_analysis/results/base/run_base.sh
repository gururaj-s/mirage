#!/usr/bin/env bash
## Command Line Arguments
NUM_BILLION_BALLS_PER_EXP=${1:-100} # $1
NUM_EXP=${2:-1}               # $2
NUM_BILLIONS=$(($NUM_BILLION_BALLS_PER_EXP * $NUM_EXP))

echo "Running Buckets & Balls Simulation for WaysPerSkew=8"
echo "(Throwing ${NUM_BILLIONS} Billion Balls)"
mkdir -p raw_results;
rm -rf raw_results/*;

## Run Empirical Results for Extra-Ways = 1,2,3,4,5,6
for extra_ways_per_skew in 1 2 3 4 5 6
do
    ## Run $NUM_EXP experiments
    for (( i=0; i<$NUM_EXP; i++ ))
    do
        stdbuf -oL ../../bin/mirage8WPS_kExtraWays_NBn.o $extra_ways_per_skew $NUM_BILLION_BALLS_PER_EXP $i \
               > raw_results/Base8.ExtraWays${extra_ways_per_skew}.Exp${i}.out &
    done
done

## Wait for completion of all experiments.
exp_count=`ps aux | grep -i "mirage8WPS_kExtraWays_NBn.o" | grep -v "grep" | wc -l`
while [ $exp_count -gt 0 ]
do
    sleep 30
    exp_count=`ps aux | grep -i "mirage8WPS_kExtraWays_NBn.o" | grep -v "grep" | wc -l`    
done


## Generate the Spills Result (Fig-7)
./get_spills.sh

## Generate the Bucket Probabilities Result (Fig-9, Fig-10)
./get_bucket_prob.sh
