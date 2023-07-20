#!/usr/bin/env bash

ENABLER_NAME="canneal" # a easy to remember name

SUFFIX="-canneal"
if [ "$#" -ge 1 ]; then
	SUFFIX="-$1"
fi

sudo killall bench_canneal_st

source ./init.sh

COMMAND="/home/ubuntu/vmitosis/precompiled/bench_canneal_st 1 150000 2000 /home/ubuntu/vmitosis/datasets/canneal_small 10000"

PERF_INTERVAL=5
PT_MULTIPLIER=1

source ./common.sh

