#!/bin/bash

output_file="iostat_output.log"

echo "Device             tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn" > ${output_file}
# 使用while循环来持续执行脚本
while true; do
    # 运行iostat命令并将结果追加到输出文件中
    iostat -d | grep 'vda' >> "$output_file"
    # 等待3秒
    sleep 3s
done

