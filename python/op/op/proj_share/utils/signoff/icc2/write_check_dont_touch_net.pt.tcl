#!/usr/bin/tclsh
###############################################################################################################
# PROGRAM     : write_check_dont_touch_net.icc2.tcl
# CREATOR     : Zachary Shi <zacharys@alchip.com>
# DATE        : Thu May 11 09:21:58 CST 2017
# DESCRIPTION : Generated dont_touch net checking script in ICC2.
# USAGE       : write_check_dont_touch_net ?<dont_touch_nets> ?<check_dont_touch_net.pt.tcl>
# UPDATE      : updated by Felix <felix_yuan@alchip.com>    2018-03-06
# Item        : GE-02-08            
###############################################################################################################

proc write_check_dont_touch_net { { dont_touch_nets dont_touch_nets.tcl } { check_script check_dont_touch_net.pt.tcl } } {
     puts "Alchip-info: Starting to generate signoff check dont touch net PT scripts in ICC2\n"

     if {[file exist $dont_touch_nets] == 0} {
       puts "Warning: Can't find the dont touch net list, please check it: $dont_touch_nets"
       return
   
     } else {
       if {[file size $dont_touch_nets] == 0} {
         puts "Warning: The dont touch net list is empty, please check it: $dont_touch_nets"
         return
       }
     }
   
     if {$check_script == ""} {
       puts "Warning: Please assign the checking dont touch net script name, eg: check_dont_touch_net.pt.tcl"
       return
     } else {
       if {[file exist $check_script]} {
         puts "Warning: Checking dont touch net script is exist, please check it: $check_script"
         return
       }
     }

  set input_file  [open $dont_touch_nets r]
  set output_file [open $check_script w]

  puts $output_file "#!/usr/bin/tclsh"
  puts $output_file "#################################################################################################"
  puts $output_file "# PROGRAM:     check_dont_touch_net.pt.tcl"
  puts $output_file "# CREATOR:     Zachary Shi <zacharys@alchip.com>"
  puts $output_file "# DATE:        [date]"
  puts $output_file "# DESCRIPTION: Checking dont_touch net in PrimeTime"
  puts $output_file "#              Keep original connection and NO buffer's allowed on specific nets"
  puts $output_file "# USAGE:       check_dont_touch_net ?<check_dont_touch_net.rep>"
  puts $output_file "# UPDATE:      updated by Felix <felix_yuan@alchip.com>    2018-03-09 "      
  puts $output_file "# Item :       GE-02-08"      
  puts $output_file "#################################################################################################"
  puts $output_file "proc check_dont_touch_net { {output_rpt_dont_touch_net check_dont_touch_net.rpt} } {\n"
  puts $output_file "  puts \"Alchip-info: Starting to signoff check dont touch net in PrimeTime\\n\" "
  puts $output_file "  set file \[ open \$output_rpt_dont_touch_net w \] "
  puts $output_file "  set pass_num 0"
  puts $output_file "  set fail_num 0\n"
  puts $output_file "  proc checking_dont_touch { args } {\n"
  puts $output_file "    upvar pass_num loc_pass_num"
  puts $output_file "    upvar fail_num loc_fail_num\n"
  puts $output_file "    set net_name  \[ lindex \$args 0 \]"
  puts $output_file "    set drive_pin \[ lindex \$args 1 \]"
  puts $output_file "    set num_of_load_pins \[ lindex \$args 2 \]"
  puts $output_file "    set load_pin_infos   \[ lsort \[ lreplace \$args 0 2 \] \]\n"
  puts $output_file "    set load_pin_info_part1 \"\""
  puts $output_file "    set load_pin_info_part2 \"\""
  puts $output_file "    foreach lpis \$load_pin_infos {"
  puts $output_file "      lappend load_pin_info_part1 \"\[ lindex \$lpis 0 \] \[ lindex \$lpis 1 \]\""
  puts $output_file "      lappend load_pin_info_part2 \"\[ lindex \$lpis 2 \]\""
  puts $output_file "    }\n"
  puts $output_file "    if { \[ sizeof_collection \[ get_nets \$net_name -quiet \] \] != 1 } {"
  puts $output_file "      puts \$file \"Error: The dont touch net doesn't exist, please check it: \$net_name\""
  puts $output_file "      incr loc_fail_num\n"
  puts $output_file "    } else {"
  puts $output_file "      if { \[ get_attribute \[ get_nets \$net_name \] dont_touch -quiet \] != \"true\" } {"
  puts $output_file "        puts \$file \"Warning: The dont_touch attribute of net \\\"\$net_name\\\" is not true\""
  puts $output_file "      }\n"
  puts $output_file "      ## for driver pin"
  puts $output_file "      set current_drive_pin \[ get_attribute \[ get_pins -leaf -of_objects \$net_name -filter \"direction ==out\" -quiet \] full_name -quiet \]"
  puts $output_file "      set current_drive_ref \[ get_attribute \[ get_cells -of_objects \$current_drive_pin -quiet \] ref_name -quiet \]"
  puts $output_file "      set current_drive_function_id \[ lindex \[ get_attribute \[ get_lib_cells */\$current_drive_ref -quiet \] function_id -quiet \] 0 \]\n"
  puts $output_file "      if { \[ llength \$current_drive_pin \] != 1 } {"
  puts $output_file "        puts \$file \"Error: The dont touch net don't have driver pin or it became a multi-driver net: \$net_name\""
  puts $output_file "        incr loc_fail_num\n"
  puts $output_file "      } elseif { \[ lindex \$drive_pin 0 \] != \$current_drive_pin } {"
  puts $output_file "        puts \$file \"Error: The dont touch net drive pin had changed, please check it: \$net_name\""
  puts $output_file "        incr loc_fail_num\n"
  puts $output_file "      } elseif { \[ lindex \$drive_pin 1 \] != \$current_drive_function_id } {"
  puts $output_file "        puts \$file \"Error: The dont touch net drive pin had changed, please check it: \$net_name\""
  puts $output_file "        incr loc_fail_num\n"
  puts $output_file "      } else {"
  puts $output_file "        if { \[ lindex \$drive_pin 2 \] != \$current_drive_ref } {"
  puts $output_file "          puts \$file \"Warning: The driver cell's strength of dont touch net had changed, original: \\\"\[ lindex \$drive_pin 2 \]\\\", current: \\\"\$current_drive_refi\\\"\""
  puts $output_file "        }\n"
  puts $output_file "        ## for load pins"
  puts $output_file "        set current_load_pin_infos \"\""
  puts $output_file "        set current_load_pin_info_part1 \"\""
  puts $output_file "        set current_load_pin_info_part2 \"\""
  puts $output_file "        set current_load_pins        \[ get_attribute \[ get_pins -leaf -of_objects \$net_name -filter \"direction ==in\"  -quiet \] full_name \]"
  puts $output_file "        set current_num_of_load_pins \[ llength \$current_load_pins \]\n"
  puts $output_file "        foreach ptr_current_load_pin \$current_load_pins {"
  puts $output_file "          set current_load_ref         \[ get_attribute \[ get_cells -of_objects \$ptr_current_load_pin -quiet \] ref_name -quiet \]"
  puts $output_file "          set current_load_function_id \[ lindex \[ get_attribute \[ get_lib_cells */\$current_load_ref \] function_id -quiet \] 0 \]"
  puts $output_file "          lappend current_load_pin_infos \"\$ptr_current_load_pin \${current_load_function_id} \$current_load_ref\""
  puts $output_file "        }"
  puts $output_file "        set current_load_pin_infos \[ lsort \$current_load_pin_infos \]\n"
  puts $output_file "        foreach clpis \$current_load_pin_infos {"
  puts $output_file "          lappend current_load_pin_info_part1 \"\[ lindex \$clpis 0 \] \[ lindex \$clpis 1 \]\""
  puts $output_file "          lappend current_load_pin_info_part2 \"\[ lindex \$clpis 2 \]\""
  puts $output_file "        }\n"
  puts $output_file "        if { \$num_of_load_pins != \$current_num_of_load_pins } {"
  puts $output_file "          puts \$file \"Error: The dont touch net loading number had changed: \$net_name\""
  puts $output_file "          incr loc_fail_num\n"
  puts $output_file "        } elseif { \$load_pin_info_part1 != \$current_load_pin_info_part1 } {"
  puts $output_file "          puts \$file \"Error: The dont touch net load pin had changed, please check it: \$net_name\""
  puts $output_file "          incr loc_fail_num\n"
  puts $output_file "        } else {"
  puts $output_file "          if { \$load_pin_info_part2 != \$current_load_pin_info_part2 } {"
  puts $output_file "            puts \$file \"Warning: The loading cell's strength of dont touch net had changed, original: \\\"\$load_pin_info_part2\\\", current: \\\"\$current_load_pin_info_part2\\\"\""
  puts $output_file "          }\n"
  puts $output_file "          puts \$file \"Information: Checking the dont touch net is OK, net: \$net_name\""
  puts $output_file "          incr loc_pass_num"
  puts $output_file "        }"
  puts $output_file "      }"
  puts $output_file "    }"
  puts $output_file "  }\n"

  while {[gets $input_file line] >= 0} {

    if {[sizeof_collection [get_nets $line -quiet]]} {

      if { [ get_attribute [ get_nets $line ] dont_touch -quiet ] != "true" } {
        puts "Warning: The dont_touch attribute of net \"$line\" is not true"
      }

      set drive_pin [get_pins -leaf -of_objects $line -filter "direction ==out" -quiet]
      set load_pin  [get_pins -leaf -of_objects $line -filter "direction ==in"  -quiet]

      if {[sizeof_collection $drive_pin] != 1} {
        puts "Error: The dont touch net doesn't have driver pin, or it's multi-driver net: $line"

      } elseif {[sizeof_collection $load_pin] == 0} {
        puts "Error: The dont touch net doesn't have load pin: $line"

      } else {
        ## for driver pin
        set drive_pin_info ""
        set drive_pin          [get_attribute $drive_pin full_name]
        set drive_ref          [get_attribute [get_cells -of_objects $drive_pin -quiet] ref_name]
        set drive_function_id  [lindex [get_attribute [get_lib_cells */$drive_ref -quiet] function_id] 0] ; # can't distinguish buf or bufh
        lappend drive_pin_info "$drive_pin ${drive_function_id} $drive_ref"

        ## for load pins
        set load_pin_info ""
        set num_of_load_pins [sizeof_collection $load_pin]
        foreach_in_collection ptrlp $load_pin {
          set ptr_load_pin      [get_attribute $ptrlp full_name]
          set ptr_load_ref      [get_attribute [get_cells -of_objects $ptr_load_pin -quiet] ref_name]
          set load_function_id  [lindex [get_attribute [get_lib_cells */$ptr_load_ref -quiet] function_id] 0]
          lappend load_pin_info "$ptr_load_pin ${load_function_id} $ptr_load_ref"
        }

        ## save dont touch net related info
        puts $output_file "  checking_dont_touch $line ${drive_pin_info} $num_of_load_pins ${load_pin_info}"
      }

    } else {
      puts "Error: The dont touch net doesn't exist, please check it: $line"
    }
  }

  puts $output_file "\n  puts \$file \"\\n----------------------------------------------------------------------------\""
  puts $output_file "  puts \$file \"Information: Total checked \[ expr \$pass_num + \$fail_num \] dont_touch nets; \$fail_num nets have changed; \$pass_num nets are OK.\\n\" "
  puts $output_file "  close \$file "
  puts $output_file "  puts \"Alchip-info: Completed to signoff check dont touch net in PrimeTime\\n\"\n\n}\n"
  close $input_file
  close $output_file
  puts "\nInformation: The checking dont_touch net script is generated, please source the script after layout in PrimeTime: $check_script\n"
  puts "Alchip-info: Completed to generate signoff check dont touch net PT scripts in ICC2\n"
}

