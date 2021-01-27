all: base_design sensitivity

base_design : create_folder WaysPerSkew_8

sensitivity : create_folder WaysPerSkew_16 WaysPerSkew_4

#-------------------------
# DEFINES
#-------------------------
CC=g++
CFLAGS=-std=c++0x -O3 

create_folder:
	mkdir -p  bin

#-------------------------
# BINARIES
#-------------------------
WaysPerSkew_8 : src/bucketsNballs_kExtraWays_NBn.cpp src/mtrand.h
	$(CC) $(CFLAGS) src/bucketsNballs_kExtraWays_NBn.cpp -o bin/mirage8WPS_kExtraWays_NBn.o 

WaysPerSkew_16 : src/bucketsNballs_kExtraWays_NBn.cpp src/mtrand.h
	$(CC) $(CFLAGS) -DCUSTOM_BASE_WAYS_PER_SKEW=16  -DCUSTOM_MAX_FILL=32  src/bucketsNballs_kExtraWays_NBn.cpp -o bin/mirage16WPS_kExtraWays_NBn.o 

WaysPerSkew_4 : src/bucketsNballs_kExtraWays_NBn.cpp src/mtrand.h
	$(CC) $(CFLAGS) -DCUSTOM_BASE_WAYS_PER_SKEW=4  src/bucketsNballs_kExtraWays_NBn.cpp -o bin/mirage4WPS_kExtraWays_NBn.o 

clean:
	rm -rf bin/*.o ; 
