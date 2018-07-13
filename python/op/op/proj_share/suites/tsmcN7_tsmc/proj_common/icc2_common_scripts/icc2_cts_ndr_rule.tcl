## ----------------------------------------------------------------------------------
## NDR rule
## ----------------------------------------------------------------------------------

#$# remove_routing_rules -all
#$# 
#$# create_routing_rule NDR_TRUNK -default_reference_rule \
#$#    -widths   { M4 0.076 M5 0.076 M6 0.076 M7 0.076 M8 0.076 M9 0.076 M10 0.124 M11 0.124}  \
#$#    -spacings { M4 0.114 M5 0.114 M6 0.114 M7 0.114 M8 0.114 M9 0.114 M10 0.190 M11 0.190}  \
#$#    -driver_taper_distance 0 \
#$#    -vias { \
#$#          {VIA34_LONG_V_BW20_UW76 1X1 NR} \
#$#          {VIA45_big_BW76_UW76 1X1 NR} \
#$#          {VIA56_big_BW76_UW76 1X1 NR} \
#$#          {VIA67_big_BW76_UW76 1X1 NR} \
#$#          {VIA78_big_BW76_UW76 1X1 NR} \
#$#          {VIA89_big_BW76_UW76 1X1 NR} \
#$#          {VIA910_1cut_NDR 1x1 NR } \
#$#          {VIA1011_1cut_NDR 1X1 NR} \
#$#    } \
#$#    -via_distance_thresholds { M2 0.022 M3 0.038 }
#$# 
#$# 
#$# create_routing_rule NDR_LEAF -default_reference_rule \
#$#    -widths   { M4 0.038 M5 0.038 M6 0.038 M7 0.038 M8 0.038 M9 0.038 }  \
#$#    -spacings { M4 0.076 M5 0.076 M6 0.076 M7 0.076 M8 0.076 M9 0.076 }  \
#$#    -spacing_length_thresholds { M4 2 M5 2 M6 2 M7 2 M8 2 M9 2 } \
#$#    -driver_taper_distance 0 \
#$#       -vias { \
#$#          {VIA45_1cut_BW38_UW38 1X1 NR} \
#$#          {VIA56_1cut_BW38_UW38 1X1 NR} \
#$#          {VIA67_1cut_BW38_UW38 1X1 NR} \
#$#          {VIA78_1cut_BW38_UW38 1X1 NR} \
#$#          {VIA89_1cut_BW38_UW38 1X1 NR} \
#$#    } \
#$#    -via_distance_thresholds { M2 0.022 M3 0.038 }
#$# 
#$# set_clock_routing_rules -net_type root -rules NDR_TRUNK -min_routing_layer M6 -max_routing_layer M11
#$# set_clock_routing_rules -net_type internal -rules NDR_TRUNK -min_routing_layer M6 -max_routing_layer M11
#$# # M7 is actually enough here
#$# set_clock_routing_rules -net_type sink -rules NDR_LEAF -min_routing_layer M4 -max_routing_layer M9
#$# 

