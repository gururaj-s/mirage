#!/usr/bin/env bash

#Header
echo "ExtraWaysPerSkew Trials Spills Trials/Spill" > Base8.Spills.stat;

#extra_ways=1;

for extra_ways in 1 2 3 4 5 6 ; do
    ## Get number of trials run in each experiment.
    trials_per_exp=`sed -n 's/.*BALL_THROWS:\(.*\),.*/\1/p' raw_results/Base8.ExtraWays${extra_ways}.Exp0.out` ;
    ## Get the Total Spills aggregated over all experiments.
    grep -h "Spill Count:"  raw_results/Base8.ExtraWays${extra_ways}.* | awk -F ':' '{print $2}' | \
    awk -v tpe=$trials_per_exp -v ew=$extra_ways \
        '{sum+=$1; trials+=tpe/2}END{if(sum){trials_per_sum=trials/sum}else{trials_per_sum=0};print ew, trials,sum,trials_per_sum}' \
        >> Base8.Spills.stat;
done

column -t Base8.Spills.stat > temp ; mv temp Base8.Spills.stat ;
