#!/usr/bin/env bash

ENABLER_NAME="gups" # a easy to remember name

SUFFIX="-gups"
if [ "$#" -ge 1 ]; then
	SUFFIX="-$1"
fi

sudo killall bench_gups_st

source ./init.sh

COMMAND="/home/ubuntu/vmitosis/precompiled/bench_gups_st 128"

PERF_INTERVAL=5
PT_MULTIPLIER=1

source ./common.sh
