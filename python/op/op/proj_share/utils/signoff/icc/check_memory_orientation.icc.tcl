##################################################################################
# PROGRAM:     check_memory_orientation.icc.tcl 
# CREATOR:     Michael Mo <michaelm@alchport.com>
# DATE:        Fri Mar 17 11:38:31 CST 2017
# DESCRIPTION: Check memory orientation in IC Compiler
# USAGE:       check_memory_orientation
# FOR:         GE-04-13
##################################################################################

proc check_memory_orientation { { output check_memory_orientation.rep } } {
	global ip_reference_names
	global physical_partition_reference_names
	global allowed_memory_orientation_icc
  if { [ info exists ip_reference_names ] == 0 } {
		puts "Error: The procedure 'check_ip_isolation' stop, Please set variables ip_reference_names."
	  return
	}
  if { [ info exists physical_partition_reference_names ] == 0 } {
		puts "Error: The procedure 'check_ip_isolation' stop, Please set variables physical_partition_reference_names."
	  return
	}
  if { [ info exists allowed_memory_orientation_icc ] == 0 || $allowed_memory_orientation_icc == "" } {
		puts "Error: The procedure 'check_memory_orientation' stop, Please set variables allowed_memory_orientation_icc correctly"
	  return
	}
	set file [ open $output w ]
	set ip_block_reference_list ""
	set ip_names ""
	set block_names ""
	set ip_block_list ""
	set mem_orientation ""
	set mem_orientation_unique ""
	set memories ""
	set mems ""
	puts $file "Allowed memory orientation: $allowed_memory_orientation_icc"
	puts $file "Unallowed memory orientation:"
	foreach ip_reference_name $ip_reference_names {
		set ip [ get_flat_cells -filter "ref_name =~ $ip_reference_name" -quiet ]
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
	set memories [ remove_from_collection [ filter_collection [ all_macro_cells ] "is_sequential == true" ] [ get_cells $ip_block_list ] ]
	if { [ sizeof_collection [ get_cells $memories -quiet ] ] != 0 } {
		set mem_orientation [ get_attribute [ get_cells $memories ] orientation ]
		set mem_orientation_unique [ lsort -unique $mem_orientation ]
		foreach orien $mem_orientation_unique {
			set flag 0
			foreach allowed_orien $allowed_memory_orientation_icc {
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
}
