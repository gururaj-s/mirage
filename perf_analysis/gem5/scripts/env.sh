#Path to python local installation
#source /home/gattaca4/gururaj/LOCAL_LIB/python/env_python_2.7.sh

## CURRENTLY, HAVE SOFT-LINKS FOR libpython2.7, libtcmalloc in the LINKER folder (/home/gattaca4/gururaj/LOCAL_LIB/binutils-2.29_install/lib)
## Also: Have soft-link for python in /home/gattaca4/gururaj/LOCAL_LIB/python/anaconda2/bin to '/opt/rh/python27/root/usr/bin/python2.7'. Backup is backup_link_python
## IGNORE PREVIOUS LINE: Have soft-link for python in /home/gattaca4/gururaj/LOCAL_LIB/python/anaconda2/envs/gem5/bin/python to '/opt/rh/python27/root/usr/bin/python2.7'. Backup is backup_link_python

#Enable the python in OPT
source /opt/rh/python27/enable
#scl enable python27 zsh # Deprecated -this does not allow any subsequent command to execute

#Paths for Packages
source /home/gattaca4/gururaj/LOCAL_LIB/env_gcc_binutils.sh
source /home/gattaca4/gururaj/LOCAL_LIB/env_zlib.sh
source /home/gattaca4/gururaj/LOCAL_LIB/protobuf/env_protobuf.sh
source /home/gattaca4/gururaj/LOCAL_LIB/gperftools/env_gperftools.sh

#Enable Anaconda & the environment for Gem5/Python
#source /home/gattaca4/gururaj/LOCAL_LIB/python/env_anaconda2.sh
#source activate gem5 #gem5 environment in conda


#Paths for Gem5 & SPEC
#export GEM5_PATH=/home/gattaca5/gururaj/zombie/gem5_latest/gem5
export GEM5_PATH=/home/gattaca5/gururaj/MIRAGE/gem5
export WHISPER_PATH=/home/gattaca5/gururaj/whisper

export SPEC_PATH=/home/gattaca3/gururaj/SPEC2006
export M5_PATH=/home/gattaca5/gururaj/gem5_fs/x86
export CKPT_PATH=/home/gattaca5/gururaj/MIRAGE/gem5_ckpt
