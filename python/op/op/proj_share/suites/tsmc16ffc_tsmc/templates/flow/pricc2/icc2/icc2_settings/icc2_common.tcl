puts "Alchip-info: starting icc2 common settings.........."

###=============================================================================##
## Varible control by varaible OPTIMIZATION_FLOW with value $OPTIMIZATION_FLOW  ##
##==============================================================================##
set PREROUTE_TIMING_OPTIMIZATION_EFFORT_HIGH       {{local.optimization_flow}} ;# sets opt.timing.effort to high to enable higher effort timing optimization in preroute value of $OPTIMIZATION_FLOW will be converted   
                                                                               ;# ttr:false|qor:true|hplp:true|arlp:true|hc:true
set PREROUTE_TNS_DRIVEN_PLACEMENT                  {{local.optimization_flow}} ;# sets place.coarse.tns_driven_placement to true to make timing-driven placer to optimize TNS instead of WNS 
                                                                               ;# ttr:false|qor:false|hplp:true|arlp:true|hc:false
set PREROUTE_LAYER_OPTIMIZATION                    {{local.optimization_flow}} ;# sets place_opt/refine_opt/clock_opt.flow.optimize_layers to true enable layer optimization value of $OPTIMIZATION_FLOW will be converted
                                                                               ;# ttr:false|qor:true|hplp:false|arlp:false|hc:true
set PREROUTE_POWER_OPTIMIZATION_MODE               {{local.optimization_flow}} ;# sets opt.power.mode to the specified type value of $OPTIMIZATION_FLOW will be converted
                                                                               ;# ttr:leakage|qor:total|hplp:total|arlp:total|hc:total
set PREROUTE_POWER_OPTIMIZATION_EFFORT             {{local.optimization_flow}} ;# sets opt.power.effort to the specified effort value of $OPTIMIZATION_FLOW will be converted
                                                                               ;#ttr:low|qor:medium|hplp:high|arlp:high|hc:mediu
set PREROUTE_AREA_RECOVERY_EFFORT                  {{local.optimization_flow}} ;# sets opt.area.effort to control optimization effort for area recovery value of $OPTIMIZATION_FLOW will be converted
                                                                               ;# ttr:low|qor:medium|hplp:high|arlp:ultra|hc:medium"
set PREROUTE_BUFFER_AREA_EFFORT                    {{local.optimization_flow}} ;#sets app option opt.common.buffer_area_effort to reduce buffer area usage in data path optimization value of $OPTIMIZATION_FLOW will be converted 
                                                                               ;#ttr:low|qor:low|hplp:ultra|arlp:ultra|hc:low"
set PREROUTE_ROUTE_AWARE_ESTIMATION                {{local.optimization_flow}} ;#sets opt.common.use_route_aware_estimation to true to use layer-aware parasitics in preroute extraction value of $OPTIMIZATION_FLOW will be converted
                                                                               ;#ttr:false|qor:false|hplp:true|arlp:true|hc:false
set PREROUTE_PLACEMENT_DETECT_CHANNEL              {{local.optimization_flow}} ;#sets place.coarse.channel_detect_mode to true to enable channel detect mode in coarse placemen value of $OPTIMIZATION_FLOW will be converted
                                                                               ;#ttr:false|qor:false|hplp:true|arlp:true|hc:true
set PREROUTE_PLACEMENT_DETECT_DETOUR               {{local.optimization_flow}} ;#sets place.coarse.detect_detours to true to enable detour detection during coarse placement value of $OPTIMIZATION_FLOW will be converted
                                                                               ;#ttr:false|qor:false|hplp:true|arlp:true|hc:true
set PREROUTE_PLACEMENT_MAX_DENSITY                 {{local.optimization_flow}} ;# sets place.coarse.max_density to limit local density to be less than the specified value value of $OPTIMIZATION_FLOW will be converted
                                                                               ;# ttr:0.93|qor:0.93|hplp:0.7|arlp:0.7|hc:0.5
