#!/bin/bash
NUMBER=1nd
CONFIG=40_10M_F_OFF
INNODB_BUFFER_SIZE=90GB
OUTPUTPATH=./mysqlTestBysysbench_innodb_buffer_pool_size${INNODB_BUFFER_SIZE}_${CONFIG}_${NUMBER}/
MYSQLADDR="192.168.1.178"
function preparedata(){
	echo "==Prepare data=="
	sysbench --threads=200 \
		--max-requests=0 \
		--test=/home/liujianguo/Download/sysbench-1.0.11/tests/include/oltp_legacy/oltp.lua \
		--oltp-table-size=10000000 \
		--oltp-tables-count=40 \
		--mysql-db=testdb \
		--db-driver=mysql \
		--mysql-table-engine=innodb \
		--mysql-host=${MYSQLADDR} \
		--mysql-port=3306 \
		--mysql-user=root \
		--mysql-password=123456 \
		--report-interval=3 prepare >> "${OUTPUTPATH}mysysbench_prepare_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log"
        wait
        sleep 1m
}

function cleardata(){
	echo "==cleanup sysbench testdb of RW=="
	sysbench --threads=400 \
		--max-requests=0 \
		-oltp-table-size=10000000 \
		--oltp-tables-count=40 \
		--mysql-db=testdb \
		--db-driver=mysql \
		--mysql-table-engine=innodb \
                --mysql-host=${MYSQLADDR} \
                --mysql-port=3306 \
                --mysql-user=root \
                --mysql-password=123456 \
                --report-interval=3 cleanup
       wait
       sleep 1m
}

function rwtest(){
	echo "==run sysbench for RW=="
	echo "Start time is: $(date '+%c')"
	sysbench --threads=400 \
		--max-time=900 \
		--max-requests=0 \
		--test=/home/liujianguo/Download/sysbench-1.0.11/tests/include/oltp_legacy/oltp.lua \
		--mysql-db=testdb \
		--oltp-table-size=10000000 \
		--oltp-tables-count=40 \
		--db-driver=mysql \
		--mysql-host=${MYSQLADDR} \
		--mysql-port=3306 \
		--mysql-user=root \
		--mysql-password=123456 \
		--report-interval=3 \
		--thread-init-timeout=300 \
		--forced-shutdown=1 run >> "${OUTPUTPATH}mysysbench_rw_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log"
	echo "End time is: $(date '+%c')"
	wait
	sleep 1m
}

function rotest(){
	echo "==run sysbench test for RO=="
	echo "Start time is: $(date '+%c')"
	sysbench --test=/home/liujianguo/Download/sysbench-1.0.11/tests/include/oltp_legacy/oltp.lua \
		--mysql-host=${MYSQLADDR} \
		--oltp-tables-count=35 \
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
		--max-time=900 \
		--oltp-read-only=on \
		--threads=200 \
		--report-interval=3 \
		--thread-init-timeout=300 \
		--forced-shutdown=1 run >> "${OUTPUTPATH}mysysbench_ro_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log"
	echo "End time is: $(date '+%c')"
	wait
	sleep 1m
}
function rotest2(){
        echo "==run sysbench test for RO=="
        echo "Start time is: $(date '+%c')"
        sysbench --test=/home/liujianguo/Download/sysbench-1.0.11/tests/include/oltp_legacy/oltp.lua \
                --mysql-host=${MYSQLADDR} \
                --oltp-tables-count=35 \
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
                --max-time=1800 \
                --oltp-read-only=on \
                --threads=200 \
                --report-interval=3 \
                --thread-init-timeout=300 \
                --forced-shutdown=1 run >> "${OUTPUTPATH}mysysbench_ro_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log"
        echo "End time is: $(date '+%c')"
        wait
        sleep 1m
}

function wotest(){
	echo "== run sysbench for WO=="
	echo "Start time is: $(date '+%c')"
	sysbench --test=/home/liujianguo/Download/sysbench-1.0.11/tests/include/oltp_legacy/oltp.lua \
		--mysql-host=${MYSQLADDR} \
		--oltp-tables-count=40 \
		--mysql-user=root \
		--mysql-password=123456 \
		--mysql-port=3306 \
		--db-driver=mysql \
		--oltp-table-size=10000000 \
		--mysql-db=testdb \
		--max-requests=0 \
		--max-time=900 \
		--oltp-simple-ranges=0 \
		--oltp-distinct-ranges=0 \
		--oltp-sum-ranges=0 \
		--oltp-order-ranges=0 \
		--oltp-point-selects=0 \
		--threads=400 \
		--randtype=uniform \
		--report-interval=3 \
		--thread-init-timeout=300 \
		--forced-shutdown=1 run >> "${OUTPUTPATH}mysysbench_wo_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log"
	echo "End time is: $(date '+%c')"
	wait
	sleep 1m
}

function startMysql(){
	#sudo /etc/init.d/mysql restart
	service mysql start
	sleep 30s
}

#three times test
function alltest(){
	start_time=$(date +%s)  # script start run time
	
	#startMysql
	#preparedata
	
	#rw test
#	for ((i=1; i<=4; i++))
#        do
#                NUMBER=${i}nd
#		OUTPUTPATH=./mysqlTestBysysbench_innodb_buffer_pool_size${INNODB_BUFFER_SIZE}_${CONFIG}_${NUMBER}/
#		rwtest
#        done

	#ro test
#	for ((i=1; i<=4; i++))
#        do
#                NUMBER=${i}nd
#                OUTPUTPATH=./mysqlTestBysysbench_innodb_buffer_pool_size${INNODB_BUFFER_SIZE}_${CONFIG}_${NUMBER}/
#		rotest
#        done
                NUMBER=1nd
                OUTPUTPATH=./mysqlTestBysysbench_innodb_buffer_pool_size${INNODB_BUFFER_SIZE}_${CONFIG}_${NUMBER}/
		rotest
                NUMBER=2nd
                OUTPUTPATH=./mysqlTestBysysbench_innodb_buffer_pool_size${INNODB_BUFFER_SIZE}_${CONFIG}_${NUMBER}/
		rotest2
                NUMBER=3nd
                OUTPUTPATH=./mysqlTestBysysbench_innodb_buffer_pool_size${INNODB_BUFFER_SIZE}_${CONFIG}_${NUMBER}/
		rotest2

	
	#wo test
#	for ((i=1; i<=4; i++))
#        do
#                NUMBER=${i}nd
#                OUTPUTPATH=./mysqlTestBysysbench_innodb_buffer_pool_size${INNODB_BUFFER_SIZE}_${CONFIG}_${NUMBER}/
#		wotest
#        done

	#cleardata

	end_time=$(date +%s)  # scrip stop run time,(s).
	# calculate script run time,(s).
	duration=$((end_time - start_time))
	echo "Script run time is: $duration (s)"
}
alltest
