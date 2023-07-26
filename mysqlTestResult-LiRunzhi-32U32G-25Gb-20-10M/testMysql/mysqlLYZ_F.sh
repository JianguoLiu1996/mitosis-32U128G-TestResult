#!/bin/bash
function prepareDB(){
	sysbench --db-driver=mysql --mysql-host=localhost --mysql-port=3306 --mysql-user=root --mysql-password=123456 --mysql-db=testdb --table_size=10000000 --tables=20 --events=0 --time=300  --threads=200  oltp_read_write prepare
}
function testDB(){
	sysbench /usr/share/sysbench/oltp_read_only.lua --mysql-host=127.0.0.1 --mysql-port=3306 --mysql-user=root --mysql-password=123456 --mysql-db=testdb4 --db-driver=mysql --tables=20 --table_size=10000000 --report-interval=15 --threads=100 --rand-type=gaussian --time=1800 run > GFM1800_FM_2nd.log 2>&1 &
}
#prepareDB
#testDB
sysbench /usr/share/sysbench/oltp_read_only.lua --mysql-host=127.0.0.1 --mysql-port=3306 --mysql-user=root --mysql-password=123456 --mysql-db=testdb4 --db-driver=mysql --tables=20 --table_size=10000000 --report-interval=3 --threads=100 --rand-type=gaussian --time=1800 run > GFM1800_testdb4_F_1nd.log 2>&1 &
wait
sleep 1m

sysbench /usr/share/sysbench/oltp_read_only.lua --mysql-host=127.0.0.1 --mysql-port=3306 --mysql-user=root --mysql-password=123456 --mysql-db=testdb4 --db-driver=mysql --tables=20 --table_size=10000000 --report-interval=3 --threads=100 --rand-type=gaussian --time=1800 run > GFM1800_testdb4_F_2nd.log 2>&1 &
wait
sleep 1m

sysbench /usr/share/sysbench/oltp_read_only.lua --mysql-host=127.0.0.1 --mysql-port=3306 --mysql-user=root --mysql-password=123456 --mysql-db=testdb4 --db-driver=mysql --tables=20 --table_size=10000000 --report-interval=3 --threads=100 --rand-type=gaussian --time=1800 run > GFM1800_testdb4_F_3nd.log 2>&1 &
wait
sleep 1m

sysbench /usr/share/sysbench/oltp_read_only.lua --mysql-host=127.0.0.1 --mysql-port=3306 --mysql-user=root --mysql-password=123456 --mysql-db=testdb4 --db-driver=mysql --tables=20 --table_size=10000000 --report-interval=3 --threads=100 --rand-type=gaussian --time=1800 run > GFM1800_testdb4_F_4nd.log 2>&1 &
