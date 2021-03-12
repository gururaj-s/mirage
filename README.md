## MIRAGE: Mitigating Conflict-Based Cache Attacks with a Practical Fully-Associative Design  
Authors: Gururaj Saileshwar and Moinuddin Qureshi, Georgia Institute of Technology.  
Appears in USENIX Security 2021.   

### Citation
Gururaj Saileshwar and Moinuddin Qureshi. "MIRAGE: Mitigating Conflict-Based Cache Attacks with a Practical Fully-Associative Design". In 30th USENIX Security Symposium (USENIX Security 21). 2021.

### Introduction
The artifact covers two aspects of results from the paper:  

- **Security Analysis of MIRAGE:** A [Bins and Buckets](https://en.wikipedia.org/wiki/Balls_into_bins_problem) model of the Last-Level-Cache implementing MIRAGE is provided in a C++ program, to quantify its security properties.  This aspect can be easily evaluated on a commodity CPU (perhaps even a laptop with 4-cores/8 threads) in 3-6 hours runtime, without major SW dependencies. Your will be able to recreate all the Security-Analysis related tables and graphs: *Fig-7, Table-1, Fig-9, Fig-10, Table-4*. 
- **Performance Analysis of MIRAGE:** An implementation of the MIRAGE LLC is provided as a part of the [Gem5 CPU Simulator](https://www.gem5.org/). To run the performance evaluations, a server-grade system is needed (at least 30 threads preferred) and the expected runtime is 12 - 24 hours. You are also required to have access to the SPEC-2006 benchmark suite (we are unable to provide this due to its restrictive license). You will be able to recreate the performance results provided in Appendix-B.  
  - Note that the main performance results in the paper were generated with a cache simulator using an Intel Pin version that is no longer publicly available. Hence, for the artifact, we are providing MIRAGE implemented in Gem5 (results in Appendix-B), which is much easier to open-source and replicate. We plan to add other results shown in the paper to the Gem5 implementation, before open-sourcing it.

### Requirements For Security Evaluation:  
 - **SW Dependencies :**  C++, Python3, Jupyter Notebook and Python3 Packages (pandas, matplotlib, seaborn).   

 - **HW Dependencies :**
   - A 8 core CPU desktop/laptop will allow a simulation of 10 Billion cache-fills in 1-2 hours (default for artifact evaluation).   
   - Note the run-scripts spawn 8 parallel threads by default. If your system supports fewer than 8 threads, please modify `security_analysis/results/base/run_base.sh`.  

### Steps for Security Evaluation  
Here you can recreate all the Security-Analysis related tables and graphs: *Fig-7, Table-1, Fig-9, Fig-10, Table-4*, by following these instructions::  
- **Compile the binaries:** `cd security_analysis ; make all`  
- **Run the experiments:** `./run_exp.sh` . This will run following scripts for all experiments:
  - Base experiments: `cd results/base; ./run_base.sh`.
      * This will run the default base configuration of 16-Way LLC, i.e. 8 Base-Ways-Per-Skews
      * This will spawn 6 parallel experiments for Extra-Ways-per-Skew = 1 to 6.  (if your system cannot support 6 threads, please modify `./run_base.sh`).
      * Each experiment defaults to 10 Billion Ball Throws (default for the artifact evaluation). This can be controlled with arguments as `./run_base.sh <NUM_BILLION_THROWS> <NUM_EXP>`, to execute NUM_BILLION_THROWS x NUM_EXP` ball throws. We used 500 Billion x 20 to simulate 10 Trillion Ball throws for the paper, but using 10 Billion provides results in similar order of magnitudes.
  - Sensitivity experiments: `cd results/sensitivity; ./run_sensitivity.sh`.
      * This will run the evaluations for 8-Way and 32-Way LLC (4 and 16 Base-Ways-Per-Skews).
      * Only  10 Billion Ball Throws are simulated in these experiements.
- **Visualize the results:** `jupyter notebook results/visualize_results.ipynb`. This will plot the following:
  - Fig-7: Bucket-Spill-Frequency as Bucket-Capacity (Ways-Per-Skew) changes. This is directly from the results of the simulations.
  - Fig-9,Fig-10: Empirical and Analytical Bucket-Probabilities and Bucket-Spill-Frequency. The Empirical results are directly from the simulations. The Analytical values are calculated using the Bucket-Probability(0) from the experiments, in the Equations in Section-4.3 and 4.4 in the paper.
  - Table-1: Is directly taken from Fig-10.
  - Table-4: Bucket-Spill-Frequency as LLC-Associativity varies. This uses similar analysis as Fig-10, except the values are used from the sensitivity experiments.
  - (*Note: Results may not identically match the paper results as only 10-Billion Cache-Fill simulations are performed, while the paper had 10 Trillion Cache-Fills. However the results should be in similar order of magnitude as the paper-results.)*
      
  

### Requirements For Performance Evaluations in Gem5 CPU Simulator:
   - **SW Dependencies:** Gem5 Dependencies - gcc, Python-2.7, scons-3.
     - Tested with gcc v4.8.5/v6.4.0 and scons-3.1.2.
     - Scons-3.1.2 download [link](https://sourceforge.net/projects/scons/files/scons/3.1.2/scons-3.1.2.tar.gz/download). To install, `tar -zxvf scons-3.1.2.tar.gz` and `cd scons-3.1.2; python setup.py install` (use `--prefix=<PATH>` for local install).
   - **Benchmark Dependencies:** [SPEC-2006](https://www.spec.org/cpu2006/) Installed.
   - **HW Dependencies:** 
     - A 15 CPU Core or more system, to finish experiments in ~6 hours. 
     - A 4 CPU Core system may require approximately 1 - 1.5 days.


### Steps for Gem5 Evaluation
Here you will recreate results in Appendix-B(Fig-15), by executing the following steps:
- **Compile Gem5:** `cd perf_analysis/gem5 ; scons -j50 build/X86/gem5.opt`
- **Set Paths** in `scripts/env.sh`. You will set the following :
    - `GEM5_PATH`: the full path of the gem5 directory (current directory).
    - `SPEC_PATH`: the path to your SPEC-CPU2006 installation. 
    - `CKPT_PATH`: the path to a new folder where the checkpoints will be created next.
    - Please source the paths as: `source scripts/env.sh` after modifying the file.
- **Test Creating and Running Checkpoints:** For each program the we need to create a checkpoint of the program state after the initialization phase of the program is complete, which will be used to run the simulations with different hardware configurations. 
    - To test the checkpointing process, run `cd scripts; ./ckptscript_test.sh perlbench 4;`: this will create a checkpoint after 100K instructions (should complete in a couple of minutes). Once it completes, run `./runscript_test.sh perlbench Test Baseline 4 8MB 3`: this will run the baseline design for 500K instructions from the checkpoint.
      * In case the `ckptscript_test.sh` fails with the error `$SPEC_PATH/benchspec/CPU2006/400.perlbench/run/run_base_ref_amd64-m64-gcc41-nn.0000: No such file or directory`, it indicates the script is unable to find the run-directory for perlbench. Please follow the steps outlined in [README_SPEC_INSTALLATION.md](https://github.com/gururaj-s/mirage/blob/master/perf_analysis/README_SPEC_INSTALLATION.md) to ensure the run-directories are properly set up for all the SPEC-benchmarks.
    - To check if the run is successfully complete, check `less ../output/multiprogram_8Gmem_100K.C4/Test/Baseline/perlbench/runscript.log`. The last line should have `Exiting .. because a thread reached the max instruction count`.
- **Run All Experiments:** for all the benchmarks, run `./run_all_exp.sh`. This will run the following scripts:
    - `./run.perf.4C.sh` - This creates checkpoints and runs the experiments for the performance-results with 8MB LLC (shared among 4-cores). Specifically it runs:
      * **Create Checkpoint:** For each benchmark, the checkpoints will be created using `./ckptscript.sh <BMARK> 4`. 
      	- By default, `ckptscript.sh` is run for 42 programs in parallel (14 single-program, 14 multi-core and  14 mixed workloads). Please modify run.perf.4C.sh if your system cannot support 28 - 42 parallel threads.
      	- For each program, the execution is forwarded by 10 Billion Instructions (by when the initialization of the program should have completed) and then the architectural state (e.g. registers, memory) is checkpointed. Subsequently, when each HW-config is simulated, these checkpoints will be reloaded.
      	- This process can take 12 hours for each benchmark. Hence, all the benchmarks are run in parallel by default.
      	- Please see `../configs/example/spec06_config.py` for list of benchmarks supported.
      * **Run experiments**: Once all the checkpoints are created, the experiments will be run using `./runscript.sh <BMARK> <RUN-NAME> <SCHEME>`, where each HW config (Baseline, Scatter-Cache, MIRAGE) is simulated for each benchmark.
      	- The arguments for `runscript.sh` are as follows:
          -  RUN-NAME: Any string that will be used to identify this run, and the name for the results-folder of this run.
          -  SCHEME: [Baseline, scatter-cache, skew-vway-rand]. (skew-vway-rand is MIRAGE).
          -  NUM_CORES: Number of cores (default is 4).
          -  LLCSZ: Size of the LLC (default is 8MB).
          -  ENCRLAT: Encryptor Latency (default is 3 cycles).
      	- Each program is simulated for 1 billion instructions. This takes ~8 hours per benchmark, per scheme. Benchmarks in 2-3 schemes are run in parallel for a total of up to 84 parallel Gem5 runs at a time (please modify run.perf.4C.sh if your system cannot support upto 80 parallel threads).
      * **Generate results:** `cd stats_scripts; ./data_perf.sh`. This will compare the normalized performance (using weighted speedup metric) vs baseline.
        - The normalized peformance results will be stored in `stats_scripts/data/perf.stat`. 
        - Script to collect the LLC misses-per-thousand-instructions (MPKI) for each of the schemes is also available in `stats_scripts/data_mpki.sh`.
    - `./run.sensitivity.cachesz.sh` - This runs the evaluations for sensitivity to LLC-Size from 2MB to 64MB (shared between 4-cores)
      * Experiments are run using the script `./runscript.sh`
      * Results for normalized Perf vs. LLCSz can be generated using `cd stats_scripts; ./data_LLCSz.sh`. 
      * Results are stored in `stats_scripts/data/perf.LLCSz.stat`.
    - `./run.sensitivity.encrlat.sh` - This runs the evaluations for Encryption-latencies from 1 to 5 (used in cache-indexing).
      * Experiments are run using the script `./runscript.sh`
      * Results for normalized Perf vs. EncrLat can be generated using `cd stats_scripts; ./data_EncrLat.sh`. 
      * Results are stored in `stats_scripts/data/perf.EncLat.stat`.
- **Visualize the results:** Graphs can be generated using jupyter notebook `graphs/plot_graphs.ipynb` for Performance, LLCSz vs Perf., EncrLat vs Perf.
- **Note on Simulation Time:** Running all experiments takes almost 3-4 days on a system supporting 72 threads. 
    - To shorten experiment run time, you may reduce instruction count in `runscript.sh`to 500 Million.
    - You can also run only `./run.perf.4C.sh` and skip the sensitivity analysis.
    - You can also run many more parallel gem5 sims if your system supports it by modifying the sleep-loops in `run.perf.4C.sh` and `run.sensitivity.*.sh`.