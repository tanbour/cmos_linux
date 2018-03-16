puts "Alchip-info: starting icc2 common settings.........."
###############################################################################
## Varible control by varaible OPTIMIZATION_FLOW with value $OPTIMIZATION_FLOW
###############################################################################
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
###############################################################################
## Useful optimization control variable
###############################################################################
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
{%- if local.cts_lib_cell_pattern_list is string %}
set CTS_LIB_CELL_PATTERN_LIST                          "{{local.cts_lib_cell_pattern_list}}" 
{%- elif local.cts_lib_cell_pattern_list is sequence %}
set CTS_LIB_CELL_PATTERN_LIST                          "{{local.cts_lib_cell_pattern_list|join (' ')}}" 
{%- endif %} 
set OPT_DYNAMIC_POWER                                  "{{local.opt_dynamic_power}}"
#set TCL_ICC2_CTS_NDR_RULE_FILE                         "{{cur.config_plugins_dir}}/icc2_scripts/common_scripts/icc2_cts_ndr_rule.tcl"    
#set TCL_PLACEMENT_SPACING_LABEL_RULE_FILE              "{{cur.config_plugins_dir}}/icc2_scripts/common_scripts/placement_spacing_rule.tcl"
########################################################################
## placement continue without scandef
########################################################################
set_app_options -name place.coarse.continue_on_missing_scandef -value true