#remove_routing_rules -all
if {$lib_cell_height == "240"} {
set clock_routing_rule "NDR_TRUNK NDR_LEAF"
remove_routing_rules $clock_routing_rule

create_routing_rule NDR_TRUNK -default_reference_rule \
-widths   { M3 0.040 M4 0.076 M5 0.076 M6 0.076 M7 0.076 M8 0.076 M9 0.076 M10 0.124 M11 0.124}  \
-spacings { M3 0.048 M4 0.114 M5 0.114 M6 0.114 M7 0.114 M8 0.114 M9 0.114 M10 0.126 M11 0.126}  \
-driver_taper_distance 0 \
-vias { \
      {VIA34_LONG_V_BW20_UW76 1X1 NR} \
      {VIA45_LONG_H_BW76_UW114 1X1 NR} \
      {VIA56_LONG_H_BW114_UW76 1X1 NR} \
      {VIA56_LONG_V_BW76_UW114 1X1 NR} \
      {VIA67_LONG_H_BW76_UW114 1X1 NR} \
      {VIA67_LONG_V_BW114_UW76 1X1 NR} \
      {VIA78_LONG_H_BW114_UW76 1x1 NR } \
      {VIA78_LONG_V_BW76_UW114 1X1 NR} \
}


create_routing_rule NDR_LEAF -default_reference_rule \
-widths   { M3 0.020 M4 0.038 M5 0.038 M6 0.038 M7 0.038 M8 0.038 M9 0.038 }  \
-spacings { M3 0.048 M4 0.076 M5 0.076 M6 0.076 M7 0.076 M8 0.076 M9 0.076 }  \
-spacing_length_thresholds {M3 2 M4 2 M5 2 M6 2 M7 2 M8 2 M9 2 } \
-taper_distance 15   \
-driver_taper_distance 0 
#   -vias { \
#      {VIA34_LONG_V_BW20_UW76 1X1 NR} \
#      {VIA45_LONG_H_BW76_UW114 1X1 NR} \
#      {VIA56_LONG_H_BW114_UW76 1X1 NR} \
#      {VIA56_LONG_V_BW76_UW114 1X1 NR} \
#      {VIA67_LONG_H_BW76_UW114 1X1 NR} \
#      {VIA67_LONG_V_BW114_UW76 1X1 NR} \
#      {VIA78_LONG_H_BW114_UW76 1x1 NR } \
#      {VIA78_LONG_V_BW76_UW114 1X1 NR} \
#}

set_clock_routing_rules -net_type root -rules NDR_TRUNK -min_routing_layer M6 -max_routing_layer M11

set_clock_routing_rules -net_type internal -rules NDR_TRUNK -min_routing_layer M6 -max_routing_layer M11

set_clock_routing_rules -net_type sink -rules NDR_LEAF -min_routing_layer M4 -max_routing_layer M7
}

if {$lib_cell_height == "300"} {
set clock_routing_rule "NDR_TRUNK NDR_LEAF"
remove_routing_rules $clock_routing_rule

create_routing_rule NDR_TRUNK -default_reference_rule \
-widths   { M3 0.040 M4 0.076 M5 0.076 M6 0.076 M7 0.076 M8 0.076 M9 0.076 M10 0.124 M11 0.124}  \
-spacings { M3 0.048 M4 0.114 M5 0.114 M6 0.114 M7 0.114 M8 0.114 M9 0.114 M10 0.190 M11 0.190}  \
-driver_taper_distance 0 
#-vias { \
#      {VIA34_LONG_V_BW20_UW76 1X1 NR} \
#      {VIA45_LONG_H_BW76_UW114 1X1 NR} \
#      {VIA56_LONG_H_BW114_UW76 1X1 NR} \
#      {VIA56_LONG_V_BW76_UW114 1X1 NR} \
#      {VIA67_LONG_H_BW76_UW114 1X1 NR} \
#      {VIA67_LONG_V_BW114_UW76 1X1 NR} \
#      {VIA78_LONG_H_BW114_UW76 1x1 NR } \
#      {VIA78_LONG_V_BW76_UW114 1X1 NR} \
#}


create_routing_rule NDR_LEAF -default_reference_rule \
-widths   { M3 0.020 M4 0.038 M5 0.038 M6 0.038 M7 0.038 M8 0.038 M9 0.038 M10 0.062 M11 0.062}  \
-spacings { M3 0.068 M4 0.114 M5 0.114 M6 0.114 M7 0.114 M8 0.114 M9 0.114 M10 0.190 M11 0.190}  \
-spacing_length_thresholds {M3 2 M4 2 M5 2 M6 2 M7 2 M8 2 M9 2 M10 2 M11 2} \
-taper_distance 15   \
-driver_taper_distance 0 
#   -vias { \
#      {VIA34_LONG_V_BW20_UW76 1X1 NR} \
#      {VIA45_LONG_H_BW76_UW114 1X1 NR} \
#      {VIA56_LONG_H_BW114_UW76 1X1 NR} \
#      {VIA56_LONG_V_BW76_UW114 1X1 NR} \
#      {VIA67_LONG_H_BW76_UW114 1X1 NR} \
#      {VIA67_LONG_V_BW114_UW76 1X1 NR} \
#      {VIA78_LONG_H_BW114_UW76 1x1 NR } \
#      {VIA78_LONG_V_BW76_UW114 1X1 NR} \
#}

set_clock_routing_rules -net_type root -rules NDR_TRUNK -min_routing_layer M6 -max_routing_layer M11

set_clock_routing_rules -net_type internal -rules NDR_TRUNK -min_routing_layer M6 -max_routing_layer M11

set_clock_routing_rules -net_type sink -rules NDR_LEAF -min_routing_layer M4 -max_routing_layer M7
}
