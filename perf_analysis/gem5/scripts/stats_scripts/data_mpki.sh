cd ..

perl getdata.pl -w spec2006_hmpki_noomnet -amean -nstat system.l2.overall_misses::total -dstat sim_inst -mstat 1000  -d ../output/ooo_4Gmem_10Bn/Old_Ckpt_Test_2MB_16Way/BaselineRRIP   ../output/ooo_4Gmem_10Bn/Old_Ckpt_Test_2MB_16Way/scatter-cache  ../output/ooo_4Gmem_10Bn/16WayLLC_SKEWFAIR_tdr1_75/skew-vway-rand   ../output/ooo_4Gmem_10Bn/16WayLLC_SKEWFAIR_tdr1_75/skew-vway-rand-datareuserepl > stats_scripts/data/mpki.stat
