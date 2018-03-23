####################################################################################################################
# PROGRAM     : check_multi_drive_cell_type.pt.tcl 
# CREATOR     : Alchip                                
# DATE        : 2018-03-03                                                   
# DESCRIPTION : check  multi-drive cell type  in PrimeTime 
# USAGE       : check_multi_drive_cell_type ?<check_multi_drive_cell_type.rpt> 
# UPDATER     : Felix Yuan <felix_yuan@alchip.com>  
# ITEM        : GE-02-03 CK-01-16
####################################################################################################################

proc check_multi_drive_cell_type { {output_rpt_multi_cell_type check_multi_drive_cell_type.rpt} } {
     puts "Alchip-info: Starting to signoff check multi-driver cell type in PrimeTime\n"
     set file [ open $output_rpt_multi_cell_type w ]
	foreach_in_collection net [get_nets -hierarchical -top_net_of_hierarchical_group -segments] {
		if {[sizeof_collection [get_pins -quiet -of $net -filter "direction ==out && is_hierarchical == false"] ] > 1 } {
			set net_name [get_attr $net full_name]
			#puts "Checking multi driver net: $net_name "
			set driver_pins [get_pins -quiet -of $net -filter "direction ==out && is_hierarchical == false"]
			set driver_cell_types [lsort -unique [get_attr [get_cells -of_objects [get_pins -of_objects $net -filter "direction ==out && is_hierarchical == false" ] ] ref_name ]]
			if {[llength $driver_cell_types ]>1} {
				echo "Error : $net_name driver cell type are different : $driver_cell_types !!"
				puts $file "Error : $net_name driver cell type are different : $driver_cell_types !!"
			}
			set input_pin_names [lsort -u [get_attr [get_pins -of [get_cells -of_objects [get_drivers $net_name]] -filter "direction==in" ] lib_pin_name ]]
			foreach input_pin_name $input_pin_names {
				set drv_nets [get_nets -top -seg -of [get_pins -of [get_cells -of_objects [get_drivers $net_name]] -filter "direction==in && lib_pin_name == $input_pin_name"]]
				if {[sizeof_collection $drv_nets]> 1} {
					echo [format "Error:  %s"  [get_attr $drv_nets full_name]]
					puts $file [format "Error:  %s"  [get_attr $drv_nets full_name]]

				}
			} 
	 	}
	}
     close $file
     puts "Alchip-info: Completed to signoff check multi-driver cell type in PrimeTime\n"
}
