cd ..
mkdir -p stats_scripts/data 

### Slowdown based on WEIGHTED-SPEEDUP Metric ###
echo "EncrLat Baseline Scatter-Cache MIRAGE"  > stats_scripts/data/perf.EncLat.stat
# EncrLat = 1
perl getdata.pl -gmean -n 0  -nh -ns -gmean -w spec_mix_28 -ipc 4 -ws -b ../output/multiprogram_8Gmem_10Bn.C1/ARTIFACT_RESULTS.1C.8MBLLC/Baseline   -d  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/Baseline   ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS.EL1/scatter-cache  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS.EL1/skew-vway-rand | sed 's/Gmean/1/'  >> stats_scripts/data/perf.EncLat.stat;

# EncrLat = 2
perl getdata.pl -gmean -n 0  -nh -ns -gmean -w spec_mix_28 -ipc 4 -ws -b ../output/multiprogram_8Gmem_10Bn.C1/ARTIFACT_RESULTS.1C.8MBLLC/Baseline   -d  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/Baseline   ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS.EL2/scatter-cache  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS.EL2/skew-vway-rand | sed 's/Gmean/2/'  >> stats_scripts/data/perf.EncLat.stat;

# EncrLat = 3
perl getdata.pl -gmean -n 0  -nh -ns -gmean -w spec_mix_28 -ipc 4 -ws -b ../output/multiprogram_8Gmem_10Bn.C1/ARTIFACT_RESULTS.1C.8MBLLC/Baseline   -d  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/Baseline   ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/scatter-cache  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/skew-vway-rand | sed 's/Gmean/3/'  >> stats_scripts/data/perf.EncLat.stat;

# EncrLat = 4
perl getdata.pl -gmean -n 0  -nh -ns -gmean -w spec_mix_28 -ipc 4 -ws -b ../output/multiprogram_8Gmem_10Bn.C1/ARTIFACT_RESULTS.1C.8MBLLC/Baseline   -d  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/Baseline   ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS.EL4/scatter-cache  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS.EL4/skew-vway-rand | sed 's/Gmean/4/'  >> stats_scripts/data/perf.EncLat.stat;

# EncrLat = 5
perl getdata.pl -gmean -n 0  -nh -ns -gmean -w spec_mix_28 -ipc 4 -ws -b ../output/multiprogram_8Gmem_10Bn.C1/ARTIFACT_RESULTS.1C.8MBLLC/Baseline   -d  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/Baseline   ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS.EL5/scatter-cache  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS.EL5/skew-vway-rand | sed 's/Gmean/5/'  >> stats_scripts/data/perf.EncLat.stat;


# Format
column -t stats_scripts/data/perf.EncLat.stat > stats_scripts/data/temp ; mv stats_scripts/data/temp stats_scripts/data/perf.EncLat.stat ;
cat stats_scripts/data/perf.EncLat.stat;
