#
# RTL files
#

read_file  -type verilog $RTL

#
# ignore modules : ignore during design read
#

foreach ignore_module ${IGNORE_MODUELS} {
 set_option ignoredu $ignore_module
 }

# to remove the ignorede option : 1) remove all 2) set the update ignoredu
# sg_shell> remove_option ignoredu
# sg_shell> set_option ignoredu {pcie_wrap dsp_top emmc_wrap cpu0_wrap muc_wrap muc_wrap muc_wrap muc_wrap muc_wrap usb_wrap usb_wrap gmac_wrap gmac_wrap aximx_8i5o axi_periph_slave axi_tunnel_wrap pcie_wrap}


#
# read design
#

read_design -top ${TOP}

#
# reads SDC
#
read_file -type sgdc ${SGDC}


#
# RESET signal
#
current_design ${TOP}
reset -name ${RST}  -value 0





