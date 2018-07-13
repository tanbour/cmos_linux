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

