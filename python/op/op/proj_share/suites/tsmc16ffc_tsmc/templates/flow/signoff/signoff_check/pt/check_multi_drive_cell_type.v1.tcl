proc check_multi_drive_cell_type {} {
	foreach_in_collection net [get_nets -hierarchical] {
		if {[sizeof_collection [get_pins -quiet -of $net -filter "direction ==out && is_hierarchical == false"] ] > 1 } {
			set net_name [get_attr $net full_name]
			set driver_pins [get_pins -quiet -of $net -filter "direction ==out && is_hierarchical == false"]
			set driver_cell_types [lsort -unique [get_attr [get_cells -of_objects [get_pins -of_objects $net -filter "direction ==out && is_hierarchical == false" ] ] ref_name ]]
			if {[llength $driver_cell_types ]>1} {
				echo "Error : $net_name driver cell type are different : $driver_cell_types !!"
			}
	 	}
	}
}
