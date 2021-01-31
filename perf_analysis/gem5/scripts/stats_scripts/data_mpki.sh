cd ..
mkdir -p stats_scripts/data 
perl getdata.pl -w spec2006_hmpki_noomnet -amean -nstat system.l2.overall_misses::total -dstat sim_inst -mstat 1000  -d  ../output/ooo_4Gmem_10Bn/ARTIFACT_RESULTS/BaselineRRIP  ../output/ooo_4Gmem_10Bn/ARTIFACT_RESULTS/scatter-cache ../output/ooo_4Gmem_10Bn/ARTIFACT_RESULTS/skew-vway-rand | sed 's/[_A-Z]*\/BaselineRRIP/Baseline/' | sed 's/[_A-Z]*\/scatter-cache/scatter-cache/' | sed 's/[_A-Z]*\/skew-vway-rand/MIRAGE/' | column -t > stats_scripts/data/mpki.stat

cat stats_scripts/data/mpki.stat