set PREROUTE_PLACEMENT_TARGET_ROUTING_DENSITY      {{local.optimization_flow}} ;# sets place.coarse.target_routing_density to control target routing density for congestion-driven placement                                                                                                                         ;# ttr:0|qor:0|hplp:0|arlp:0|hc:0.6
###==================================================================##
## Useful optimization control variable                              ##
##===================================================================##
set PREROUTE_PLACEMENT_MAX_UTIL                        "{{local.preroute_placement_max_util}}"
set PREROUTE_PLACEMENT_PRECLUSTER                      "{{local.preroute_placement_precluster}}"
set PREROUTE_PLACEMENT_PIN_DENSITY_AWARE               "{{local.preroute_placement_pin_density_aware}}"
set PREROUTE_NDR_OPTIMIZATION                          "{{local.preroute_ndr_optimization}}"
set PREROUTE_LAYER_OPTIMIZATION_CRITICAL_RANGE         "{{local.preroute_layer_optimization_critical_range}}"
set TIE_CELL_MAX_FANOUT                                "{{local.tie_cell_max_fanout}}"
set PLACE_OPT_TRIAL_CTS                                "{{local.place_opt_trial_cts}}"
set PLACE_OPT_OPTIMIZE_ICGS                            "{{local.place_opt_optimize_icgs}} "
set PLACE_OPT_OPTIMIZE_ICGS_CRITICAL_RANGE             "{{local.place_opt_optimize_icgs_critical_range}}"
set PLACE_OPT_ICG_AUTO_BOUND                           "{{local.place_opt_icg_auto_bound}}"
set PLACE_OPT_ICG_AUTO_BOUND_FANOUT_LIMIT              "{{local.place_opt_icg_auto_bound_fanout_limit}}"
set PLACE_OPT_CLOCK_AWARE_PLACEMENT                    "{{local.place_opt_clock_aware_placement}}"
set PLACE_OPT_MULTIBIT_BANKING                         "{{local.place_opt_multibit_banking}}"
set PLACE_OPT_MULTIBIT_DEBANKING                       "{{local.place_opt_multibit_debanking}}"
set DATA_PATH_MAX_FANOUT                               "{{local.data_path_max_fanout}}"
set DATA_PATH_MAX_NET_LENGTH                           "{{local.data_path_max_net_length}}"
set LVT_LIB_CELL_LIST                                  "{{local.lvt_lib_cell_list}}"
set SVT_LIB_CELL_LIST                                  "{{local.svt_lib_cell_list}}"
set HVT_LIB_CELL_LIST                                  "{{local.hvt_lib_cell_list}}"
set LVTH_CELL_MAX_PERCENTAGE                           "{{local.lvth_cell_max_percentage}}"
set SWITCH_ACTIVITY_FILE                               "{{local.switch_activity_file}}"
{%- if local.lib_cell_dont_use_list is string %}
set LIB_CELL_DONT_USE_LIST                             "{{local.lib_cell_dont_use_list}}"
{%- elif local.lib_cell_dont_use_list is sequence %}
set LIB_CELL_DONT_USE_LIST                             "{{local.lib_cell_dont_use_list|join (' ')}}"
{%- endif %}
set MAX_ROUTING_LAYER                                  "{{local.max_routing_layer}}"
set MIN_ROUTING_LAYER                                  "{{local.min_routing_layer}}"
set CTS_MAX_NET_LENGTH                                 "{{local.cts_max_net_lengt}}"
set CTS_MAX_FANOUT                                     "{{local.cts_max_fanout}}"
set CTS_TARGET_SKEW                                    "{{local.cts_target_skew}}"              
set CTS_TARGET_LATENCY                                 "{{local.cts_target_latency}}"
set CTS_ROOT_NDR_RULE_NAME                             "{{local.cts_root_ndr_rule_name}}"
set CTS_INTERNAL_NDR_RULE_NAME                         "{{local.cts_internal_ndr_rule_name}}"  
set CTS_SINK_NDR_RULE_NAME                             "{{local.cts_sink_ndr_rule_name}}"
set CTS_ROOT_NDR_MIN_ROUTING_LAYER                     "{{local.cts_root_ndr_min_routing_layer}}"
set CTS_ROOT_NDR_MAX_ROUTING_LAYER                     "{{local.cts_root_ndr_max_routing_layer}}"
set CTS_INTERNAL_NDR_MIN_ROUTING_LAYER                 "{{local.cts_internal_ndr_min_routing_layer}}"
set CTS_INTERNAL_NDR_MAX_ROUTING_LAYER                 "{{local.cts_internal_ndr_max_routing_layer}}"
set CTS_SINK_NDR_MIN_ROUTING_LAYER                     "{{local.cts_sink_ndr_min_routing_layer}}"
set CTS_SINK_NDR_MAX_ROUTING_LAYER                     "{{local.cts_sink_ndr_max_routing_layer}}"
{%- if local.cts_lib_cell_pattern_list is string %}
set CTS_LIB_CELL_PATTERN_LIST                          "{{local.cts_lib_cell_pattern_list}}" 
{%- elif local.cts_lib_cell_pattern_list is sequence %}
set CTS_LIB_CELL_PATTERN_LIST                          "{{local.cts_lib_cell_pattern_list|join (' ')}}" 
{%- endif %} 
set OPT_DYNAMIC_POWER                                  "{{local.opt_dynamic_power}}"

