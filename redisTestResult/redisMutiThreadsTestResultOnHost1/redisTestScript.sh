#!/bin/bash
NUMBER=1nd # test times label
OUTPUTPATH=./redis_test_result_by_memtier_benchmark_FM_OFF_${NUMBER}/ # output path
CONFIG=FM_OFF # output file label
CURR_CONFIG=m # pagetable talbe replication cache set sign
#NR_PTCACHE_PAGES=1100000 # --- 2GB per socket
NR_PTCACHE_PAGES=1100000 # --- 2GB per socket
SERVERADDR="localhost" # redis server address
function prepareData(){
	echo "===begin prepare data for test==="
	# 8 processes
	memtier_benchmark -s ${SERVERADDR} \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--requests 100000 \
		-p 6379 \
		--key-pattern P:P \
		--ratio=1:0 \
		--key-minimum=1 \
		--key-maximum=6800000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7003 \
		--out-file=${OUTPUTPATH}redis_prepare_${CONFIG}_P1_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--requests 100000 \
		-p 6380 \
		--key-pattern P:P \
		--ratio=1:0 \
		--key-minimum=6800000 \
		--key-maximum=12000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7004 \
		--out-file=${OUTPUTPATH}redis_prepare_${CONFIG}_P2_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--requests 100000 \
		-p 6381 \
		--key-pattern P:P \
		--ratio=1:0 \
		--key-minimum=12000000 \
		--key-maximum=18043086 \
		--key-prefix=memtier-benchmark-prefix-redistests-7005 \
		--out-file=${OUTPUTPATH}redis_prepare_${CONFIG}_P3_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--requests 100000 \
		-p 6382 \
		--key-pattern P:P \
		--ratio=1:0 \
		--key-minimum=18043086 \
		--key-maximum=36000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7006 \
		--out-file=${OUTPUTPATH}redis_prepare_${CONFIG}_P4_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--requests 100000 \
		-p 6383 \
		--key-pattern P:P \
		--ratio=1:0 \
		--key-minimum=36000000 \
		--key-maximum=56000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7007 \
		--out-file=${OUTPUTPATH}redis_prepare_${CONFIG}_P5_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--requests 100000 \
		-p 6384 \
		--key-pattern P:P \
		--ratio=1:0 \
		--key-minimum=56000000 \
		--key-maximum=72000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7008 \
		--out-file=${OUTPUTPATH}redis_prepare_${CONFIG}_P6_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--requests 100000 \
		-p 6385 \
		--key-pattern P:P \
		--ratio=1:0 \
		--key-minimum=72000000 \
		--key-maximum=84000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7009 \
		--out-file=${OUTPUTPATH}redis_prepare_${CONFIG}_P7_$(date +"%Y%m%d%H%M%S").log

#	memtier_benchmark -s ${SERVERADDR} \
#		--threads=20 \
#		--clients=5 \
#		--pipeline 1 \
#		--data-size=1024 \
#		--requests 100000 \
#		-p 6386 \
#		--key-pattern P:P \
#		--ratio=1:0 \
#		--key-minimum=84000000 \
#		--key-maximum=96000000 \
#		--key-prefix=memtier-benchmark-prefix-redistests-7010 \
#		--out-file=${OUTPUTPATH}redis_prepare_${CONFIG}_P8_$(date +"%Y%m%d%H%M%S").log
	wait
	sleep 1m
	echo "===success prepare data for test==="
}

