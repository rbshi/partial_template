proc implement_design {} {
    opt_design
    place_design
    route_design
}

proc implement_design_w_phys_opt {} {
    opt_design
    place_design
    phys_opt_design
    route_design
}

proc implement_design_opt {} {
    opt_design -directive ExploreWithRemap
    place_design -directive Explore
    phys_opt_design -directive Explore
    route_design -directive AggressiveExplore -tns_cleanup
}

proc implement_design_opt_iteration {} {
    place_design -post_place_opt
    phys_opt_design -directive Explore
    route_design -directive AggressiveExplore -tns_cleanup
}

proc implement_design_opt_try {} {
# try few more times if the timing requirements are not met
    set pass [expr {[get_property SLACK [get_timing_paths]] >= 0}]
    set max_iterations 10

    set i 1
    while {$i <= $max_iterations && $pass == 0} {
        puts "Iteration $i..."
        implement_design_opt_iteration
        set pass [expr {[get_property SLACK [get_timing_paths]] >= 0}]
        set i [expr {$i + 1}]
    }
}