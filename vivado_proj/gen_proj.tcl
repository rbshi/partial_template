# General user top project

set user_conf [lindex $argv 0]
set part      [lindex $argv 1]
set ip_dir    [lindex $argv 2]

puts "Generating example dynamic project"
set project         "design_user_wrapper_0"
set top_module      "design_user_wrapper_0"

# Source files are included relative to the directory containing this script.
set src_dir   [file normalize "[file dirname [info script]]/../"]
set build_dir [file normalize "."]

# Create project (force)
create_project -force $project "$build_dir/$project" -part $part
set proj [current_project]

# Set project properties
set_property "default_lib" "xil_defaultlib"                                  $proj
set_property "ip_cache_permissions" "read write"                             $proj
set_property "ip_output_repo" "$build_dir/$project/$project.cache/ip"        $proj
set_property "sim.ip.auto_export_scripts" "1"                                $proj
set_property "simulator_language" "Mixed"                                    $proj
set_property "xpm_libraries" "XPM_CDC XPM_MEMORY"                            $proj
set_property "ip_repo_paths" "$ip_dir"                                       $proj
set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -objects [get_runs synth_1]

# create ip here (axisr_register_slice_512 used in perf_host example)
create_ip -name axis_register_slice -vendor xilinx.com -library ip -version 1.1 -module_name axisr_register_slice_512
set_property -dict [list CONFIG.TDATA_NUM_BYTES {64} CONFIG.REG_CONFIG {8} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.TID_WIDTH {6}] [get_ips axisr_register_slice_512]

# Make sure any repository IP is visible.
update_ip_catalog

# add RTL here
add_files -fileset [get_filesets sources_1] "$src_dir/hdl/"

# xdc
# set_property used_in_implementation false  [get_files -of_objects [get_filesets constrs_1]]

# Set top entity
set_property "top" $top_module [get_filesets sources_1]

# Create a project-local constraint file to take debugging constraints that we
# don't want to propagate to the repository.
file mkdir "$build_dir/$project/$project.srcs/constrs_1"
close [ open "$build_dir/$project/$project.srcs/constrs_1/local.xdc" w ]

close_project

puts "**** User design project generated."