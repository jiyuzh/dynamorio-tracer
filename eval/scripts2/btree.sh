#!/usr/bin/env bash

ENABLER_NAME="btree" # a easy to remember name

SUFFIX="-btree"
if [ "$#" -ge 1 ]; then
	SUFFIX="-$1"
fi

sudo killall bench_btree_st

source ./init.sh

COMMAND="/home/ubuntu/vmitosis/precompiled/bench_btree_st"

PERF_INTERVAL=5
PT_MULTIPLIER=1

source ./common.sh
