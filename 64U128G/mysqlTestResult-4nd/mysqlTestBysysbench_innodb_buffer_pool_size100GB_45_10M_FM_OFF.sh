#!/bin/bash
NUMBER=1nd
CONFIG=45_10M_FM_OFF
INNODB_BUFFER_SIZE=100GB
# OUTPUTPATH=./mysqlTestBysysbench_innodb_buffer_pool_size${INNODB_BUFFER_SIZE}_${CONFIG}_${NUMBER}/
OUTPUTPATH=./FM/
#MYSQLADDR="192.168.1.182"
MYSQLADDR="localhost"
function preparedata(){
	echo "SIGN: prepare data=="
	sysbench /usr/share/sysbench/oltp_write_only.lua \
		--mysql-host=${MYSQLADDR} \
		--mysql-port=3306 \
		--mysql-user=root \
		--mysql-password=123456 \
		--mysql-db=testdb \
		--db-driver=mysql \
		--tables=45 \
		--table_size=10000000 \
		--report-interval=3 \
		--threads=64 prepare >> "${OUTPUTPATH}mysql_test_prepare_innodbBufferSize${INNODB_BUFFER_SIZE}_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log"
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
	sysbench /usr/share/sysbench/oltp_read_only.lua \
		--mysql-host=${MYSQLADDR} \
		--mysql-port=3306 \
		--mysql-user=root \
		--mysql-password=123456 \
		--mysql-db=testdb \
		--db-driver=mysql \
		--tables=45 \
		--table_size=10000000 \
		--report-interval=3 \
		--threads=200 \
		--time=3600 run >> "${OUTPUTPATH}mysql_test_result_ro_innodbBufferSize${INNODB_BUFFER_SIZE}_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log"
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
	
	sudo ./monitor_all.sh &
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
#disableSWAP
#disableAutoNUMA
#preparedata
#testOne
alltest
#cleardata
