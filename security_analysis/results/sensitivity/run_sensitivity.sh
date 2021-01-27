## Fire short runs for generating Bucket-Probability Distribution.
echo "Running Sensitivity: Buckets & Balls Simulation for WaysPerSkew=4,16"
echo "(Throwing 1 Billion Balls)"
mkdir -p raw_results;
rm -rf raw_results/*;
#LLC-Associativity=32
stdbuf -oL ../../bin/mirage16WPS_kExtraWays_NBn.o 5 1 42 \
       > raw_results/Base16.ExtraWays5.out &
#LLC-Associativity=8
stdbuf -oL ../../bin/mirage4WPS_kExtraWays_NBn.o 5 1 42 \
       > raw_results/Base4.ExtraWays5.out &

## Wait for completion of all experiments.
exp_count=`ps aux | grep -i "mirage" | grep -v "grep" | wc -l`
while [ $exp_count -gt 0 ]
do
    sleep 30
    exp_count=`ps aux | grep -i "mirage" | grep -v "grep" | wc -l`    
done

##Generate Bucket_Probabilities
## TODO: ./get_bucket_prob_16.sh
## TODO: ./get_bucket_prob_4.sh
