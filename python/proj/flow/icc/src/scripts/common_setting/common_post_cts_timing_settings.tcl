puts "RM-Info: Running script [info script]\n"

##########################################################################################
# Version: E-2010.12 (January 10, 2011)
# Copyright (C) 2007-2011 Synopsys, Inc. All rights reserved.
##########################################################################################

## Enabling CRPR - CRPR is usually used with timing derate (bc_wc) and with OCV
  set_app_var timing_remove_clock_reconvergence_pessimism true 

#set_app_var case_analysis_sequential_propagation never


## Set Area Critical Range
## Typical value: 5 percent of critical clock period
#if {$AREA_CRITICAL_RANGE_POST_CTS != ""} {set_app_var physopt_area_critical_range $AREA_CRITICAL_RANGE_POST_CTS}

## Set Power Critical Range
## Typical value: 5 percent of critical clock period
#if {$POWER_CRITICAL_RANGE_POST_CTS != ""} {set_app_var physopt_power_critical_range $POWER_CRITICAL_RANGE_POST_CTS}

## Hold fixing cells
#if { $ICC_FIX_HOLD_PREFER_CELLS != ""} {
#    remove_attribute [get_lib_cells $ICC_FIX_HOLD_PREFER_CELLS] dont_touch
#    set_prefer -min [get_lib_cells $ICC_FIX_HOLD_PREFER_CELLS]
#    set_fix_hold_options -preferred_buffer
#}


puts "RM-Info: Completed script [info script]\n"
