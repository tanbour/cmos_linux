###==================================================================##
##  Script: settings.common.opt.tcl                                  ##
##===================================================================##
set preroute_timing_optimization_effort             "{{local.preroute_timing_optimization_effort}}"
set preroute_auto_timing_control_placement          "{{local.preroute_auto_timing_control_placement}}"
set preroute_layer_optimization                     "{{local.preroute_layer_optimization}}"
set preroute_layer_optimization_critical_range      "{{local.preroute_layer_optimization_critical_range}}"
set preroute_ndr_optimization                       "{{local.preroute_ndr_optimization}}"
set opt_common_max_fanout                           "{{local.opt_common_max_fanout}}"                    
set preroute_power_optimization_mode                "{{local.preroute_power_optimization_mode}}"
set preroute_power_optimization_effort              "{{local.preroute_power_optimization_effort}}"
set preroute_low_power_placement                    "{{local.preroute_low_power_placement}}"
set preroute_area_recovery_effort                   "{{local.preroute_area_recovery_effort}}"
set preroute_buffer_area_effort                     "{{local.preroute_buffer_area_effort}}"
set preroute_route_aware_estimation                 "{{local.preroute_route_aware_estimation}}"
set preroute_placement_detect_channel               "{{local.preroute_placement_detect_channel}}"
set preroute_placement_detect_detour                "{{local.preroute_placement_detect_detour}}"
#  - when the value is 0 (tool default) and
#	- when place.coarse.auto_density_control is true, tool will auto determine an appropriate value;
#	- when place.coarse.auto_density_control is false, tool will try to spread cells evenly
set preroute_placement_auto_density                 "{{local.preroute_placement_auto_density}}"
#  - when this value is set, coarse placer attempts to limit local cell density to be less than the value; 
set preroute_placement_max_density                  "{{local.preroute_placement_max_density}}"

set preroute_placement_target_routing_density       "{{local.preroute_placement_target_routing_density}}"
## Specify the maximum design utilization after congestion driven padding during congestion driven placement (optional)
set preroute_placement_max_util                     "{{local.preroute_placement_max_util}}"
## Pin density aware placement for preroute flows 
set preroute_placement_pin_density_aware            "{{local.preroute_placement_pin_density_aware}}"
## Lib cell usage restrictions 
set tcl_lib_cell_purpose_file                       "{{local.tcl_lib_cell_purpose_file}}"
## setets freeze_clock_ports and freeze_data_ports attributes on the specified cells
set optimization_freeze_port_list                   "{{local.optimization_freeze_port_list}}"
set tcl_placement_spacing_label_rule_file           "{{local.tcl_placement_spacing_label_rule_file}}"
## Stream placement,  For each large displacement cell, it attempts to move out other cells to make room
set preroute_placement_stream_legalizer             "{{local.preroute_placement_stream_legalizer}}"
## Orientation optimization (RM default is true)
#  Legalizer will consider flipping the orientations of cells in order to reduce displacements during legalization.
set preroute_placement_orientation_optimization     "{{local.preroute_placement_orientation_optimization}}"
set tcl_non_clock_ndr_rules_file                    "{{local.tcl_non_clock_ndr_rules_file}}"
set tcl_clock_ndr_rules_file                         "{{local.tcl_clock_ndr_rules_file}}"
set max_routing_layer                               "{{local.max_routing_layer}}"
set min_routing_layer                               "{{local.min_routing_layer}}"
## Enable low power improvement techniques during CTS (optional)
set cts_low_power                                   "{{local.cts_low_power}}"
set place_opt_optimize_icgs                         "{{local.place_opt_optimize_icgs}}"
set place_opt_trial_cts                             "{{local.place_opt_trial_cts}}"
set place_opt_mscts                                 "{{local.place_opt_mscts}}"

# technology setting----------------------------------------------------------------------
#set_technology -node 7
#get_attribute [current_block] technology_node

## Additional timer related setups : create path groups-----------------------------------
# Tool auto creates 3 IO path groups : in2reg_default, reg2out_default, and in2out_default
set_app_options -name time.enable_io_path_groups -value true  

