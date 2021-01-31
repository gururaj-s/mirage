cd ..
mkdir -p stats_scripts/data 
perl getdata.pl -w spec2006_hmpki_noomnet -gmean -n 0   -nstat system.switch_cpus.numCycles -dstat sim_inst   -d  ../output/ooo_4Gmem_10Bn/ARTIFACT_RESULTS/BaselineRRIP  ../output/ooo_4Gmem_10Bn/ARTIFACT_RESULTS/scatter-cache ../output/ooo_4Gmem_10Bn/ARTIFACT_RESULTS/skew-vway-rand | sed 's/[_A-Z]*\/BaselineRRIP/Baseline/' | sed 's/[_A-Z]*\/scatter-cache/scatter-cache/' | sed 's/[_A-Z]*\/skew-vway-rand/MIRAGE/' | column -t  > stats_scripts/data/perf.stat 

cat stats_scripts/data/perf.stat

