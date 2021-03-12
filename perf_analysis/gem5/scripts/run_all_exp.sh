## Run Main Performance Results (Fig-15)
echo "Running Performance Results: (Estimated Time 1.5 days)"
./run.perf.4C.sh

## Run Sensitivity Results Performance vs LLCSz
echo "Running Sensitivity Results: Perf vs LLCSz (Estimated Time 2 days)"
./run.sensitivity.cachesz.sh

## Run Sensitivity Results Performance vs Encryptor Latency
echo "Running Sensitivity Results: vs LLCSz (Estimated Time 1 day)" 
./run.sensitivity.encrlat.sh

