#!/usr/bin/env bash

ENABLER_NAME="xsbench" # a easy to remember name

SUFFIX="-xsbench"
if [ "$#" -ge 1 ]; then
	SUFFIX="-$1"
fi

sudo killall bench_xsbench_mt2

source ./init.sh

function pre_hook { :; }
function post_hook { :; }

COMMAND="/home/ubuntu/vmitosis/precompiled/bench_xsbench_mt2 -- -t 1 -g 170000 -p 4000000" # 24 170000 4000000

VERSION=2

PERF_INTERVAL=5
PT_MULTIPLIER=1

START_METHOD="file"
START_FILE="/tmp/enablement/xsbench_watch"

source ./common.sh
