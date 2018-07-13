#!/usr/bin/tclsh
#################################################################################################################################################
# PROGRAM:	check_multi_drive_net.icc2.tcl
# CREATOR:	Zachary Shi <zacharys@alchip.com>
# DATE:		Thu May 25 09:32:56 2017
# DESCRIPTION:
# 		If the design have Fishbone nets, you can list all fishbone patterns into <fishbone_patterns> to ignore them.
# 		If the design have specially nets that can be ignored, you can list them into <special_patterns>.
# USAGE:	check_multi_drive_net ?<check_multi_drive_net.rpt>
# UPDATE:       updated by Felix <felix_yuan@alchip.com>    2018-03-02
# ITEM :        GE-02-03 CK-01-16
#################################################################################################################################################

proc check_multi_drive_net { {output_rpt_multi_drive_net check_multi_drive_net.rpt} } {
     puts "Alchip-info: Starting to signoff check multi drive net in PrimeTime\n"
     set file [ open $output_rpt_multi_drive_net w ]

  # Used for search fishbone nets: [string match $fishbone_pattern $net_name]
  # The fishbone pattern is the key word of the top net segment of fishbone net.
  set fishbone_patterns " \
    *_FB_L2 \
    *CLK_BUF_* \
    *CLK_ISO_BUF* \
    *eco_net* \
    eco_cell* \
    n131* \
    n77* \
    CLK_ISO_CLK_BUF_* \
    titan_0/CKFT \
    titan_0/CKFTISIC \
    titan_0/CKFTISICDLY \
    titan_0/CKSB \
    titan_0/tclkgen_0_CKFB_clk_0_FBBUF_FB_SPLIT* \
    titan_0/tcore_0/tcfect_0/tcfcoret_0/tcfvitt_0/CKVIT \
    bist_clk_1_0_FBBUF_FB_SPLIT_n* \
    titan_0/tclkgen_0_CKFC_clk_0_FBBUF_FB_SPLIT* \
  "

  # Used for search specilly nets: [string match $special_pattern $net_name]
  # The special pattern is the key word of the top net segment of special net.
  set special_patterns " \
    TXOP \
    TXON \
    XOSC26M_XO \
  "

  if { [ get_designs -quiet ] != "" } {
    set top_design [ get_object_name [ get_designs ] ]
    puts $file "Information: check multi_driver_net for design \"$top_design\" starting...\n"
  } else {
    puts $file "Error: Please open a design first!"
    return
  }

  set num_special_net      0
  set num_fishbone_net     0
  set num_multi_driver_net 0
  set all_nets [ get_nets -hierarchical * -top_net_of_hierarchical_group -segments -quiet ]
  if { [ sizeof_collection $all_nets ] == 0 } {
    puts $file "Error: Can not find any nets, please check the design."
    return

  } else {
    foreach_in_collection ptrn $all_nets {
      set net_name   [ get_attribute $ptrn full_name ]
      set pins_name  [ get_pins  -of_objects $net_name -filter "direction == out || direction == inout" -quiet -leaf]
      set ports_name [ get_ports -of_objects $net_name -filter "direction == in  || direction == inout" -quiet ]
      set num_pins   [ sizeof_collection $pins_name ]
      set num_ports  [ sizeof_collection $ports_name ]

      if { [ expr $num_pins + $num_ports ] >= 2 } {
        set net_type "none"

        if { [ llength $fishbone_patterns ] != 0 } {
          foreach fishbone_pattern $fishbone_patterns {
            if { [ string match $fishbone_pattern $net_name ] } {
              set  net_type "fishbone"
              incr num_fishbone_net
              puts $file "Information: Fishbone net found: $net_name"
              break
            }
          }
        }

        if { [ llength $special_patterns ] != 0 && $net_type == "none" } {
          foreach special_pattern $special_patterns {
            if { [ string match $special_pattern $net_name ] } {
              set net_type "specially"
              incr num_special_net
              puts $file  "Information: Special net found: $net_name"
              break
            }
          }
        }

        if { $net_type == "none" } {
          puts $file "Error: multi_drive net found, net: ${net_name}"
          incr num_multi_driver_net
        }

      }
    }
  }

  puts "\n---------------------------------------------------------------------------------"
  puts $file "\n---------------------------------------------------------------------------------"
  puts "Information: There total found \"$num_fishbone_net\" fishbone nets, \"$num_multi_driver_net\" multi-driver nets, \"$num_special_net\" special nets."
  puts $file "Information: There total found \"$num_fishbone_net\" fishbone nets, \"$num_multi_driver_net\" multi-driver nets, \"$num_special_net\" special nets."
  if { $num_multi_driver_net !=0 } {
    puts "Information: You can check that if these ${num_multi_driver_net} multi-driver nets can be ignored and added them to <special_patterns>."
    puts $file "Information: You can check that if these ${num_multi_driver_net} multi-driver nets can be ignored and added them to <special_patterns>."
  }
  puts "Information: Check multi_driver_net for design \"$top_design\" end."
  puts $file "Information: Check multi_driver_net for design \"$top_design\" end."
  close $file
  puts "Alchip-info: Completed to signoff check multi drive net in PrimeTime\n"
}
