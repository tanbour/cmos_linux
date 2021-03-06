##########################################################################################
# Version: E-2010.12 (January 10, 2011)
# Copyright (C) 2007-2011 Synopsys, Inc. All rights reserved.
##########################################################################################

puts "RM-Info: Running script [info script]\n"

## CTS Common Session Options - set in place_opt and clock_opt sessions



## Clock Tree References
#  Choose Balanced Buffers and Inverters for best results
#  Avoid low strengths for initial CTS (bad CTS)
#  Avoid high strengths for signal EM problems
#  Each of the following list take a space separated list of buffers/cels: ex: "buf1 inv1 inv2"
#  Note: references are cumulative
#if {$ICC_CTS_REF_LIST != "" || $ICC_CTS_REF_SIZING_ONLY != "" || $ICC_CTS_REF_DEL_INS_ONLY != ""} {
   reset_clock_tree_references
#}
#if {$ICC_CTS_REF_LIST != ""} {

remove_attribute [get_lib_cells [list */INV* */BUF*]] dont_use
set_clock_tree_references -references  [get_lib_cells [list */INV* */BUF*]]

#}
#if {$ICC_CTS_REF_DEL_INS_ONLY != ""} {
#}
#if {$ICC_CTS_REF_SIZING_ONLY != ""} {
#}

## CLOCK NDR's
#  Specify the rule prior to CTS such that CTS can predict its effects
#  Avoid setting the rule on metal 1 to avoids pin access issues on buffers and gates in the tree

## Define double spacing NDR: ICC-RM by default uses a 2x spacing rule. 
#  It is also a recommended way for pre-route crosstalk prevention. 
redirect -var x {report_routing_rules $ICC_CTS_RULE_NAME}
if {$ICC_CTS_RULE_NAME == "iccrm_clock_double_spacing" && [regexp "Info: No nondrule" $x]} {
  define_routing_rule iccrm_clock_double_spacing -default_reference_rule -multiplier_spacing 2
  ## add -multiplier_width 2 for double width
  report_routing_rule iccrm_clock_double_spacing
  set_clock_tree_options -routing_rule iccrm_clock_double_spacing -use_default_routing_for_sinks 1 
}

## Define NDR in general for spacings and widths
#  define_routing_rule $ICC_CTS_RULE_NAME -default_reference_rule \
#  -spacings "BEST_PRACTICE_clock_ndr_metal_layer_and_spacing" \
#  -widths "BEST_PRACTICE_clock_ndr_metal_layer_and_width" \
#  report_routing_rule $ICC_CTS_RULE_NAME
#  -spacing_length_thresholds <use 3-5x metal layer pitch>

## Define double vias NDR: Zroute will insert double via during clock nets routing
#  Example: To use 1x2 via34 via-array, and allow rotate and swap the via-array
#  	define_routing_rule $ICC_CTS_RULE_NAME -default_reference_rule \    
#       -via_cuts {{via34 1x2 NR} {via34 2x1 R} {via34 2x1 NR} {via34 1x2 R}}
#  If there is no via defined in via_cuts, for that layer Zroute will use default via with single cut
#  Note: if classic router is used, R & NR syntax do not apply and will be ignored

## Define clock shielding NDR
#if {$ICC_CTS_SHIELD_MODE != "OFF"} {
#redirect -var x {report_routing_rules $ICC_CTS_SHIELD_RULE_NAME}
#if {$ICC_CTS_SHIELD_RULE_NAME != "" && [regexp "Info: No nondrule" $x]} {
#  define_routing_rule $ICC_CTS_SHIELD_RULE_NAME -default_reference_rule \
    -shield_spacings "$ICC_CTS_SHIELD_SPACINGS" \
    -shield_widths "$ICC_CTS_SHIELD_WIDTHS"
#  report_routing_rule $ICC_CTS_SHIELD_RULE_NAME
#}

#if {$ICC_CTS_SHIELD_MODE == "ALL" } {
#  set_clock_tree_options -routing_rule $ICC_CTS_SHIELD_RULE_NAME -use_default_routing_for_sinks 1  ;#apply rule to all but leaf nets
#}

#if {$ICC_CTS_SHIELD_MODE == "NAMES"} {
#  if {$ICC_CTS_RULE_NAME != ""} {
#  set_clock_tree_options -routing_rule $ICC_CTS_RULE_NAME -use_default_routing_for_sinks 1  ;#apply rule to all but leaf nets
#  }
#  if {$ICC_CTS_SHIELD_CLK_NAMES != ""} {
#    set_clock_tree_options -routing_rule $ICC_CTS_SHIELD_RULE_NAME -clock_trees $ICC_CTS_SHIELD_CLK_NAMES -use_default_routing_for_sinks 1
#  }
#}
#}

##Typically route clocks on metal3 and above
#if {$ICC_CTS_LAYER_LIST != ""} {
   set_clock_tree_options -layer_list $ICC_CTS_LAYER_LIST
#}

## You can use following commands to further specify CTS constraints and options: 
  set_clock_tree_options -target_skew 	0.1 
  set_clock_tree_options -target_early_delay 1.0
#  Note: it's not recommended to change -max_fanout unless necessary as doing so may degrade QoR easily.

## End of CTS Optimization Session Options #############

puts "RM-Info: Completed script [info script]\n"