## placement continue without scandef settings---------------------------------------------
set_app_options -name place.coarse.continue_on_missing_scandef -value true

## PPA - Performance focused features------------------------------------------------------
{%- if local.optimization_flow == "ttr"  %}
set_app_option -name opt.timing.effort -value low
{%- elif local.optimization_flow == "qor" or local.optimization_flow == "hplp" or local.optimization_flow == "arlp" or local.optimization_flow == "hc" %}
set_app_option -name opt.timing.effort -value high
{%- endif %}

{%- if local.optimization_flow == "ttr" or local.optimization_flow == "qor" or local.optimization_flow == "hc" %}
set_app_option -name place.coarse.tns_driven_placement -value false
{%- elif  local.optimization_flow == "hplp" or local.optimization_flow == "arlp" %}
set_app_option -name place.coarse.tns_driven_placement -value true
{%- endif %}

{%- if local.optimization_flow == "ttr" or local.optimization_flow == "hplp" or local.optimization_flow == "arlp" %}
set_app_option -name place_opt.flow.optimize_layers -value false
set_app_option -name refine_opt.flow.optimize_layers -value false
{%- elif  local.optimization_flow == "qor" or local.optimization_flow == "hc" %}
set_app_option -name place_opt.flow.optimize_layers -value true
set_app_option -name refine_opt.flow.optimize_layers -value true
{%- if local.preroute_layer_optimization_critical_range %}
set_app_options -name place_opt.flow.optimize_layers_critical_range  -value {{local.preroute_layer_optimization_critical_range}} 
{%- endif %}
{%- endif %}

## NDR optimization in preroute settings---------------------------------------------------
{%- if local.preroute_ndr_optimization == "true" %}
	set_app_options -name place_opt.flow.optimize_ndr -value true ;# default false 
	set_app_options -name refine_opt.flow.optimize_ndr -value true ;# default false 
	set_app_options -name clock_opt.flow.optimize_ndr -value true ;# default false 
{%- endif %}

## DATA PATH max fanout/max net length/ max tansition/ max capacitance settings-----------
{%- if local.data_path_max_fanout %}
set_app_options -name opt.common.max_fanout -value $DATA_PATH_MAX_FANOUT ;# default 40, if no fanout constraint apply
{%- endif %}
{%- if local.data_path_max_net_length %}
set_app_options -name opt.common.max_net_length -value $DATA_PATH_MAX_NET_LENGTH ;# default no constraint on this
{%- endif %}

## PPA - Power focused features -----------------------------------------------------------
# Set your threshold_voltage_group attributes--------------------------
  	define_user_attribute -type string -class lib_cell threshold_voltage_group

{%- if local.lvt_lib_cell_list %}
    set_attribute -quiet [get_lib_cells -quiet $LVT_LIB_CELL_LIST] threshold_voltage_group LVt
    set_threshold_voltage_group_type -type low_vt LVt
    {%- endif %}

{%- if local.svt_lib_cell_list %}
   	set_attribute -quiet [get_lib_cells -quiet $SVT_LIB_CELL_LIST] threshold_voltage_group SVt
  	set_threshold_voltage_group_type -type normal_vt SVt
    {%- endif %}

