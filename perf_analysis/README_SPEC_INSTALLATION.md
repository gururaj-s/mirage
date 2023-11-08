For running the SPEC-CPU2006 benchmarks with Gem5, you need to create the run-directories for each SPEC benchmark with the following steps (these steps are only needed once for each benchmark):  
- Run the following command: `runspec --config=Example-linux64-amd64-gcc41.cfg --size=ref --noreportable --tune=base --iterations=1 perlbench`. This command should build a benchmark (if it does not exist), create run directories and copy the executable & inputs to run folder and then run the benchmark. 
    - A helpful resource for understanding this process can be the [SPEC2006 installation page](https://www.spec.org/cpu2006/Docs/install-guide-unix.html#s9), which outlines the steps to install SPEC benchmarks (Step 1-5), how to get runspec utility (Step 6), and how to use runsoec utility to run a benchmark (Step 9).
- Check `$SPEC_PATH/benchspec/CPU2006/400.perlbench/run/run*`: there should be a run folder created with the executable (something like `./perlbench_base.amd64-m64-gcc41-nn`) & input files (e.g. `checkspam.pl`) for the benchmark.
- The exact name of the run-folder (run*) might be different based on your OS/CPU/compiler. If so, please update the RUN_DIR variable with the name of the run-folder in: `ckptscript_test.sh`, `runscript_test.sh`, `ckptscript.sh` and `runscript.sh`.
- Lastly, you need to make sure Gem5 runs with the correct executable names for benchmarks (this can also vary on different SPEC installations):
    - Check the name of the executable `$SPEC_PATH/benchspec/CPU2006/400.perlbench/run/run*/perlbench*`. On our system, the binary name is `perlbench_base.amd64-m64-gcc41-nn`. Note the suffix after `perlbench` (e.g. `_base.amd64-m64-gcc41-nn`).
    - Edit `perf_analysis/gem5/configs/example/spec06_benchmarks.py`: Replace `x86_suffix` variable with the suffix on your system.  
- After these steps,`ckptscript_test.sh perlbench 4` should hopefully work: the script should be able to `cd` into the correct run-directory for the SPEC-benchmark and run the correct executable name with the right input parameters. 
    - You can check the command used in `perf_analysis/gem5/output/multiprogram_8Gmem_100K.C4/checkpoint_out/perlbench/runscript.log` in the line after `Process stderr file: ..`.
- Once perlbench is successfully tested, to generate the run directories for all the other benchmarks, use: `runspec --config=Example-linux64-amd64-gcc41.cfg --size=ref --noreportable --tune=base --iterations=1 lbm soplex milc mcf sphinx3 libquantum cactusADM bzip2 perlbench hmmer gromacs sjeng gobmk gcc h264ref`.  
- Note: After all benchmark run-directories are created, please make sure run-directories of all benchmarks have the same naming format.    


After completing these steps, all the SPEC benchmnark run-directories should be set up. Now, you can try the next step using `runscript_test.sh` in [README.md](https://github.com/gururaj-s/mirage/blob/master/README.md) to test Gem5 functionality and then run all the experiments.



