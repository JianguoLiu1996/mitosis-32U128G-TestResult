#!/bin/bash

# 创建一个名为memory_usage.log的日志文件，如果文件已存在，则追加内容
echo "time               total        used        free      shared  buff/cache   available" > memory_usage.log

# 循环获取内存使用情况并保存到日志文件中
while true; do
    memory_info=$(free -h | grep --line-buffered -e "Mem:")
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "$timestamp  $memory_info" >> memory_usage.log
    sleep 3s
done

