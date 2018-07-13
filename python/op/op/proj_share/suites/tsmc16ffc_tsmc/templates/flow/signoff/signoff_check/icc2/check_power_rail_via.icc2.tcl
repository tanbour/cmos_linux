#!/usr/bin/tclsh
#######################################################################################################
# PROGRAM     : check_power_rail_via.icc2.tcl
# CREATOR     : Zachary Shi <zacharys@alchip.com>
# DATE        : Fri Aug 11 12:23:04 2017
# DESCRIPTION : checking the PG via array size if they match the "via_patterns".
#               you can modify the "via_patterns" to fit your design
# USAGE       : check_power_rail_via < none | -power | -ground >
#               check_power_rail_via -help
# ITEM        : GE-04-01
#######################################################################################################

proc check_power_rail_via { args } {
  puts "Alchip-info: Starting to signoff check PG via array size in ICC2\n"

  set args_num [ llength $args ]
  # comment: you can updated the patterns to check other via array size type
  set via_patterns {{1 1} {1 2} {2 1} {2 2}}
  # comment: output all the matched PG vias to this script and used it to hightlight these PG vias in ICC2 GUI
  set hl_via_script "check_power_rail_via.[clock milliseconds].tcl"
  redirect -file $hl_via_script {puts "change_selection"}
  # comment: false is not write hight light script, true is write
  set write_hl_script "false"
  # comment: for count vias which do not match the via_patterns
  set via_num 0

  foreach via_pattern $via_patterns {
    set VIA($via_pattern) 0
    dputs "Info: initial set the variable \$VIA($via_pattern) 0"
  }

  if { $args_num == 0 } {
    set pg_vias [ check_power_rail_via::get_pg_vias ]

  } elseif { $args_num == 1 } {

    set flag [ lindex $args 0 ]
    if { $flag == "-power" } {
      set pg_vias [ check_power_rail_via::get_pg_vias power ]
    } elseif { $flag == "-ground" } {
      set pg_vias [ check_power_rail_via::get_pg_vias ground ]
    } else {
      check_power_rail_via::script_help
      return
    }

  } else {
    check_power_rail_via::script_help
    return
  }

  puts "Info: there total found [ llength $pg_vias ] PG vias."

  foreach pg_via $pg_vias {
    set via_array [ get_attribute [ get_vias $pg_via ] array_size ]
    if { [ lsearch $via_patterns $via_array ] == "-1" } {
      incr via_num
    } else {
      incr VIA($via_array)
      set loc_box [ get_attribute [ get_vias $pg_via ] bbox ]
      
      redirect -file $hl_via_script -append {
        puts "change_selection \[ get_attribute \[ get_vias $pg_via \] full_name \] -add\t\t;# PG via location: $loc_box"
      }
    }
  }

  dputs "Info: there total $via_num PG vias were checked OK."

  foreach via_pattern $via_patterns {
    if { $VIA($via_pattern) != 0 } {
      puts "Error: the PG via array size \"$via_pattern\" number: $VIA($via_pattern)"
      set write_hl_script "true"
    } else {
      dputs "Info: the PG via array size \"$via_pattern\" number is $VIA($via_pattern)"
    }
  }

  if { $write_hl_script == "false" } {
    file delete $hl_via_script
    puts "Info: all the PG vias were checked OK."
  } else {
    puts "\nInfo: please using the script $hl_via_script to high light the PG vias array which matched \"$via_patterns\""
  }

}

#### sub proceduce ####
namespace eval check_power_rail_via {

  proc script_help {} {
    puts "Warning: the input variable is not right."
    puts "Usage:   check_power_rail_via < none | -power | -ground >"
    puts "         <none>      check all the PG vias in the design, nothing need to be specified."
    puts "         <-power>    check the \"power\" PG vias in the design, only need to specified the option \"-power\"."
    puts "         <-ground>   check the \"ground\" PG vias in the design, only need to specified the option \"-ground\"."
  }

  proc get_pg_vias { args } {
    if { [ llength $args ] == 0 } {
      set pg_vias [ get_attribute [ get_vias * -filter "net_type == ground || net_type == power || net_type == analog_ground || net_type == analog_power" ] full_name ] ;# issue: if the "net_type" does not cover all the PG nets
    } else {
      set pg_vias [ get_attribute [ get_vias * -filter "net_type == $args" ] full_name ]
    }
    return $pg_vias
  }
  puts "Alchip-info: Completed to signoff check PG via array size in ICC2\n"
}

proc dputs { input } {

  set is_debug "false" ; # "true" is used for debug script, "false" is used for regular using script.

  if { $is_debug } {
    puts $input
  }
}
  puts "Alchip-info: Completed to signoff check PG via array size in ICC2\n"