function Gauss82(){
	echo "===begin test for Gauss82==="
	# 8 process
	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6379 \
		--key-pattern G:G \
                --ratio=2:8 \
		--key-minimum=1 \
		--key-maximum=6800000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7003 \
		--key-stddev=1133333 \
		--out-file=${OUTPUTPATH}redis_result_Gauss82_${CONFIG}_P1_${NUMBER}$(date +"%Y%m%d%H%M%S").log
	
	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6380 \
		--key-pattern G:G \
                --ratio=2:8 \
		--key-minimum=6800000 \
		--key-maximum=12000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7004 \
		--key-stddev=1133333 \
		--out-file=${OUTPUTPATH}redis_result_Gauss82_${CONFIG}_P2_${NUMBER}$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6381 \
		--key-pattern G:G \
                --ratio=2:8 \
		--key-minimum=12000000 \
		--key-maximum=18043086 \
		--key-prefix=memtier-benchmark-prefix-redistests-7005 \
		--key-stddev=1133333 \
		--out-file=${OUTPUTPATH}redis_result_Gauss82_${CONFIG}_P3_${NUMBER}$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6382 \
		--key-pattern G:G \
                --ratio=2:8 \
		--key-minimum=18043086 \
		--key-maximum=36000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7006 \
		--key-stddev=1133333 \
		--out-file=${OUTPUTPATH}redis_result_Gauss82_${CONFIG}_P4_${NUMBER}$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6383 \
		--key-pattern G:G \
                --ratio=2:8 \
		--key-minimum=36000000 \
		--key-maximum=56000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7007 \
		--key-stddev=1133333 \
		--out-file=${OUTPUTPATH}redis_result_Gauss82_${CONFIG}_P5_${NUMBER}$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6384 \
		--key-pattern G:G \
                --ratio=2:8 \
		--key-minimum=56000000 \
		--key-maximum=72000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7008 \
		--key-stddev=1133333 \
		--out-file=${OUTPUTPATH}redis_result_Gauss82_${CONFIG}_P6_${NUMBER}$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6385 \
		--key-pattern G:G \
                --ratio=2:8 \
		--key-minimum=72000000 \
		--key-maximum=84000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7009 \
		--key-stddev=1133333 \
		--out-file=${OUTPUTPATH}redis_result_Gauss82_${CONFIG}_P7_${NUMBER}$(date +"%Y%m%d%H%M%S").log

#	memtier_benchmark -s ${SERVERADDR} \
#		--test-time=50 \
#		--threads=20 \
#		--clients=5 \
#		--pipeline 1 \
#		--data-size=1024 \
#		--distinct-client-seed \
#		-p 6386 \
#		--key-pattern G:G \
#                --ratio=2:8 \
#		--key-minimum=84000000 \
#		--key-maximum=96000000 \
#		--key-prefix=memtier-benchmark-prefix-redistests-7010 \
#		--key-stddev=1133333 \
#		--out-file=${OUTPUTPATH}redis_result_Gauss82_${CONFIG}_P8_${NUMBER}$(date +"%Y%m%d%H%M%S").log
	wait
        sleep 1m
        echo "===Gauss82 is test end==="
}

function Gauss110(){
	echo "===begin test for Gauss110==="
	# 8 process
	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6379 \
		--key-pattern G:G \
		--ratio=10:1 \
		--key-minimum=1 \
		--key-maximum=6800000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7003 \
		--key-stddev=1133333 \
		--out-file=${OUTPUTPATH}redis_result_Gauss110_${CONFIG}_P1_${NUMBER}_$(date +"%Y%m%d%H%M%S").log
	
	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6380 \
		--key-pattern G:G \
		--ratio=10:1 \
		--key-minimum=6800000 \
		--key-maximum=12000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7004 \
		--key-stddev=1133333 \
		--out-file=${OUTPUTPATH}redis_result_Gauss110_${CONFIG}_P2_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6381 \
		--key-pattern G:G \
		--ratio=10:1 \
		--key-minimum=12000000 \
		--key-maximum=18043086 \
		--key-prefix=memtier-benchmark-prefix-redistests-7005 \
		--key-stddev=1133333 \
		--out-file=${OUTPUTPATH}redis_result_Gauss110_${CONFIG}_P3_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6382 \
		--key-pattern G:G \
		--ratio=10:1 \
		--key-minimum=18043086 \
		--key-maximum=36000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7006 \
		--key-stddev=1133333 \
		--out-file=${OUTPUTPATH}redis_result_Gauss110_${CONFIG}_P4_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6383 \
		--key-pattern G:G \
		--ratio=10:1 \
		--key-minimum=36000000 \
		--key-maximum=56000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7007 \
		--key-stddev=1133333 \
		--out-file=${OUTPUTPATH}redis_result_Gauss110_${CONFIG}_P5_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6384 \
		--key-pattern G:G \
		--ratio=10:1 \
		--key-minimum=56000000 \
		--key-maximum=72000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7008 \
		--key-stddev=1133333 \
		--out-file=${OUTPUTPATH}redis_result_Gauss110_${CONFIG}_P6_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6385 \
		--key-pattern G:G \
		--ratio=10:1 \
		--key-minimum=72000000 \
		--key-maximum=84000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7009 \
		--key-stddev=1133333 \
		--out-file=${OUTPUTPATH}redis_result_Gauss110_${CONFIG}_P7_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

#	memtier_benchmark -s ${SERVERADDR} \
#		--test-time=50 \
#		--threads=20 \
#		--clients=5 \
#		--pipeline 1 \
#		--data-size=1024 \
#		--distinct-client-seed \
#		-p 6386 \
#		--key-pattern G:G \
#		--ratio=10:1 \
#		--key-minimum=84000000 \
#		--key-maximum=96000000 \
#		--key-prefix=memtier-benchmark-prefix-redistests-7010 \
#		--key-stddev=1133333 \
#		--out-file=${OUTPUTPATH}redis_result_Gauss110_${CONFIG}_P8_${NUMBER}_$(date +"%Y%m%d%H%M%S").log
	wait
	sleep 1m
	echo "===Gauss110 is test end==="
}

