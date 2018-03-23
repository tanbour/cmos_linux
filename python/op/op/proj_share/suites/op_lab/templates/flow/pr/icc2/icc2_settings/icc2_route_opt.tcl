puts "this is icc2 route_opt settings"

## Router settings----------------------------------------------------------------------
set_app_options -name route.global.timing_driven -value true
set_app_options -name route.track.timing_driven -value true
set_app_options -name route.detail.timing_driven -value true
set_app_options -name route.global.crosstalk_driven -value false
set_app_options -name route.track.crosstalk_driven -value true
set_app_options -name route.detail.repair_shorts_over_macros_effort_level  -value medium
{%- if local.route_common_threshold_noise_ratio %}
set_app_options -name route.common.threshold_noise_ratio -value {{local.route_common_threshold_noise_ratio}}
{%- endif %}

## Antenna analysis and fixing settings----------------------------------------------------------------------
{%- if local.route_opt_antenna_fixing == "true" %}
	if {[file exists [which $tcl_antenna_rule_file]]} {
		puts "Alchip-info : Sourcing [which $tcl_antenna_rule_file]"
		source $tcl_antenna_rule_file
	} else {
	set_app_options -name route.detail.antenna -value false ;# default true
	set_app_options -name route.detail.hop_layers_to_fix_antenna -value false ;# default true
}
{%- endif %}

## Redundant via insertion settings----------------------------------------------------------------------
{%- if local.tcl_user_icc2_format_redundant_via_mapping_file %} 
source $tcl_user_icc2_format_redundant_via_mapping_file
{%- endif %}
{%- if local.tcl_user_icc_format_redundant_via_mapping_file %} 
add_via_mapping -from_icc_file $tcl_user_icc_redundant_via_mapping_file
{%- endif %}
redirect -tee $blk_rpt_dir/report_via_map.rpt {report_via_mapping}

{%- if local.icc2_route_opt_optimize_double_via == "true" %} 
    set_app_options -name route.common.post_detail_route_redundant_via_insertion -value medium ;# default off
{%- if concurrent_redundant_via_mode_reserve_space == "true" %}
    set_app_options -name route.common.concurrent_redundant_via_mode -value reserve_space ;# default off
{%- endif %}
	set_app_options -name route.common.eco_route_concurrent_redundant_via_mode -value reserve_space ;# default off
{%- endif %}

## To insert redundant vias starting from lower layers first then process higher layers, set the following.
#  Depending on the design, redundant via insertion rates on DPT layers can be higher if insertion is done from lower to upper layers.
#	set_app_options -name route.detail.insert_redundant_vias_layer_order_low_to_high -value true ;# default false

## PPA - Performance focused features----------------------------------------------------------------------
{%- if local.route_opt_enable_ccd == "true" %}
set_app_option -name route_opt.flow.enable_ccd -value true
{%- else %}
set_app_option -name route_opt.flow.enable_ccd -value false
{%- endif %}

## PPA - Power focused features----------------------------------------------------------------------
{%- if local.route_opt_leakage_power_optimization == "true" %}
	set_app_options -name route_opt.flow.enable_power -value true ;# default false; global-scoped and needs to be re-applied in a new session
{%- endif %}

## Timing settings----------------------------------------------------------------------
{%- if local.si_enable_analysis == "true" %}
set_app_options -name time.si_enable_analysis -value true ;# default false
{%- endif %}

## ECO route settings ----------------------------------------------------------------------
## To disable soft-rule-based timing optimization during ECO routing, uncomment the following.
#  This is to limit spreading which can impact convergence by touching multiple routes.
#	set_app_options -name route.detail.eco_route_use_soft_spacing_for_timing_optimization -value false

## ECO router control : 
#  route_opt default is 5. The following adds more S&R for each iteration of eco route in route_opt. 
#  This is useful at 20nm and below for better DRC reduction and less calls to router 
set_app_options -name route.detail.eco_max_number_of_iterations -value 10 