## PPA - Performance focused features---------------------------------
{% if local.preroute_timing_optimization_effort %}
puts "RM-info: Setting opt.timing.effort to $preroute_timing_optimization_effort (tool default low)"
set_app_option -name opt.timing.effort -value $preroute_timing_optimization_effort
{%- endif %}

puts "RM-info: Setting place.coarse.auto_timing_control to $preroute_auto_timing_control_placement (tool default false)"
set_app_options -name place.coarse.auto_timing_control -value $preroute_auto_timing_control_placement

puts "RM-info: Setting place_opt/refine_opt.flow.optimize_layers to $preroute_layer_optimization (tool default false)"
set_app_option -name place_opt.flow.optimize_layers -value $preroute_layer_optimization
set_app_option -name refine_opt.flow.optimize_layers -value $preroute_layer_optimization

{%- if local.preroute_layer_optimization_critical_range  %}
puts "RM-info: Setting place_opt.flow.optimize_layers_critical_range to $preroute_layer_optimization_critical_range (tool default 0.7)"
set_app_options -name place_opt.flow.optimize_layers_critical_range -value $preroute_layer_optimization_critical_range ;# tool default 0.7
{% endif %}

## NDR optimization in preroute (optional)-------------------------------
puts "RM-info: Setting place_opt/refine_opt/clock_opt.flow.optimize_ndr to $preroute_ndr_optimization (tool default false)"
set_app_options -name place_opt.flow.optimize_ndr -value $preroute_ndr_optimization ;# tool default false 
set_app_options -name refine_opt.flow.optimize_ndr -value $preroute_ndr_optimization ;# tool default false 
set_app_options -name clock_opt.flow.optimize_ndr -value $preroute_ndr_optimization ;# tool default false

{%- if local.opt_common_max_fanout %}
set_app_options -name opt.common.max_fanout -value $opt_common_max_fanout ;# tool default 40
{% endif %}

## PPA - Power focused features-----------------------------------------

{%- if local.preroute_power_optimization_mode  %}
puts "RM-info: Setting opt.power.mode to $preroute_power_optimization_mode (tool default none)"
set_app_option -name opt.power.mode -value $preroute_power_optimization_mode
{% endif %}