{%- if local.hvt_lib_cell_list %}
  	set_attribute -quiet [get_lib_cells -quiet $HVT_LIB_CELL_LIST] threshold_voltage_group HVt
  	set_threshold_voltage_group_type -type high_vt HVt
    {%- endif %}
    
{%- if local.lvt_lib_cell_list or local.lvth_cell_max_percentage %}
    set_max_lvth_percentage $LVTH_CELL_MAX_PERCENTAGE
	set_app_option -name opt.power.leakage_type -value percentage_lvt ;# default conventional
{%- endif %}

## Power optimization mode-------------------------------------------------
{%- if local.optimization_flow == "ttr"  %}
set_app_option -name opt.power.mode -value leakage
{%- elif local.optimization_flow == "qor" or local.optimization_flow == "hc" or local.optimization_flow == "hplp" or local.optimization_flow == "arlp" %}
set_app_option -name opt.power.mode -value total
{%- endif %}

{%- if local.optimization_flow == "ttr" or local.optimization_flow == "qor" or local.optimization_flow == "hc"  %}
set_app_option -name opt.power.effort -value medium
{%- elif  local.optimization_flow == "hplp" or local.optimization_flow == "arlp" %}
set_app_option -name opt.power.effort -value high
{%- endif %}

{%- if local.opt_dynamic_power == "true" %}
	set_app_option -name place.coarse.low_power_placement -value true
{%- endif %}

{%- if local.switch_activity_file %}
	set_app_options -name place.coarse.low_power_placement -value true ;# default false
{%- endif %}

## PPA - Area focused features---------------------------------------------------
{%- if local.optimization_flow == "ttr"  %}
set_app_option -name opt.area.effort -value low
{%- elif local.optimization_flow == "qor" or local.optimization_flow == "hc" %}
set_app_option -name opt.area.effort -value medium
{%- elif local.optimization_flow == "hplp" %}
set_app_option -name opt.area.effort -value high
{%- elif local.optimization_flow == "arlp" %}
set_app_option -name opt.area.effort -value ultra
{%- endif %}

{%- if local.optimization_flow == "ttr" or local.optimization_flow == "qor" or  local.optimization_flow == "hc" %}
set_app_option -name opt.common.buffer_area_effort -value low
{%- elif local.optimization_flow == "hplp" or local.optimization_flow == "arlp" %}
set_app_option -name opt.common.buffer_area_effort -value ultra
{%- endif %}

{%- if local.optimization_flow == "ttr" or local.optimization_flow == "qor" or  local.optimization_flow == "hc" %}
set_app_option -name opt.common.use_route_aware_estimation -value false
{%- elif local.optimization_flow == "hplp" or local.optimization_flow == "arlp" %}
set_app_option -name opt.common.use_route_aware_estimation -value true
{%- endif %}

## Congestion handling focused features -------------------------------------
{%- if local.optimization_flow == "ttr" or local.optimization_flow == "qor"  %}
set_app_option -name place.coarse.channel_detect_mode -value false
{%- elif local.optimization_flow == "hc" or local.optimization_flow == "hplp" or local.optimization_flow == "arlp" %}
set_app_option -name place.coarse.channel_detect_mode -value true
{%- endif %}

{%- if local.optimization_flow == "ttr" or local.optimization_flow == "qor"  %}
set_app_option -name place.coarse.detect_detours -value false
{%- elif local.optimization_flow == "hc" or local.optimization_flow == "hplp" or local.optimization_flow == "arlp" %}
set_app_option -name place.coarse.detect_detours -value true
{%- endif %}

{%- if local.optimization_flow == "ttr" or local.optimization_flow == "qor"  %}
set_app_option -name place.coarse.max_density -value 0
{%- elif local.optimization_flow == "hplp" or local.optimization_flow == "arlp" %}
set_app_option -name place.coarse.max_density -value 0.7
{%- elif local.optimization_flow == "hc" %}
set_app_option -name place.coarse.max_density -value 0.5
{%- endif %}

{%- if local.optimization_flow == "ttr" or local.optimization_flow == "qor" or local.optimization_flow == "hplp" or local.optimization_flow == "arlp" %}
set_app_option -name place.coarse.target_routing_density -value 0
{%- elif local.optimization_flow == "hc" %}
set_app_option -name place.coarse.target_routing_density -value 0.6
{%- endif %}

