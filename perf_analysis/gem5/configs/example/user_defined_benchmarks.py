import spec06_benchmarks
import custom_benchmarks
import m5
from  m5.objects import *

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
    elif benchmark_name == 'stream_1':
        print( '--> '+benchmark_name)
        process = custom_benchmarks.stream_1
    elif benchmark_name == 'stream_2':
        print( '--> '+benchmark_name)
        process = custom_benchmarks.stream_2
    elif benchmark_name == 'stream_3':
        print( '--> '+benchmark_name)
        process = custom_benchmarks.stream_3
    elif benchmark_name == 'stream_4':
        print( '--> '+benchmark_name)
        process = custom_benchmarks.stream_4
    elif benchmark_name == 'stream_5':
        print( '--> '+benchmark_name)
        process = custom_benchmarks.stream_5
    elif benchmark_name == 'stream_6':
        print( '--> '+benchmark_name)
        process = custom_benchmarks.stream_6
    elif benchmark_name == 'stream_8':
        print( '--> '+benchmark_name)
        process = custom_benchmarks.stream_8
    elif benchmark_name == 'stream_10':
        print( '--> '+benchmark_name)
        process = custom_benchmarks.stream_10
    elif benchmark_name == 'stream_20':
        print( '--> '+benchmark_name)
        process = custom_benchmarks.stream_20
    elif benchmark_name == 'stream_30':
        print( '--> '+benchmark_name)
        process = custom_benchmarks.stream_30
    elif benchmark_name == 'stream_40':
        print( '--> '+benchmark_name)
        process = custom_benchmarks.stream_40
    elif benchmark_name == 'stream_50':
        print( '--> '+benchmark_name)
        process = custom_benchmarks.stream_50
    elif benchmark_name == 'stream_60':
        print( '--> '+benchmark_name)
        process = custom_benchmarks.stream_60
    elif benchmark_name == 'stream_80':
        print( '--> '+benchmark_name)
        process = custom_benchmarks.stream_80
    elif benchmark_name == 'stream_100':
        print( '--> '+benchmark_name)
        process = custom_benchmarks.stream_100
    elif benchmark_name == 'stream_200':
	print( '--> '+benchmark_name)
	process = custom_benchmarks.stream_200
    elif benchmark_name == 'stream_300':
	print( '--> '+benchmark_name)
	process = custom_benchmarks.stream_300
    elif benchmark_name == 'stream_500':
	print( '--> '+benchmark_name)
	process = custom_benchmarks.stream_500
    elif benchmark_name == 'stream_1000':
	print( '--> '+benchmark_name)
	process = custom_benchmarks.stream_1000
    elif benchmark_name == 'stream_2000':
	print( '--> '+benchmark_name)
	process = custom_benchmarks.stream_2000
    elif benchmark_name == 'stream_3000':
	print( '--> '+benchmark_name)
	process = custom_benchmarks.stream_3000
    elif benchmark_name == 'stream_5000':
	print( '--> '+benchmark_name)
	process = custom_benchmarks.stream_5000
    elif benchmark_name == 'stream_10000':
	print( '--> '+benchmark_name)
	process = custom_benchmarks.stream_10000
    elif benchmark_name == 'stream_20000':
	print( '--> '+benchmark_name)
	process = custom_benchmarks.stream_20000
    elif benchmark_name == 'stream_30000':
	print( '--> '+benchmark_name)
	process = custom_benchmarks.stream_30000
    elif benchmark_name == 'stream_50000':
	print( '--> '+benchmark_name)
	process = custom_benchmarks.stream_50000
    elif benchmark_name == 'stream_100000':
	print( '--> '+benchmark_name)
	process = custom_benchmarks.stream_100000
    else:
        print( "No recognized SPEC2006 benchmark selected! Exiting.")
        sys.exit(1)
    return  process


def create_proc_ratemode (benchmark_name,id):
    curr_proc = create_process(benchmark_name)
    new_proc = Process(pid = 100 +id)
    new_proc.executable  = curr_proc.executable
    new_proc.cmd  = curr_proc.cmd
    return new_proc
