cd ..
mkdir -p stats_scripts/data 
perl getdata.pl  -w spec_mix_28 -amean -nstat system.l2.overall_misses::total -dstat sim_inst -mstat 1000  -d  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/Baseline   ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/scatter-cache  ../output/multiprogram_8Gmem_10Bn.C4/ARTIFACT_RESULTS/skew-vway-rand | sed 's/[_A-Z]*\/BaselineRRIP/Baseline/' | sed 's/[_A-Z]*\/scatter-cache/scatter-cache/' | sed 's/[_A-Z]*\/skew-vway-rand/MIRAGE/' | column -t > stats_scripts/data/mpki.stat

cat stats_scripts/data/mpki.stat
