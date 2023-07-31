#!/bin/bash
sudo ./monitor_memory.sh &
MONITOR_MEMORY_PID=$!

sudo ./monitor_io.sh &
MONITOR_IO_PID=$!

sudo ./monitor_network.sh &
MONITOR_NETOWRK_PID=$!

echo "monitor_memory_pid: $MONITOR_MEMORY_PID" >> monitor_all.log
echo "monitor_io_pid: $MONITOR_IO_PID" >> monitor_all.log
echo "monitor_network_pid: $MONITOR_NETOWRK_PID" >> monitor_all.log
echo "sudo kill $MONITOR_MEMORY_PID $MONITOR_IO_PID $MONITOR_NETOWRK_PID" >> monitor_all.log

# 等待3个小时
#sleep 3h
#sleep 10m
#sudo kill $MONITOR_MEMORY_PID $MONITOR_IO_PID $MONITOR_NETOWRK_PID
