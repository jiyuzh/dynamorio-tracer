#!/usr/bin/env bash

cd /home/ubuntu/ycsb-0.17.0
mkdir -p results

./bin/ycsb load memcached -s -P "workloads/perfeval" -p "memcached.hosts=127.0.0.1" 2>&1

sleep 5

echo "++++++++++++++++++++++++++++++++ real work ++++++++++++++++++++++++++++++++++"

now=$(date)
echo "$now" > /tmp/enablement/memcached_watch

./bin/ycsb run memcached -s -P "workloads/perfeval" -p "memcached.hosts=127.0.0.1" 2>&1

sudo killall memcached