########################################################################
## PPA - Performance focused features
########################################################################
switch -regexp $PREROUTE_TIMING_OPTIMIZATION_EFFORT_HIGH {
	"ttr|false"             {set_app_option -name opt.timing.effort -value low ;# tool default}
	"qor|hplp|arlp|hc|true" {set_app_option -name opt.timing.effort -value high}
}

switch -regexp $PREROUTE_TNS_DRIVEN_PLACEMENT {
	"ttr|qor|hc|false"      {set_app_option -name place.coarse.tns_driven_placement -value false ;# tool default}
	"hplp|arlp|true"        {set_app_option -name place.coarse.tns_driven_placement -value true}
}

switch -regexp $PREROUTE_LAYER_OPTIMIZATION {
	"ttr|hplp|arlp|false"   {set_app_option -name place_opt.flow.optimize_layers -value false ;# tool default
				 set_app_option -name refine_opt.flow.optimize_layers -value false ;# tool default}

	"qor|hc|true"           {set_app_option -name place_opt.flow.optimize_layers -value true
			            	 set_app_option -name refine_opt.flow.optimize_layers -value true
			            	   if {$PREROUTE_LAYER_OPTIMIZATION_CRITICAL_RANGE != ""} {
		           	             set_app_options -name place_opt.flow.optimize_layers_critical_range  -value $PREROUTE_LAYER_OPTIMIZATION_CRITICAL_RANGE ;# default 0.7
  }
 }
}

## NDR optimization in preroute
if {$PREROUTE_NDR_OPTIMIZATION} {
	set_app_options -name place_opt.flow.optimize_ndr -value true ;# default false 
	set_app_options -name refine_opt.flow.optimize_ndr -value true ;# default false 
	set_app_options -name clock_opt.flow.optimize_ndr -value true ;# default false 
}

########################################################################
## DATA PATH max fanout/max net length/ max tansition/ max capacitance
########################################################################
if {$DATA_PATH_MAX_FANOUT != ""} {
set_app_options -name opt.common.max_fanout -value $DATA_PATH_MAX_FANOUT ;# default 40, if no fanout constraint apply
}

if {$DATA_PATH_MAX_NET_LENGTH != ""} {
set_app_options -name opt.common.max_net_length -value $DATA_PATH_MAX_NET_LENGTH ;# default no constraint on this
}
########################################################################
## PPA - Power focused features
########################################################################
# Set your threshold_voltage_group attributes. 
  	define_user_attribute -type string -class lib_cell threshold_voltage_group
  	if {$LVT_LIB_CELL_LIST != ""} {
    set_attribute -quiet [get_lib_cells -quiet $LVT_LIB_CELL_LIST] threshold_voltage_group LVt
    set_threshold_voltage_group_type -type low_vt LVt
    }
  	if {$SVT_LIB_CELL_LIST != ""} {
   	set_attribute -quiet [get_lib_cells -quiet $SVT_LIB_CELL_LIST] threshold_voltage_group SVt
  	set_threshold_voltage_group_type -type normal_vt SVt
    }
  	if {$HVT_LIB_CELL_LIST != ""} {
  	set_attribute -quiet [get_lib_cells -quiet $HVT_LIB_CELL_LIST] threshold_voltage_group HVt
  	set_threshold_voltage_group_type -type high_vt HVt
    }
    
    if {$LVT_LIB_CELL_LIST != "" && $LVTH_CELL_MAX_PERCENTAGE != ""} {
    set_max_lvth_percentage $LVTH_CELL_MAX_PERCENTAGE
	set_app_option -name opt.power.leakage_type -value percentage_lvt ;# default conventional
    }

## Power optimization mode
switch -regexp $PREROUTE_POWER_OPTIMIZATION_MODE {
	"ttr|leakage"         {set_app_option -name opt.power.mode -value leakage}
	"qor|hplp|arlp|hc|total" {set_app_option -name opt.power.mode -value total}
	"none"                {set_app_option -name opt.power.mode -value none ;# tool default}
}

switch -regexp $PREROUTE_POWER_OPTIMIZATION_EFFORT {
	"low"                 {set_app_option -name opt.power.effort -value low ;# tool default}
	"ttr|qor|hc|medium"   {set_app_option -name opt.power.effort -value medium}
	"hplp|arlp|high"      {set_app_option -name opt.power.effort -value high}
}

if {$OPT_DYNAMIC_POWER} {
	set_app_option -name place.coarse.low_power_placement -value true
}

if {$SWITCH_ACTIVITY_FILE != ""} {
	set_app_options -name place.coarse.low_power_placement -value true ;# default false
}
########################################################################
## PPA - Area focused features
########################################################################
{# 
#Area recovery effort for preroute optimization
#  Note that TNS degradation can occur when set to higher levels
#  [FLOW] hplp - area recovery with high effort
#  [FLOW] arlp - area recovery with ultra effort as ARLP is focusing on area recovery
#}
switch -regexp $PREROUTE_AREA_RECOVERY_EFFORT {
	"ttr|low"    	      {set_app_option -name opt.area.effort -value low ;# tool default}
	"qor|hc|medium"       {set_app_option -name opt.area.effort -value medium}
	"hplp|high"           {set_app_option -name opt.area.effort -value high}
	"arlp|ultra"          {set_app_option -name opt.area.effort -value ultra}
}
{#
# Buffer area reduction effort for preroute optimization 
#  Note that QoR degradation can occur when set to higher levels
#  [FLOW] hplp - buffer area reduction with ultra effort
#  [FLOW] arlp - with GR-based layer binning, it is recommended to keep buffer area reduction effort set to tool default
#}
switch -regexp $PREROUTE_BUFFER_AREA_EFFORT {
	"ttr|qor|hc|low"      {set_app_option -name opt.common.buffer_area_effort -value low ;# tool default}
	"medium"     	      {set_app_option -name opt.common.buffer_area_effort -value medium}
	"high"     	      {set_app_option -name opt.common.buffer_area_effort -value high}
	"hplp|arlp|ultra"     {set_app_option -name opt.common.buffer_area_effort -value ultra}
}
{#
## GR-based layer binning for preroute flows
#  GR layer aware optimization during preroute for advanced technologies to mitigate pre and post-route mis-correlation.
#  If enabled, remove_route_aware_estimation will be run before route_auto
#  [FLOW] hplp | arlp - enabled  
#}
switch -regexp $PREROUTE_ROUTE_AWARE_ESTIMATION {
	"ttr|qor|hc|false"    {set_app_option -name opt.common.use_route_aware_estimation -value false ;# tool default}
	"hplp|arlp|true"      {set_app_option -name opt.common.use_route_aware_estimation -value true}
}

########################################################################
## Congestion handling focused features
########################################################################
{#
# Channel detect mode in coarse placement
#  [FLOW] hc - enabled
#}
switch -regexp $PREROUTE_PLACEMENT_DETECT_CHANNEL {
	"ttr|qor|false"       {set_app_option -name place.coarse.channel_detect_mode -value false ;# tool default}
	"hplp|arlp|hc|true"   {set_app_option -name place.coarse.channel_detect_mode -value true}
}

{#
# Detour detection during coarse placement
#  [FLOW] hc - enabled
#}
switch -regexp $PREROUTE_PLACEMENT_DETECT_DETOUR {
	"ttr|qor|false"       {set_app_option -name place.coarse.detect_detours -value false ;# tool default}
	"hplp|arlp|hc|true"   {set_app_option -name place.coarse.detect_detours -value true}
} 

{#
# Coarse placement max density
#  To change the maximum density for the coarse placement engine:
#  The coarse placer attempts to limit local density to less than this setting. 
#  Default value of 0 indicates that the placer will try to spread cells evenly.
#  [FLOW] hc - set to 0.5
#}
switch -regexp $PREROUTE_PLACEMENT_MAX_DENSITY {
	"ttr|qor"             {set_app_option -name place.coarse.max_density -value 0}
	"hplp|arlp"           {set_app_option -name place.coarse.max_density -value 0.7}
	"hc"                  {set_app_option -name place.coarse.max_density -value 0.5}
}

{#
# Target routing density for congestion-driven placement
#  [FLOW] hc - set to 0.6
#}
switch -regexp $PREROUTE_PLACEMENT_TARGET_ROUTING_DENSITY {
	"ttr|qor|hplp|arlp"   {set_app_option -name place.coarse.target_routing_density -value 0 ;# tool default}
	"hc"                  {set_app_option -name place.coarse.target_routing_density -value 0.6}
	"default"             {
			       if {$PREROUTE_PLACEMENT_TARGET_ROUTING_DENSITY != ""} {
				 set_app_option -name place.coarse.target_routing_density -value $PREROUTE_PLACEMENT_TARGET_ROUTING_DENSITY
			       }
			      }
}

## Specify the maximum design utilization after congestion driven padding during congestion driven placement
if {$PREROUTE_PLACEMENT_MAX_UTIL != ""} {
	set_app_options -name place.coarse.congestion_driven_max_util -value $PREROUTE_PLACEMENT_MAX_UTIL ;# default 0.93
}

{#
# Enable the preclustering in coarse placement
#  The placer will be more aware of logic modules and naturally clumped groups of logic in your netlist.  
#  In general, the resulting placement will have improved quality with respect to these structures.
#}
if {$PREROUTE_PLACEMENT_PRECLUSTER} {
	set_app_options -name place.coarse.precluster -value true ;# default false
}

########################################################################
## Lib cell usage restrictions (set_lib_cell_purpose)
########################################################################

if {$LIB_CELL_DONT_USE_LIST != ""} {
	puts "Alchip-info: Lib Cells $LIB_CELL_DONT_USE_LIST will not be used in design"
	set_lib_cell_purpose -include none [get_lib_cell $LIB_CELL_DONT_USE_LIST]
} 
########################################################################
## Additional optimization related settings
########################################################################
## To ensure no Verilog assigns in the output netlist of place_opt:
set_app_options -name opt.port.eliminate_verilog_assign -value true ;# default false

## To disable DFT optimization:
# 	set_app_options -name opt.dft.optimize_scan_chain -value false ;# default true

## To enable switching activity persistency
set_app_options -name power.enable_activity_persistency -value on ;# default off
## To set tie cell max fanout
set_app_options -name opt.tie_cell.max_fanout -value $TIE_CELL_MAX_FANOUT ;# default 10

########################################################################
## Additional placement and legalization related settings
########################################################################
## Pin density aware placement for preroute flows 
#  For designs with pin access and local density hot spot issues. 
if {$PREROUTE_PLACEMENT_PIN_DENSITY_AWARE} {
	set_app_option -name place.coarse.pin_density_aware -value true
}
## Placement spacing labels and rules
#  Example : set_placement_spacing_label -name X -side both -lib_cells [get_lib_cells -of [get_cells]]
#  Example : set_placement_spacing_rule -labels {X SNPS_BOUNDARY} {0 1}
	puts "Alchip-info: Sourcing [which $TCL_PLACEMENT_SPACING_LABEL_RULE_FILE]"
	source $TCL_PLACEMENT_SPACING_LABEL_RULE_FILE

## Soft blockage enhancement : to prevent incremental coarse placer from moving cells out of soft blockages
#	set_app_options -name place.coarse.enable_enhanced_soft_blockages -value true


if {$MAX_ROUTING_LAYER != ""} {set_ignored_layers -max_routing_layer $MAX_ROUTING_LAYER}
if {$MIN_ROUTING_LAYER != ""} {set_ignored_layers -min_routing_layer $MIN_ROUTING_LAYER}

{%- if cur.sub_stage == "clock.tcl" or cur.sub_stage == "clock_opt.tcl" or local.place_opt_optimize_icgs == "ture" or local.place_enable_ccd == "true" %}

############################################################################################################
## CTS common setting, only open while in clock/clock_opt stage, also do place_ccd or place_opt icg optimization
############################################################################################################

####################################
## CTS max length/max_fanout/ transition /capacitance 
####################################
if {$CTS_MAX_NET_LENGTH != ""} {
set_app_options -name cts.common.max_net_length -value $CTS_MAX_NET_LENGTH
} else {
 puts "Information: CTS has no max length constraint."
}

if {$CTS_MAX_FANOUT != ""} {
set_app_options -name cts.common.max_fanout -value $CTS_MAX_FANOUT
}  else {
 puts "Information: CTS has no max fanout constraint."
}

####################################
## CTS target skew and latency 
####################################
# By default CTS targets best skew and latency. These options can be used in case user wants to relax the target.
if {$CTS_TARGET_SKEW != ""} {
set_clock_tree_options -target_skew $CTS_TARGET_SKEW 
} 

if {$CTS_TARGET_LATENCY != ""} {
set_clock_tree_options -target_latency $CTS_TARGET_LATENCY
}
# ++++++++++++++++++++++++++++++++++
# NDR for root and internal nets
# ++++++++++++++++++++++++++++++++++

if {[file exist $TCL_ICC2_CTS_NDR_RULE_FILE]} {
source -v -e $TCL_ICC2_CTS_NDR_RULE_FILE
}

if {$CTS_ROOT_NDR_RULE_NAME != ""} {
	# Check if the rule has been created properly
	redirect -var x {report_routing_rules $CTS_ROOT_NDR_RULE_NAME}
	if {![regexp "Error" $x]} {
		# set_clock_routing_rules on root nets
		set set_clock_routing_rules_cmd_root "set_clock_routing_rules -net_type root -rule $CTS_ROOT_NDR_RULE_NAME"
		if {$CTS_ROOT_NDR_MIN_ROUTING_LAYER != ""} {lappend set_clock_routing_rules_cmd_root -min_routing_layer $CTS_ROOT_NDR_MIN_ROUTING_LAYER}
		if {$CTS_ROOT_NDR_MAX_ROUTING_LAYER != ""} {lappend set_clock_routing_rules_cmd_root -max_routing_layer $CTS_ROOT_NDR_MAX_ROUTING_LAYER}
		puts "Alchip-info: $set_clock_routing_rules_cmd_root"
			eval ${set_clock_routing_rules_cmd_root}
		} else {
		puts "Alchip-error: CTS_ROOT_NDR_RULE_NAME($CTS_ROOT_NDR_RULE_NAME) hasn't been created yet. Can not associate it with root nets!"
	}

}

if {$CTS_INTERNAL_NDR_RULE_NAME != ""} {
	# Check if the rule has been created properly
	redirect -var x {report_routing_rules $CTS_INTERNAL_NDR_RULE_NAME}
	if {![regexp "Error" $x]} {
		# set_clock_routing_rules on internal nets
		set set_clock_routing_rules_cmd_internal "set_clock_routing_rules -net_type internal -rule $CTS_INTERNAL_NDR_RULE_NAME"
		if {$CTS_INTERNAL_NDR_MIN_ROUTING_LAYER != ""} {lappend set_clock_routing_rules_cmd_internal -min_routing_layer $CTS_INTERNAL_NDR_MIN_ROUTING_LAYER}
		if {$CTS_INTERNAL_NDR_MAX_ROUTING_LAYER != ""} {lappend set_clock_routing_rules_cmd_internal -max_routing_layer $CTS_INTERNAL_NDR_MAX_ROUTING_LAYER}
		puts "Alchip-info: $set_clock_routing_rules_cmd_internal"
			eval ${set_clock_routing_rules_cmd_internal}
	} else {
		puts "Alchip-error: CTS_INTERNAL_NDR_RULE_NAME($CTS_INTERNAL_NDR_RULE_NAME) hasn't been created yet. Can not associate it with internal nets!"
	}

}

# ++++++++++++++++++++++++++++++++++
# NDR for leaf (sink) nets
# ++++++++++++++++++++++++++++++++++
## Rule association (set_clock_routing_rules) ##
if {$CTS_SINK_NDR_RULE_NAME != ""} {
	# Check if the rule has been created properly
	redirect -var x {report_routing_rules $CTS_SINK_NDR_RULE_NAME}
	if {![regexp "Error" $x]} {
		set set_clock_routing_rules_cmd_leaf "set_clock_routing_rules -net_type sink -rule $CTS_SINK_NDR_RULE_NAME"
		if {$CTS_SINK_NDR_MIN_ROUTING_LAYER != ""} {lappend set_clock_routing_rules_cmd_leaf -min_routing_layer $CTS_SINK_NDR_MIN_ROUTING_LAYER}
		if {$CTS_SINK_NDR_MAX_ROUTING_LAYER != ""} {lappend set_clock_routing_rules_cmd_leaf -max_routing_layer $CTS_SINK_NDR_MAX_ROUTING_LAYER}
		puts "Alchip-info: $set_clock_routing_rules_cmd_leaf"
		eval $set_clock_routing_rules_cmd_leaf
	} else {
		puts "Alchip-error: CTS_SINK_NDR_RULE_NAME($CTS_SINK_NDR_RULE_NAME) hasn't been created yet. Can not associate it with sink nets!"
	}
}

# ++++++++++++++++++++++++++++++++++
# Report routing rules 
# ++++++++++++++++++++++++++++++++++
#redirect -file \$RPT_DIR/$BLOCK_NAME.\$vars(dst).\$LVAR(CURR_VIEW).report_routing_rules.rpt {report_routing_rules -verbose}
#redirect -file \$RPT_DIR/$BLOCK_NAME.\$vars(dst).\$LVAR(CURR_VIEW).report_clock_routing_rules.rpt {report_clock_routing_rules}

 if {$CTS_LIB_CELL_PATTERN_LIST != "" } {
 	set_lib_cell_purpose -exclude cts [get_lib_cells */*]
 }
 
 if {$CTS_LIB_CELL_PATTERN_LIST != ""} {
 	set_dont_touch [get_lib_cells $CTS_LIB_CELL_PATTERN_LIST] false ;# In ICC-II, CTS respects dont_touch
 	set_lib_cell_purpose -include cts [get_lib_cells $CTS_LIB_CELL_PATTERN_LIST]
 } 

# To prevent CTS from punching new logical ports for logical hierarchies
# set_freeze_ports -clocks [get_cells {block1}]

{%- endif %}
puts "Alchip-info: Ending icc2 common settings.........."

