puts "RM-info : Running script [info script]\n"
##########################################################################################
# Tool: IC Compiler II
# Script: settings.common.cts.tcl
# Purpose: Common CTS related settings that can be sourced in clock_opt_cts or place_opt
##########################################################################################
## Timer
set_app_options -name time.remove_clock_reconvergence_pessimism -value true

# ------- General
set_app_options -list {cts.common.verbose 1}
set_app_options -list {cts.common.max_fanout 32 }
set_app_options -list {cts.common.max_net_length 150}

# --------- Cell Relocation
#set_app_options -name cts.compile.enable_cell_relocation -value none

# --------- GRoute based CTS
set_app_options -list {cts.compile.enable_global_route true}
set_app_options -list {cts.optimize.enable_global_route true}

# --------- clock_opt effort
#set_app_options -list {clock_opt.place.effort high}
set_app_options -list {clock_opt.flow.optimize_layers true}
#set_app_options -name clock_opt.flow.optimize_ndr -value false
#set_app_options -name clock_opt.congestion.effort -value high

# ----------- CCD Control
set_app_options -list {clock_opt.flow.enable_ccd false}
set_app_options -list {ccd.skip_path_groups {REGIN REGOUT IN_ICG}}
set_app_options -list {ccd.optimize_boundary_timing true}
