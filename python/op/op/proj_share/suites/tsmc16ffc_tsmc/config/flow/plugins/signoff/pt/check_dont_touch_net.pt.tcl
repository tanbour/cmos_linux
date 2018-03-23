#!/usr/bin/tclsh
#################################################################################################
# PROGRAM:     check_dont_touch_net.pt.tcl
# CREATOR:     Zachary Shi <zacharys@alchip.com>
# DATE:        Tue Mar 13 16:45:55 2018
# DESCRIPTION: Checking dont_touch net in PrimeTime
#              Keep original connection and NO buffer's allowed on specific nets
# USAGE:       check_dont_touch_net ?<check_dont_touch_net.rep>
# UPDATE:      updated by Felix <felix_yuan@alchip.com>    2018-03-09 
# Item :       GE-02-08
#################################################################################################
proc check_dont_touch_net { {output_rpt_dont_touch_net check_dont_touch_net.rpt} } {

  puts "Alchip-info: Starting to signoff check dont touch net in PrimeTime\n" 
  set file [ open $output_rpt_dont_touch_net w ] 
  set pass_num 0
  set fail_num 0

  proc checking_dont_touch { args } {

    upvar pass_num loc_pass_num
    upvar fail_num loc_fail_num

    set net_name  [ lindex $args 0 ]
    set drive_pin [ lindex $args 1 ]
    set num_of_load_pins [ lindex $args 2 ]
    set load_pin_infos   [ lsort [ lreplace $args 0 2 ] ]

    set load_pin_info_part1 ""
    set load_pin_info_part2 ""
    foreach lpis $load_pin_infos {
      lappend load_pin_info_part1 "[ lindex $lpis 0 ] [ lindex $lpis 1 ]"
      lappend load_pin_info_part2 "[ lindex $lpis 2 ]"
    }

    if { [ sizeof_collection [ get_nets $net_name -quiet ] ] != 1 } {
      puts $file "Error: The dont touch net doesn't exist, please check it: $net_name"
      incr loc_fail_num

    } else {
      if { [ get_attribute [ get_nets $net_name ] dont_touch -quiet ] != "true" } {
        puts $file "Warning: The dont_touch attribute of net \"$net_name\" is not true"
      }

      ## for driver pin
      set current_drive_pin [ get_attribute [ get_pins -leaf -of_objects $net_name -filter "direction ==out" -quiet ] full_name -quiet ]
      set current_drive_ref [ get_attribute [ get_cells -of_objects $current_drive_pin -quiet ] ref_name -quiet ]
      set current_drive_function_id [ lindex [ get_attribute [ get_lib_cells */$current_drive_ref -quiet ] function_id -quiet ] 0 ]

      if { [ llength $current_drive_pin ] != 1 } {
        puts $file "Error: The dont touch net don't have driver pin or it became a multi-driver net: $net_name"
        incr loc_fail_num

      } elseif { [ lindex $drive_pin 0 ] != $current_drive_pin } {
        puts $file "Error: The dont touch net drive pin had changed, please check it: $net_name"
        incr loc_fail_num

      } elseif { [ lindex $drive_pin 1 ] != $current_drive_function_id } {
        puts $file "Error: The dont touch net drive pin had changed, please check it: $net_name"
        incr loc_fail_num

      } else {
        if { [ lindex $drive_pin 2 ] != $current_drive_ref } {
          puts $file "Warning: The driver cell's strength of dont touch net had changed, original: \"[ lindex $drive_pin 2 ]\", current: \"$current_drive_refi\""
        }

        ## for load pins
        set current_load_pin_infos ""
        set current_load_pin_info_part1 ""
        set current_load_pin_info_part2 ""
        set current_load_pins        [ get_attribute [ get_pins -leaf -of_objects $net_name -filter "direction ==in"  -quiet ] full_name ]
        set current_num_of_load_pins [ llength $current_load_pins ]

        foreach ptr_current_load_pin $current_load_pins {
          set current_load_ref         [ get_attribute [ get_cells -of_objects $ptr_current_load_pin -quiet ] ref_name -quiet ]
          set current_load_function_id [ lindex [ get_attribute [ get_lib_cells */$current_load_ref ] function_id -quiet ] 0 ]
          lappend current_load_pin_infos "$ptr_current_load_pin ${current_load_function_id} $current_load_ref"
        }
        set current_load_pin_infos [ lsort $current_load_pin_infos ]

        foreach clpis $current_load_pin_infos {
          lappend current_load_pin_info_part1 "[ lindex $clpis 0 ] [ lindex $clpis 1 ]"
          lappend current_load_pin_info_part2 "[ lindex $clpis 2 ]"
        }

        if { $num_of_load_pins != $current_num_of_load_pins } {
          puts $file "Error: The dont touch net loading number had changed: $net_name"
          incr loc_fail_num

        } elseif { $load_pin_info_part1 != $current_load_pin_info_part1 } {
          puts $file "Error: The dont touch net load pin had changed, please check it: $net_name"
          incr loc_fail_num

        } else {
          if { $load_pin_info_part2 != $current_load_pin_info_part2 } {
            puts $file "Warning: The loading cell's strength of dont touch net had changed, original: \"$load_pin_info_part2\", current: \"$current_load_pin_info_part2\""
          }

          puts $file "Information: Checking the dont touch net is OK, net: $net_name"
          incr loc_pass_num
        }
      }
    }
  }


  puts $file "\n----------------------------------------------------------------------------"
  puts $file "Information: Total checked [ expr $pass_num + $fail_num ] dont_touch nets; $fail_num nets have changed; $pass_num nets are OK.\n" 
  close $file 
  puts "Alchip-info: Completed to signoff check dont touch net in PrimeTime\n"

}

