cd ..
mkdir -p stats_scripts/data 

### Normalized Performance based on Weighted-Speedup Metric ###
# SPEC-14 workloads
perl getdata.pl -n 0  -w spec_14 -ipc 4 -ws -b ../output/multiprogram_8Gmem_10Bn.C1/ARTIFACT_RESULTS.1C.8MBLLC/Baseline   -d  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/Baseline   ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/scatter-cache  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/skew-vway-rand  | sed 's/[_A-Z]*\/Baseline/Baseline/' | sed 's/[_A-Z]*\/scatter-cache/scatter-cache/' | sed 's/[_A-Z]*\/skew-vway-rand/MIRAGE/' | column -t  > stats_scripts/data/perf.stat ; 

# MIX-14 workloads
perl getdata.pl -n 0 -nh  -w mix_14 -ipc 4 -ws -b ../output/multiprogram_8Gmem_10Bn.C1/ARTIFACT_RESULTS.1C.8MBLLC/Baseline   -d  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/Baseline   ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/scatter-cache  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/skew-vway-rand | column -t >> stats_scripts/data/perf.stat;
echo ".  0  0  0" | column -t >> stats_scripts/data/perf.stat;
 
# Avg - SPEC-14
perl getdata.pl -gmean -n 0  -nh -ns -gmean -w spec_14 -ipc 4 -ws -b ../output/multiprogram_8Gmem_10Bn.C1/ARTIFACT_RESULTS.1C.8MBLLC/Baseline   -d  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/Baseline   ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/scatter-cache  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/skew-vway-rand | sed 's/Gmean/SPEC-14/' | column -t >> stats_scripts/data/perf.stat;
# Avg - MIX-14
perl getdata.pl -gmean -n 0 -nh -ns -gmean -w mix_14 -ipc 4 -ws -b ../output/multiprogram_8Gmem_10Bn.C1/ARTIFACT_RESULTS.1C.8MBLLC/Baseline   -d  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/Baseline   ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/scatter-cache  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/skew-vway-rand | sed 's/Gmean/MIX-14/' | column -t >> stats_scripts/data/perf.stat;
# Avg - ALL-28
perl getdata.pl -gmean -n 0 -nh -ns -gmean -w spec_mix_28 -ipc 4 -ws -b ../output/multiprogram_8Gmem_10Bn.C1/ARTIFACT_RESULTS.1C.8MBLLC/Baseline   -d  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/Baseline   ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/scatter-cache  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/skew-vway-rand | sed 's/Gmean/ALL-28/' | column -t >> stats_scripts/data/perf.stat;
# Format
cat stats_scripts/data/perf.stat

### Uncomment for Normalized Performance based on Raw-IPC Metric ### 
# perl getdata.pl -n 0 -gmean -w spec_mix_28 -ipc 4  -d  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/Baseline   ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/scatter-cache  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/skew-vway-rand  | sed 's/[_A-Z]*\/Baseline/Baseline/' | sed 's/[_A-Z]*\/scatter-cache/scatter-cache/' | sed 's/[_A-Z]*\/skew-vway-rand/MIRAGE/' | column -t ;