function Random82(){
	echo "===begin test for Random82==="
	# 8 process
	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6379 \
		--key-pattern R:R \
		--ratio=2:8 \
		--key-minimum=1 \
		--key-maximum=6800000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7003 \
		--out-file=${OUTPUTPATH}redis_result_Random82_${CONFIG}_P1_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6380 \
		--key-pattern R:R \
		--ratio=2:8 \
		--key-minimum=6800000 \
		--key-maximum=12000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7004 \
		--out-file=${OUTPUTPATH}redis_result_Random82_${CONFIG}_P2_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6381 \
		--key-pattern R:R \
		--ratio=2:8 \
		--key-minimum=12000000 \
		--key-maximum=18043086 \
		--key-prefix=memtier-benchmark-prefix-redistests-7005 \
		--out-file=${OUTPUTPATH}redis_result_Random82_${CONFIG}_P3_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6382 \
		--key-pattern R:R \
		--ratio=2:8 \
		--key-minimum=18043086 \
		--key-maximum=36000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7006 \
		--out-file=${OUTPUTPATH}redis_result_Random82_${CONFIG}_P4_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6383 \
		--key-pattern R:R \
		--ratio=2:8 \
		--key-minimum=36000000 \
		--key-maximum=56000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7007 \
		--out-file=${OUTPUTPATH}redis_result_Random82_${CONFIG}_P5_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6384 \
		--key-pattern R:R \
		--ratio=2:8 \
		--key-minimum=56000000 \
		--key-maximum=72000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7008 \
		--out-file=${OUTPUTPATH}redis_result_Random82_${CONFIG}_P6_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6385 \
		--key-pattern R:R \
		--ratio=2:8 \
		--key-minimum=72000000 \
		--key-maximum=84000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7009 \
		--out-file=${OUTPUTPATH}redis_result_Random82_${CONFIG}_P7_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

#	memtier_benchmark -s ${SERVERADDR} \
#		--test-time=50 \
#		--threads=20 \
#		--clients=5 \
#		--pipeline 1 \
#		--data-size=1024 \
#		--distinct-client-seed \
#		-p 6386 \
#		--key-pattern R:R \
#		--ratio=2:8 \
#		--key-minimum=84000000 \
#		--key-maximum=96000000 \
#		--key-prefix=memtier-benchmark-prefix-redistests-7010 \
#		--out-file=${OUTPUTPATH}redis_result_Random82_${CONFIG}_P8_${NUMBER}_$(date +"%Y%m%d%H%M%S").log
	wait
	sleep 1m
	echo "===Random82 is test end==="
}
function Random110(){
	echo "===Begin test for Random110==="
	# 8 process
	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6379 \
		--key-pattern R:R \
		--ratio=10:1 \
		--key-minimum=1 \
		--key-maximum=6800000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7003 \
		--out-file=${OUTPUTPATH}redis_result_Random110_${CONFIG}_P1_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6380 \
		--key-pattern R:R \
		--ratio=10:1 \
		--key-minimum=6800000 \
		--key-maximum=12000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7004 \
		--out-file=${OUTPUTPATH}redis_result_Random110_${CONFIG}_P2_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6381 \
		--key-pattern R:R \
		--ratio=10:1 \
		--key-minimum=12000000 \
		--key-maximum=18043086 \
		--key-prefix=memtier-benchmark-prefix-redistests-7005 \
		--out-file=${OUTPUTPATH}redis_result_Random110_${CONFIG}_P3_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6382 \
		--key-pattern R:R \
		--ratio=10:1 \
		--key-minimum=18043086 \
		--key-maximum=36000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7006 \
		--out-file=${OUTPUTPATH}redis_result_Random110_${CONFIG}_P4_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6383 \
		--key-pattern R:R \
		--ratio=10:1 \
		--key-minimum=36000000 \
		--key-maximum=56000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7007 \
		--out-file=${OUTPUTPATH}redis_result_Random110_${CONFIG}_P5_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6384 \
		--key-pattern R:R \
		--ratio=10:1 \
		--key-minimum=56000000 \
		--key-maximum=72000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7008 \
		--out-file=${OUTPUTPATH}redis_result_Random110_${CONFIG}_P6_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6385 \
		--key-pattern R:R \
		--ratio=10:1 \
		--key-minimum=72000000 \
		--key-maximum=84000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7009 \
		--out-file=${OUTPUTPATH}redis_result_Random110_${CONFIG}_P7_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

#	memtier_benchmark -s ${SERVERADDR} \
#		--test-time=50 \
#		--threads=20 \
#		--clients=5 \
#		--pipeline 1 \
#		--data-size=1024 \
#		--distinct-client-seed \
#		-p 6386 \
#		--key-pattern R:R \
#		--ratio=10:1 \
#		--key-minimum=84000000 \
#		--key-maximum=96000000 \
#		--key-prefix=memtier-benchmark-prefix-redistests-7010 \
#		--out-file=${OUTPUTPATH}redis_result_Random110_${CONFIG}_P8_${NUMBER}_$(date +"%Y%m%d%H%M%S").log
	wait
	sleep 1m
	echo "===Random110 is test end==="
}
function Sequential82(){
	echo "===Begin test for Sequential82==="
	# 8 process
	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6379 \
		--key-pattern S:S \
		--ratio=2:8 \
		--key-minimum=1 \
		--key-maximum=6800000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7003 \
		--out-file=${OUTPUTPATH}redis_result_Sequential82_${CONFIG}_P1_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6380 \
		--key-pattern S:S \
		--ratio=2:8 \
		--key-minimum=6800000 \
		--key-maximum=12000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7004 \
		--out-file=${OUTPUTPATH}redis_result_Sequential82_${CONFIG}_P2_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6381 \
		--key-pattern S:S \
		--ratio=2:8 \
		--key-minimum=12000000 \
		--key-maximum=18043086 \
		--key-prefix=memtier-benchmark-prefix-redistests-7005 \
		--out-file=${OUTPUTPATH}redis_result_Sequential82_${CONFIG}_P3_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6382 \
		--key-pattern S:S \
		--ratio=2:8 \
		--key-minimum=18043086 \
		--key-maximum=36000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7006 \
		--out-file=${OUTPUTPATH}redis_result_Sequential82_${CONFIG}_P4_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6383 \
		--key-pattern S:S \
		--ratio=2:8 \
		--key-minimum=36000000 \
		--key-maximum=56000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7007 \
		--out-file=${OUTPUTPATH}redis_result_Sequential82_${CONFIG}_P5_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6384 \
		--key-pattern S:S \
		--ratio=2:8 \
		--key-minimum=56000000 \
		--key-maximum=72000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7008 \
		--out-file=${OUTPUTPATH}redis_result_Sequential82_${CONFIG}_P6_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6385 \
		--key-pattern S:S \
		--ratio=2:8 \
		--key-minimum=72000000 \
		--key-maximum=84000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7009 \
		--out-file=${OUTPUTPATH}redis_result_Sequential82_${CONFIG}_P7_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

#	memtier_benchmark -s ${SERVERADDR} \
#		--test-time=50 \
#		--threads=20 \
#		--clients=5 \
#		--pipeline 1 \
#		--data-size=1024 \
#		--distinct-client-seed \
#		-p 6386 \
#		--key-pattern S:S \
#		--ratio=2:8 \
#		--key-minimum=84000000 \
#		--key-maximum=96000000 \
#		--key-prefix=memtier-benchmark-prefix-redistests-7010 \
#		--out-file=${OUTPUTPATH}redis_result_Sequential82_${CONFIG}_P8_${NUMBER}_$(date +"%Y%m%d%H%M%S").log
	wait
	sleep 1m
	echo "===Sequential82 is test end==="
}
function Sequential110(){
	echo "===Bengin test for Sequential110==="
	# 8 process
	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6379 \
		--key-pattern S:S \
		--ratio=10:1 \
		--key-minimum=1 \
		--key-maximum=6800000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7003 \
		--out-file=${OUTPUTPATH}redis_result_Sequential110_${CONFIG}_P1_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6380 \
		--key-pattern S:S \
		--ratio=10:1 \
		--key-minimum=6800000 \
		--key-maximum=12000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7004 \
		--out-file=${OUTPUTPATH}redis_result_Sequential110_${CONFIG}_P2_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6381 \
		--key-pattern S:S \
		--ratio=10:1 \
		--key-minimum=12000000 \
		--key-maximum=18043086 \
		--key-prefix=memtier-benchmark-prefix-redistests-7005 \
		--out-file=${OUTPUTPATH}redis_result_Sequential110_${CONFIG}_P3_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6382 \
		--key-pattern S:S \
		--ratio=10:1 \
		--key-minimum=18043086 \
		--key-maximum=36000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7006 \
		--out-file=${OUTPUTPATH}redis_result_Sequential110_${CONFIG}_P4_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6383 \
		--key-pattern S:S \
		--ratio=10:1 \
		--key-minimum=36000000 \
		--key-maximum=56000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7007 \
		--out-file=${OUTPUTPATH}redis_result_Sequential110_${CONFIG}_P5_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6384 \
		--key-pattern S:S \
		--ratio=10:1 \
		--key-minimum=56000000 \
		--key-maximum=72000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7008 \
		--out-file=${OUTPUTPATH}redis_result_Sequential110_${CONFIG}_P6_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=50 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6385 \
		--key-pattern S:S \
		--ratio=10:1 \
		--key-minimum=72000000 \
		--key-maximum=84000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-7009 \
		--out-file=${OUTPUTPATH}redis_result_Sequential110_${CONFIG}_P7_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

#	memtier_benchmark -s ${SERVERADDR} \
#		--test-time=50 \
#		--threads=20 \
#		--clients=5 \
#		--pipeline 1 \
#		--data-size=1024 \
#		--distinct-client-seed \
#		-p 6386 \
#		--key-pattern S:S \
#		--ratio=10:1 \
#		--key-minimum=84000000 \
#		--key-maximum=96000000 \
#		--key-prefix=memtier-benchmark-prefix-redistests-7010 \
#		--out-file=${OUTPUTPATH}redis_result_Sequential110_${CONFIG}_P8_${NUMBER}_$(date +"%Y%m%d%H%M%S").log
	wait
	sleep 1m
	echo "===Sequential110 is test end==="
}
function clearData(){
        #clean up databases
        echo "===Begin to clean databases==="
        redis-cli -h $SERVERADDR -p 6379 flushall
        redis-cli -h $SERVERADDR -p 6380 flushall
        redis-cli -h $SERVERADDR -p 6381 flushall
        redis-cli -h $SERVERADDR -p 6382 flushall
        redis-cli -h $SERVERADDR -p 6383 flushall
        redis-cli -h $SERVERADDR -p 6384 flushall
        redis-cli -h $SERVERADDR -p 6385 flushall
        #redis-cli -h $SERVERADDR -p 6386 flushall
        wait
        sleep 5s
        echo "===Databases are cleaned==="
}