## Specify the maximum design utilization after congestion driven padding during congestion driven placement
{%- if local.preroute_placement_max_util %}
	set_app_options -name place.coarse.congestion_driven_max_util -value $PREROUTE_PLACEMENT_MAX_UTIL ;# default 0.93
{%- endif %}

{%- if local.preroute_placement_precluster == "true" %}
	set_app_options -name place.coarse.precluster -value true ;# default false
{%- endif %}

## Lib cell usage restrictions (set_lib_cell_purpose)------------------------------------
{%- if local.lib_cell_dont_use_list %}
	puts "Alchip-info: Lib Cells $LIB_CELL_DONT_USE_LIST will not be used in design"
	set_lib_cell_purpose -include none [get_lib_cell $LIB_CELL_DONT_USE_LIST]
{%- endif %}
 
## Additional optimization related settings-----------------------------------------------
set_app_options -name opt.port.eliminate_verilog_assign -value true ;# default false
## To enable switching activity persistency-----------------------------
set_app_options -name power.enable_activity_persistency -value on ;# default off
## To set tie cell max fanout-------------------------------------------
set_app_options -name opt.tie_cell.max_fanout -value $TIE_CELL_MAX_FANOUT ;# default 10

## Additional placement and legalization related settings ---------------------------------
{%- if local.preroute_placement_pin_density_aware %}
	set_app_option -name place.coarse.pin_density_aware -value true
{%- endif %}

## Placement spacing labels and rules------------------------------------
puts "Alchip-info: Sourcing [which $TCL_PLACEMENT_SPACING_LABEL_RULE_FILE]"
source $TCL_PLACEMENT_SPACING_LABEL_RULE_FILE

## Soft blockage enhancement : to prevent incremental coarse placer from moving cells out of soft blockages
#	set_app_options -name place.coarse.enable_enhanced_soft_blockages -value true

{%- if local.max_routing_layer %}
set_ignored_layers -max_routing_layer $MAX_ROUTING_LAYER
{%- endif %}
{%- if local.min_routing_layer %}
set_ignored_layers -min_routing_layer $MIN_ROUTING_LAYER
{%- endif %}

{%- if cur.sub_stage == "clock.tcl" or cur.sub_stage == "clock_opt.tcl" or local.place_opt_optimize_icgs == "ture" or local.place_enable_ccd == "true" %}
###==================================================================##
## CTS common setting, only open while in clock/clock_opt stage      ##
## also do place_ccd or place_opt icg optimization                   ##
##===================================================================##

## CTS max length/max_fanout/ transition /capacitance---------------------------
{%- if local.cts_max_net_length %} 
set_app_options -name cts.common.max_net_length -value $CTS_MAX_NET_LENGTH
{%- else %}
 puts "Information: CTS has no max length constraint."
{%- endif %}

{%- if local.cts_max_fanout %}
set_app_options -name cts.common.max_fanout -value $CTS_MAX_FANOUT
{%- else %}
puts "Information: CTS has no max fanout constraint."
{%- endif %}

## CTS target skew and latency----------------------------------------------------
# By default CTS targets best skew and latency. These options can be used in case user wants to relax the target.
{%- if local.cts_target_skew %}
set_clock_tree_options -target_skew $CTS_TARGET_SKEW 
{%- endif %}

{%- if local.cts_target_latency %}
set_clock_tree_options -target_latency $CTS_TARGET_LATENCY
{%- endif %}

# NDR for root and internal nets----------------------------------------------------------------------
puts "Alchip-info: Sourcing [which $TCL_ICC2_CTS_NDR_RULE_FILE]"
source -v -e $TCL_ICC2_CTS_NDR_RULE_FILE

