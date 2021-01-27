#!/usr/bin/env bash

## Temp Files
rm -f bucket_occ_temp;
touch bucket_occ_temp;

## Get Total number of experiments
tot_exp=`ls raw_results/Base8.ExtraWays6.Exp* | wc -l`;

## For each experiment: Get the Bucket-Occupancy and Add.
for (( exp_num=0; exp_num<$tot_exp; exp_num++ )) ; do
    ## Get Line Number for Distribution of Bucket-Occupancy
    line_num=`grep -n "Distribution of Bucket-Occupancy (Averaged across Ball Throws) => Used for P(Bucket = k balls) calculation" raw_results/Base8.ExtraWays6.Exp${exp_num}.out | awk -F':' '{print $1}'`
    start_line_num=$(($line_num+3))

    ## Get the Bucket-Occupancy for an experiment & add it to bucket_occ_temp counts
    tail -n+$start_line_num raw_results/Base8.ExtraWays6.Exp${exp_num}.out | head -n17 | awk -F':' '{print $2}' | awk '{print $1}' >bucket_occ_curr
    paste bucket_occ_temp bucket_occ_curr > bucket_occ_next;
    awk '{print $1+$2}' bucket_occ_next > bucket_occ_temp
done

## Total-Ball-Count (2x Ball-thrown, as statistic counts one ball twice)
total_ball_count=`awk '{sum+=$1}END{print sum}' bucket_occ_temp`;

## Output Bucket-Probabilities
echo "BallsInBucket-N Pr_obs(N)" > Base8.BucketProb.stat;
awk -v count=$total_ball_count '{print NR-1, $1/count}' bucket_occ_temp >> Base8.BucketProb.stat
column -t Base8.BucketProb.stat > temp
mv temp Base8.BucketProb.stat

## Remove Temp Files
rm -f bucket_occ_curr bucket_occ_next bucket_occ_temp;
