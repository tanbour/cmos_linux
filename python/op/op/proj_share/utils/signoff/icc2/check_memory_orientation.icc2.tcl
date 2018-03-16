#################################################################################################################################################
# PROGRAM     : check_memory_orientation.icc2.tcl 
# CREATOR     : Michael Mo <michaelm@alchport.com>
# DATE        : Mon Mar 27 16:03:45 CST 2017
# DESCRIPTION : Check memory orientation in IC Compiler II
# USAGE       : check_memory_orientation ?<allowed_orientation.list> ?<check_memory_orientation.rpt>
# UPDATE      : updated by Felix Yuan <felix_yuan@alchip.com>  2018-02-10
# ITEM        : GE-04-15
#################################################################################################################################################

proc check_memory_orientation {{mem_orientation_file "allowed_orientation.list"} { output_rpt_mem_orientation check_memory_orientation.rpt } } {
        puts "Alchip-info: Starting to signoff check memory orientation in ICC2\n"
        set allowed_mem_orientation [ open $mem_orientation_file r ]
	global mem_ref_names
	global physical_partition_reference_names
#	global allowed_mem_orientation
	if { [ info exists mem_ref_names ] == 0 } {
		puts "Error: The procedure 'check_ip_isolation' stop, Please set variables mem_ref_names."
	  return
	}
	if { [ info exists physical_partition_reference_names ] == 0 } {
		puts "Error: The procedure 'check_ip_isolation' stop, Please set variables physical_partition_reference_names."
	  return
	}
  if { [ info exists allowed_mem_orientation ] == 0 || $allowed_mem_orientation == "" } {
		puts "Error: The procedure 'check_memory_orientation' stop, Please set variables allowed_mem_orientation correctly."
	  return
	}
	set file [ open $output_rpt_mem_orientation w ]
	set ip_block_reference_list ""
	set ip_names ""
	set block_names ""
	set ip_block_list ""
	set mem_orientation ""
	set mem_orientation_unique ""
	set memories ""
	set mems ""
	puts $file "Allowed memory orientation: $allowed_mem_orientation"
	puts $file "Unallowed memory orientation:"
	foreach mem_ref_name $mem_ref_names {
		set ip [ get_flat_cells -filter "ref_name =~ $mem_ref_name" -quiet ]
		if { [ sizeof_collection [ get_cells $ip -quiet ] ] == 0 } {
			continue
		}
		set ip_names [ get_attr [ get_cells $ip ] full_name ]
		foreach ip_name $ip_names {
			lappend ip_block_list $ip_name
		}
	}
	foreach physical_reference_name $physical_partition_reference_names {
		set block [ get_flat_cells -filter "ref_name =~ $physical_reference_name" -quiet ]
		if { [ sizeof_collection [ get_cells $block -quiet ] ] == 0 } {
			continue
		}
		set block_names [ get_attr [ get_cells $block ] full_name ]
		foreach block_name $block_names {
			lappend ip_block_list $block_name
		}
	}
	set memories [ remove_from_collection [ filter_collection [ get_flat_cells -filter "is_memory_cell == true" ] "is_sequential == true" ] [ get_cells $ip_block_list ] ]
	if { [ sizeof_collection [ get_cells $memories -quiet ] ] != 0 } {
		set mem_orientation [ get_attribute [ get_cells $memories ] orientation ]
		set mem_orientation_unique [ lsort -unique $mem_orientation ]
		foreach orien $mem_orientation_unique {
			set flag 0
			foreach allowed_orien $allowed_mem_orientation {
				if { $orien == $allowed_orien } {
					set flag 1
				}
			}
			if { $flag == 0 } {
				set mems [ get_attribute [ get_flat_cells $memories -filter "orientation =~ $orien" ] full_name ]
				foreach mem $mems {
					puts $file "Error: $mem ($orien)"
				}
			}
		}
	} else {
		puts $file "No memory!"
	}
	close $file
        puts "Alchip-info: Completed to signoff check memory orientation in ICC2\n"
}
