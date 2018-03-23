################################################################################################################################################
# PROGRAM   : report_clock_cell_type.pt.tcl 
# CREATOR   : Alchip                                
# DATE      : 2018-02-13                                                                              
# Modifier  : Felix <felix_yuan@alchip.com>                                                           
# Function  : check high_vth / low_drive / non_symmetric cell in PrimeTime.                           
# Usage     : report_clock_cell_type ?<high_vth_cell_ref_name> ?<low_drive_cell_ref_name> ?<report_clock_cell_type.rpt> 
# UPDATER   : Felix Yuan <felix_yuan@alchip.com>  
# ITEM      : CK-01-03 ;  CK-01-04 ; CK-01-05                                                              
################################################################################################################################################

proc report_clock_cell_type {{high_vth_cell_ref_name *HVT} {low_drive_cell_ref_name *D[01]HVT} {output_rpt_clock_cell report_clock_cell_type.rpt} } {
     puts "Alchip-info: Starting to signoff check clock cell type in PrimeTime\n"
     set file [ open $output_rpt_clock_cell w ]

     set total_count(high_vth)      0
     set total_count(low_drive)     0
     set total_count(non_symmetric) 0

     set error_count   0
     set warning_count 0
     set info_count    0

     set clocks [ get_clocks -quiet * ]
     set clocks [ add_to_collection $clocks [ get_clocks -quiet * ] ]

  foreach_in_collection clock $clocks {
    foreach_in_collection source [ get_attribute -quiet $clock sources ] {
      puts $file [ format "------------------------------------------------------------------------" ]
      if { [ get_attribute $source object_class ] == "port" } {
        puts $file [ format "Information: Checking clock network from source %s (%s) in clock %s" \
          [ get_attribute $source full_name ] [ get_attribute $source direction ] [ get_attribute $clock full_name ] ]
        incr info_count
      } else {
        puts $file [ format "Information: Checking clock network from source %s (%s) in clock %s" \
          [ get_attribute $source full_name ] [ get_attribute [ get_cells -of_objects $source ] ref_name ] [ get_attribute $clock full_name ] ]
        incr info_count
      }

      # all cells from clock source
      set clock_cells [ all_fanout -flat -from $source -only_cells ]

      # exclude leaf flipflops
      set clock_cells [ remove_from_collection $clock_cells [ all_fanout -flat -from $source -only_cells -endpoints_only ] ]

      # generated clock source
      if { [ get_attribute $source object_class ] == "pin" } {
        set clock_cell [ get_cells -of_objects $source ]
        if { [ sizeof_collection $clock_cells ] == [ sizeof_collection [ remove_from_collection $clock_cells $clock_cell ] ] } {
          set clock_cells [ add_to_collection $clock_cells $clock_cell ]
        }
      } 

      ########################################################################
      # check high-vth cells
      #
      set high_vth_cells [ filter_collection -regexp $clock_cells { ref_name =~ .$high_vth_cell_ref_name$ } ]
      set count [ sizeof_collection $high_vth_cells ]
      if { $count == 0 } {
        puts $file [ format "Information: %d high-vth cells used in %s." $count [ get_attribute $clock full_name ] ]
      } else {
        puts $file [ format "Error: %d high-vth cells used in %s." $count [ get_attribute $clock full_name ] ]
        foreach_in_collection cell $high_vth_cells {
          puts $file [ format "%s (%s)" [ get_attribute $cell full_name ] [ get_attribute $cell ref_name ] ]
        }
      }
      set total_count(high_vth) [ expr $total_count(high_vth) + $count ]

      ########################################################################
      # low drive cells
      #
      #set low_drive_cells [ filter_collection -regexp $clock_cells { ref_name =~ .$low_drive_cell_ref_name$ || ref_name =~ .*D[01]$ } ]
      set low_drive_cells [ filter_collection -regexp $clock_cells { ref_name =~ .$low_drive_cell_ref_name$ } ]
      set count [ sizeof_collection $low_drive_cells ]
      if { $count == 0 } {
        puts $file [ format "Information: %d low-drive cells used in %s." $count [ get_attribute $clock full_name ] ]
        incr info_count
      } else {
        puts $file [ format "Error: %d low-drive cells used in %s." $count [ get_attribute $clock full_name ] ]
        foreach_in_collection cell $low_drive_cells {
          puts $file [ format "%s (%s)" [ get_attribute $cell full_name ] [ get_attribute $cell ref_name ] ]
        }
        incr warning_count
      }
      set total_count(low_drive) [ expr $total_count(low_drive) + $count ]

      ########################################################################
      # check non-symmetric cells
      #
      set non_symmetric_cells [ filter_collection -regexp $clock_cells { ref_name =~ ^AN2D[0-9].* || ref_name =~ ^BUFFD[0-9].* || ref_name =~ ^MUX2D[0-9].* || ref_name =~ ^INVD[0-9].* || ref_name =~ ^ND2D[0-9].* || ref_name =~ ^XOR2D[0-9].* } ]
      set count [ sizeof_collection $non_symmetric_cells ]
      if { $count == 0 } {
        puts $file [ format "Information: %d non-symmetric cells used in %s." $count [ get_attribute $clock full_name ] ]
        incr info_count
      } else {
        puts $file [ format "Error: %d non-symmetric cells used in %s." $count [ get_attribute $clock full_name ] ]
        foreach_in_collection cell $non_symmetric_cells {
          puts $file [ format "%s (%s)" [ get_attribute $cell full_name ] [ get_attribute $cell ref_name ] ]
        }
        incr error_count
      }
      puts $file [ format "" ]
      set total_count(non_symmetric) [ expr $total_count(non_symmetric) + $count ]
    }
  }
  puts $file [ format "========================================================================" ]
  puts $file [ format "Information: Total %d high-vth cells used." $total_count(high_vth) ]
  puts $file [ format "Information: Total %d low-drive cells used." $total_count(low_drive) ]
  puts $file [ format "Information: Total %d non-symmetric cells used." $total_count(non_symmetric) ]
# puts $file [ format "Diagnostics summary: %d errors, %d warnings, %d informationals" $error_count $warning_count $info_count ]
  puts $file [ format "" ]
  close $file
  puts "Alchip-info: Completed to signoff check clock cell type in PrimeTime\n"
}
