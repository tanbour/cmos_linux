##==================================================================##
## settings.step.route_auto.tcl                                     ##
##==================================================================##
#  This threshold is for the router to identity the criticality of xtalk impact of the nets.
set route_common_threshold_noise_ratio             "{{local.route_common_threshold_noise_ratio}}"
set route_auto_antenna_fixing                      "{{local.route_auto_antenna_fixing}}"
set tcl_antenna_rule_file                          "{{local.tcl_antenna_rule_file}}"
set redundant_via_insertion                        "{{local.redundant_via_insertion}}"
set tcl_user_icc2_redundant_via_mapping_file       "{{local.tcl_user_icc2_redundant_via_mapping_file}}"
set tcl_user_icc_redundant_via_mapping_file        "{{local.tcl_user_icc_redundant_via_mapping_file}}" 

## Router----------------------------------------------------------------------
# set_app_options -name route.global.timing_driven -value true ;# already set in icc2_common.tcl 
set_app_options -name route.track.timing_driven -value true
set_app_options -name route.detail.timing_driven -value true
set_app_options -name route.global.crosstalk_driven -value false
set_app_options -name route.track.crosstalk_driven -value true

set_app_options -name route.common.threshold_noise_ratio -value $route_common_threshold_noise_ratio

## Antenna analysis and fixing--------------------------------------------------
{%- if local.route_auto_antenna_fixing %}
source $tcl_antenna_rule_file
{% else %}
## Disables antenna analysis and fix
set_app_options -name route.detail.antenna -value false ;# default true
## Disables layer hopping for antenna fix
set_app_options -name route.detail.hop_layers_to_fix_antenna -value false ;# default true
{% endif %}

## Redundant via insertion---------------------------------------------------------
{% if local.redundant_via_insertion %}
{%- if local.tcl_user_icc2_redundant_via_mapping_file %}
## Source ICC-II via mapping file for redundant via insertion	
source $tcl_user_icc2_redundant_via_mapping_file
redirect -file {{cur.cur_flow_rpt_dir}}/report_via_mapping.rpt {report_via_mapping}
{%- elif local.tcl_user_icc_redundant_via_mapping_file %}
## Source ICC via mapping file that contains define_zrt_redundant_vias commands
add_via_mapping -from_icc_file $tcl_user_icc_redundant_via_mapping_file
redirect -file {{cur.cur_flow_rpt_dir}}/report_via_mapping.rpt {report_via_mapping}
{%- endif %}
## Enable redundant via insertion 
#  For advanced nodes, where DRC could be a concern, reserve space and run standalone add_redundant_vias command after route_auto and route_opt.
set_app_options -name route.common.concurrent_redundant_via_mode -value reserve_space ;# default off
set_app_options -name route.common.eco_route_concurrent_redundant_via_mode -value reserve_space ;# default off
set_app_options -name route.detail.insert_redundant_vias_layer_order_low_to_high -value true ;# default false
{%- endif %}

## Timing----------------------------------------------------------------------
## Enable crosstalk analysis and the extraction of the routed nets along with their coupling caps
set_app_options -name time.si_enable_analysis -value true ;# default false

## MISC----------------------------------------------------------------------
## Prepare the design for final routing if GRLB (global route layer aware optimization) is enabled in preroute;
#  However if CLOCK_OPT_GLOBAL_ROUTE_OPT is also enabled along with GRLB, the following is not needed because
#  CLOCK_OPT_GLOBAL_ROUTE_OPT will automatically perform remove_route_aware_estimation  
if {[get_app_option_value -name opt.common.use_route_aware_estimation] != "false" } {
	remove_route_aware_estimation
}

##==================================================================##
## settings.step.route_opt.tcl                                      ##
##==================================================================##
# route_opt CCD and buffer removal during CCD (RM default true)
set route_opt_ccd                                 "{{local.route_opt_ccd}}"
# Leakage optimization during route_opt (RM default true)
set route_opt_leakage_power_optimization          "{{local.route_opt_leakage_power_optimization}}"
# Enable power or area recovery from clock cells and registers during route_opt (RM default power)
set route_opt_power_recovery                      "{{local.route_opt_power_recovery}}"
# Incremental reshielding
set route_auto_create_shields                     "{{local.route_auto_create_shields}}"
set route_opt_reshield                            "{{local.route_opt_reshield}}"

## Timing----------------------------------------------------------------------
# Enable delay calculation using CCS receiver model during timing analysis (RM default true)
puts "RM-info: Setting time.enable_ccs_rcv_cap to true (tool default false)"
set_app_options -name time.enable_ccs_rcv_cap -value true

# Enable CCS waveform analysis (AWP) on the entire design
#  Recommended for designs with technology nodes 10nm and below.
#  Note :
#  - CCS waveform analysis requires libraries that contain CCS timing and CCS noise data.
#    Contact Synopsys if you require assistance to fine tune AWP usage on your design.
set_app_options -name time.delay_calc_waveform_analysis_mode -value full_design
  
#  - To make use of the new AWP algorithm, please set the following.
#    Default true enables original AWP engine. Set it to false enables new engine that is more aligned to primetime results.
set_app_options -name time.awp_compatibility_mode -value false ;# tool default true

## PPA - Performance focused features---------------------------------------------
# route_opt CCD and buffer removal during CCD (RM default true)
puts "RM-info: Setting route_opt.flow.enable_ccd and ccd.post_route_buffer_removal to $route_opt_ccd (tool default false)"
set_app_option -name route_opt.flow.enable_ccd -value $route_opt_ccd
set_app_option -name ccd.post_route_buffer_removal -value $route_opt_ccd

## PPA - Power focused features---------------------------------------------------
# Leakage optimization during route_opt (RM default true)
puts "RM-info: Setting route_opt.flow.enable_power to $route_opt_leakage_power_optimization (tool default false)"
set_app_options -name route_opt.flow.enable_power -value $route_opt_leakage_power_optimization

## Enable power or area recovery from clock cells and registers during route_opt (RM default power)
puts "RM-info: Setting route_opt.flow.enable_clock_power_recovery to $route_opt_power_recovery (tool default none)"
set_app_option -name route_opt.flow.enable_clock_power_recovery -value $route_opt_power_recovery

## route_opt CTO for non-CCD flow---------------------------------------------------
{% if local.route_opt_cto == "true" and local.route_opt_ccd == "false" %}
puts "RM-info: Setting route_opt.flow.enable_cto to true (tool default false)"
set_app_options -name route_opt.flow.enable_cto -value true ;# global-scoped and needs to be re-applied in a new session
{%- endif %}

# ECO route----------------------------------------------------------------------
{#
   ## To disable soft-rule-based timing optimization during ECO routing, uncomment the following.
   #  This is to limit spreading which can impact convergence by touching multiple routes.
   #	set_app_options -name route.detail.eco_route_use_soft_spacing_for_timing_optimization -value false
#}
# ECO router control : 
#  route_opt default is 5. The following adds more S&R for each iteration of eco route in route_opt. 
puts "RM-info: Setting route.detail.eco_max_number_of_iterations to 10 (tool default -1)"
set_app_options -name route.detail.eco_max_number_of_iterations -value 10 

## Incremental reshielding---------------------------------------------------------
{%- if local.route_auto_create_shields != "none" and local.route_opt_reshield == "incremental" %}
puts "RM-info: Setting route.common.reshield_modified_nets to reshield (tool default off)"
set_app_options -name route.common.reshield_modified_nets -value reshield
{% endif %}
