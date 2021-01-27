cd ..

perl getdata.pl -w spec2006_hmpki_noomnet -gmean -n 0   -nstat system.switch_cpus.numCycles -dstat sim_inst   -d  ../output/ooo_4Gmem_10Bn/Old_Ckpt_Test_2MB_16Way/BaselineRRIP   ../output/ooo_4Gmem_10Bn/Old_Ckpt_Test_2MB_16Way/scatter-cache/  ../output/ooo_4Gmem_10Bn/16WayLLC_SKEWFAIR_tdr1_75/skew-vway-rand   ../output/ooo_4Gmem_10Bn/16WayLLC_SKEWFAIR_tdr1_75/skew-vway-rand-datareuserepl > stats_scripts/data/perf.stat
