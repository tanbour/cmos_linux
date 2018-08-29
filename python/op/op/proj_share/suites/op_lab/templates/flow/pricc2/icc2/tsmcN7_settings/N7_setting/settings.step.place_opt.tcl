##########################################################################################
# Tool: IC Compiler II
# Script: settings.step.place_opt.tcl
##########################################################################################
### soure other comment app_options #######
source -e -v ./rm_user_scripts/N7_settings/N7_settings_common_opt.tcl
source -e -v ./rm_user_scripts/app_options_setting/settings.common.cts.tcl
source -e -v ./rm_user_scripts/N7_settings/N7_settings_common_route.tcl

###########################################
# avoid assign statement in verilog netlist
set_app_option -list {opt.port.eliminate_verilog_assign true}
set_app_options -list {opt.tie_cell.max_fanout 10}
#set_app_options -list {opt.common.max_net_length 250}
#set_app_options -list {opt.wns_effort_high 1 }

# ----- Area Recovery
#set_app_options -name opt.bf.effort -value ultra
#set_app_options -name opt.area.effort -value ultra
#set_app_options -name opt.common.buffer_area_effort -value ultra


## -------------------------------
## Common place settings
## -------------------------------
# congestion
#set_app_options -list {place.coarse.target_routing_density 0.70}
#set_app_options -list {place.coarse.detect_detours true}
#set_app_options -list {place.coarse.channel_detect_mode true}
#set_app_options -list {place_opt.congestion.effort high}
#set_app_options -list {refine_opt.congestion.effort high}

# timing
set_app_options -list {place.coarse.enable_enhanced_soft_blockages true}
set_app_options -list {place.coarse.tns_driven_placement true}
#set_app_options -list {place_opt.flow.do_path_opt true}

# ICG auto bound
set_app_options -list {place.coarse.icg_auto_bound true}
set_app_options -list {place.coarse.icg_auto_bound_fanout_limit 40}

# place_opt
# optional for hpc
set_app_options -list {place_opt.initial_drc.global_route_based 1}
set_app_options -list {place_opt.initial_place.effort high}
set_app_options -list {place_opt.final_place.effort high}
set_app_options -list {refine_opt.place.effort high}

# In case don't have scandef
set_app_options -list {place.coarse.continue_on_missing_scandef true}
## Enable clock-to-data analysis
set_app_options -name time.enable_clock_to_data_analysis -value true ;# default false

## PPA - Performance focused features (place_opt)
## Path opt
#  Performs register location optimization for better timing
set_app_option -name place_opt.flow.do_path_opt -value true

## Final coarse placement effort level 
set_app_option -name place_opt.final_place.effort -value high

## Auto bound for ICG placement
#	# Note : optionally can be enabled along with PLACE_OPT_OPTIMIZE_ICGS
#	set_app_options -name place.coarse.icg_auto_bound -value true ;# default false

## Trial clock tree
#  Enabled only if PLACE_OPT_OPTIMIZE_ICGS is not enabled since tool will enable this feature automatically,
#  if PLACE_OPT_OPTIMIZE_ICGS is enabled
#	set_app_options -name place_opt.flow.trial_clock_tree -value true ;# default false

## Clock-aware placement
#  Enabled only if PLACE_OPT_OPTIMIZE_ICGS is not enabled since tool will enable this feature automatically,
#  if PLACE_OPT_OPTIMIZE_ICGS is enabled
#	set_app_options -name place_opt.flow.clock_aware_placement -value true ;# default false


## place_opt/placement specific features
## Effort level for congestion alleviation in place_opt
#  Expect a significant increase in runtime at high effort.
# set_app_option -name place_opt.congestion.effort -value high

## Enable high CPU effort level for coarse placements invoked in refine_opt
#	set_app_options -name refine_opt.place.effort -value high
 
## GR-opto : 
#  Run global route based buffering during HFS/DRC fixing. Global routes are deleted after buffering. 
#  This is especially useful for fragmented and narrow-channelled floorplans.
#  [FLOW] hc - set to 1 to accommodate fragmented shapes and narrow channels
# set_app_option -name place_opt.initial_drc.global_route_based -value 1

## To create a buffer-only blockage, follow the example below.
#  The area covered by a buffer-only blockage can only be used by buffers and inverters, which is honored by placement.
#  -blocked_percentage 0 means that 100% of the area can be used by buffers and inverters.
#  -blocked_percentage 100 means that 0% of the area can be used by buffers and inverters. 
#   (as a result, no standard cells can be placed under a buffer only blockage with -blocked_percentage 100).
#
#  Example for creating a buffer only blockage with 100% of the area open to repeaters : 
#	create_placement_blockage -name placement_blockage_1 -type allow_buffer_only -blocked_percentage 0 \
#       -boundary { {x1 y1} {x2 y2} }

## For all the flows supported by OPTIMIZATION_FLOW, only TTR is using the place_opt.flow.do_spg app option for handling SPG inputs 
#  with place_opt command. All the other flows are using atomic commands such as "create_placement -use_seed_locs" and 
#  "place_opt -from initial_drc" commands. To prevent place_opt.flow.do_spg from accidentally being set and 
#  making initial_drc phase skipped during "place_opt -from initial_drc" for the non-TTR flows,
#  place_opt.flow.do_spg is reset to false for non-TTR flows.
#	set_app_options -name place_opt.flow.do_spg -value true
   # not: 
#	reset_app_options place_opt.flow.do_spg

source  -e -v ./rm_user_scripts/N7_settings/N7_settings_place_opt.tcl

