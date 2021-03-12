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

$SUITES{'spec_mix_28'} =
'lbm
soplex
milc
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
h264ref
mix1
mix2
mix3
mix4
mix5
mix6
mix7
mix8
mix9
mix10
mix11
mix12
mix13
mix14';

$SUITES{'spec_14'} =
'lbm
soplex
milc
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

$SUITES{'mix_14'} =
'mix1
mix2
mix3
mix4
mix5
mix6
mix7
mix8
mix9
mix10
mix11
mix12
mix13
mix14';

%mix_wls = (
   mix1 => ['gobmk',    'milc',       'cactusADM',   'lbm'],
   mix2 => ['hmmer',    'cactusADM',  'milc',        'sjeng'],
   mix3 => ['gobmk',    'perlbench',  'soplex',      'cactusADM'],
   mix4 => ['gobmk',    'sjeng',      'gcc',         'bzip2'],
   mix5 => ['sjeng',    'hmmer',      'cactusADM',   'bzip2'],
   mix6 => ['lbm',      'sphinx3',    'gobmk',       'hmmer'],
   mix7 => ['bzip2',    'lbm',        'libquantum',  'perlbench'],
   mix8 => ['gromacs',  'gobmk',      'h264ref',     'hmmer'],
   mix9 => ['gromacs',  'h264ref',    'lbm',         'perlbench'],
   mix10=> ['bzip2',    'perlbench',  'gobmk',       'soplex'],
   mix11=> ['milc',     'sphinx3',    'gcc',         'lbm'],
   mix12=> ['milc',     'lbm',        'h264ref',     'hmmer'],
   mix13=> ['sjeng',    'sphinx3',    'lbm',         'h264ref'],
   mix14=> ['gromacs',  'soplex',     'lbm',         'milc'],
);


$SUITES{'spec2006_hmpki_avail'} =
'lbm
soplex
milc
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
