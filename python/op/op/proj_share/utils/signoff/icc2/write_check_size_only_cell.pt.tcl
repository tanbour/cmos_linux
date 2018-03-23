#!/usr/bin/tclsh
###############################################################################################################
# PROGRAM    : write_check_size_only_cell.pt.tcl
# CREATOR    : Zachary Shi <zacharys@alchip.com>
# DATE       : Fri Apr 14 19:24:21 CST 2017
# DESCRIPTION: Generated size_only cell checking script in ICC2.
# Usage      : write_check_size_only_cell ?<size_only_cells.tcl> ?<check_size_only_cell.pt.tcl>
# UPDATE     : updated by Felix <felix_yuan@alchip.com>    2018-03-06
# Item       : GE-02-06 GE-02-07               
###############################################################################################################

proc write_check_size_only_cell { { size_only_cell size_only_cells.tcl } { check_script check_size_only_cell.pt.tcl } } {
     puts "Alchip-info: Starting to generate signoff check size only cell PT scripts in ICC2\n"

     if {[file exist $check_script]} {
       puts "Warning: Checking size_only cell script is exist: $check_script"
       return
     }
   
     if {[file exist $size_only_cell] == 0} {
       puts "Warning: Can't find the size_only cell list, please check it."
       return
   
     } else {
       if {[file size $size_only_cell] == 0} {
         puts "Warning: The size_only cell list is empty, please check it: $size_only_cell"
         return
       }
     }

  set input_file  [open $size_only_cell r]
  set output_file [open $check_script w]

  puts $output_file "#!/usr/bin/tclsh"
  puts $output_file "################################################################################################"
  puts $output_file "# PROGRAM:     check_size_only_cell.pt.tcl"
  puts $output_file "# CREATOR:     Zachary Shi <zacharys@alchip.com>"
  puts $output_file "# DATE:        [date]"
  puts $output_file "# DESCRIPTION: Checking size_only cell in PrimeTime"
  puts $output_file "#              The specific instances (size_only cells) need to be preserved"
  puts $output_file "# USAGE:       check_size_only_cell ?<check_size_only_cell.rpt>"
  puts $output_file "# UPDATE:      updated by Felix <felix_yuan@alchip.com>    2018-03-09 "      
  puts $output_file "# Item :       GE-02-06 GE-02-07"      
  puts $output_file "#################################################################################################"
  puts $output_file "proc check_size_only_cell { {output_rpt_size_only_cell  check_size_only_cell.rpt} } {\n"
  puts $output_file "  puts \"Alchip-info: Starting to signoff check size only cell in PrimeTime\\n\" "
  puts $output_file "  set file \[ open \$output_rpt_size_only_cell w \] "
  puts $output_file "  set pass_num 0"
  puts $output_file "  set fail_num 0\n"
  puts $output_file "  proc checking_size_only { args } {\n"
  puts $output_file "    upvar pass_num loc_pass_num"
  puts $output_file "    upvar fail_num loc_fail_num\n"
  puts $output_file "    set cell_name   \[ lindex \$args 0 \]"
  puts $output_file "    set ref_name    \[ lindex \$args 1 \]"
  puts $output_file "    set function_id \[ lindex \$args 2 \]\n"
  puts $output_file "    if { \[ sizeof_collection \[ get_cells \$cell_name -quiet \] \] } {"
  puts $output_file "      set cur_ref_name \[ get_attribute \[ get_cells \$cell_name \] ref_name \]"
  puts $output_file "      set cur_funct_id \[ lindex \[ get_attribute \[ get_lib_cells */\$cur_ref_name \] function_id \] 0 \]\n"
  puts $output_file "      if { \$cur_ref_name == \$ref_name } {"
  puts $output_file "        puts \$file \"Information: Checking the size_only cell is OK, cell: \${cell_name}\""
  puts $output_file "        incr loc_pass_num\n"
  puts $output_file "      } elseif { \$cur_funct_id == \$function_id } {"
  puts $output_file "        puts \$file \"Warning: The size_only cell looks have changed the drive strength, cell: \${cell_name}, orig_ref_name: \${ref_name}, current_ref_name: \${cur_ref_name}\""
  puts $output_file "        incr loc_pass_num\n"
  puts $output_file "      } else {"
  puts $output_file "        puts \$file \"Error: The size_only cell have been changed, please check it: \${cell_name}\""
  puts $output_file "        incr loc_fail_num"
  puts $output_file "      }\n"
  puts $output_file "    } else {"
  puts $output_file "      puts \$file \"Error: The size_only cell doesn't exist, please check it: \${cell_name}\""
  puts $output_file "      incr loc_fail_num"
  puts $output_file "    }"
  puts $output_file "  }\n"

  while {[gets $input_file line] >= 0} {

    ## ignore the annotations and empty lines, update Fri Apr 14 19:24:21 CST 2017
    if { [ regexp {^\s*#} $line ] || [ regexp {^\s*$} $line ] } {
      continue
    }

    if {[llength $line] == 1} {
      set cell_name $line

    } else {
      if {[regsub {\W*\]} [regsub {set_dont_touch.*get_cells\W*} $line ""] "" match_cell]} {
        set cell_name $match_cell

      } else {
        puts "Warning: Can't understand the size_only cell list, ignored and please check it: $line"
        continue
      }
    }

    if {[sizeof_collection [get_cells $cell_name -quiet]]} {
      set ref_name    [get_attribute [get_cells $cell_name] ref_name]
      set function_id [lindex [get_attribute [get_lib_cells */$ref_name] function_id] 0] ; # can't differentiate buf/bufh
      puts $output_file "  checking_size_only $cell_name $ref_name \{$function_id\}"

    } else {
      puts "Error: This size_only cell doesn't exist in the original netlist, please check it: $line"
    }
  }

  puts $output_file "\n  puts \$file \"\\n----------------------------------------------------------------------------\""
  puts $output_file "  puts \$file \"Information: Total checked \[ expr \$pass_num + \$fail_num \] size_only cells, \$fail_num cell type are changed, \$pass_num cells are OK.\\n\" "
  puts $output_file "  close \$file "
  puts $output_file "  puts \"Alchip-info: Completed to signoff check size only cell in PrimeTime\\n\"\n\n}\n"
  close $input_file
  close $output_file
  puts "\nInformation: The checking size_only cell script is generated, please source the script after layout in PrimeTime: $check_script\n"
  puts "Alchip-info: Completed to generate signoff check size only cell PT scripts in ICC2\n"
}
