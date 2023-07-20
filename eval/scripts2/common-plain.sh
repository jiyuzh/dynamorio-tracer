# this is not a full script, use it with source

TRACER_DIR="/home/ubuntu/tracer"
PERF_PATH="perf"
PERF_DTLB_LOAD="dtlb_load_misses.miss_causes_a_walk,dtlb_load_misses.walk_completed,dtlb_load_misses.walk_active,dtlb_load_misses.walk_pending"
PERF_DTLB_STORE="dtlb_store_misses.miss_causes_a_walk,dtlb_store_misses.walk_completed,dtlb_store_misses.walk_active,dtlb_store_misses.walk_pending"
PERF_ITLB="itlb_misses.miss_causes_a_walk,itlb_misses.walk_completed,itlb_misses.walk_active,itlb_misses.walk_pending"
PERF_OTHER="ept.walk_pending,faults"
PERF_COMMON="cycles:ukhHG,task-clock:ukhHG,cpu-clock:ukhHG,instructions:ukhHG"
PERF_ITEMS="$PERF_DTLB_LOAD,$PERF_DTLB_STORE,$PERF_ITLB,$PERF_OTHER,$PERF_COMMON"

cd "$SCRIPT_DIR"

kill_descendant_processes() {
	local pid="$1"
	local and_self="${2:-false}"
	if children="$(pgrep -P "$pid")"; then
		for child in $children; do
			kill_descendant_processes "$child" true
		done
	fi
	if [[ "$and_self" == true ]]; then
		echo "Killing $pid"
		kill -INT "$pid"
	fi
}

sigint()
{
	echo "signal INT received, script ending"
	kill_descendant_processes $$
	exit 0
}
trap sigint SIGINT

post_hook_launcher()
{
        sleep 5

        echo "++++++++++++++++++++++ posthook ++++++++++++++++++++++"

        post_hook
}

echo "++++++++++++++++++++++ prehook ++++++++++++++++++++++"

pre_hook

sleep 5

echo "++++++++++++++++++++++ starting ++++++++++++++++++++++"

post_hook_launcher &

taskset -c 39 $COMMAND

sync

echo "Done"