{%- if local.cts_root_ndr_rule_name %}
	# Check if the rule has been created properly
	redirect -var x {report_routing_rules $CTS_ROOT_NDR_RULE_NAME}
	if {![regexp "Error" $x]} {
		# set_clock_routing_rules on root nets
		set set_clock_routing_rules_cmd_root "set_clock_routing_rules -net_type root -rule $CTS_ROOT_NDR_RULE_NAME"
        {%- if local.cts_root_ndr_min_routing_layer %}
		lappend set_clock_routing_rules_cmd_root -min_routing_layer $CTS_ROOT_NDR_MIN_ROUTING_LAYER
        {%- endif %}
        {%- if local.cts_root_ndr_max_routing_layer %}
		lappend set_clock_routing_rules_cmd_root -max_routing_layer $CTS_ROOT_NDR_MAX_ROUTING_LAYER
        {%- endif %}
		puts "Alchip-info: $set_clock_routing_rules_cmd_root"
		eval ${set_clock_routing_rules_cmd_root}
		} else {
		puts "Alchip-error: CTS_ROOT_NDR_RULE_NAME($CTS_ROOT_NDR_RULE_NAME) hasn't been created yet. Can not associate it with root nets!"
	}
{%- endif %}

{%- if local.cts_internal_ndr_rule_name %}
	# Check if the rule has been created properly
	redirect -var x {report_routing_rules $CTS_INTERNAL_NDR_RULE_NAME}
	if {![regexp "Error" $x]} {
		# set_clock_routing_rules on internal nets
		set set_clock_routing_rules_cmd_internal "set_clock_routing_rules -net_type internal -rule $CTS_INTERNAL_NDR_RULE_NAME"
        {%- if local.cts_internal_ndr_min_routing_layer %}
        lappend set_clock_routing_rules_cmd_internal -min_routing_layer $CTS_INTERNAL_NDR_MIN_ROUTING_LAYER
        {%- endif %}
        {%- if local.cts_internal_ndr_max_routing_layer %}
        lappend set_clock_routing_rules_cmd_internal -max_routing_layer $CTS_INTERNAL_NDR_MAX_ROUTING_LAYER
        {%- endif %}
        puts "Alchip-info: $set_clock_routing_rules_cmd_internal"
		eval ${set_clock_routing_rules_cmd_internal}
	} else {
		puts "Alchip-error: CTS_INTERNAL_NDR_RULE_NAME($CTS_INTERNAL_NDR_RULE_NAME) hasn't been created yet. Can not associate it with internal nets!"
	}
{%- endif %}

# NDR for leaf (sink) nets----------------------------------------------------------------------
{%- if local.cts_sink_ndr_rule_name %}
	# Check if the rule has been created properly
	redirect -var x {report_routing_rules $CTS_SINK_NDR_RULE_NAME}
	if {![regexp "Error" $x]} {
		set set_clock_routing_rules_cmd_leaf "set_clock_routing_rules -net_type sink -rule $CTS_SINK_NDR_RULE_NAME"
        {%- if local.cts_sink_ndr_min_routing_layer %}
		lappend set_clock_routing_rules_cmd_leaf -min_routing_layer $CTS_SINK_NDR_MIN_ROUTING_LAYER
        {%- endif %}
        {%- if local.cts_sink_ndr_max_routing_layer %}
		lappend set_clock_routing_rules_cmd_leaf -max_routing_layer $CTS_SINK_NDR_MAX_ROUTING_LAYER
        {%- endif %}
		puts "Alchip-info: $set_clock_routing_rules_cmd_leaf"
		eval $set_clock_routing_rules_cmd_leaf
	} else {
		puts "Alchip-error: CTS_SINK_NDR_RULE_NAME($CTS_SINK_NDR_RULE_NAME) hasn't been created yet. Can not associate it with sink nets!"
	}
{%- endif %}

{%- if local.cts_lib_cell_pattern_list %}
 	set_lib_cell_purpose -exclude cts [get_lib_cells */*]
{%- endif %}
{%- if local.cts_lib_cell_pattern_list %}
 	set_dont_touch [get_lib_cells $CTS_LIB_CELL_PATTERN_LIST] false ;# In ICC-II, CTS respects dont_touch
 	set_lib_cell_purpose -include cts [get_lib_cells $CTS_LIB_CELL_PATTERN_LIST]
{%- endif %}
# To prevent CTS from punching new logical ports for logical hierarchies
# set_freeze_ports -clocks [get_cells {block1}]
{%- endif %}
puts "Alchip-info: Ending icc2 common settings.........."

