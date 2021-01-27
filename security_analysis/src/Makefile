all: base_design sensitivity

base_design : create_folder WaysPerSkew_8

sensitivity : create_folder WaysPerSkew_16 WaysPerSkew_4

#-------------------------
# DEFINES
#-------------------------
CC=g++
CFLAGS=-std=c++0x -O3 

create_folder:
	mkdir -p  ../bin

#-------------------------
# BINARIES
#-------------------------
WaysPerSkew_8 : bucketsNballs_kExtraWays_NBn.cpp mtrand.h
	$(CC) $(CFLAGS) bucketsNballs_kExtraWays_NBn.cpp -o ../bin/mirage8WPS_kExtraWays_NBn.o 

WaysPerSkew_16 : bucketsNballs_kExtraWays_NBn.cpp mtrand.h


WaysPerSkew_4 : bucketsNballs_kExtraWays_NBn.cpp mtrand.h

clean:
	rm -rf bin/*.o ; 
clean_results:
	rm -rf results/*/*.txt results/*/*.log;
