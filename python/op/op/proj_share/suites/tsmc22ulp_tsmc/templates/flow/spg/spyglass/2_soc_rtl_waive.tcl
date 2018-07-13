#
# stop module : considered s black boxes during SpyGlass analysis
#
 
foreach bbox_module ${BBOX_MODULES} {
 set_option stop $bbox_module
 }

# remove stop option : 1) remove all 2) to update the stop module
# sg_shell> remove_option stop
# sg_shell> set_option stop {ppinmux dsp_top emmc_wrap cpu0_wrap cpu1_wrap gpu0_wrap gpu1_wrap gpu2_wrap gpu3_wrap usb0_wrap usb1_wrap mac0_wrap mac1_wrap aximx_8i5o axi_periph_slave axi_tunnel_wrap pcie_wrap usb2_pads_x1}

#
# Waive modules
#

foreach waive_module ${WAIVE_MODULES} {
 waive -du $waive_module -rule ALL 
 }

#
# Waive rules
#
foreach waive_rule ${WAIVE_RULES} {
 waive -rule $waive_rule
 }

#
# remove waive
#
#remove_waiver -id 0
#

