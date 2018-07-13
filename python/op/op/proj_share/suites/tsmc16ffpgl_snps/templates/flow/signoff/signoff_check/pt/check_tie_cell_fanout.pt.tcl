proc check_tie_cell_fanout {} {
puts  "Info: TIE_HL fanout checking start..."

set tie_cells [get_cells * -hier -filter { ( is_hierarchical == false ) && ( ref_name =~ "*TIEH*" || ref_name =~ "*TIEL*") } ]

foreach_in_collection tie_cell $tie_cells {
	set tie_cell_name [get_attribute [get_cells $tie_cell] full_name]
	set tie_fanout_number [sizeof_collection [filter_collection [all_connected [get_nets [all_connected [get_pins ${tie_cell_name}/Z*]]] -leaf ] "( object_class == pin && direction == in )"]]
	if { ${tie_fanout_number} > 15 } {
	echo "${tie_cell_name}/Z* fanout is " ${tie_fanout_number}
	}
   }
}

#Usage:check_tie_cell_fanout
