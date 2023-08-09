#!/bin/bash
NUMBER=1nd # test times label
CONFIG=F_OFF # output file label
OUTPUTPATH="./F-2nd/" # output path
NR_PTCACHE_PAGES=262144 # ---1Gb per socket

SERVERADDR="192.168.1.178" # redis server address
function prepareData(){
	echo "===begin prepare data for test==="
	sudo numactl -C 8-15 -l memtier_benchmark -s $SERVERADDR -P memcache_text --threads=20 --clients=5 --pipeline 1 --data-size=1024 --requests 100000 -p 7000 --key-pattern P:P --ratio=1:0 --key-minimum=1 --key-maximum=7200000 --key-prefix=memtier-benchmark-prefix-memcachedtests-7000 --out-file=${OUTPUTPATH}memcached_test_prepare_P1_${CONFIG}_$(date +"%Y%m%d%H%M%S").log &
	
	sudo numactl -C 16-23 -l memtier_benchmark -s $SERVERADDR -P memcache_text --threads=20 --clients=5 --pipeline 1 --data-size=1024 --requests 100000 -p 7001 --key-pattern P:P --ratio=1:0 --key-minimum=7200000 --key-maximum=16000000 --key-prefix=memtier-benchmark-prefix-memcachedtests-7001 --out-file=${OUTPUTPATH}memcached_test_prepare_P2_${CONFIG}_$(date +"%Y%m%d%H%M%S").log &
	
	sudo numactl -C 32-39 -l memtier_benchmark -s $SERVERADDR -P memcache_text --threads=20 --clients=5 --pipeline 1 --data-size=1024 --requests 100000 -p 7002 --key-pattern P:P --ratio=1:0 --key-minimum=16000000 --key-maximum=2200000 --key-prefix=memtier-benchmark-prefix-memcachedtests-7002 --out-file=${OUTPUTPATH}memcached_test_prepare_P3_${CONFIG}_$(date +"%Y%m%d%H%M%S").log &

	sudo numactl -C 40-47 -l memtier_benchmark -s $SERVERADDR -P memcache_text --threads=20 --clients=5 --pipeline 1 --data-size=1024 --requests 100000 -p 7011 --key-pattern P:P --ratio=1:0 --key-minimum=2200000 --key-maximum=39000000 --key-prefix=memtier-benchmark-prefix-memcachedtests-7011 --out-file=${OUTPUTPATH}memcached_test_prepare_P4_${CONFIG}_$(date +"%Y%m%d%H%M%S").log &
	
	sudo numactl -C 56-63 -l memtier_benchmark -s $SERVERADDR -P memcache_text --threads=20 --clients=5 --pipeline 1 --data-size=1024 --requests 100000 -p 7012 --key-pattern P:P --ratio=1:0 --key-minimum=39000000 --key-maximum=58000000 --key-prefix=memtier-benchmark-prefix-memcachedtests-7012 --out-file=${OUTPUTPATH}memcached_test_prepare_P5_${CONFIG}_$(date +"%Y%m%d%H%M%S").log &

	sudo numactl -C 64-71 -l memtier_benchmark -s $SERVERADDR -P memcache_text --threads=20 --clients=5 --pipeline 1 --data-size=1024 --requests 100000 -p 7013 --key-pattern P:P --ratio=1:0 --key-minimum=58000000 --key-maximum=76000000 --key-prefix=memtier-benchmark-prefix-memcachedtests-7013 --out-file=${OUTPUTPATH}memcached_test_prepare_P6_${CONFIG}_$(date +"%Y%m%d%H%M%S").log &
	
	sudo numactl -C 80-87 -l memtier_benchmark -s $SERVERADDR -P memcache_text --threads=20 --clients=5 --pipeline 1 --data-size=1024 --requests 100000 -p 7014 --key-pattern P:P --ratio=1:0 --key-minimum=76000000 --key-maximum=88000000 --key-prefix=memtier-benchmark-prefix-memcachedtests-7014 --out-file=${OUTPUTPATH}memcached_test_prepare_P7_${CONFIG}_$(date +"%Y%m%d%H%M%S").log &
	
	sudo numactl -C 88-95 -l memtier_benchmark -s $SERVERADDR -P memcache_text --threads=20 --clients=5 --pipeline 1 --data-size=1024 --requests 100000 -p 7015 --key-pattern P:P --ratio=1:0 --key-minimum=88000000 --key-maximum=99000000 --key-prefix=memtier-benchmark-prefix-memcachedtests-7015 --out-file=${OUTPUTPATH}memcached_test_prepare_P8_${CONFIG}_$(date +"%Y%m%d%H%M%S").log &
	wait
	sleep 1m
	echo "===success prepare data for test==="
}

