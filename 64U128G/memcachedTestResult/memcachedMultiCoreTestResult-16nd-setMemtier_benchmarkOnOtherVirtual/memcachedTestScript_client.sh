#!/bin/bash
NUMBER=1nd # test times label
CONFIG=F_OFF # output file label
OUTPUTPATH="./F-1st/" # output path
CURR_CONFIG=m # pagetable talbe replication cache set sign
NR_PTCACHE_PAGES=131072 # ---1Gb per socket
SERVERADDR="192.168.1.182" # redis server address
function prepareData(){
	echo "===begin prepare data for test==="
	sudo memtier_benchmark -p 6379 \
		-s $SERVERADDR \
		-P memcache_text \
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
	sudo memtier_benchmark -p 6379 \
		-s $SERVERADDR \
		-P memcache_text \
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
		-o ${OUTPUTPATH}memcached_test_result_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log \
		--hide-histogram \
		--pipeline=10000
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

function stopRedis(){
	# stop redis
	sudo service memcached stop
	wait
	sleep 1s

	sudo kill -9 $(ps aux | grep 'memtier_benchmark' | grep -v grep | tr -s ' '| cut -d ' ' -f 2)
	#sudo kill -9 $(ps aux | grep 'redis' | grep -v grep | tr -s ' '| cut -d ' ' -f 2)
	#sudo kill -9 $(ps aux | grep 'memcached' | grep -v grep | tr -s ' '| cut -d ' ' -f 2)
	#sudo kill -9 $(ps aux | grep 'keydb' | grep -v grep | tr -s ' '| cut -d ' ' -f 2)
	sleep 1s

	ps aux | grep memcached
	#sudo service memcached status
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

function mainTest(){
	# Test three times
	for ((i=1; i<=2; i++))
	do
		NUMBER=${i}nd
		testOne
	done
}
#stopMySQL
disableAutoNUMA
disableSWAP
prepareData
mainTest
#testOne
#clearData
#stopRedis
