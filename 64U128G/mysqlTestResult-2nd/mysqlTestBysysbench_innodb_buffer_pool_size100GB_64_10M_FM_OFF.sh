#!/bin/bash
NUMBER=1nd
CONFIG=64_10M_F_OFF
INNODB_BUFFER_SIZE=100GB
# OUTPUTPATH=./mysqlTestBysysbench_innodb_buffer_pool_size${INNODB_BUFFER_SIZE}_${CONFIG}_${NUMBER}/
OUTPUTPATH=./
MYSQLADDR="192.168.1.182"
function preparedata(){
	echo "SIGN: prepare data=="
	sysbench /home/liujianguo/Download/sysbench-1.0.11/tests/include/oltp_legacy/oltp.lua \
		--threads=400 \
		--max-requests=0 \
		--oltp-table-size=10000000 \
		--oltp-tables-count=45 \
		--mysql-db=testdb \
		--db-driver=mysql \
		--mysql-table-engine=innodb \
		--mysql-host=${MYSQLADDR} \
		--mysql-port=3306 \
		--mysql-user=root \
		--mysql-password=123456 \
		--report-interval=3 prepare >> "mysql_test_result_innodbBufferSize${INNODB_BUFFER_SIZE}_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log"
        wait
        sleep 1m
	echo "SIGN:data ready"
}

function cleardata(){
	echo "==SIGN: start cleardata=="
	sysbench /home/liujianguo/Download/sysbench-1.0.11/tests/include/oltp_legacy/oltp.lua \
                --mysql-host=${MYSQLADDR} \
                --oltp-tables-count=45 \
                --mysql-user=root \
                --mysql-password=123456 \
                --mysql-port=3306 \
                --db-driver=mysql \
                --oltp-table-size=10000000 \
                --mysql-db=testdb cleanup
	echo "==SIGN: successful cleardata=="
}
function testOne(){
	echo "SIGN: stat one test."
	sysbench /home/liujianguo/Download/sysbench-1.0.11/tests/include/oltp_legacy/oltp.lua \
		--mysql-host=${MYSQLADDR} \
		--oltp-tables-count=45 \
		--mysql-user=root \
		--mysql-password=123456 \
		--mysql-port=3306 \
		--db-driver=mysql \
		--oltp-table-size=10000000 \
		--mysql-db=testdb \
		--max-requests=0 \
		--oltp-simple-ranges=0 \
		--oltp-distinct-ranges=0 \
		--oltp-sum-ranges=0 \
		--oltp-order-ranges=0 \
		--max-time=3600 \
		--oltp-read-only=on \
		--threads=400 \
		--report-interval=3 \
		--thread-init-timeout=300 \
		--forced-shutdown=1 run >> "${OUTPUTPATH}mysql_test_result_ro_innodbBufferSize${INNODB_BUFFER_SIZE}_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log"
	wait
	sleep 1m
	echo "SIGN: test one end."

}
function disableSWAP(){
	sudo swapoff -a
	wait
	echo "SIGN: success disable swap."
}
function stopMYSQLandRedis(){
	sudo service mysql stop
	sudo service redis stop
	sudo kill -9 $(ps aux | grep 'redis' | grep -v grep | tr -s ' '| cut -d ' ' -f 2)
	sudo service mysql status
	sudo service redis status
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

#three times test
function alltest(){
	start_time=$(date +%s)  # script start run time
	
	#rw test
	for ((i=1; i<=3; i++))
        do
                NUMBER=${i}nd
		testOne
        done

	end_time=$(date +%s)  # scrip stop run time,(s).
	# calculate script run time,(s).
	duration=$((end_time - start_time))
	echo "Script run time is: $duration (s)"
}
#stopMYSQLandRedis
disableSWAP
disableAutoNUMA
#preparedata
#testOne
#alltest
#cleardata
