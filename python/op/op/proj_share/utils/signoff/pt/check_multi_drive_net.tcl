########################################################################
# PROGRAM:     check_multi_drive_net.tcl
# CREATOR:     Hideki Abe <abe@alchip.com>
# DATE:        Thu April 28 18:10:00 2017
# DESCRIPTION: Check multi drive net in PrimeTime.
# USAGE:       check_multi_drive_net
########################################################################

proc check_multi_drive_net {} {
	set TOP [get_object_name [get_designs ]]
	echo "##INFO: check multi_driver_net for design '$TOP' starting ..."
     set all_nets [get_nets -hier]
     foreach_in_collection all_net $all_nets {
            set net_drive_num 0
            set net_name [get_attribute -class net $all_net full_name]
#            set net_name_top [get_nets -top -seg $net_name]
            set net_pins [all_connected -leaf $net_name]
            if { [string match *true* [get_attribute [get_lib_pins -of_objects $net_pins -quiet] is_pad]] } {
               continue
            }
            foreach_in_collection net_pin $net_pins {
               if { [string equal [get_attribute -quiet $net_pin object_class] pin] || [string equal [get_attribute -quiet $net_pin is_hierarchical] true] } {
                   set net_pin_name [get_attribute -class pin $net_pin full_name]
                   set net_pin_direc [get_attribute -class pin $net_pin_name pin_direction]
                   if {$net_pin_direc == "out" || $net_pin_direc == "inout"} {
                       incr net_drive_num
                   }
               } elseif { [string equal [get_attribute -quiet $net_pin object_class] port] || [string equal [get_attribute -quiet $net_pin is_hierarchical] true] } {
                   set net_port_name [get_attribute -class port $net_pin full_name]
                   set net_port_direc [get_attribute -class port $net_port_name port_direction]
                   if {$net_port_direc == "in" || $net_port_direc == "inout"} {
                       incr net_drive_num
                   }
               }
            }
            

            set fishbone_pattern_1 "*_FB_L2"
            set fishbone_pattern_2 "*CLK_BUF_*"
            set fishbone_pattern_3 "*CLK_ISO_BUF*"
            set fishbone_pattern_4 "*eco_net*"
            set fishbone_pattern_5 "eco_cell*"
            set fishbone_pattern_6 "n131*"
            set fishbone_pattern_7 "n77*"
            set fishbone_pattern_8 "CLK_ISO_CLK_BUF_*"
            set fishbone_pattern_9 "titan_0/CKFT"
            set fishbone_pattern_10 "titan_0/CKFTISIC"
            set fishbone_pattern_11 "titan_0/CKFTISICDLY"
            set fishbone_pattern_12 "titan_0/CKSB"
            set fishbone_pattern_13 "titan_0/tclkgen_0_CKFB_clk_0_FBBUF_FB_SPLIT*"
            set fishbone_pattern_14 "titan_0/tcore_0/tcfect_0/tcfcoret_0/tcfvitt_0/CKVIT"
            set fishbone_pattern_15 "bist_clk_1_0_FBBUF_FB_SPLIT_n*"
            set fishbone_pattern_16 "titan_0/tclkgen_0_CKFC_clk_0_FBBUF_FB_SPLIT*"
            if {$net_drive_num >= 2} {
                set net_name_top [get_nets -top -seg $net_name]
                set net_name_top_name [get_attribute -class net $net_name_top full_name]
                if {[string match $fishbone_pattern_1 $net_name_top_name]} {
                   echo "INFO: Multi drive net find! \(Fishbone Net\)"
                   echo "Multi drive net is: $net_name_top_name"
                } elseif {[string match $fishbone_pattern_2 $net_name_top_name]} {
                   echo "INFO: Multi drive net find! \(Fishbone Net\)"
                   echo "Multi drive net is: $net_name_top_name"
                } elseif {[string match $fishbone_pattern_3 $net_name_top_name]} {
                   echo "INFO: Multi drive net find! \(Fishbone Net\)"
                   echo "Multi drive net is: $net_name_top_name"
                } elseif {[string match $fishbone_pattern_4 $net_name_top_name]} {
                   echo "INFO: Multi drive net find! \(Fishbone Net\)"
                   echo "Multi drive net is: $net_name_top_name"
                } elseif {[string match $fishbone_pattern_5 $net_name_top_name]} {
                   echo "INFO: Multi drive net find! \(Fishbone Net\)"
                   echo "Multi drive net is: $net_name_top_name"
                } elseif {[string match $fishbone_pattern_6 $net_name_top_name]} {
                   echo "INFO: Multi drive net find! \(Fishbone Net\)"
                   echo "Multi drive net is: $net_name_top_name"
                } elseif {[string match $fishbone_pattern_7 $net_name_top_name]} {
                   echo "INFO: Multi drive net find! \(Fishbone Net\)"
                   echo "Multi drive net is: $net_name_top_name"
                } elseif {[string match $fishbone_pattern_8 $net_name_top_name]} {
                   echo "INFO: Multi drive net find! \(Fishbone Net\)"
                   echo "Multi drive net is: $net_name_top_name"
                } elseif {[string match $fishbone_pattern_9 $net_name_top_name]} {
                   echo "INFO: Multi drive net find! \(Fishbone Net\)"
                   echo "Multi drive net is: $net_name_top_name"
                } elseif {[string match $fishbone_pattern_10 $net_name_top_name]} {
                   echo "INFO: Multi drive net find! \(Fishbone Net\)"
                   echo "Multi drive net is: $net_name_top_name"
                } elseif {[string match $fishbone_pattern_11 $net_name_top_name]} {
                   echo "INFO: Multi drive net find! \(Fishbone Net\)"
                   echo "Multi drive net is: $net_name_top_name"
                } elseif {[string match $fishbone_pattern_12 $net_name_top_name]} {
                   echo "INFO: Multi drive net find! \(Fishbone Net\)"
                   echo "Multi drive net is: $net_name_top_name"
                } elseif {[string match $fishbone_pattern_13 $net_name_top_name]} {
                   echo "INFO: Multi drive net find! \(Fishbone Net\)"
                   echo "Multi drive net is: $net_name_top_name"
                } elseif {[string match $fishbone_pattern_14 $net_name_top_name]} {
                   echo "INFO: Multi drive net find! \(Fishbone Net\)"
                   echo "Multi drive net is: $net_name_top_name"
                } elseif {[string match $fishbone_pattern_15 $net_name_top_name]} {
                   echo "INFO: Multi drive net find! \(Fishbone Net\)"
                   echo "Multi drive net is: $net_name_top_name"
                } elseif {[string match $fishbone_pattern_16 $net_name_top_name]} {
                   echo "INFO: Multi drive net find! \(Fishbone Net\)"
                   echo "Multi drive net is: $net_name_top_name"
                } else {
                   echo "ERROR: Multi drive net find !!!"
                   echo "Multi drive net is: $net_name_top_name"
#                   get_net_drive_pin $net_name_top
                }
            }
      }
}
