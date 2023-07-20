#!/usr/bin/env bash

ENABLER_NAME="redis" # a easy to remember name

SUFFIX="-redis"
if [ "$#" -ge 1 ]; then
	SUFFIX="-$1"
fi

sudo service redis stop
sudo killall redis-server
sudo killall bench_redis_st
sudo rm ./dump.rdb

source ./init.sh

function pre_hook { :; }
function post_hook { :; }

COMMAND="/home/ubuntu/vmitosis/precompiled/bench_redis_st"

PERF_INTERVAL=5
PT_MULTIPLIER=1

VERSION=2

START_METHOD="file"
START_FILE="/tmp/enablement/redis_watch"

source ./common.sh
