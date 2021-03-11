import spec06_benchmarks
import custom_benchmarks
import m5
from  m5.objects import *

## At-most 4-Core mix-workloads.
mix_wls = {
   'mix1' : ['gobmk',    'milc',       'cactusADM',   'lbm'],
   'mix2' : ['hmmer',    'cactusADM',  'milc',        'sjeng'],
   'mix3' : ['gobmk',    'perlbench',  'soplex',      'cactusADM'],
   'mix4' : ['gobmk',    'sjeng',      'gcc',         'bzip2'],
   'mix5' : ['sjeng',    'hmmer',      'cactusADM',   'bzip2'],
   'mix6' : ['lbm',      'sphinx3',    'gobmk',       'hmmer'],
   'mix7' : ['bzip2',    'lbm',        'libquantum',  'perlbench'],
   'mix8' : ['gromacs',  'gobmk',      'h264ref',     'hmmer'],
   'mix9' : ['gromacs',  'h264ref',    'lbm',         'perlbench'],
   'mix10': ['bzip2',    'perlbench',  'gobmk',       'soplex'],
   'mix11': ['milc',     'sphinx3',    'gcc',         'lbm'],
   'mix12': ['milc',     'lbm',        'h264ref',     'hmmer'],
   'mix13': ['sjeng',    'sphinx3',    'lbm',         'h264ref'],
   'mix14': ['gromacs',  'soplex',     'lbm',         'milc']
}

def create_process(benchmark_name):    
    print( 'Selected benchmark')
    if benchmark_name == 'perlbench':
        print( '--> perlbench')
        process = spec06_benchmarks.perlbench
    elif benchmark_name == 'bzip2':
        print( '--> bzip2')
        process = spec06_benchmarks.bzip2
    elif benchmark_name == 'gcc':
        print( '--> gcc')
        process = spec06_benchmarks.gcc
    elif benchmark_name == 'bwaves':
        print( '--> bwaves')
        process = spec06_benchmarks.bwaves
    elif benchmark_name == 'gamess':
        print( '--> gamess')
        process = spec06_benchmarks.gamess
    elif benchmark_name == 'mcf':
        print( '--> mcf')
        process = spec06_benchmarks.mcf
    elif benchmark_name == 'milc':
        print( '--> milc')
        process = spec06_benchmarks.milc
    elif benchmark_name == 'zeusmp':
        print( '--> zeusmp')
        process = spec06_benchmarks.zeusmp
    elif benchmark_name == 'gromacs':
        print( '--> gromacs')
        process = spec06_benchmarks.gromacs
    elif benchmark_name == 'cactusADM':
        print( '--> cactusADM')
        process = spec06_benchmarks.cactusADM
    elif benchmark_name == 'leslie3d':
        print( '--> leslie3d')
        process = spec06_benchmarks.leslie3d
    elif benchmark_name == 'namd':
        print( '--> namd')
        process = spec06_benchmarks.namd
    elif benchmark_name == 'gobmk':
        print( '--> gobmk')
        process = spec06_benchmarks.gobmk
    elif benchmark_name == 'dealII':
        print( '--> dealII')
        process = spec06_benchmarks.dealII
    elif benchmark_name == 'soplex':
        print( '--> soplex')
        process = spec06_benchmarks.soplex
    elif benchmark_name == 'povray':
        print( '--> povray')
        process = spec06_benchmarks.povray
    elif benchmark_name == 'calculix':
        print( '--> calculix')
        process = spec06_benchmarks.calculix
    elif benchmark_name == 'hmmer':
        print( '--> hmmer')
        process = spec06_benchmarks.hmmer
    elif benchmark_name == 'sjeng':
        print( '--> sjeng')
        process = spec06_benchmarks.sjeng
    elif benchmark_name == 'GemsFDTD':
        print( '--> GemsFDTD')
        process = spec06_benchmarks.GemsFDTD
    elif benchmark_name == 'libquantum':
        print( '--> libquantum')
        process = spec06_benchmarks.libquantum
    elif benchmark_name == 'h264ref':
        print( '--> h264ref')
        process = spec06_benchmarks.h264ref
    elif benchmark_name == 'tonto':
        print( '--> tonto')
        process = spec06_benchmarks.tonto
    elif benchmark_name == 'lbm':
        print( '--> lbm')
        process = spec06_benchmarks.lbm
    elif benchmark_name == 'omnetpp':
        print( '--> omnetpp')
        process = spec06_benchmarks.omnetpp
    elif benchmark_name == 'astar':
        print( '--> astar')
        process = spec06_benchmarks.astar
    elif benchmark_name == 'wrf':
        print( '--> wrf')
        process = spec06_benchmarks.wrf
    elif benchmark_name == 'sphinx3':
        print( '--> sphinx3')
        process = spec06_benchmarks.sphinx3
    elif benchmark_name == 'xalancbmk':
        print( '--> xalancbmk')
        process = spec06_benchmarks.xalancbmk
    elif benchmark_name == 'specrand_i':
        print( '--> specrand_i')
        process = spec06_benchmarks.specrand_i
    elif benchmark_name == 'specrand_f':
        print( '--> specrand_f')
        process = spec06_benchmarks.specrand_f        
    else:
        print( "No recognized SPEC2006 benchmark selected! Exiting.")
        sys.exit(1)
    return  process


def create_proc (benchmark_name,id):
    import re
    #Check if mix-benchmark
    procName = ""
    if(re.match(r"^mix[0-9]+$",benchmark_name)):
       # Do mix
       procName = mix_wls[benchmark_name][id]
    else :       
       # Do rate-mode
       procName = benchmark_name
    print "Benchmark-"+str(id)+" "+procName
       
    curr_proc = create_process(procName)
    new_proc = Process(pid = 100 +id)
    new_proc.executable  = curr_proc.executable
    new_proc.cmd  = curr_proc.cmd
    new_proc.input = curr_proc.input
    new_proc.cwd   = curr_proc.cwd 
    return new_proc