function testOne(){
	echo "===begin test for testOne==="
	sudo numactl -C 8-15 -l memtier_benchmark -s $SERVERADDR --test-time=1200 -P memcache_text --threads=20 --clients=5 --pipeline 1 --data-size=1024 --distinct-client-seed -p 7000 --key-pattern G:G --ratio=2:8 --key-minimum=1 --key-maximum=7200000 --key-prefix=memtier-benchmark-prefix-memcachedtests-7000 --key-stddev=1200000 --out-file=${OUTPUTPATH}memcached_test_result_P1_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log &

	sudo numactl -C 16-23 -l memtier_benchmark -s $SERVERADDR --test-time=1200 -P memcache_text --threads=20 --clients=5 --pipeline 1 --data-size=1024 --distinct-client-seed -p 7001 --key-pattern G:G --ratio=2:8 --key-minimum=7200000 --key-maximum=16000000 --key-prefix=memtier-benchmark-prefix-memcachedtests-7001 --key-stddev=1200000 --out-file=${OUTPUTPATH}memcached_test_result_P2_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log &

	sudo numactl -C 32-39 -l memtier_benchmark -s $SERVERADDR --test-time=1200 -P memcache_text --threads=20 --clients=5 --pipeline 1 --data-size=1024 --distinct-client-seed -p 7002 --key-pattern G:G --ratio=2:8 --key-minimum=16000000 --key-maximum=22000000 --key-prefix=memtier-benchmark-prefix-memcachedtests-7002 --key-stddev=1200000 --out-file=${OUTPUTPATH}memcached_test_result_P3_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log &

	sudo numactl -C 40-47 -l memtier_benchmark -s $SERVERADDR --test-time=1200 -P memcache_text --threads=20 --clients=5 --pipeline 1 --data-size=1024 --distinct-client-seed -p 7011 --key-pattern G:G --ratio=2:8 --key-minimum=22000000 --key-maximum=39000000 --key-prefix=memtier-benchmark-prefix-memcachedtests-7011 --key-stddev=1200000 --out-file=${OUTPUTPATH}memcached_test_result_P4_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log &

	sudo numactl -C 56-63 -l memtier_benchmark -s $SERVERADDR --test-time=1200 -P memcache_text --threads=20 --clients=5 --pipeline 1 --data-size=1024 --distinct-client-seed -p 7012 --key-pattern G:G --ratio=2:8 --key-minimum=39000000 --key-maximum=58000000 --key-prefix=memtier-benchmark-prefix-memcachedtests-7012 --key-stddev=1200000 --out-file=${OUTPUTPATH}memcached_test_result_P5_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log &

	sudo numactl -C 64-71 -l memtier_benchmark -s $SERVERADDR --test-time=1200 -P memcache_text --threads=20 --clients=5 --pipeline 1 --data-size=1024 --distinct-client-seed -p 7013 --key-pattern G:G --ratio=2:8 --key-minimum=58000000 --key-maximum=76000000 --key-prefix=memtier-benchmark-prefix-memcachedtests-7013 --key-stddev=1200000 --out-file=${OUTPUTPATH}memcached_test_result_P6_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log &

	sudo numactl -C 80-87 -l memtier_benchmark -s $SERVERADDR --test-time=1200 -P memcache_text --threads=20 --clients=5 --pipeline 1 --data-size=1024 --distinct-client-seed -p 7014 --key-pattern G:G --ratio=2:8 --key-minimum=76000000 --key-maximum=88000000 --key-prefix=memtier-benchmark-prefix-memcachedtests-7014 --key-stddev=1200000 --out-file=${OUTPUTPATH}memcached_test_result_P7_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log &

	sudo numactl -C 88-95 -l memtier_benchmark -s $SERVERADDR --test-time=1200 -P memcache_text --threads=20 --clients=5 --pipeline 1 --data-size=1024 --distinct-client-seed -p 7015 --key-pattern G:G --ratio=2:8 --key-minimum=88000000 --key-maximum=99000000 --key-prefix=memtier-benchmark-prefix-memcachedtests-7015 --key-stddev=1200000 --out-file=${OUTPUTPATH}memcached_test_result_P8_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log &
	wait
	sleep 1m
	echo "===Gauss82 is test end==="
}

