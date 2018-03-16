##############################################################################################
# PROGRAM     : check_delay_cell_chain.icc2.tcl 
# CREATOR     : Alchip                                
# DATE        : 2018-02-08                                                   
# DESCRIPTION : check delay cell chain which contain five delay cells                                    
# UPDATER     : Felix Yuan <felix_yuan@alchip.com>  
# USAGE       : check_delay_cell_chain ?<delay_cell_type> ?<output_rpt_delay_cell_chain>                           
# ITEM        : GE-02-03                                                   
##############################################################################################

proc check_delay_cell_chain {{delay_cell_type "ref_name=~DEL*"} {output_rpt_delay_cell_chain "check_delay_cell_chain.rpt"} } {
     puts "Alchip-info: Starting to signoff check delay cell chain in ICC2\n"
     ###
     #source /proj/MDGRAPE-4A_new/WORK/felix/Sign-off-check/get_drivers.tcl
     set file [ open $output_rpt_delay_cell_chain w ]
     set delay_cells [get_cells -hierarchical -filter "$delay_cell_type && is_hierarchical==false"]
     set delay_cell_input_pin I
     
foreach_in_collection delay_cell $delay_cells {
	set drive_1_cell_ref ""
	set drive_2_cell_ref ""
	set drive_3_cell_ref ""
	set drive_4_cell_ref ""
	set drive_5_cell_ref ""

	set delay_cell_name [get_object_name $delay_cell]
	set delay_cell_ref [get_attribute $delay_cell ref_name]

	set drive_1_pin  [get_drivers $delay_cell_name/$delay_cell_input_pin ]
	set drive_1_pin_name [get_object_name $drive_1_pin]
	if { [regexp {/} $drive_1_pin_name] } {
		set drive_1_cell [get_cells -of $drive_1_pin]
		set drive_1_cell_name [get_object_name $drive_1_cell]
		set drive_1_cell_ref [get_attribute $drive_1_cell ref_name]

		if { [regexp {^DEL} $drive_1_cell_ref] } {
			set drive_2_pin [get_driver $drive_1_cell_name/$delay_cell_input_pin ]
			set drive_2_pin_name [get_object_name $drive_2_pin]
			if { [regexp {/} $drive_2_pin_name] } {
				set drive_2_cell [get_cells -of $drive_2_pin]
				set drive_2_cell_name [get_object_name $drive_2_cell]
				set drive_2_cell_ref [get_attribute $drive_2_cell ref_name]

				if { [regexp {^DEL} $drive_2_cell_ref] } {
					set drive_3_pin [get_driver $drive_2_cell_name/$delay_cell_input_pin ]
					set drive_3_pin_name [get_object_name $drive_3_pin]
					if { [regexp {/} $drive_3_pin_name] } {
						set drive_3_cell [get_cells -of $drive_3_pin]
						set drive_3_cell_name [get_object_name $drive_3_cell]
						set drive_3_cell_ref [get_attribute $drive_3_cell ref_name]
						if { [regexp {^DEL} $drive_3_cell_ref] } {
							set drive_4_pin [get_driver $drive_3_cell_name/$delay_cell_input_pin ]
							set drive_4_pin_name [get_object_name $drive_4_pin]
							if { [regexp {/} $drive_4_pin_name] } {
								set drive_4_cell [get_cells -of $drive_4_pin]
								set drive_4_cell_name [get_object_name $drive_4_cell]
								set drive_4_cell_ref [get_attribute $drive_4_cell ref_name]
								if { [regexp {^DEL} $drive_4_cell_ref] } {
									set drive_5_pin [get_driver $drive_4_cell_name/$delay_cell_input_pin ]
									set drive_5_pin_name [get_object_name $drive_5_pin]
									if { [regexp {/} $drive_5_pin_name] } {
										set drive_5_cell [get_cells -of $drive_5_pin]
										set drive_5_cell_name [get_object_name $drive_5_cell]
										set drive_5_cell_ref [get_attribute $drive_5_cell ref_name]
	
										if { [regexp {^DEL}  $drive_5_cell_ref] } {
											echo "$drive_5_cell_ref -> $drive_4_cell_ref -> $drive_3_cell_ref -> $drive_2_cell_ref -> $drive_1_cell_ref -> $delay_cell_ref $delay_cell_name"
											puts $file "$drive_5_cell_ref -> $drive_4_cell_ref -> $drive_3_cell_ref -> $drive_2_cell_ref -> $drive_1_cell_ref -> $delay_cell_ref $delay_cell_name"
										}
									}
								}
	
							}
						}
					}
				}
			} 
		}
	} else {
		set drive_1_cell_ref ""
		echo "Warning: $delay_cell_name  cell's driver is port"
		puts $file "Warning: $delay_cell_name  cell's driver is port"
	}
    }
    close $file
    puts "Alchip-info: Completed to signoff check delay cell chain in ICC2\n"
}
