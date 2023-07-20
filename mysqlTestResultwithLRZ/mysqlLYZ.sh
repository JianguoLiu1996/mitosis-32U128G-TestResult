#!/bin/bash
function prepareData(){
	sysbench --db-driver=mysql --mysql-host=localhost --mysql-port=3306 --mysql-user=root --mysql-password=123456 --mysql-db=testdb --table_size=10000000 --tables=20 --events=0 --time=300  --threads=200  oltp_read_write prepare
}

function gaussTest(){
	sysbench /usr/share/sysbench/oltp_read_only.lua --mysql-host=127.0.0.1 --mysql-port=3306 --mysql-user=root --mysql-password=123456 --mysql-db=testdb --db-driver=mysql --tables=20 --table_size=10000000 --report-interval=30 --threads=100 --time=300 run >F3600 2>&1 &
}
