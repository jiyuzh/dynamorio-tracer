# Tracing

This is a trace generator for the simulator used in a paper.

The trace generator records (1) an instruction trace, and (2) a page table dump at the end of the trace generation. Both the trace and the page table dump are later consumed by the simulator.

Main changes are in `./clients/drcachesim/tracer/tracer.cpp`.

0. Make sure you have the following requirements installed

```
# Server
gcc == 7
g++ == 7
pmap
dotnet == 7

# Client
VSCode with Polyglot Notebooks extension
```

1. Set up environment variables

```bash
source source.sh
```

2. Install/Build the tracer

```bash
./install.sh
```

3. Prepare the system: disable THP, enable page table dump module

```bash
sudo ./prepare_system.sh
```

4. Modify scripts in `eval/scripts2`

```bash
# common-*.sh

TRACER_DIR="<the dir you put this tracer in>"
PERF_PATH="<the path to your perf binary>"

# Other script files

# See https://github.com/jiyuzh/evaluation-scripts
# Scripts in eval/scripts2 are a derived version of the scripts in the repo

# See common-trace.sh
# It provides some speical arguments in drivers to signal the start of tracing
# The comments at the beginning of this file tell you how to use them
```

5. Modify script `./generate_trace.sh`
  
  - Only change the `exit_after_tracing` on Line 78
    
  - It controls the maximum number of instructions to be traced before the tracer quits.
    
6. Run drivers in `eval/scripts2` to create traces
  
  - They will shown in `eval/scripts2/results` folder
    
7. Pick a `pt_dump_raw.*` and a `pmap_raw.*` file to keep
  
  - Tracer will generate multiple versions of these two files, you only need to keep the most suitable one. Usually, the largest ones.
    
  - You should rename the kept ones as `pt_dump_raw` and `pmap_raw`
    
  - You can remove the other copies safely - they will not be used
    
8. Use `source/dump_pagetables/transform_pt_guest.dib` to process the `pt_dump_raw`
  
  - Open it with VSCode Polyglot Notebook
    
  - Change the `var path` in the second block to the folder containing the `pt_dump_raw`
    
  - Wait for it to finish, a `pt_dump` file will be generated in the same folder
    
9. Run the following command on the generated `pt_dump` file
  
  ```bash
  sed -i "1i $(wc -l ./pt_dump | awk '{print $1}')" ./pt_dump
  ```
  
10. The trace is now ready for use in the simulator


# Simulating

Use [this repo](https://github.com/jiyuzh/dynamorio)

Choose branch `simulator-pwc-prepare4release` (for 1D paging) or `simulator-virt-prepare4release` (for 2D paging)

Modify `run.sh` and `run_common.sh`. The semantic of parameters should be pretty obvious.
