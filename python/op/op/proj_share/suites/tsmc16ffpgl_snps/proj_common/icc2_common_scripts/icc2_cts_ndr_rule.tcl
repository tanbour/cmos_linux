# M1 :    0.032000
# M2 :    0.032000
# M3 :    0.032000
# M4 :    0.032000
# M5 :    0.044000
# M6 :    0.044000
# M7 :    0.062000
# M8 :    0.062000
# M9 :    0.126000
# M10 :   0.126000
# M11 :   0.360000
# M12 :   0.450000
# M0 :    0.040000

#create_routing_rule -multiplier_width 3 -multiplier_spacing 3 3w3s
#create_routing_rule -multiplier_width 2 -multiplier_spacing 3 2w3s
#create_routing_rule -multiplier_width 2 -multiplier_spacing 2 2w2s

if {[sizeof [get_routing_rules NDR_TRUNK_2w3s]]} {
  puts "Alchip-info: Have exist NDR: NDR_LEAF_2w3s"
} else {
  create_routing_rule NDR_TRUNK_2w3s -default_reference_rule \
  -widths {  M2 0.032 M3 0.064 M4 0.064 M5 0.088 M6 0.088 M7 0.124 M8 0.124 M9 0.252 M10 0.252}  \
  -spacings { M2 0.064 M3 0.096 M4 0.096 M5 0.132 M6 0.132 M7 0.124 M8 0.186 M9 0.378 M10 0.378}  \
  -driver_taper_distance 0
  # -vias
}
if {[sizeof [get_routing_rules -q NDR_LEAF_1w2s]]} {
  puts "Alchip-info: Have exist NDR: NDR_LEAF_1w2s"
} else {
  create_routing_rule NDR_LEAF_1w2s -default_reference_rule \
  -widths {  M2 0.032 M3 0.032 M4 0.032 M5 0.044 M6 0.044 M7 0.062 M8 0.062} \
  -spacings { M2 0.064 M3 0.064 M4 0.064 M5 0.088 M6 0.088 M7 0.124 M8 0.124}  \
  -spacing_length_thresholds {M2 2 M3 2 M4 2 M5 2 M6 2 M7 2 M8 2} \
  -taper_distance 15   \
  -driver_taper_distance 0
  # -vias
}

set_clock_routing_rules -net_type root -rule NDR_TRUNK_2w3s -min_routing_layer "M7" -max_routing_layer "M10"
set_clock_routing_rules -net_type internal -rule NDR_TRUNK_2w3s -min_routing_layer "M7" -max_routing_layer "M10"
set_clock_routing_rules -net_type sink -rule NDR_LEAF_1w2s -min_routing_layer "M5" -max_routing_layer "M8"

redirect -file $blk_rpt_dir/$cur_stage.create_routing_rules.rpt {report_routing_rules -verbose}
redirect -file $blk_rpt_dir/$cur_stage.set_clock_routing_rules.rpt {report_clock_routing_rules}



