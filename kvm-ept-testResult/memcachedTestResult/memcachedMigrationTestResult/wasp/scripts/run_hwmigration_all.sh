#!/bin/bash

echo "**************************"
echo "***pgtablre test***"
echo "**************************"

ROOT=$(dirname `readlink -f "$0"`)

# BENCHMARKS="memcache redi kdb"
BENCHMARKS="memcache"
# BENCHMARKS="redi"
#BENCHMARKS="kdb"
# BENCHMARKS="my"
# CONFIGS="FM F I IM"
#CONFIGS="F FM"
# CONFIGS="I IM"
#CONFIGS="F"
#CONFIGS="F I"
#CONFIGS="LPLD RPILD RPILDM" # It's very useful, save time.
CONFIGS="RPILD" # It's very useful, save time.
#CONFIGS="RPILDM" # It's very useful, save time.
#CONFIGS="LPLD RPILD RPILDM RPLD RPLDM"
#CONFIGS="RPILD RPILDM"
# CONFIGS="LPLD RPLD RPLDM"
#CONFIGS="LPLD LPLDM"
#CONFIGS="LPLD"
#CONFIGS="RPILD"
# CONFIGS="RPILDM"
# CONFIGS="LPLD RPILD"
function disableTHP(){
        echo "current thp config:"
        cat /sys/kernel/mm/transparent_hugepage/enabled

        sudo echo never > /sys/kernel/mm/transparent_hugepage/enabled

        echo "success set /sys/kernel/mm/transparent_hugepage/enabled never"
        cat /sys/kernel/mm/transparent_hugepage/enabled
}
function disableAutoNUMA(){
        # disable auto numa
        echo 0 | sudo tee /proc/sys/kernel/numa_balancing > /dev/null
        if [ $? -ne 0 ]; then
                echo "ERROR setting AutoNUMA to: 0"
                exit
        fi
        echo "SIGN:success disable Auto NUMA"
}
disableAutoNUMA
disableTHP
sudo swapoff -a # disable swap

for round in $(seq 1 3)
#for round in $(seq 1)
do
	echo "$BENCHMARKS run round $round......"
	for bench in $BENCHMARKS; do
		for config in $CONFIGS; do
			echo "***************$bench : $config***************"
			# bash $ROOT/run_hwmigration_one.sh $bench-$config-$round 800000000 24 $config $bench
			# bash $ROOT/run_hwmigration_one.sh $bench-$config-$round 80000000 1024 $config $bench

			#redis
			# bash $ROOT/run_hwmigration_one.sh $bench-$config-$round 160000000 64 $config $bench 900
			bash $ROOT/run_hwmigration_one.sh $bench-$config-$round 240000000 24 $config $bench 900
		done
	done
done

echo "**************************"
echo "*** test  end ***"
echo "**************************"
