#!/usr/bin/env bash

ENABLER_NAME="memcached-server" # a easy to remember name

SUFFIX="-memcached"
if [ "$#" -ge 1 ]; then
	SUFFIX="-$1"
fi

sudo killall memcached
sudo service memcached stop

source ./init.sh

function pre_hook { :; }

function post_hook {
	/home/ubuntu/tracer/eval/scripts2/memcached-client.sh &
}

COMMAND="/usr/bin/memcached -u root -m 131000 -p 11211 -l 127.0.0.1"

VERSION=2

PERF_INTERVAL=5
PT_MULTIPLIER=1

START_METHOD="file"
START_FILE="/tmp/enablement/memcached_watch"

source ./common.sh
