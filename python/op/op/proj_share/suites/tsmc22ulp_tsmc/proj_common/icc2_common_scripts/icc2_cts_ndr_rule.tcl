## ----------------------------------------------------------------------------------
## NDR rule
## ----------------------------------------------------------------------------------

#set clock_routing_rule "NDR_TRUNK NDR_LEAF"
#remove_routing_rules $clock_routing_rule
#
#create_routing_rule NDR_TRUNK -default_reference_rule \
#-widths   { M3 0.040 M4 0.076 M5 0.076 M6 0.076 M7 0.076 M8 0.076 M9 0.076 M10 0.124 M11 0.124}  \
#-spacings { M3 0.048 M4 0.114 M5 0.114 M6 0.114 M7 0.114 M8 0.114 M9 0.114 M10 0.126 M11 0.126}  \
#-driver_taper_distance 0 \
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
#
#
#create_routing_rule NDR_LEAF -default_reference_rule \
#-widths   { M3 0.020 M4 0.038 M5 0.038 M6 0.038 M7 0.038 M8 0.038 M9 0.038 }  \
#-spacings { M3 0.048 M4 0.076 M5 0.076 M6 0.076 M7 0.076 M8 0.076 M9 0.076 }  \
#-spacing_length_thresholds {M3 2 M4 2 M5 2 M6 2 M7 2 M8 2 M9 2 } \
#-taper_distance 15   \
#-driver_taper_distance 0 
##   -vias { \
##      {VIA34_LONG_V_BW20_UW76 1X1 NR} \
##      {VIA45_LONG_H_BW76_UW114 1X1 NR} \
##      {VIA56_LONG_H_BW114_UW76 1X1 NR} \
##      {VIA56_LONG_V_BW76_UW114 1X1 NR} \
##      {VIA67_LONG_H_BW76_UW114 1X1 NR} \
##      {VIA67_LONG_V_BW114_UW76 1X1 NR} \
##      {VIA78_LONG_H_BW114_UW76 1x1 NR } \
##      {VIA78_LONG_V_BW76_UW114 1X1 NR} \
##}
#
#set_clock_routing_rules -net_type root -rules NDR_TRUNK -min_routing_layer M6 -max_routing_layer M11
#
#set_clock_routing_rules -net_type internal -rules NDR_TRUNK -min_routing_layer M6 -max_routing_layer M11
#
#set_clock_routing_rules -net_type sink -rules NDR_LEAF -min_routing_layer M4 -max_routing_layer M7


