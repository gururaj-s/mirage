#Enable the python27 in OPT
source /opt/rh/python27/enable

#Paths for Packages
source /home/gattaca4/gururaj/LOCAL_LIB/env_gcc_binutils.sh
source /home/gattaca4/gururaj/LOCAL_LIB/env_zlib.sh
source /home/gattaca4/gururaj/LOCAL_LIB/protobuf/env_protobuf.sh
source /home/gattaca4/gururaj/LOCAL_LIB/gperftools/env_gperftools.sh

#Enable Anaconda & the environment for Gem5/Python
source /home/gattaca4/gururaj/LOCAL_LIB/python/env_anaconda2.sh
source activate gem5 #gem5 environment in conda


#Paths for Gem5 & SPEC
export GEM5_PATH=/home/gattaca5/gururaj/MIRAGE/PUBLIC_REPO_SEC21/mirage/perf_analysis/gem5
export SPEC_PATH=/home/gattaca3/gururaj/SPEC2006
