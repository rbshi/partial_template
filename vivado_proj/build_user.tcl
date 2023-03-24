# Implementation
set user_conf [lindex $argv 0]
set shell_dir [lindex $argv 1]
set part      [lindex $argv 2]
set build_dir [file normalize "."]

set project   "design_user_wrapper_0"

open_project "$build_dir/$project/$project.xpr"

# synthesis
update_compile_order
reset_run synth_1
launch_runs -verbose synth_1
wait_on_run synth_1
open_run synth_1
write_checkpoint "${build_dir}/${project}_syn.dcp"
report_utilization -file "${build_dir}/${project}_syn.rpt"
close_project

puts "**** User design synthesised."

# implementation with the abstract shell
set tcl_dir   [file normalize "[file dirname [info script]]"]
source -quiet "$tcl_dir/impl_proc.tcl"

create_project -in_memory -part $part
add_files "$build_dir/${project}_syn.dcp"
add_files "$shell_dir/dcp/user_wrapper_abshell_0.dcp"

# map the syn user netlist to the greybox in the abstract shell
set_property SCOPED_TO_CELLS {inst_dynamic/inst_user_wrapper_0} [get_files "${project}_syn.dcp"]
link_design -mode default -reconfig_partitions {inst_dynamic/inst_user_wrapper_0} -part $part -top cyt_top
implement_design
write_checkpoint -cell {inst_dynamic/inst_user_wrapper_0} "$build_dir/${project}_routed.dcp"

report_utilization -file "$build_dir/${project}_utilization.rpt"
report_timing_summary -file "$build_dir/${project}_timing_summary.rpt"

write_bitstream -cell {inst_dynamic/inst_user_wrapper_0} "$build_dir/$project.bit"
write_debug_probes -cell {inst_dynamic/inst_user_wrapper_0} "$build_dir/$project.ltx"

close_project

puts "**** User design implemented with abstract shell."

# merge the partial user dcp with static_shell dcp

create_project -in_memory -part $part
add_files "$build_dir/${project}_routed.dcp"
add_files "$shell_dir/dcp/static_shell.dcp"

# map the syn user netlist to the greybox in the abstract shell
set_property SCOPED_TO_CELLS {inst_dynamic/inst_user_wrapper_0} [get_files "${project}_routed.dcp"]
link_design -mode default -reconfig_partitions {inst_dynamic/inst_user_wrapper_0} -part $part -top cyt_top
write_checkpoint "$build_dir/${project}_full.dcp"

puts "**** User design and static shell linked."

write_bitstream "$build_dir/${project}_full.bit"
write_debug_probes "$build_dir/${project}_full.ltx"

puts "**** Full bitstream generated."

close_project