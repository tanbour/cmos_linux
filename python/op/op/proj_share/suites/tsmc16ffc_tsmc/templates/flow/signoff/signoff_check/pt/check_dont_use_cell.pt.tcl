#!/usr/bin/tclsh
#########################################################################################################
# PROGRAM:     check_dont_use_cell.pt.tcl
# CREATOR:     Zachary Shi <zacharys@alchip.com>
# DATE:        Wed Mar 29 10:37:45 CST 2017
# DESCRIPTION: Check dont_use cell script in PrimeTime.
# USAGE:       check_dont_use_cell ?<check_dont_use_cell.rep>
# UPDATE:      updated by Felix <felix_yuan@alchip.com>    2018-03-06
# FOR:         GE-02-16
#########################################################################################################

proc check_dont_use_cell {{output_rpt_dont_use_cell check_dont_use_cell.rep} } {
     puts "Alchip-info: Starting to signoff check dont use cell in PrimeTime\n"
     set file [ open $output_rpt_dont_use_cell w ]

     set pass_num    0
     set fail_num    0
     set max_area    50
     set max_pin_num 10
     set std_cel_vio ""
     set cell_names [ lsort -uniq [ get_attribute [ get_cells * -hierarchical -filter "is_combinational == true || is_sequential == true" ] ref_name ] ]

  foreach cel $cell_names {
    if { [sizeof_collection [ get_lib_cells */$cel -quiet ] ] } {

      set area    [get_attribute [get_lib_cells */$cel -quiet ] area -quiet ]
      set pin_num [get_attribute [get_lib_cells */$cel -quiet ] number_of_pins -quiet ]

      if { $area > $max_area || $area == "0" } {
        set is_standard_cell 0
      } else {
        if { $pin_num > $max_pin_num } {
          set is_standard_cell 0
        } else {
          set is_standard_cell 1
        }
      }

      if { [ get_attribute [ get_lib_cells */$cel -quiet ] dont_use -quiet ] } {
        if { $is_standard_cell } {
          #puts [ format "Error: Standard cell type '%s' found, but 'dont_use' attribute given to cell type '%s'." $cel $cel ]
          lappend std_cel_vio $cel
          incr fail_num

        } else {
          puts $file [ format "Warning: Macro cell type '%s' found, but 'dont_use' attribute given to cell type '%s'." $cel $cel ]
          incr pass_num
        }

      } else {
        if { $is_standard_cell } {
          puts $file [ format "Information: Standard cell type '%s' found, 'dont_use' attribute checking is OK." $cel ]
          incr pass_num

        } else {
          puts $file [ format "Information: Macro cell type '%s' found, 'dont_use' attribute checking is OK." $cel ]
          incr pass_num
        }
      }

    } else {
      puts  $file "Error: Can not find this lib cell, please check it: $cel"
      incr fail_num
    }
  }

  if { [ llength $std_cel_vio ] > 0 } {
    puts $file "---------------------------------------------------------------------------------"

    foreach scv $std_cel_vio {
      puts $file [ format "Error: Standard cell type '%s' found, but 'dont_use' attribute given to cell type '%s'." $scv $scv ]
      set cell_name [ get_attribute [ get_cells * -hierarchical -filter "ref_name == $scv" ] full_name ]
      set vio_std   [ llength $cell_name ]

      if { $vio_std >= 10 } {
        set echo_num 10
      } else {
        set echo_num $vio_std
      }

      puts $file "\tTotal $vio_std instances, first $echo_num:"
      for { set n 1 } { $n <= $echo_num } { incr n } {
        puts $file [ format "\t%2d: %s" $n [ lindex $cell_name [expr $n -1] ] ]
      }
    }

  }

  puts $file "---------------------------------------------------------------------------------"
  puts $file "Total checked [ expr $pass_num + $fail_num ] lib cells, $fail_num failed, $pass_num passed.\n"
  
  puts  "Alchip-info: Completed to signoff check dont use cell in PrimeTime\n"
}
