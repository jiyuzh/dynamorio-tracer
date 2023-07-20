# this is not a full script, use it with source

# Params:
#
# ENABLER_NAME: The name of the enabler file
# SUFFIX: The suffix for the result directory
# COMMAND: The job command to run
# VERSION: Version number of the script, must set to 2
#
# PERF_INTERVAL: Time slice length for one perf sample (perf will keep taking sample until the program exits)
# PT_MULTIPLIER: How many perf samples are required before one page table dump is taken
# START_METHOD: value={timed, file, manual} How the start of real job is signaled
#	timed: Delay a certain time period for the program to finish initialization
#	file: Wait for a signal file to be changed
#	manual: Wait for user input before start tracing (hit Enter)
# START_AFTER: Use with START_METHOD="timed", sleep certain time before the job is started
# START_FILE: Use with START_METHOD="file", start the job when the content of the file is changed

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

if [ "$VERSION" != "2" ]; then
	echo "Invalid Script Version Number"
	exit
fi

sudo rm -rf "$OUTPUT_DIR"

cd "$TRACER_DIR"

sudo ./prepare_system.sh

echo "++++++++++++++++++++++ prehook ++++++++++++++++++++++"

pre_hook

sleep 5

echo "++++++++++++++++++++++ starting ++++++++++++++++++++++"

"$TRACER_DIR/generate_trace.sh" "--output_dir=$OUTPUT_DIR" "--enabler_file=$ENABLE_FILE" $COMMAND 2>&1 & pid=$!

sleep 5

echo "++++++++++++++++++++++ posthook ++++++++++++++++++++++"

post_hook

sleep 5

cd "$SCRIPT_DIR"

echo "++++++++++++++++++++++ started (PID = $pid) ++++++++++++++++++++++"

count=99999
serial=0

if [ "$START_METHOD" = "timed" ]; then
	echo "++++++++++++++++++++++ Timed Enablement ++++++++++++++++++++++"
	sleep "$START_AFTER"
else
if [ "$START_METHOD" = "file" ]; then
	echo "++++++++++++++++++++++ Programmed File Enablement ++++++++++++++++++++++"

	monitor=`cat $START_FILE 2>/dev/null`

	while true; do
		monitor2=`cat $START_FILE 2>/dev/null`
		if [ "$monitor2" != "$monitor" ]; then
			break
		fi
		sleep 1
	done
else
if [ "$START_METHOD" = "manual" ]; then
	echo "++++++++++++++++++++++ Manual Enablement ++++++++++++++++++++++"
	echo "Hit Enter to start tracing"
	read __enable
fi
fi
fi

echo "++++++++++++++++++++++ enabled ++++++++++++++++++++++"

echo 1 > "$ENABLE_FILE"

while true; do

		checker=`cat /proc/$pid/comm 2>/dev/null`
		if [ "$checker" != "generate_trace." ]; then
			break
		fi

		pid2=`cat $ENABLE_FILE`
		if [ "$pid2" != "1" ] && [ "$pid2" != "0" ]; then
			date -Iseconds >> "$OUTPUT_DIR/perf.log"
			"$PERF_PATH" stat -e "$PERF_ITEMS" -p "$pid2" sleep "$PERF_INTERVAL" >> "$OUTPUT_DIR/perf.log" 2>&1

			if [ $count -ge $PT_MULTIPLIER ]; then
				echo "$pid2" | sudo tee /proc/page_tables
				sudo cat /proc/page_tables > "$OUTPUT_DIR/pt_dump_raw.$serial"
				sudo pmap -XX "$pid2" > "$OUTPUT_DIR/pmap_raw.$serial"
				count=0
			fi

			if [ ! -d "/proc/$pid2" ]; then
				break
			fi
		else
			sleep "$PERF_INTERVAL"
		fi

		count=`expr $count + 1`
		serial=`expr $serial + 1`
done

sudo chmod -R 777 "$OUTPUT_DIR"

sync

echo "Done"
