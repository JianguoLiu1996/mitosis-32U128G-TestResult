#!/bin/bash
function disableTHP(){
	echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled
	echo never | sudo tee /sys/kernel/mm/transparent_hugepage/defrag
}
function seteptCached(){
	echo 0 | sudo tee /sys/kernel/mm/mitosis/ept_replication_cache > /dev/null
	sleep 1s
	echo 1100000 | sudo tee /sys/kernel/mm/mitosis/ept_replication_cache > /dev/null
	cat /sys/kernel/mm/mitosis/ept_replication_cache
}
function cleareptCache(){
	echo 0 | sudo tee /sys/kernel/mm/mitosis/ept_replication_cache > /dev/null
	cat /sys/kernel/mm/mitosis/ept_replication_cache
}
function bindeptNode(){
	echo 1 | sudo tee /sys/kernel/mm/mitosis/ept_migration > /dev/null
	echo "ept_migration:"
	cat /sys/kernel/mm/mitosis/ept_migration
	echo 0 | sudo tee /sys/kernel/mm/mitosis/current_ept_node > /dev/null
	echo "current_ept_node:"
	cat /sys/kernel/mm/mitosis/current_ept_node
}
function unbindNode(){
	echo 0 | sudo tee /sys/kernel/mm/mitosis/ept_migration > /dev/null
	echo "ept_migration:"
	cat /sys/kernel/mm/mitosis/ept_migration
	echo -1 | sudo tee /sys/kernel/mm/mitosis/current_ept_node > /dev/null
	echo "ept_migration:"
	cat /sys/kernel/mm/mitosis/current_ept_node
}

disableTHP
#seteptCached
cleareptCache
bindeptNode
#unbindNode