{#- # Percentage lvth flow  (optional)
   #  By default, leakage optimization is mW-based. To enable percentage lvth flow, do the following:
   #  Specifies the maximum percentage of low-threshold-voltage cells.
   #	set_max_lvth_percentage %
   #  Enable percentage_lvt leakage type
   #	set_app_option -name opt.power.leakage_type -value percentage_lvt ;# default conventional
-#}

{%- if local.preroute_power_optimization_effort %}
puts "RM-info: Setting opt.power.effort to $preroute_power_optimization_effort (tool default low)"
set_app_option -name opt.power.effort -value $preroute_power_optimization_effort
{%- endif %}

puts "RM-info: Setting place.coarse.low_power_placement to $preroute_low_power_placement (tool default false)"
set_app_option -name place.coarse.low_power_placement -value $preroute_low_power_placement

## PPA - Area focused features------------------------------------------
{% if local.preroute_area_recovery_effort  %}
puts "RM-info: Setting opt.area.effort to $preroute_area_recovery_effort (tool default low)"
set_app_option -name opt.area.effort -value $preroute_area_recovery_effort
{%- endif %}

{%- if local.preroute_buffer_area_effort  %}
puts "RM-info: Setting opt.common.buffer_area_effort to $preroute_buffer_area_effort (tool default low)"
set_app_option -name opt.common.buffer_area_effort -value $preroute_buffer_area_effort
{%- endif %}

puts "RM-info: Setting opt.common.use_route_aware_estimation to $preroute_route_aware_estimation (tool default false)"
set_app_option -name opt.common.use_route_aware_estimation -value $preroute_route_aware_estimation

## Congestion and displacement handling features-----------------------
{# # Enable keep going legalizer to improve legalizer turn-around time (optional)
   #	set_app_option -name place.legalize.limit_legality_checks -value true ;# tool default false
-#}

puts "RM-info: Setting place.coarse.channel_detect_mode to $preroute_placement_detect_channel (tool default false)"
set_app_option -name place.coarse.channel_detect_mode -value $preroute_placement_detect_channel

## Detour detection during coarse placement (RM default is true)
puts "RM-info: Setting place.coarse.detect_detours to $preroute_placement_detect_detour (tool default false)"
set_app_option -name place.coarse.detect_detours -value $preroute_placement_detect_detour

puts "RM-info: Setting place.coarse.auto_density_control to $preroute_placement_auto_density (tool default true)"
set_app_option -name place.coarse.auto_density_control -value $preroute_placement_auto_density

{%- if local.preroute_placement_max_density %}	
puts "RM-info: Setting place.coarse.max_density to $preroute_placement_max_density"
set_app_option -name place.coarse.max_density -value $preroute_placement_max_density
{%- endif %}

{%- if local.preroute_placement_target_routing_density %}
puts "RM-info: Setting place.coarse.target_routing_density to $preroute_placement_target_routing_density"
set_app_option -name place.coarse.target_routing_density -value $preroute_placement_target_routing_density
{%- endif %}

{%- if  local.preroute_placement_max_util  %}
puts "RM-info: Setting place.coarse.congestion_driven_max_util to $preroute_placement_max_util" 
set_app_option -name place.coarse.congestion_driven_max_util -value $preroute_placement_max_util
{%- endif %}

puts "RM-info: Setting place.coarse.pin_density_aware to $preroute_placement_pin_density_aware (tool default false)" 
set_app_option -name place.coarse.pin_density_aware -value $preroute_placement_pin_density_aware

puts "RM-info: Setting place.coarse.cong_restruct_effort to ultra (tool default medium)"
set_app_option -name place.coarse.cong_restruct_effort -value ultra

## Lib cell usage restrictions (set_lib_cell_purpose)-------------------
source $tcl_lib_cell_purpose_file

## Additional optimization related settings-----------------------------
puts "RM-info: Setting opt.port.eliminate_verilog_assign to true (tool default false)"
set_app_options -name opt.port.eliminate_verilog_assign -value true

set_app_options -name place.coarse.continue_on_missing_scandef -value true ;# tool default false

{# # To disable DFT optimization (optional)
   #	set_app_options -name opt.dft.optimize_scan_chain -value false ;# tool default true
-#}

{#- ## To invoke clock driver aware DFT optimization in clock_opt final_opto phase  (optional)
   #  Typically results in scan connection structure with reduced hold violations along scan path,
   #  at cost of increased total scan net length and potentially degraded timing
   #	set_app_options -name  opt.dft.clock_aware_scan -value true ;# tool default false
-#}

{%- if local.optimization_freeze_port_list %}
	puts "RM-info: Setting opt.dft.hier_preservation to true (tool default false)"
	set_app_options -name opt.dft.hier_preservation -value true 
	set_freeze_port -all [get_cells $optimization_freeze_port_list] ;# sets freeze_clock_ports and freeze_data_ports attributes on the specified cells
{%- endif %}

## Legalization related settings----------------------------------------
source $tcl_placement_spacing_label_rule_file

{# # Soft blockage enhancement : to prevent incremental coarse placer from moving cells out of soft blockages
   #	set_app_options -name place.coarse.enable_enhanced_soft_blockages -value true
-#}

puts "RM-info: Setting place.legalize.stream_place to $preroute_placement_stream_legalizer (tool default false)"
set_app_option -name place.legalize.stream_place -value $preroute_placement_stream_legalizer

puts "RM-info: Setting place.legalize.optimize_orientations to $preroute_placement_orientation_optimization (tool default false)"
set_app_option -name place.legalize.optimize_orientations -value $preroute_placement_orientation_optimization

{# # Uncomment below for designs with fishbone PG structure, to support PDC checking with EoL rule
   #  and VIA enclosure for pin access point, uncomment to apply the following
   #	set_app_options -name place.legalize.use_eol_spacing_for_access_check -value true ;# tool default false
-#}

## Non-Clock NDR ----------------------------------------------------------
source $tcl_non_clock_ndr_rules_file

# settings.common.routing.tcl-----------------------------------------------

## Timing-driven global route
set_app_options -name route.global.timing_driven -value true

#  New PDC engine
set_app_options -name place.legalize.enable_advanced_prerouted_net_check -value true ;# tool default false
# resove H240.CM0B.W.4
set_app_options -name place.legalize.enable_vertical_abutment_rules -value true ;# tool default false
set_app_options -name place.rules.vertical_abutment_mode -value user ;# tool default user

{#  # Vertical abutment rules (optional as it is library specific)
    #	set_app_options -name place.legalize.enable_vertical_abutment_rules -value true ;# tool default false
    #	set_app_options -name place.rules.vertical_abutment_mode -value user ;# tool default user
    
    ## PNET-aware settings (optional for high utilization and congested designs)
    #  pnet-aware coarse placement considers only $7nm_M1
    # 	set_app_options -name place.coarse.pnet_aware_layers -value $7nm_M1
    #  pnet-aware coarse placement is triggered if utilization is above 0.5
    # 	set_app_options -name place.coarse.pnet_aware_density -value 0.5
    #  pnet-aware coarse placement considers all pnets wider than 0
    # 	set_app_options -name place.coarse.pnet_aware_min_width -value 0
    
    ## Below are optional settings
    #	## Pin access with NDR
    #	set_app_options -name place.legalize.avoid_pins_under_preroute_layers -value $7nm_M3
    #	set_app_options -name place.legalize.avoid_pins_under_preroute_libpins -value {list of your library pins}
    #	set_app_options -name cts.placement.enable_ndr_pins -value true ;# tool default false
-#}

## Set max routing layer
{%- if local.max_routing_layer %}
set_ignored_layers -max_routing_layer $max_routing_layer
{%- endif %}

{%- if local.min_routing_layer %}
set_ignored_layers -min_routing_layer $min_routing_layer
{%- endif %}

## Specify the types of rotated via arrays that can be used to "rotate" 
set_app_options -name route.common.via_array_mode -value rotate

{%- if local.place_opt_optimize_icgs == "true" or local.place_opt_trial_cts == "true" or local.place_opt_mscts == "true"  %}
## CRPT (RM default is true)
puts "RM-info: Setting time.remove_clock_reconvergence_pessimism to true (tool default false)"
set_app_options -name time.remove_clock_reconvergence_pessimism -value true

## Enable low power improvement techniques during CTS (optional)
puts "RM-info: Setting cts.common.enable_low_power to $cts_low_power (tool default false)"
set_app_options -name cts.common.enable_low_power -value $cts_low_power

# source icc2 clock cts routing NDR rule file
source -e -v $tcl_clock_ndr_rules_file
{% endif %}

{%- if cur.sub_stage == "03_clock.tcl" or cur.sub_stage == "04_clock_opt.tcl" %}
## CRPT (RM default is true)
puts "RM-info: Setting time.remove_clock_reconvergence_pessimism to true (tool default false)"
set_app_options -name time.remove_clock_reconvergence_pessimism -value true

## Enable low power improvement techniques during CTS (optional)
puts "RM-info: Setting cts.common.enable_low_power to $cts_low_power (tool default false)"
set_app_options -name cts.common.enable_low_power -value $cts_low_power

# source icc2 clock cts routing NDR rule file
source -e -v $tcl_clock_ndr_rules_file
{% endif %}

# Report routing rules ------------------------------------------------------
redirect -file {{cur.cur_flow_rpt_dir}}/settings.common.cts.report_routing_rules.rpt {report_routing_rules -verbose}
redirect -file {{cur.cur_flow_rpt_dir}}/settings.common.cts.report_clock_routing_rules.rpt {report_clock_routing_rules}

# vt control----------------------------------------------------------------------

set_attribute -quiet [get_lib_cells -quiet {{local.svt_lib_cells}}] threshold_voltage_group SVT
set_attribute -quiet [get_lib_cells -quiet {{local.lvt_lib_cells}}] threshold_voltage_group LVT
set_attribute -quiet [get_lib_cells -quiet {{local.ulvt_lib_cells}}] threshold_voltage_group ULVT

set_threshold_voltage_group_type -type low_vt ULVT 
set_threshold_voltage_group_type -type normal_vt LVT 
set_threshold_voltage_group_type -type high_vt SVT 

set_max_lvth_percentage 90