function startRedis(){
	# start redis
	sudo /etc/init.d/redis-server start
	sudo redis-server /etc/redis/redis6380.conf
	sudo redis-server /etc/redis/redis6381.conf
	sudo redis-server /etc/redis/redis6382.conf
	sudo redis-server /etc/redis/redis6383.conf
	sudo redis-server /etc/redis/redis6384.conf
	sudo redis-server /etc/redis/redis6385.conf
	#sudo redis-server /etc/redis/redis6386.conf
	wait 
	ps auxf | grep redis-server
	sleep 5s
	echo "SIGN: success start redis"
}
function startRedisWithPageReplication(){
	sudo numactl -r 0-3 /etc/init.d/redis-server start
        sudo numactl -r 0-3 redis-server /etc/redis/redis6380.conf
        sudo numactl -r 0-3 redis-server /etc/redis/redis6381.conf
        sudo numactl -r 0-3 redis-server /etc/redis/redis6382.conf
        sudo numactl -r 0-3 redis-server /etc/redis/redis6383.conf
        sudo numactl -r 0-3 redis-server /etc/redis/redis6384.conf
        sudo numactl -r 0-3 redis-server /etc/redis/redis6385.conf
        #sudo numactl -r 0-3 redis-server /etc/redis/redis6386.conf
	wait 
	ps auxf | grep redis-server
	sleep 5s
	echo "SIGN: success start redis server with pgreplication"
}
function stopRedis(){
	# stop redis
	#sudo redis-cli -p 6386 shutdown
	sudo redis-cli -p 6385 shutdown
	sudo redis-cli -p 6384 shutdown
	sudo redis-cli -p 6383 shutdown
	sudo redis-cli -p 6382 shutdown
	sudo redis-cli -p 6381 shutdown
	sudo redis-cli -p 6380 shutdown
	sudo sudo /etc/init.d/redis-server stop
	wait 
	ps auxf | grep redis-server
	sleep 5s
	echo "SIGN: success stop redis"
}
function stopMySQL(){
	sudo service mysql stop
	sleep 1s
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
	sleep 5s
	echo "SIGN:success disable Auto NUMA"
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
		sleep 5s
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
		sleep 5s
		echo "SIGN: success set pgtable replication strategy default, and set pgtable cache size zero"
        fi

}
function mainTest(){
	# Test three times
	for ((i=1; i<=3; i++))
	do
		NUMBER=${i}nd
		OUTPUTPATH=./redis_test_result_by_memtier_benchmark_FM_OFF_${NUMBER}/ # output path
		Gauss82
	done

	for ((i=1; i<=3; i++))
        do
                NUMBER=${i}nd
		OUTPUTPATH=./redis_test_result_by_memtier_benchmark_FM_OFF_${NUMBER}/ # output path
		Gauss110
        done

#	for ((i=1; i<=3; i++))
#        do
#                NUMBER=${i}nd
#		OUTPUTPATH=./redis_test_result_by_memtier_benchmark_FM_OFF_${NUMBER}/ # output path
#		Random82
#        done
#
#	for ((i=1; i<=3; i++))
#        do
#                NUMBER=${i}nd
#		OUTPUTPATH=./redis_test_result_by_memtier_benchmark_FM_OFF_${NUMBER}/ # output path
#                Random110
#        done
#
#	for ((i=1; i<=3; i++))
#        do
#                NUMBER=${i}nd
#		OUTPUTPATH=./redis_test_result_by_memtier_benchmark_FM_OFF_${NUMBER}/ # output path
#		Sequential82
#        done
#
#	for ((i=1; i<=3; i++))
#        do
#                NUMBER=${i}nd
#		OUTPUTPATH=./redis_test_result_by_memtier_benchmark_FM_OFF_${NUMBER}/ # output path
#		Sequential110
#        done
}
#stopMySQL
#disableAutoNUMA
#setPagetableReplication
#startRedisWithPageReplication
startRedis
#prepareData
#mainTest
#clearData
#stopRedis
