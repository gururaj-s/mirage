cd ..
mkdir -p stats_scripts/data 

### Slowdown based on WEIGHTED-SPEEDUP Metric ###
echo "LLCSz Baseline Scatter-Cache MIRAGE"  > stats_scripts/data/perf.LLCSz.stat
# LLCSz=2MB
perl getdata.pl -gmean -n 0  -nh -ns -gmean -w spec_mix_28 -ipc 4 -ws -b ../output/multiprogram_8Gmem_10Bn.C1/ARTIFACT_RESULTS.1C.2MBLLC/Baseline   -d  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS.2MB/Baseline   ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS.2MB/scatter-cache  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS.2MB/skew-vway-rand | sed 's/Gmean/2MB/'  >> stats_scripts/data/perf.LLCSz.stat;

# LLCSz=4MB
perl getdata.pl -gmean -n 0  -nh -ns -gmean -w spec_mix_28 -ipc 4 -ws -b ../output/multiprogram_8Gmem_10Bn.C1/ARTIFACT_RESULTS.1C.4MBLLC/Baseline   -d  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS.4MB/Baseline   ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS.4MB/scatter-cache  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS.4MB/skew-vway-rand | sed 's/Gmean/4MB/'  >> stats_scripts/data/perf.LLCSz.stat;

# LLCSz=8MB
perl getdata.pl -gmean -n 0  -nh -ns -gmean -w spec_mix_28 -ipc 4 -ws -b ../output/multiprogram_8Gmem_10Bn.C1/ARTIFACT_RESULTS.1C.8MBLLC/Baseline   -d  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/Baseline   ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/scatter-cache  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/skew-vway-rand | sed 's/Gmean/8MB/'  >> stats_scripts/data/perf.LLCSz.stat;

# LLCSz=16MB
perl getdata.pl -gmean -n 0  -nh -ns -gmean -w spec_mix_28 -ipc 4 -ws -b ../output/multiprogram_8Gmem_10Bn.C1/ARTIFACT_RESULTS.1C.16MBLLC/Baseline   -d  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS.16MB/Baseline   ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS.16MB/scatter-cache  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS.16MB/skew-vway-rand | sed 's/Gmean/16MB/'  >> stats_scripts/data/perf.LLCSz.stat;

# LLCSz=32MB
perl getdata.pl -gmean -n 0  -nh -ns -gmean -w spec_mix_28 -ipc 4 -ws -b ../output/multiprogram_8Gmem_10Bn.C1/ARTIFACT_RESULTS.1C.32MBLLC/Baseline   -d  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS.32MB/Baseline   ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS.32MB/scatter-cache  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS.32MB/skew-vway-rand | sed 's/Gmean/32MB/'  >> stats_scripts/data/perf.LLCSz.stat;

# LLCSz=64MB
perl getdata.pl -gmean -n 0  -nh -ns -gmean -w spec_mix_28 -ipc 4 -ws -b ../output/multiprogram_8Gmem_10Bn.C1/ARTIFACT_RESULTS.1C.64MBLLC/Baseline   -d  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS.64MB/Baseline   ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS.64MB/scatter-cache  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS.64MB/skew-vway-rand | sed 's/Gmean/64MB/'  >> stats_scripts/data/perf.LLCSz.stat;

# Format
column -t stats_scripts/data/perf.LLCSz.stat > stats_scripts/data/temp ; mv stats_scripts/data/temp stats_scripts/data/perf.LLCSz.stat ;
cat stats_scripts/data/perf.LLCSz.stat;
