#!/bin/bash

###############################################################################
# Script to run Figure 9 Evaluation of the paper
# 
# Paper: Mitosis - Mitosis: Transparently Self-Replicating Page-Tables 
#                  for Large-Memory Machines
# Authors: Reto Achermann, Jayneel Gandhi, Timothy Roscoe, 
#          Abhishek Bhattacharjee, and Ashish Panwar
###############################################################################

echo "************************************************************************"
echo "ASPLOS'20 - Artifact Evaluation - Mitosis - Figure 9A"
echo "************************************************************************"

ROOT=$(dirname `readlink -f "$0"`)
#source $ROOT/site_config.sh

# List of all benchmarks to run
#BENCHMARKS="memcached xsbench graph500 hashjoin btree canneal"
#BENCHMARKS="btree hashjoin"
# BENCHMARKS="hashjoin"
BENCHMARKS="memcached"
#BENCHMARKS="canneal"
#BENCHMARKS="btree"
# BENCHMARKS="sysbench"
# List of all configs to run
#CONFIGS="F FM FA FAM I IM"
#CONFIGS="F"
#CONFIGS="FM"
#CONFIGS="I"
CONFIGS="IM"
#CONFIGS="F FM I IM"
#CONFIGS="F FM"
#CONFIGS="FM F"
#CONFIGS="I IM"

for RUNTIMES in $(seq 1) 
do
	echo "Start test round: $RUNTIMES"
	echo "Start test round: $RUNTIMES" >> /var/log/syslog 
    for bench in $BENCHMARKS; do
		for config in $CONFIGS; do
			echo "******************$bench : $config***********************"
			bash $ROOT/run_prepare_one.sh $bench $config
		done
	done
done

echo "******************ALL done : suncess!***********************"
# --- process the output logs
#$ROOT/process_logs_core.py --quiet
