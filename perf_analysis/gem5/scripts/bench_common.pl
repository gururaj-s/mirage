#******************************************************************************
# Benchmark Sets
# ************************************************************

%SUITES = ();

#***************************************************************
# Exception
#**************************************************************
$SUITES{'h264ref'}	=
    'h264ref';

$SUITES{'sjeng'}	=
    'sjeng';

$SUITES{'wrf'}	=
    'wrf';

$SUITES{'sphinx3'}	=
    'sphinx3';

$SUITES{'perlbench'}	=
    'perlbench';

$SUITES{'gcc'}	=
    'gcc';

$SUITES{'soplex'}	=
    'soplex';

$SUITES{'bzip2'}	=
    'bzip2';

$SUITES{'gromacs'}	=
    'gromacs';

$SUITES{'mcf'}	=
    'mcf';

$SUITES{'milc'}	=
    'milc';

$SUITES{'lbm'}	=
    'lbm';

$SUITES{'hmmer'}	=
    'hmmer';

$SUITES{'gobmk'}	=
    'gobmk';

$SUITES{'povray'}	=
    'povray';

$SUITES{'namd'}	=
    'namd';

#***************************************************************
# SPEC2006 SUITE 
#***************************************************************

$SUITES{'spec2006_final'}      =
'gobmk
sjeng
bzip2
perlbench
povray
gromacs
h264ref
namd
sphinx3
wrf
hmmer
mcf
soplex
gcc
lbm
cactusADM
milc
libquantum';

$SUITES{'spec2006_ckpt_avail'} =
'astar
bzip2
cactusADM
gcc
gobmk
gromacs
h264ref
hmmer
lbm
libquantum
mcf
milc
namd
omnetpp
perlbench
povray
sjeng
soplex
sphinx3
wrf';


$SUITES{'spec2006_hmpki'} =
'bzip2
cactusADM
gcc
gobmk
gromacs
h264ref
hmmer
lbm
libquantum
mcf
milc
omnetpp
perlbench
sjeng
soplex
sphinx3';


$SUITES{'spec2006_hmpki_noomnet'} =
'lbm
soplex
milc
mcf
sphinx3
libquantum
cactusADM
bzip2
perlbench
hmmer
gromacs
sjeng
gobmk
gcc
h264ref';

$SUITES{'spec2006_noomnet'} =
'astar
bzip2
cactusADM
gcc
gobmk
gromacs
h264ref
hmmer
lbm
libquantum
mcf
milc
namd
perlbench
povray
sjeng
soplex
sphinx3
wrf';

$SUITES{'spec2006'} =
'mcf 
lbm
soplex
milc
libquantum
omnetpp
bwaves
gcc
sphinx3
GemsFDTD
leslie3d
wrf
cactusADM
zeusmp
bzip2
dealII
xalancbmk
hmmer
perlbench
h264ref
astar
gromacs
gobmk
sjeng
namd
tonto
calculix
gamess
povray';
