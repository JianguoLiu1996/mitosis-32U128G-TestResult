#!/bin/bash
function disableTHP(){
	echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled
	echo never | sudo tee /sys/kernel/mm/transparent_hugepage/defrag
}
function seteptCached(){
	echo 0 | sudo tee /sys/kernel/mm/mitosis/ept_replication_cache > /dev/null
	sleep 1s
	echo 1100000 | sudo tee /sys/kernel/mm/mitosis/ept_replication_cache > /dev/null
	cat /sys/kernel/mm/mitosis/ept_replication_cache > /dev/null
}
function cleareptCache(){
	echo 0 | sudo tee /sys/kernel/mm/mitosis/ept_replication_cache > /dev/null
	cat /sys/kernel/mm/mitosis/ept_replication_cache > /dev/null
}
function bindeptNode(){
	echo 1 | sudo tee /sys/kernel/mm/mitosis/ept_migration > /dev/null
	cat /sys/kernel/mm/mitosis/ept_migration
	echo 0 | sudo tee /sys/kernel/mm/mitosis/current_ept_node > /dev/null
	cat /sys/kernel/mm/mitosis/current_ept_node > /dev/null
}
function unbindNode(){
	echo 0 | sudo tee /sys/kernel/mm/mitosis/ept_migration > /dev/null
	cat /sys/kernel/mm/mitosis/ept_migration
	echo -1 | sudo tee /sys/kernel/mm/mitosis/current_ept_node > /dev/null
	cat /sys/kernel/mm/mitosis/current_ept_node > /dev/null
}

disableTHP
#seteptCached
cleareptCache
#bindeptNode
unbindNode
