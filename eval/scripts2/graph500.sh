#!/usr/bin/env bash

ENABLER_NAME="graph500" # a easy to remember name

SUFFIX="-graph500"
if [ "$#" -ge 1 ]; then
	SUFFIX="-$1"
fi

sudo killall bench_graph500_st2

source ./init.sh

function pre_hook { :; }
function post_hook { :; }

COMMAND="/home/ubuntu/vmitosis/precompiled/bench_graph500_st -- -s 24 -e 30 -V" # 27 32

VERSION=2

PERF_INTERVAL=5
PT_MULTIPLIER=1

START_METHOD="file"
START_FILE="/tmp/enablement/graph500_watch"

source ./common.sh