function clearData(){
	#clean up databases
	echo "===Begin to clean databases==="
	echo "flush_all" | nc -q 2 $SERVERADDR 6379
	wait
	sleep 1s
	echo "===Databases are cleaned==="
}

function stopMySQL(){
        sudo service mysql stop
        sleep 1s
	sudo service mysql status
        echo "SIGN: success stop mysql"
}
function disableAutoNUMA(){
	# disable auto numa
	echo 0 | sudo tee /proc/sys/kernel/numa_balancing > /dev/null
	if [ $? -ne 0 ]; then
		echo "ERROR setting AutoNUMA to: 0"
                exit
        fi
	wait
	cat /proc/sys/kernel/numa_balancing
	sleep 1s
	echo "SIGN:success disable Auto NUMA"
}
function disableSWAP(){
	sudo swapoff -a
	sleep 1s
	echo "SIGN: success disable SWAP"
}
function setPagetableReplication(){
        #CURR_CONFIG=m
        FIRST_CHAR=${CURR_CONFIG:0:1}
        # --- check page table replication
        LAST_CHAR="${CURR_CONFIG: -1}"
        if [ $FIRST_CHAR == "m" ]; then
                echo 0 | sudo tee /proc/sys/kernel/pgtable_replication > /dev/null
                if [ $? -ne 0 ]; then
                        echo "ERROR setting pgtable_replication to $0"
                        exit
                fi
                # --- drain first then reserve
                echo -1 | sudo tee /proc/sys/kernel/pgtable_replication_cache > /dev/null
                if [ $? -ne 0 ]; then
                        echo "ERROR setting pgtable_replication_cache to $0"
                        exit
                fi
                echo $NR_PTCACHE_PAGES | sudo tee /proc/sys/kernel/pgtable_replication_cache > /dev/null
                if [ $? -ne 0 ]; then
                        echo "ERROR setting pgtable_replication_cache to $NR_PTCACHE_PAGES"
                        exit
                fi
		wait
		sleep 1s
		echo "SIGN: success set pagetable cache $NR_PTCACHE_PAGES"
        else
		#CMD_PREFIX+=" --pgtablerepl=$NODE_MAX "
                # --- enable default page table allocation
                echo -1 | sudo tee /proc/sys/kernel/pgtable_replication > /dev/null
                if [ $? -ne 0 ]; then
                        echo "ERROR setting pgtable_replication to -1"
                        exit
                fi
                # --- drain page table cache
                echo -1 | sudo tee /proc/sys/kernel/pgtable_replication_cache > /dev/null
                if [ $? -ne 0 ]; then
                        echo "ERROR setting pgtable_replication to 0"
                        exit
                fi
		wait
		sleep 1s
		echo "SIGN: success set pgtable replication strategy default, and set pgtable cache size zero"
        fi

}

function clearPgReplication(){
        echo -1 | sudo tee /proc/sys/kernel/pgtable_replication > /dev/null
        if [ $? -ne 0 ]; then
                echo "ERROR setting pgtable_replication to -1"
                exit
        fi
        # --- drain page table cache
        echo -1 | sudo tee /proc/sys/kernel/pgtable_replication_cache > /dev/null
        if [ $? -ne 0 ]; then
                echo "ERROR setting pgtable_replication to 0"
                exit
        fi
        wait
        sleep 1s
        echo "SIGN: success set pgtable replication strategy default, and set pgtable cache size zero"
}

function mainTest(){
	# Test three times
	for ((i=1; i<=2; i++))
	do
		NUMBER=${i}nd
		testOne
	done
}
#stopMySQL
#disableAutoNUMA
#disableSWAP
#setPagetableReplication
prepareData
mainTest
#testOne
#clearData
#clearPgReplication
