#!/bin/bash
NUMBER=1nd # test times label
#CONFIG=FM_OFF # output file label
CONFIG=F_OFF # output file label
#OUTPUTPATH="./FM/" # output path
OUTPUTPATH="./F-1st/" # output path
CURR_CONFIG=m # pagetable talbe replication cache set sign
NR_PTCACHE_PAGES=131072 # ---0.5Gb per socket
SERVERADDR="localhost" # redis server address
function prepareData(){
	echo "===begin prepare data for test==="
	memtier_benchmark -p 6379 \
		-P memcache_text \
		-s $SERVERADDR \
		-t 20 \
		-c 5 \
		-n 8000000 \
		-R \
		--randomize \
		--distinct-client-seed \
		-d 24 \
		--key-maximum=800000000 \
		--key-minimum=1 \
		--ratio=1:0 \
		--key-pattern=P:P \
		--pipeline=10000 \
		--hide-histogram >> ${OUTPUTPATH}memcached_test_prepare_${CONFIG}_$(date +"%Y%m%d%H%M%S").log
	wait
	sleep 1m
	echo "===success prepare data for test==="
}

function testOne(){
	echo "===begin test for testOne==="
	memtier_benchmark -p 6379 \
		-P memcache_text \
		-s $SERVERADDR \
		-t 20 \
		-c 5 \
		--test-time=1200 \
		-R \
		--randomize \
		--distinct-client-seed \
		-d 24 \
		--key-maximum=800000000 \
		--key-minimum=1 \
		--ratio=0:1 \
		--key-pattern=R:R \
		-o ${OUTPUTPATH}memcached_test_result_RO_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log \
		--hide-histogram \
		--pipeline=10000
	wait
	sleep 1m
	echo "===RO is test end==="
}

function clearData(){
	#clean up databases
	echo "===Begin to clean databases==="
	echo "flush_all" | nc -q 2 $SERVERADDR 6379
	wait
	sleep 1s
	echo "===Databases are cleaned==="
}

function startRedis(){
	# start memcached
	sudo memcached -d -m 102400 -p 6379 -u root -t 64
	wait 
	ps auxf | grep memcached
	sleep 1s
	echo "SIGN: success start redis"
}
function startRedisWithPageReplication(){
        sudo numactl -r 0-3 memcached -d -m 102400 -p 6379 -u root -t 64
	wait 
	ps auxf | grep memcached
	sleep 1s
	echo "SIGN: success start redis server with pgreplication"
}
function stopRedis(){
	# stop redis
	sudo service memcached stop
	wait
	sleep 1s
	sudo kill -9 $(ps aux | grep 'memtier_benchmark' | grep -v grep | tr -s ' '| cut -d ' ' -f 2)
	sudo kill -9 $(ps aux | grep 'memcached' | grep -v grep | tr -s ' '| cut -d ' ' -f 2)
	sleep 1m
	#ps aux | grep memcached
	sudo service memcached status
	echo "SIGN: success stop redis"
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
function disableTHP(){
	echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled
	echo never | sudo tee /sys/kernel/mm/transparent_hugepage/defrag
	cat /sys/kernel/mm/transparent_hugepage/enabled
	cat /sys/kernel/mm/transparent_hugepage/defrag
}

function mainTest(){
	# Test three times
	for ((i=1; i<=3; i++))
	do
		NUMBER=${i}nd
		testOne
	done
	sleep 1m
}
#stopMySQL
disableAutoNUMA
disableSWAP
disableTHP
#setPagetableReplication
#startRedisWithPageReplication
#startRedis
#prepareData
#mainTest
#clearData
#stopRedis
#clearPgReplication
