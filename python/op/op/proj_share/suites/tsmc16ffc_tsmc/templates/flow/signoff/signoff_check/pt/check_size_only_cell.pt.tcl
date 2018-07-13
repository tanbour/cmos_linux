#!/usr/bin/tclsh
################################################################################################
# PROGRAM:     check_size_only_cell.pt.tcl
# CREATOR:     Zachary Shi <zacharys@alchip.com>
# DATE:        Sat Mar  3 13:15:11 2018
# DESCRIPTION: Checking size_only cell in PrimeTime
#              The specific instances (size_only cells) need to be preserved
# USAGE:       check_size_only_cell > check_size_only_cell.rep
# Item :       GE-02-06 GE-02-07
#################################################################################################
proc check_size_only_cell { } {

  set pass_num 0
  set fail_num 0

  proc checking_size_only { args } {

    upvar pass_num loc_pass_num
    upvar fail_num loc_fail_num

    set cell_name   [ lindex $args 0 ]
    set ref_name    [ lindex $args 1 ]
    set function_id [ lindex $args 2 ]

    if { [ sizeof_collection [ get_cells $cell_name -quiet ] ] } {
      set cur_ref_name [ get_attribute [ get_cells $cell_name ] ref_name ]
      set cur_funct_id [ lindex [ get_attribute [ get_lib_cells */$cur_ref_name ] function_id ] 0 ]

      if { $cur_ref_name == $ref_name } {
        puts "Information: Checking the size_only cell is OK, cell: ${cell_name}"
        incr loc_pass_num

      } elseif { $cur_funct_id == $function_id } {
        puts "Warning: The size_only cell looks have changed the drive strength, cell: ${cell_name}, orig_ref_name: ${ref_name}, current_ref_name: ${cur_ref_name}"
        incr loc_pass_num

      } else {
        puts "Error: The size_only cell have been changed, please check it: ${cell_name}"
        incr loc_fail_num
      }

    } else {
      puts "Error: The size_only cell doesn't exist, please check it: ${cell_name}"
      incr loc_fail_num
    }
  }

  checking_size_only alchip251_dcg XOR2D0BWP16P90CPDULVT {xor2}
  checking_size_only alchip1166_dcg FA1D0BWP16P90CPDULVT {maj23_xor3}
  checking_size_only alchip718_dcg AOI21D1BWP16P90CPDULVT {a2.1b2.2}
  checking_size_only alchip1017_dcg XOR3D0BWP16P90CPDULVT {xor3}
  checking_size_only alchip339_dcg OAI21D0BWP16P90CPDULVT {Ia2.0b2.0}
  checking_size_only alchip597_dcg FA1D0BWP16P90CPDULVT {maj23_xor3}

  puts "\n----------------------------------------------------------------------------"
  puts "Information: Total checked [ expr $pass_num + $fail_num ] size_only cells, $fail_num cell type are changed, $pass_num cells are OK.\n"

}

