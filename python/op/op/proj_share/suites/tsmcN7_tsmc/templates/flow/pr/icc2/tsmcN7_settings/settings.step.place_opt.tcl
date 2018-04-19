##########################################################################################
# Tool: IC Compiler II
# Script: settings.step.place_opt.tcl
##########################################################################################
### soure other comment app_options #######
#source -e -v ./rm_user_scripts/N7_settings/N7_settings_common_opt.tcl
#source -e -v ./rm_user_scripts/app_options_setting/settings.common.cts.tcl
#source -e -v ./rm_user_scripts/N7_settings/N7_settings_common_route.tcl

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


