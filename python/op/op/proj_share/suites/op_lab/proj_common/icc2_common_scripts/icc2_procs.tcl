
## Revision History
#  April 26 write_floorplan_def added
#  April 27 gen_power udpated (old one is too dense)
#  	    gen_tracks updated (old one need to manual update M1 offset, new one is automatic)
#  	    clean_power_vias renamed to clean_power
#  May15    gen_power udpated to meet PG IR/EM requirement
#		M2 pitch 0.096 --> 0.048
#		M3 strap doubled
#		M11 width 0.288 --> 0.368 to enable more VIA10
#  June28   Add Vertical Abutment rule procs
#		dump_VAbut_attri
#		define_VAbut_attri


## ---------------------
## Sec0:  lib_prep Scripts
## ---------------------

proc dump_VAbut_attri {} {
	## DOC:  Use this proc to dump vertical abutment rule information from foundry provided NDM_physical_only ref_lib

      	set foundry_ndm_list [list \
        	tcbn07_bwph240l11p57pd_base_lvt \
	        tcbn07_bwph240l11p57pd_base_svt \
        	tcbn07_bwph240l11p57pd_base_ulvt \
	        tcbn07_bwph240l8p57pd_base_lvt \
        	tcbn07_bwph240l8p57pd_base_svt \
	        tcbn07_bwph240l8p57pd_base_ulvt \
	        tcbn07_bwph240l11p57pd_mb_lvt \
	        tcbn07_bwph240l11p57pd_mb_svt \
	        tcbn07_bwph240l11p57pd_mb_ulvt \
	        tcbn07_bwph240l8p57pd_mb_lvt \
	        tcbn07_bwph240l8p57pd_mb_svt \
        	tcbn07_bwph240l8p57pd_mb_ulvt \
	]

        foreach ref_lib $foundry_ndm_list {
                set outFileName ${ref_lib}.attri_setting.tcl
                set outFile [open $outFileName w]
  
		set lib_name [glob /proj/7nm_evl/Lib_N7/SC/6T_v1.0/${ref_lib}_*/TSMCHOME/digital/Back_End/ndm/${ref_lib}_*/${ref_lib}_physicalonly.ndm]
		open_lib $lib_name
			
		set ref_lib_p ${ref_lib}_physicalonly                

		foreach_in_collection lib_cell [get_lib_cells -include_subcells $ref_lib_p/*/frame] {
                        set ref_name [get_attribute $lib_cell block_name]
			set flipped_legal_site_index "\{[get_attribute $lib_cell flipped_legal_site_index]\}"
                        set legal_site_index "\{[get_attribute $lib_cell legal_site_index]\}"
                        set vertical_abut_pattern_bottom [get_attribute $lib_cell vertical_abut_pattern_bottom]
                        set vertical_abut_pattern_top [get_attribute $lib_cell vertical_abut_pattern_top]
			
                        puts $outFile "set_attri \[get_lib_cell ${ref_lib}/${ref_name}/\$view\] flipped_legal_site_index \{$flipped_legal_site_index\}"
                        puts $outFile "set_attri \[get_lib_cell ${ref_lib}/${ref_name}/\$view\] legal_site_index \{$legal_site_index\}"
                        puts $outFile "set_attri \[get_lib_cell ${ref_lib}/${ref_name}/\$view\] vertical_abut_pattern_bottom \{$vertical_abut_pattern_bottom\}"
                        puts $outFile "set_attri \[get_lib_cell ${ref_lib}/${ref_name}/\$view\] vertical_abut_pattern_top \{$vertical_abut_pattern_top\}"
                        puts $outFile "set_attri \[get_lib_cell ${ref_lib}/${ref_name}/\$view\] is_mask_shiftable true"
                }
                close $outFile
        	close_lib 
	}
}

proc define_VAbut_attri {} {
	## DOC:  You may need to define attibutes for adding VAbut rule markers

	define_user_attribute -persistent -type int -classes lib legal_index_cycle_length
        define_user_attribute -persistent -type string -class lib_cell flipped_legal_site_index
        define_user_attribute -persistent -type string -class lib_cell legal_site_index
        define_user_attribute -persistent -type string -class lib_cell vertical_abut_pattern_bottom
        define_user_attribute -persistent -type string -class lib_cell vertical_abut_pattern_top

	set_attribute [get_lib] legal_index_cycle_length 2
}


## ---------------------
## Sec1:  Floorplan Scripts
## ---------------------

proc gen_pblkg_for_macro {} {
	## DOC: This proc generate hard placement blkg and routing blkg for all macros in curren_design
	set macros_col [get_cells -hier -filter "design_type == macro"]
	set i 0
	foreach_in_collection macro $macros_col {
		set macro_bbox [get_attri $macro bbox]
		create_placement_blockage -type hard -boundary "$macro_bbox" -name PBLKG_$i
		incr i
	}
}

proc cut_macro_rows {} {
	## DOC: cut row for later PG generation
	foreach_in_collection pblkg [get_placement_blockages -filter "blockage_type == hard"] {
		set pblkg_box [get_attribute $pblkg bbox]
		cut_rows -within "$pblkg_box"
	}
}


proc gen_rblkg {blocked_layers} {
	## DOC: This proc generate routing blkg based on current hard placement blkg in curren_design
	set i 0
	foreach_in_collection pblkg [get_placement_blockage -filter "blockage_type==hard"] {
		set pblkg_boundary [get_attri $pblkg boundary]
		create_routing_blockage -layers $blocked_layers -boundary "$pblkg_boundary" -zero_spacing -name_prefix "RBLKG_${i}_"
		incr i
	}
}

proc get_blkg_p {type} {
	### DOC: get placement blockages
	return [get_placement_blockages -filter "blockage_type == $type"]
}

proc gen_floorplan {} {
	## initial_floorplan w/even number of site/row
	set_app_options -list {plan.flow.target_site_def "unit"}
	set_app_options -list {plan.flow.segment_rule "horizontal_even vertical_even"}
	initialize_floorplan -keep_boundary -site_def unit -core_offset {0.24 0.57} -flip_first_row true
	
	## tracks need to be dedicated defined
	remove_tracks -all
	## even segment_parity check
	check_boundary_cells -precheck_segment_parity -error_view " "
}

proc gen_tracks {} {
	set core_llx [lindex [lindex [get_attribute [get_core_area] bbox] 0] 0]
	set core_lly [lindex [lindex [get_attribute [get_core_area] bbox] 0] 1]
	set core_urx [lindex [lindex [get_attribute [get_core_area] bbox] 1] 0]
	set core_ury [lindex [lindex [get_attribute [get_core_area] bbox] 1] 1]
	
	set die_llx [lindex [lindex [get_attribute [current_block] boundary_bbox] 0] 0]
	set die_lly [lindex [lindex [get_attribute [current_block] boundary_bbox] 0] 1]
	set die_urx [lindex [lindex [get_attribute [current_block] boundary_bbox] 1] 0]
	set die_ury [lindex [lindex [get_attribute [current_block] boundary_bbox] 1] 1]
	
	set tile_height [lindex [get_attribute [get_site_rows] site_height] 0]
	set tile_height2 [expr 2*$tile_height]
	
	# Layer:  	M0 	 M1 	  M2 	   M3 	    M4 	     M5       M6       M7       M8 	 M9 	  M10 	   M11 	    M12      M13
	# min_width:	0.020000 0.034000 0.020000 0.020000 0.038000 0.038000 0.038000 0.038000 0.038000 0.038000 0.062000 0.062000 0.360000 0.360000
	# min_spacing:	0.020000 0.020000 0.020000 0.020000 0.038000 0.038000 0.038000 0.038000 0.038000 0.038000 0.064000 0.064000 0.360000 0.360000
	# pitch:	0.040000 0.057000 0.040000 0.044000 0.076000 0.076000 0.076000 0.076000 0.076000 0.076000 0.126000 0.126000 0.720000 0.720000

	set My_pitch_p76 0.076
	set My_pitch_p126 0.1260 
	set My_pitch_p720 0.7200

	set M0_pitch 0.0400
	set M1_pitch 0.0570
	set M2_pitch 0.0400
	set M3_pitch 0.0440
	set M4_pitch $My_pitch_p76; set M6_pitch $My_pitch_p76; set M8_pitch $My_pitch_p76
	set M5_pitch $My_pitch_p76; set M7_pitch $My_pitch_p76; set M9_pitch $My_pitch_p76
	set M10_pitch $My_pitch_p126; set M11_pitch $My_pitch_p126
	set M12_pitch $My_pitch_p720; set M13_pitch $My_pitch_p720
	
	set M0_track_offset [expr ($M0_pitch/2)];
	set M1_track_offset 0;
	set M2_track_offset [expr -($M2_pitch/2)];
	set M3_track_offset $M1_track_offset;
	set M4_track_offset $M1_track_offset;
	set M5_track_offset $M1_track_offset;
	set M6_track_offset $M1_track_offset ;
	set M7_track_offset $M1_track_offset;
	set M8_track_offset $M1_track_offset ;
	set M9_track_offset $M1_track_offset;
	set M10_track_offset $M1_track_offset;
	set M11_track_offset $M1_track_offset;
	set M12_track_offset $M1_track_offset;
	set M13_track_offset $M1_track_offset;
	
	## M0 track 
	#ROW1
	remove_track -layer M0
	create_track -layer M0 -coord [expr ${core_lly} + 0.000] -space $tile_height2 -mask_pattern mask_one
	create_track -layer M0 -coord [expr ${core_lly} + $M0_track_offset + $M0_pitch] -space $tile_height2 -mask_pattern mask_two
	create_track -layer M0 -coord [expr ${core_lly} + $M0_track_offset + 2 * $M0_pitch] -space $tile_height2 -mask_pattern mask_one
	create_track -layer M0 -coord [expr ${core_lly} + $M0_track_offset + 3 * $M0_pitch] -space $tile_height2 -mask_pattern mask_two
	create_track -layer M0 -coord [expr ${core_lly} + $M0_track_offset + 4 * $M0_pitch] -space $tile_height2 -mask_pattern mask_one
	#ROW2
	create_track -layer M0 -coord [expr ${core_lly} + $tile_height + 0.00] -space $tile_height2 -mask_pattern mask_two
	create_track -layer M0 -coord [expr ${core_lly} + $tile_height + $M0_track_offset + $M0_pitch] -space $tile_height2 -mask_pattern mask_one
	create_track -layer M0 -coord [expr ${core_lly} + $tile_height + $M0_track_offset + 2 * $M0_pitch] -space $tile_height2 -mask_pattern mask_two
	create_track -layer M0 -coord [expr ${core_lly} + $tile_height + $M0_track_offset + 3 * $M0_pitch] -space $tile_height2 -mask_pattern mask_one
	create_track -layer M0 -coord [expr ${core_lly} + $tile_height + $M0_track_offset + 4 * $M0_pitch] -space $tile_height2 -mask_pattern mask_two
	
	## M1 track with end_grid
	
	################################################################################
	#Create M1 track for TSMC H240, H300 and H360 libraries
	################################################################################

	remove_track -layer M1
	
	#set first_track_color mask_one
	set first_track_color mask_two
	
	if {$first_track_color == "mask_one"} { 
		set second_track_color mask_two 
	} elseif {$first_track_color == "mask_two"} { 
		set second_track_color mask_one 
	} else { 
		echo "Error: first_track_color should be mask_one or mask_two!" 
	}
	
	set tile_height [lindex [get_attribute [get_site_rows] site_height] 0]
	set library_name [expr int([expr $tile_height * 1000])]
	set M1_pitch [get_attribute [get_layers M1] pitch]
	set M1_2X_pitch [expr $M1_pitch * 2]
	set M1_P [expr int([expr $M1_pitch * 1000])]
	
	set boundary_to_core_distance [expr $core_llx - $die_llx]
	set number_of_track [expr int( [expr $boundary_to_core_distance/$M1_2X_pitch])]
	set track_coord [expr $core_llx - [expr $number_of_track * $M1_2X_pitch]]
	
	if {$tile_height == 0.24} {
		echo "Create M1_P${M1_P} track for H${library_name} library"
		set first_track_end_grid_high_offset [expr [expr fmod ( [expr ($core_lly ) / $tile_height], 1.00000)] * $tile_height]
		set first_track_end_grid_low_offset [expr $first_track_end_grid_high_offset + 0.030]
		set second_track_end_grid_high_offset [expr $first_track_end_grid_high_offset - 0.030]
		set second_track_end_grid_low_offset $first_track_end_grid_high_offset
	        set step1 0.13
	        set step2 [expr $tile_height - $step1]
		set first_track_high_steps "$step1 $step2"
		set first_track_low_steps "$step1 $step2"
		set second_track_high_steps "$step2 $step1"
		set second_track_low_steps "$step2 $step1"
	} elseif {$tile_height == 0.30} {
		echo "Create M1_P${M1_P} track for H${library_name} library"
		set core_lly [expr $core_lly + 0.05]
		set first_track_end_grid_high_offset [expr [expr fmod ( [expr ($core_lly ) / $tile_height], 1.00000)] * $tile_height]
		set first_track_end_grid_low_offset [expr $first_track_end_grid_high_offset + 0.030]
		set second_track_end_grid_high_offset [expr $first_track_end_grid_high_offset - 0.030 - 0.010]
		set second_track_end_grid_low_offset [expr $first_track_end_grid_high_offset - 0.010]
	        set step1 0.17
	        set step2 [expr $tile_height - $step1]
		set first_track_high_steps "$step1 $step2"
		set first_track_low_steps "$step1 $step2"
		set second_track_high_steps "$step2 $step1"
		set second_track_low_steps "$step2 $step1"
	} elseif {$tile_height == 0.36} {
		echo "Create M1_P${M1_P} track for H${library_name} library"
		set core_lly [expr $core_lly + 0.03]
		set first_track_end_grid_high_offset [expr [expr fmod ( [expr ($core_lly ) / $tile_height], 1.00000)] * $tile_height]
		set first_track_end_grid_low_offset [expr $first_track_end_grid_high_offset + 0.030]
		set second_track_end_grid_high_offset [expr $first_track_end_grid_high_offset - 0.030 - 0.015]
		set second_track_end_grid_low_offset [expr $first_track_end_grid_high_offset - 0.015]
		set first_track_high_steps "0.11 0.12 0.13"
		set first_track_low_steps "0.11 0.12 0.13"
		set second_track_high_steps "0.12 0.12 0.12"
		set second_track_low_steps "0.12 0.12 0.12"
	} else {
		echo "Error: Library is not H240, H300 or H360!"
	}
	
	while {$first_track_end_grid_high_offset < 0} {set first_track_end_grid_high_offset [expr $first_track_end_grid_high_offset + $tile_height] }
	while {$first_track_end_grid_low_offset < 0} {set first_track_end_grid_low_offset [expr $first_track_end_grid_low_offset + $tile_height] }
	while {$second_track_end_grid_high_offset < 0} {set second_track_end_grid_high_offset [expr $second_track_end_grid_high_offset + $tile_height] }
	while {$second_track_end_grid_low_offset < 0} {set second_track_end_grid_low_offset [expr $second_track_end_grid_low_offset + $tile_height] }
	
	create_track -layer M1 -dir X -mask_pattern $first_track_color -space $M1_2X_pitch -coord [expr $track_coord ] \
	             -end_grid_high_steps $first_track_high_steps -end_grid_low_steps $first_track_low_steps \
	             -end_grid_high_offset $first_track_end_grid_high_offset -end_grid_low_offset $first_track_end_grid_low_offset
	create_track -layer M1 -dir X -mask_pattern $second_track_color -space $M1_2X_pitch -coord [expr $track_coord + $M1_pitch ] \
	             -end_grid_high_steps $second_track_high_steps -end_grid_low_steps $second_track_low_steps \
	             -end_grid_high_offset $second_track_end_grid_high_offset -end_grid_low_offset $second_track_end_grid_low_offset
	# report_track -layer M1

	## M2 track
	
	set track_y [expr $core_lly + $M2_track_offset - (int (($core_lly - $die_lly + $M2_track_offset)/$M2_pitch)*$M2_pitch)]
	
	remove_track -layer M2
	create_track -layer M2  -dir Y -coord $track_y -space $M2_pitch -mask_pattern {mask_two mask_one}
	
	## M3 track
	
	set track_x [expr $core_llx + $M3_track_offset - (int (($core_llx - $die_llx + $M3_track_offset)/$M3_pitch)*$M3_pitch)]
	
	remove_track -layer M3
	create_track -layer M3  -dir X -coord [expr $track_x]  -space $M3_pitch  -mask_pattern {mask_one mask_two}
	
	## M4 track
	set track_y [expr $core_lly + $M4_track_offset - (int (($core_lly - $die_lly + $M4_track_offset)/$M4_pitch)*$M4_pitch)]
	set count [expr 1 + int (($die_ury - $track_y)/$M4_pitch)]
	remove_tracks -layer M4
	create_track -layer M4  -coord $track_y -space $M4_pitch -dir Y -count $count
	
	## M5 track
	set track_x [expr $core_llx + $M5_track_offset - (int (($core_llx - $die_llx + $M5_track_offset)/$M5_pitch)*$M5_pitch)]
	set count [expr 1 + int (($die_urx - $track_x)/$M5_pitch)]
	remove_tracks -layer M5
	create_track -layer M5  -coord $track_x -space $M5_pitch -dir X -count $count
	
	## M6 track
	set track_y [expr $core_lly + $M6_track_offset - (int (($core_lly - $die_lly + $M6_track_offset)/$M6_pitch)*$M6_pitch)]
	set count [expr 1 + int (($die_ury - $track_y)/$M6_pitch)]
	remove_tracks -layer M6
	create_track -layer M6  -coord $track_y -space $M6_pitch -dir Y -count $count
	
	## M7 track
	set track_x [expr $core_llx + $M7_track_offset - (int (($core_llx - $die_llx + $M7_track_offset)/$M7_pitch)*$M7_pitch)]
	set count [expr 1 + int (($die_urx - $track_x)/$M7_pitch)]
	remove_tracks -layer M7
	create_track -layer M7  -coord $track_x -space $M7_pitch -dir X -count $count 
	
	## M8 track
	set track_y [expr $core_lly + $M8_track_offset - (int (($core_lly - $die_lly + $M8_track_offset)/$M8_pitch)*$M8_pitch)]
	set count [expr 1 + int (($die_ury - $track_y)/$M8_pitch)]
	remove_tracks -layer M8
	create_track -layer M8  -coord $track_y -space $M8_pitch -dir Y -count $count
	
	## M9 track
	set track_x [expr $core_llx + $M9_track_offset - (int (($core_llx - $die_llx + $M9_track_offset)/$M9_pitch)*$M9_pitch)]
	set count [expr 1 + int (($die_urx - $track_x)/$M9_pitch)]
	remove_tracks -layer M9
	create_track -layer M9  -coord $track_x -space $M9_pitch -dir X -count $count 
	
	## M10 track
	set track_y [expr $core_lly + $M10_track_offset - (int (($core_lly - $die_lly + $M10_track_offset)/$M10_pitch)*$M10_pitch)]
	set count [expr 1 + int (($die_ury - $track_y)/$M10_pitch)]
	remove_tracks -layer M10
	create_track -layer M10  -coord $track_y -space $M10_pitch -dir Y -count $count
	
	## M11 track
	set track_x [expr $core_llx + $M11_track_offset - (int (($core_llx - $die_llx + $M11_track_offset)/$M11_pitch)*$M11_pitch)]
	set count [expr 1 + int (($die_urx - $track_x)/$M11_pitch)]
	remove_tracks -layer M11
	create_track -layer M11  -coord $track_x -space $M11_pitch -dir X -count $count 
	
	## M12 track
	set track_y [expr $core_lly + $M12_track_offset - (int (($core_lly - $die_lly + $M12_track_offset)/$M12_pitch)*$M12_pitch)]
	set count [expr 1 + int (($die_ury - $track_y)/$M12_pitch)]
	remove_tracks -layer M12
	create_track -layer M12 -coord $track_y -space $M12_pitch -dir Y -count $count
	
	## M13 track
	set track_x [expr $core_llx + $M13_track_offset - (int (($core_llx - $die_llx + $M13_track_offset)/$M13_pitch)*$M13_pitch)]
	set count [expr 1 + int (($die_urx - $track_x)/$M13_pitch)]
	remove_tracks -layer M13
	create_track -layer M13 -coord $track_x -space $M13_pitch -dir X -count $count 
}

proc adjust_pblkgs {site_name verbose} {
	### DOC: to to make all boundary cell successfully inserted (min boundary cell width is 2X)
	### DOC: adjust height and width for all placement blockages
	set site_height [get_attribute [get_site_defs $site_name] height]
	set site_width  [get_attribute [get_site_defs $site_name] width]

	set core_bbox_llx [lindex [lindex [get_attribute [get_core_area] bbox] 0] 0]
	set core_bbox_lly [lindex [lindex [get_attribute [get_core_area] bbox] 0] 1]

	set all_pblkg_col [get_placement_blockages -filter "blockage_type == hard"]
	
	foreach_in_collection pblkg $all_pblkg_col {
		set pblkg_name [get_object_name $pblkg]
		set pblkg_boundary [get_attribute $pblkg boundary]
		set adjusted_pblkg_boundary ""
		set num_pblkg_boundary_points [llength $pblkg_boundary]
		for {set i 0} {$i<$num_pblkg_boundary_points} {incr i} {
			set point_x ""
			set point_y ""
			set adjusted_point_x ""
			set adjusted_point_y ""

			set point_x [lindex [lindex $pblkg_boundary $i] 0]
			set point_y [lindex [lindex $pblkg_boundary $i] 1]

			# use round here to avoid strange tcl behavior
			set adjusted_point_x [format "%.4f" [expr round(($point_x-$core_bbox_llx)/(2*$site_width))*(2*$site_width) + $core_bbox_llx]]
			set adjusted_point_y [format "%.4f" [expr round(($point_y-$core_bbox_lly)/(2*$site_height))*(2*$site_height) + $core_bbox_lly]]

			if {$point_x != $adjusted_point_x || $point_y != $adjusted_point_y} {
				puts "INFO: Hard Placement Blockage Adjustment (Points Adjuted): $pblkg_name ($point_x,$point_y) ---> ($adjusted_point_x,$adjusted_point_y)"
				set adjusted_point "$adjusted_point_x $adjusted_point_y"
			} elseif {$verbose  == 1} {
				puts "INFO: Hard Placement Blockage Adjustment (Points Unchanged): $pblkg_name ($point_x,$point_y) ---> ($adjusted_point_x,$adjusted_point_y)"
				set adjusted_point "$point_x $point_y"	
			} else {
				# for unchanged pblkg points we don't print them by default (in non verbose mode)
				set adjusted_point "$point_x $point_y"
			}

			lappend adjusted_pblkg_boundary $adjusted_point
		}

		if {$pblkg_boundary ne $adjusted_pblkg_boundary} {
			puts "INFO: Hard Placement Blockage Adjustment (Boundary Adjusted):\n\t$pblkg_name \n\t\t$pblkg_boundary --->\n\t\t\t$adjusted_pblkg_boundary"
			set_attribute $pblkg boundary "$adjusted_pblkg_boundary"
		} elseif {$verbose == 1} {
			puts "INFO: Hard Placement Blockage Adjustment (Boundary Unchanged):\n\t$pblkg_name \n\t\t$pblkg_boundary --->\n\t\t\t$adjusted_pblkg_boundary"
		} else {
			# for unchanged pblkg we don't print them by default (in non verbose mode)
		}
	}
}


proc remove_boundary_cells {} {
	set_placement_status placed boundary*
	remove_cells [get_cells boundary*]
}

proc remove_tap_cells {} {
	set_placement_status placed  tapfiller*
	remove_cells [get_cells -filter "ref_name =~TAPCELLB*"]
}


proc gen_240_boundary_cells {} {
	### DOC:  using H8 cells since only have *CW* boundary cells for clean DRC result
	### DOC:  -mirror_left_outside_corner_cell && -mirror_left_inside_corner_cell needed for clean DRC

	## area based design rule checking
	# define shrink factor
	set_app_options -name chipfinishing.metal_cut_allowed_horizontal_shrink_factor -value 0
	set_app_options -name chipfinishing.metal_cut_allowed_vertical_shrink_factor -value 0.5
	# enable auto route guide generation option
	# insert boundary cell

	## add boundary
	set LIBH8S tcbn07_bwph240l8p57pd_base_ulvt_ccs
        set_boundary_cell_rules \
                -top_boundary_cells  "$LIBH8S/BOUNDARYNROW8BWP240H8P57PDULVT $LIBH8S/BOUNDARYNROW4BWP240H8P57PDULVT $LIBH8S/BOUNDARYNROW2BWP240H8P57PDULVT" \
                -bottom_boundary_cells            "$LIBH8S/BOUNDARYPROW8BWP240H8P57PDULVT $LIBH8S/BOUNDARYPROW4BWP240H8P57PDULVT $LIBH8S/BOUNDARYPROW2BWP240H8P57PDULVT" \
                -left_boundary_cell               "$LIBH8S/BOUNDARYLEFTCWBWP240H8P57PDULVT" \
                -right_boundary_cell              "$LIBH8S/BOUNDARYRIGHTCWBWP240H8P57PDULVT" \
                -top_right_outside_corner_cell    "$LIBH8S/BOUNDARYNCORNERBWP240H8P57PDULVT" \
                -bottom_right_outside_corner_cell "$LIBH8S/BOUNDARYPCORNERCWBWP240H8P57PDULVT" \
                -top_left_outside_corner_cell     "$LIBH8S/BOUNDARYNCORNERBWP240H8P57PDULVT" \
                -bottom_left_outside_corner_cell  "$LIBH8S/BOUNDARYPCORNERCWBWP240H8P57PDULVT" \
                -top_right_inside_corner_cells    "$LIBH8S/BOUNDARYNINCORNERCWBWP240H8P57PDULVT" \
                -bottom_right_inside_corner_cells "$LIBH8S/BOUNDARYPINCORNERBWP240H8P57PDULVT" \
                -top_left_inside_corner_cells     "$LIBH8S/BOUNDARYNINCORNERCWBWP240H8P57PDULVT" \
                -bottom_left_inside_corner_cells  "$LIBH8S/BOUNDARYPINCORNERBWP240H8P57PDULVT" \
                -top_left_inside_horizontal_abutment_cells "$LIBH8S/BOUNDARYNROW4BWP240H8P57PDULVT" \
                -top_right_inside_horizontal_abutment_cells "$LIBH8S/BOUNDARYNROW4BWP240H8P57PDULVT" \
                -bottom_left_inside_horizontal_abutment_cells "$LIBH8S/BOUNDARYPROW4BWP240H8P57PDULVT" \
                -bottom_right_inside_horizontal_abutment_cells "$LIBH8S/BOUNDARYPROW4BWP240H8P57PDULVT" \
                -mirror_left_outside_corner_cell \
		-mirror_left_inside_corner_cell \
                -segment_parity {horizontal_even} \
                -min_vertical_jog 0.72 \
                -min_horizontal_jog 0.9 \
                -min_vertical_separation 1.14 \
                -min_horizontal_separation 8.0 \
                -add_metal_cut_allowed \
                -no_1x

	compile_boundary_cells
	set_placement_status locked boundarycell*

	puts "INFO: Checking boundary cell segment_parity ..."
        set_app_options -list {plan.flow.segment_rule "horizontal_even vertical_even"}
	check_boundary_cells -precheck_segment_parity

	puts "INFO: Checking boundary cell legality ..."
	check_boundary_cells
}

proc gen_300_boundary_cells {} {
	### DOC:  using H8 cells since only have *CW* boundary cells for clean DRC result
	### DOC:  -mirror_left_outside_corner_cell && -mirror_left_inside_corner_cell needed for clean DRC

	## area based design rule checking
	# define shrink factor
	set_app_options -name chipfinishing.metal_cut_allowed_horizontal_shrink_factor -value 0
	set_app_options -name chipfinishing.metal_cut_allowed_vertical_shrink_factor -value 0.5
	# enable auto route guide generation option
	# insert boundary cell

	## add boundary
	set LIBH8S tcbn07_bwph300l11p64pd_base_svt_ccs
        set_boundary_cell_rules \
                -top_boundary_cells  "$LIBH8S/BOUNDARYNROW8BWP300H11P64PDSVT $LIBH8S/BOUNDARYNROW4BWP300H11P64PDSVT $LIBH8S/BOUNDARYNROW2BWP300H11P64PDSVT" \
                -bottom_boundary_cells            "$LIBH8S/BOUNDARYPROW8BWP300H11P64PDSVT $LIBH8S/BOUNDARYPROW4BWP300H11P64PDSVT $LIBH8S/BOUNDARYPROW2BWP300H11P64PDSVT" \
                -left_boundary_cell               "$LIBH8S/BOUNDARYLEFTCWBWP300H11P64PDSVT" \
                -right_boundary_cell              "$LIBH8S/BOUNDARYRIGHTCWBWP300H11P64PDSVT" \
                -top_right_outside_corner_cell    "$LIBH8S/BOUNDARYNCORNERBWP300H11P64PDSVT" \
                -bottom_right_outside_corner_cell "$LIBH8S/BOUNDARYPCORNERCWBWP300H11P64PDSVT" \
                -top_left_outside_corner_cell     "$LIBH8S/BOUNDARYNCORNERBWP300H11P64PDSVT" \
                -bottom_left_outside_corner_cell  "$LIBH8S/BOUNDARYPCORNERCWBWP300H11P64PDSVT" \
                -top_right_inside_corner_cells    "$LIBH8S/BOUNDARYNINCORNERCWBWP300H11P64PDSVT" \
                -bottom_right_inside_corner_cells "$LIBH8S/BOUNDARYPINCORNERBWP300H11P64PDSVT" \
                -top_left_inside_corner_cells     "$LIBH8S/BOUNDARYNINCORNERCWBWP300H11P64PDSVT" \
                -bottom_left_inside_corner_cells  "$LIBH8S/BOUNDARYPINCORNERBWP300H11P64PDSVT" \
                -top_left_inside_horizontal_abutment_cells "$LIBH8S/BOUNDARYNROW4BWP300H11P64PDSVT" \
                -top_right_inside_horizontal_abutment_cells "$LIBH8S/BOUNDARYNROW4BWP300H11P64PDSVT" \
                -bottom_left_inside_horizontal_abutment_cells "$LIBH8S/BOUNDARYPROW4BWP300H11P64PDSVT" \
                -bottom_right_inside_horizontal_abutment_cells "$LIBH8S/BOUNDARYPROW4BWP300H11P64PDSVT" \
                -mirror_left_outside_corner_cell \
		-mirror_left_inside_corner_cell \
                -segment_parity {horizontal_even} \
                -min_vertical_jog 0.6 \
                -min_horizontal_jog 0.64 \
                -min_vertical_separation 3.00 \
                -min_horizontal_separation 2.048 \
                -add_metal_cut_allowed \
                -no_1x

	compile_boundary_cells
	set_placement_status locked boundarycell*

	puts "INFO: Checking boundary cell segment_parity ..."
        set_app_options -list {plan.flow.segment_rule "horizontal_even vertical_even"}
	check_boundary_cells -precheck_segment_parity

	puts "INFO: Checking boundary cell legality ..."
	check_boundary_cells
}

proc gen_240_tap_cells {} {
	## add_tap_cell
	## to add noabut buondary cells, need to give whitespace to  boundary (bound_cell:0.57 + spacing:3 + tap_cell:0.684 + bound_cell:0.57 = 
	set LIBH8S tcbn07_bwph240l8p57pd_base_ulvt_ccs
	create_tap_cells \
			-lib_cell $LIBH8S/TAPCELLBWP240H8P57PDULVT \
			-pattern stagger \
			-distance 60 \
			-offset 15 \
                        -prefix WELLTAP \
			-no_abutment \
                        -no_abutment_horizontal_spacing 1 \
                        -no_abutment_corner_spacing 3 \
			-skip_fixed_cells

	set_placement_status locked tapfiller*
}

proc gen_300_tap_cells {} {
	## add_tap_cell
	## to add noabut buondary cells, need to give whitespace to  boundary (bound_cell:0.57 + spacing:3 + tap_cell:0.684 + bound_cell:0.57 = 
	set LIBH8S tcbn07_bwph300l11p64pd_base_svt_ccs
	create_tap_cells \
			-lib_cell $LIBH8S/TAPCELLBWP300H11P64PDSVT \
			-pattern stagger \
			-distance 60 \
			-offset 15 \
                        -prefix WELLTAP \
			-no_abutment \
                        -no_abutment_horizontal_spacing 1 \
                        -no_abutment_corner_spacing 3 \
			-skip_fixed_cells

	set_placement_status locked tapfiller*
}

proc snap_mem {} {

	remove_grids -all
	remove_placement_blockages -all
	
	set site_def_name unit
	set site_width [get_attribute [get_site_defs $site_def_name] width]
	set row_height [get_attribute [get_site_defs $site_def_name] height]
	
	set site_width_2 [expr $site_width*2]
	set row_height_2 [expr $row_height*2]

        set core_llx [lindex [lindex [get_attribute [get_core_area] bbox] 0] 0]
        set core_lly [lindex [lindex [get_attribute [get_core_area] bbox] 0] 1]

	set die_llx 0
	set die_lly 0

	set x_offset [expr $core_llx - $die_llx]
	set y_offset [expr $core_lly - $die_lly]

	puts "core_llx $core_llx die_llx $die_llx x_offset $x_offset"
	puts "core_lly $core_lly die_lly $die_lly y_offset $y_offset"
	

	# define placement grid
	create_grid -type user -x_step 0.057 -y_step 0.030 -x_offset $x_offset -y_offset $y_offset user_mem_snap_grid
	# set snapping targer
	set_snap_setting -class {macro_cell} -snap {user} -user_grid user_mem_snap_grid
	set all_macros [get_cells -physical_context * -filter "is_hard_macro == true"]
	set_attribute $all_macros physical_status placed
	snap_objects [get_cells -physical_context * -filter "is_hard_macro == true"]
	set_attribute $all_macros physical_status locked
}


proc check_macro_width {} {
	### DOC: Currently seems Mem only got even site_width, height is not 2N*row_height
	#
	set site_def_name unit
        set site_width_2 [expr 2*[get_attribute [get_site_defs $site_def_name] width]]
        set row_height [get_attribute [get_site_defs $site_def_name] height]
	set found_flag 0
	

	set all_macros [get_cells -physical_context * -filter "is_hard_macro == true"]
	foreach_in_collection macro $all_macros {
		set macro_width [get_attri $macro width]
		set int_macro_width [expr round ($macro_width / $site_width_2)*$site_width_2]
		set diff_width [expr $macro_width - $int_macro_width]
		if {$diff_width != 0} {
			puts "INFO: Macro [get_object_name $macro] is not even site_width. "
			set found_flag 1
		}
	}
	if {$found_flag == 0} {
		puts "INFO: all macros are in even site_width."
	}
}


proc write_floorplan_def {def_name} {
        write_def -units 2000 -version 5.8 -include_tech_via_definitions -include "blockages cells ports rows_tracks specialnets vias" -objects [get_cells -physical_context * -filter "is_hard_macro == true"] $def_name
}


## ---------------------
## Sec2:  PG Genration Scripts
## ---------------------

proc clean_power {} {
        remove_vias [get_vias -filter "net_type == ground"]
        remove_vias [get_vias -filter "net_type == power"]
        remove_shapes [get_shapes -of [get_nets -hier -physical_context VDD]]
        remove_shapes [get_shapes -of [get_nets -hier -physical_context VSS]]
}


proc clean_power_by_layer {} {
	remove_vias [get_vias -of [get_nets "VDD VSS"] -filter "shape_use ==stripe && lower_layer_name == M1"]
	remove_vias [get_vias -of [get_nets "VDD VSS"] -filter "shape_use ==stripe && lower_layer_name == M2"]
	remove_shapes [get_shapes -of_objects [get_nets "VDD VSS" ] -filter "layer_name ==M2"]
	remove_shapes [get_shapes -of_objects [get_nets "VDD VSS" ] -filter "layer_name ==M3"]

        remove_vias [get_vias -of [get_nets "VDD VSS"] -filter "shape_use ==stripe && lower_layer_name == M3"]
        remove_vias [get_vias -of [get_nets "VDD VSS"] -filter "shape_use ==stripe && lower_layer_name == M4"]
        remove_vias [get_vias -of [get_nets "VDD VSS"] -filter "shape_use ==stripe && lower_layer_name == M5"]
        remove_vias [get_vias -of [get_nets "VDD VSS"] -filter "shape_use ==stripe && lower_layer_name == M6"]
        remove_vias [get_vias -of [get_nets "VDD VSS"] -filter "shape_use ==stripe && lower_layer_name == M7"]
        remove_vias [get_vias -of [get_nets "VDD VSS"] -filter "shape_use ==stripe && lower_layer_name == M8"]
        remove_shapes [get_shapes -of_objects [get_nets "VDD VSS" ] -filter "layer_name ==M4"]
        remove_shapes [get_shapes -of_objects [get_nets "VDD VSS" ] -filter "layer_name ==M5"]
        remove_shapes [get_shapes -of_objects [get_nets "VDD VSS" ] -filter "layer_name ==M6"]
        remove_shapes [get_shapes -of_objects [get_nets "VDD VSS" ] -filter "layer_name ==M7"]
        remove_shapes [get_shapes -of_objects [get_nets "VDD VSS" ] -filter "layer_name ==M8"]
        remove_shapes [get_shapes -of_objects [get_nets "VDD VSS" ] -filter "layer_name ==M9"]

        remove_vias [get_vias -of [get_nets "VDD VSS"] -filter "shape_use ==stripe && lower_layer_name == M9"]
        remove_vias [get_vias -of [get_nets "VDD VSS"] -filter "shape_use ==stripe && lower_layer_name == M10"]
        remove_shapes [get_shapes -of_objects [get_nets "VDD VSS" ] -filter "layer_name ==M10"]
        remove_shapes [get_shapes -of_objects [get_nets "VDD VSS" ] -filter "layer_name ==M11"]
}


proc gen_power {} {
	set_host_options -max_cores 16
	set_app_options -list {plan.pgroute.drc_check_fast_mode true}
	set_app_options -list {plan.pgroute.verbose true}
	
	remove_pg_regions -all
	remove_pg_patterns -all
	remove_pg_strategies -all
	remove_via_defs [get_via_defs]
	remove_pg_via_master_rules -all
	
	set tile_height 0.24
	set core_bbox [get_attribute [get_core_area] bbox]
	set core_llx  [lindex $core_bbox 0 0]
	set core_lly  [lindex $core_bbox 0 1]
	set core_urx  [lindex $core_bbox 1 0]
	set core_ury  [lindex $core_bbox 1 1]
	set orient [get_attribute [get_site_rows -touching "{{$core_llx $core_lly} {$core_urx [expr $core_lly+$tile_height]}}"] site_orientation]
	
	## M0 Rail
	create_pg_std_cell_conn_pattern m0_rail_color -layers {M0} -rail_width {@wtop @wbottom} -parameters {wtop wbottom} -rail_mask {mask_two mask_one}
	set_pg_strategy m0_rail_strategy -pattern {{name: m0_rail_color} {nets: VDD VSS} {parameters: {0.060 0.060}}} -core -blockage {{layers: M0} {placement_blockages:all}}
	compile_pg -strategies {m0_rail_strategy}
	

	## M1 Mesh + VIA0
	set_app_options -list {plan.pgroute.maximize_total_cut_area Vv}

	create_pg_mesh_pattern mesh_m1 \
	      -parameters {w1 s1 f1}  \
	      -layers { \
	      {{vertical_layer: M1} {width: @w1} {spacing: @s1} {pitch: 3.42} {offset: @f1} {trim: false}}} 
	
	set_pg_strategy mesh_m1_vdd1 -pattern {{name: mesh_m1} {nets: VDD} {parameters: {0.037 1.710 0.342}}} -core -blockage {{layers: M1} {placement_blockages:all}}
	set_pg_strategy mesh_m1_vss1 -pattern {{name: mesh_m1} {nets: VSS} {parameters: {0.037 1.710 2.052}}} -core -blockage {{layers: M1} {placement_blockages:all}}
	set_pg_strategy mesh_m1_vdd2 -pattern {{name: mesh_m1} {nets: VDD} {parameters: {0.037 1.710 0.399}}} -core -blockage {{layers: M1} {placement_blockages:all}}
	set_pg_strategy mesh_m1_vss2 -pattern {{name: mesh_m1} {nets: VSS} {parameters: {0.037 1.710 2.109}}} -core -blockage {{layers: M1} {placement_blockages:all}}
	
	set_pg_strategy_via_rule std_rail_vias -via_rule {{via_master: default}}
	
	compile_pg -strategies {mesh_m1_vdd1 mesh_m1_vss1 mesh_m1_vdd2 mesh_m1_vss2} -via_rule std_rail_vias


	## Do some clean up work around memories
        set extra_VIA0 ""
        suppress_message SEL-003
        foreach_in_collection pblkg_hard [get_placement_blockages -filter "blockage_type == hard"] {
                set pblkg_hard_box [get_attri $pblkg_hard bbox]
                set extra_VIA0_inters_box [get_vias -intersect $pblkg_hard_box -filter "lower_layer_name =~ M0 && shape_use == stripe"]
                append_to_collection extra_VIA0 $extra_VIA0_inters_box
        }
        unsuppress_message SEL-003
        remove_vias $extra_VIA0

	remove_shapes [get_shapes -of_objects [get_nets VSS ] -filter "layer_name == M0 && shape_use == stripe && width != 0.06"]
	remove_shapes [get_shapes -of_objects [get_nets VDD ] -filter "layer_name == M0 && shape_use == stripe && width != 0.06"]


	## M2 Stub / M3 Mesh + VIA1 / VIA2
	create_pg_wire_pattern P_wire_base -direction @d -layer @l -width @w -spacing @s -pitch @p -track_alignment @t -parameters {d l w s p t}
	create_pg_wire_pattern P_wire_base_no_track -direction @d -layer @l -width @w -spacing @s -pitch @p -parameters {d l w s p}

	create_pg_wire_pattern P_seg_base -direction @d -layer @l -width @w -spacing @s -pitch @p -track_alignment @t -low_end_reference_point @low -high_end_reference_point @high -parameters {d l w s p t low high}
	create_pg_wire_pattern P_seg_base_no_track -direction @d -layer @l -width @w -spacing @s -pitch @p -low_end_reference_point @low -high_end_reference_point @high -parameters {d l w s p low high}

	set_pg_strategy_via_rule VIA_NIL -via_rule { \
		{{intersection: undefined} {via_master:NIL}} \
	}

	set_app_options -list {plan.pgroute.maximize_total_cut_area "Vs Vh Vv"}
	set_app_options -list {plan.pgroute.ignore_same_color_via_cut_min_spacing_rule true}

	create_pg_composite_pattern P_core_PG2 -nets {VDD VSS} -add_patterns { \
		{{pattern: P_seg_base} {nets: {VDD}} {parameters: horizontal M2 0.02 0.02 {3.42 0.48} track -0.166 0.166} {offset: {0.37 0.46}}} \
		{{pattern: P_seg_base} {nets: {VSS}} {parameters: horizontal M2 0.02 0.02 {3.42 0.48} track -0.166 0.166} {offset: {2.08 0.22}}} \
		{{pattern: P_wire_base} {nets: {VDD VDD}} {parameters: vertical M3 0.040 0.136 3.42 track} {offset: 0.282}} \
		{{pattern: P_wire_base} {nets: {VSS VSS}} {parameters: vertical M3 0.040 0.136 3.42 track} {offset: 1.992}} \
	} -via_rule { \
		{{layers: M1} {layers: M2} {via_master: default}} \
		{{layers: M2} {layers: M3} {via_master: default}} \
		{{intersection: undefined} {via_master: NIL}} \
	}
	
	set_pg_strategy S_CORE_PG2 -pattern {{name: P_core_PG2} {nets: {VDD VSS}} {offset: {0 0}}} -core -blockage {{layers: {M2 M3}} {placement_blockages:all}}
	compile_pg -strategies S_CORE_PG2 -via_rule VIA_NIL
	create_pg_vias -nets {VDD VSS} -from_layer M1 -to_layer M2

	set_app_options -list {plan.pgroute.ignore_same_color_via_cut_min_spacing_rule true}

	## M4, now use 2*M2_H_pitch, 4*M2_V_pitch
	set_pg_via_master_rule VIA89_big_1x2_CUSTOM -contact_code VIA89_big_BW58_UW58 -via_array_dimension {2 1} -cut_spacing 0.122

        create_pg_composite_pattern P_core_PG3 -nets {VDD VSS} -add_patterns { \
                {{pattern: P_seg_base} {nets: {VDD}} {parameters: horizontal M4 0.058 0.114 {6.84 3.84} track -0.20 0.20} {offset: {0.37 0.46}}} \
                {{pattern: P_seg_base} {nets: {VSS}} {parameters: horizontal M4 0.058 0.114 {6.84 3.84} track -0.20 0.20} {offset: {2.08 0.22}}} \
                {{pattern: P_seg_base} {nets: {VDD}} {parameters: vertical   M5 0.058 0.114 {6.84 3.84} track -0.15 0.15} {offset: {0.37 0.46}}} \
                {{pattern: P_seg_base} {nets: {VSS}} {parameters: vertical   M5 0.058 0.114 {6.84 3.84} track -0.15 0.15} {offset: {2.08 0.22}}} \
		{{pattern: P_seg_base} {nets: {VDD}} {parameters: horizontal M6 0.058 0.114 {6.84 3.84} track -0.15 0.15} {offset: {0.37 0.46}}} \
                {{pattern: P_seg_base} {nets: {VSS}} {parameters: horizontal M6 0.058 0.114 {6.84 3.84} track -0.15 0.15} {offset: {2.08 0.22}}} \
                {{pattern: P_seg_base} {nets: {VDD}} {parameters: vertical   M7 0.058 0.114 {6.84 3.84} track -0.15 0.15} {offset: {0.37 0.46}}} \
                {{pattern: P_seg_base} {nets: {VSS}} {parameters: vertical   M7 0.058 0.114 {6.84 3.84} track -0.15 0.15} {offset: {2.08 0.22}}} \
                {{pattern: P_seg_base} {nets: {VDD}} {parameters: horizontal M8 0.058 0.114 {6.84 3.84} track -0.26 0.26} {offset: {0.37 0.46}}} \
                {{pattern: P_seg_base} {nets: {VSS}} {parameters: horizontal M8 0.058 0.114 {6.84 3.84} track -0.26 0.26} {offset: {2.08 0.22}}} \
                {{pattern: P_wire_base} {nets: {VDD}} {parameters: vertical   M9 0.245 0.114 6.84 track } {offset: {0.37 0.46}}} \
                {{pattern: P_wire_base} {nets: {VSS}} {parameters: vertical   M9 0.245 0.114 6.84 track } {offset: {2.08 0.22}}} \
        } -via_rule { \
                {{layers: M3} {layers: M4} {via_master: VIA34_big_BW40_UW58}} \
                {{layers: M4} {layers: M5} {via_master: VIA45_big_BW58_UW58}} \
		{{layers: M5} {layers: M6} {via_master: VIA56_big_BW58_UW58}} \
                {{layers: M6} {layers: M7} {via_master: VIA67_big_BW58_UW58}} \
                {{layers: M7} {layers: M8} {via_master: VIA78_big_BW58_UW58}} \
                {{layers: M8} {layers: M9} {via_master: VIA89_big_1x2_CUSTOM}} \
                {{intersection: undefined} {via_master: NIL}} \
        }

	set_pg_strategy S_CORE_PG3 -pattern {{name: P_core_PG3} {nets: {VDD VSS}} {offset: {0 0}}} -core -blockage {{layers: {M4 M5 M6 M7 M8 M9}} {placement_blockages:all}}
        compile_pg -strategies S_CORE_PG3 -via_rule VIA_NIL
        create_pg_vias -nets {VDD VSS} -from_layer M3 -to_layer M4 -via_masters VIA34_big_BW40_UW58


        ###################   M10~M11 Rail   ###############


        set_app_options -list {plan.pgroute.maximize_total_cut_area "Vs"}

        create_pg_composite_pattern P_core_PG4 -nets {VDD VSS} -add_patterns { \
                {{pattern: P_wire_base} {nets: {VDD}} {parameters: horizontal M10 0.288 0.126 7.56 track} {offset: 0.378}} \
                {{pattern: P_wire_base} {nets: {VSS}} {parameters: horizontal M10 0.288 0.126 7.56 track} {offset: 2.142}} \
                {{pattern: P_wire_base} {nets: {VDD}} {parameters: vertical   M11 0.368 0.126 7.56 track} {offset: 0.378}} \
                {{pattern: P_wire_base} {nets: {VSS}} {parameters: vertical   M11 0.368 0.126 7.56 track} {offset: 2.142}} \
        } -via_rule { \
                {{layers: M9} {layers: M10} {via_master: default}} \
                {{layers: M10} {layers: M11} {via_master: default}} \
                {{intersection: undefined} {via_master: NIL}} \
        }

	set_pg_strategy S_CORE_PG4 -pattern {{name: P_core_PG4} {nets: {VDD VSS}} {offset: {0 0}}} -core -blockage {{layers: {M10 M11}} {placement_blockages:all}}
        compile_pg -strategies S_CORE_PG4 -via_rule VIA_NIL

	set_pg_via_master_rule VIA910_2x2_CUSTOM -contact_code VIA910_1cut_BW76_UW62 -via_array_dimension {2 2} -cut_spacing 0.064 -track_alignment top_track_only 
        create_pg_vias -nets {VDD VSS} -from_layer M9 -to_layer M10 -via_masters VIA910_2x2_CUSTOM


	###################   Auto PG Coloring   ###############
	
	derive_pg_mask_constraint
	set_host_options -max_cores 8
}


proc check_libcel_legality {} {
	## DOC: Use this proc to check cell legalization fail before place_opt
        analyze_lib_cell_placement -lib_cell [add_to_collection -unique "" [get_attribute [get_cells -physical_context ] ref_phys_block]]
}


## ---------------------
## Sec3:  Routing Scripts
## ---------------------

proc clean_detail_route_nets {} {
	remove_routes -detail_route -net_types signal
	remove_routes -detail_route -net_types clock
	remove_shapes  [get_shapes -filter "layer_name == M1:-1 && shape_use == detail_route" ]
}

proc check_clock_nets  {} {
	set M1_TRUNK [get_shapes -filter "net_type == clock && layer_name == M1 && owner.routing_rule == NDR_TRUNK"]
	set M2_TRUNK [get_shapes -filter "net_type == clock && layer_name == M2 && owner.routing_rule == NDR_TRUNK"]
	set M3_TRUNK [get_shapes -filter "net_type == clock && layer_name == M3 && owner.routing_rule == NDR_TRUNK"]
	set M4_TRUNK [get_shapes -filter "net_type == clock && layer_name == M4 && owner.routing_rule == NDR_TRUNK"]
	set M5_TRUNK [get_shapes -filter "net_type == clock && layer_name == M5 && owner.routing_rule == NDR_TRUNK"]
	set M6_TRUNK [get_shapes -filter "net_type == clock && layer_name == M6 && owner.routing_rule == NDR_TRUNK"]
	set M7_TRUNK [get_shapes -filter "net_type == clock && layer_name == M7 && owner.routing_rule == NDR_TRUNK"]
	set M8_TRUNK [get_shapes -filter "net_type == clock && layer_name == M8 && owner.routing_rule == NDR_TRUNK"]
	set M9_TRUNK [get_shapes -filter "net_type == clock && layer_name == M9 && owner.routing_rule == NDR_TRUNK"]
	set M10_TRUNK [get_shapes -filter "net_type == clock && layer_name == M10 && owner.routing_rule == NDR_TRUNK"]
	set M11_TRUNK [get_shapes -filter "net_type == clock && layer_name == M11 && owner.routing_rule == NDR_TRUNK"]

        set M1_LEAF [get_shapes -filter "net_type == clock && layer_name == M1 && owner.routing_rule == NDR_LEAF"]
        set M2_LEAF [get_shapes -filter "net_type == clock && layer_name == M2 && owner.routing_rule == NDR_LEAF"]
        set M3_LEAF [get_shapes -filter "net_type == clock && layer_name == M3 && owner.routing_rule == NDR_LEAF"]
        set M4_LEAF [get_shapes -filter "net_type == clock && layer_name == M4 && owner.routing_rule == NDR_LEAF"]
        set M5_LEAF [get_shapes -filter "net_type == clock && layer_name == M5 && owner.routing_rule == NDR_LEAF"]
        set M6_LEAF [get_shapes -filter "net_type == clock && layer_name == M6 && owner.routing_rule == NDR_LEAF"]
        set M7_LEAF [get_shapes -filter "net_type == clock && layer_name == M7 && owner.routing_rule == NDR_LEAF"]
        set M8_LEAF [get_shapes -filter "net_type == clock && layer_name == M8 && owner.routing_rule == NDR_LEAF"]
        set M9_LEAF [get_shapes -filter "net_type == clock && layer_name == M9 && owner.routing_rule == NDR_LEAF"]
        set M10_LEAF [get_shapes -filter "net_type == clock && layer_name == M10 && owner.routing_rule == NDR_LEAF"]
        set M11_LEAF [get_shapes -filter "net_type == clock && layer_name == M11 && owner.routing_rule == NDR_LEAF"]

	puts "INFO: M1_TRUNK: [sizeof_collection $M1_TRUNK] \tM1_LEAF: [sizeof_collection $M1_LEAF]"
	puts "INFO: M2_TRUNK: [sizeof_collection $M2_TRUNK] \tM2_LEAF: [sizeof_collection $M2_LEAF]"
	puts "INFO: M3_TRUNK: [sizeof_collection $M3_TRUNK] \tM3_LEAF: [sizeof_collection $M3_LEAF]"
	puts "INFO: M4_TRUNK: [sizeof_collection $M4_TRUNK] \tM4_LEAF: [sizeof_collection $M4_LEAF]"
	puts "INFO: M5_TRUNK: [sizeof_collection $M5_TRUNK] \tM5_LEAF: [sizeof_collection $M5_LEAF]"
	puts "INFO: M6_TRUNK: [sizeof_collection $M6_TRUNK] \tM6_LEAF: [sizeof_collection $M6_LEAF]"
	puts "INFO: M7_TRUNK: [sizeof_collection $M7_TRUNK] \tM7_LEAF: [sizeof_collection $M7_LEAF]"
	puts "INFO: M8_TRUNK: [sizeof_collection $M8_TRUNK] \tM8_LEAF: [sizeof_collection $M8_LEAF]"
	puts "INFO: M9_TRUNK: [sizeof_collection $M9_TRUNK] \tM9_LEAF: [sizeof_collection $M9_LEAF]"
	puts "INFO: M10_TRUNK: [sizeof_collection $M10_TRUNK] \tM10_LEAF: [sizeof_collection $M10_LEAF]"
	puts "INFO: M11_TRUNK: [sizeof_collection $M11_TRUNK] \tM11_LEAF: [sizeof_collection $M11_LEAF]"


}

proc enable_RVI {} {
	## DOC:  Below are foundry provied RVI mappings

	# Reserve space for DFM via swapping
	set_app_options -name route.common.concurrent_redundant_via_mode -value reserve_space
	set_app_options -name route.common.eco_route_concurrent_redundant_via_mode -value reserve_space
	
	# Define DFM via mapping list
	add_via_mapping -from {VIA34_1cut_BW24_UW38_ISO 1x1} -to {VIA34_VIAya_DFM_P1_C 1x1} -weight 10
	add_via_mapping -from {VIA34_1cut_BW24_UW38_ISO 1x1} -to {VIA34_VIAya_DFM_P2_C 1x1} -weight 9
	add_via_mapping -from {VIA34_1cut_BW24_UW38_ISO 1x1} -to {VIA34_VIAya_DFM_P3_C 1x1} -weight 8
	add_via_mapping -from {VIA34_1cut_BW24_UW38_ISO 1x1} -to {VIA34_VIAya_DFM_P4_C 1x1} -weight 7
	add_via_mapping -from {VIA34_1cut_BW24_UW38_ISO 1x1} -to {VIA34_VIAya_DFM_P5_C 1x1} -weight 6
	add_via_mapping -from {VIA34_1cut_BW24_UW38_ISO 1x1} -to {VIA34_VIAya_DFM_P6_C 1x1} -weight 5
	add_via_mapping -from {VIA45_1cut_BW38_UW38_ISO 1x1} -to {VIA45_VIAy_DFM_P1_C 1x1} -weight 10
	add_via_mapping -from {VIA45_1cut_BW38_UW38_ISO 1x1} -to {VIA45_VIAy_DFM_P2_C 1x1} -weight 9
	add_via_mapping -from {VIA45_1cut_BW38_UW38_ISO 1x1} -to {VIA45_VIAy_DFM_P3_C 1x1} -weight 8
	add_via_mapping -from {VIA45_1cut_BW38_UW38_ISO 1x1} -to {VIA45_VIAy_DFM_P5_C 1x1} -weight 7
	add_via_mapping -from {VIA45_1cut_BW38_UW38_ISO 1x1} -to {VIA45_VIAy_DFM_P7_C 1x1} -weight 6
	add_via_mapping -from {VIA56_1cut_BW38_UW38_ISO 1x1} -to {VIA56_VIAy_DFM_P1_C 1x1} -weight 10
	add_via_mapping -from {VIA56_1cut_BW38_UW38_ISO 1x1} -to {VIA56_VIAy_DFM_P2_C 1x1} -weight 9
	add_via_mapping -from {VIA56_1cut_BW38_UW38_ISO 1x1} -to {VIA56_VIAy_DFM_P3_C 1x1} -weight 8
	add_via_mapping -from {VIA56_1cut_BW38_UW38_ISO 1x1} -to {VIA56_VIAy_DFM_P5_C 1x1} -weight 7
	add_via_mapping -from {VIA56_1cut_BW38_UW38_ISO 1x1} -to {VIA56_VIAy_DFM_P7_C 1x1} -weight 6
	add_via_mapping -from {VIA67_1cut_BW38_UW38_ISO 1x1} -to {VIA67_VIAy_DFM_P1_C 1x1} -weight 10
	add_via_mapping -from {VIA67_1cut_BW38_UW38_ISO 1x1} -to {VIA67_VIAy_DFM_P2_C 1x1} -weight 9
	add_via_mapping -from {VIA67_1cut_BW38_UW38_ISO 1x1} -to {VIA67_VIAy_DFM_P3_C 1x1} -weight 8
	add_via_mapping -from {VIA67_1cut_BW38_UW38_ISO 1x1} -to {VIA67_VIAy_DFM_P5_C 1x1} -weight 7
	add_via_mapping -from {VIA67_1cut_BW38_UW38_ISO 1x1} -to {VIA67_VIAy_DFM_P7_C 1x1} -weight 6
	add_via_mapping -from {VIA78_1cut_BW38_UW38_ISO 1x1} -to {VIA78_VIAy_DFM_P1_C 1x1} -weight 10
	add_via_mapping -from {VIA78_1cut_BW38_UW38_ISO 1x1} -to {VIA78_VIAy_DFM_P2_C 1x1} -weight 9
	add_via_mapping -from {VIA78_1cut_BW38_UW38_ISO 1x1} -to {VIA78_VIAy_DFM_P3_C 1x1} -weight 8
	add_via_mapping -from {VIA78_1cut_BW38_UW38_ISO 1x1} -to {VIA78_VIAy_DFM_P5_C 1x1} -weight 7
	add_via_mapping -from {VIA78_1cut_BW38_UW38_ISO 1x1} -to {VIA78_VIAy_DFM_P7_C 1x1} -weight 6
	add_via_mapping -from {VIA89_1cut 1x1} -to {VIA89_VIAyy_DFM_P2_C 1x1} -weight 10
	add_via_mapping -from {VIA89_1cut 1x1} -to {VIA89_VIAyy_DFM_P4_C 1x1} -weight 9
	add_via_mapping -from {VIA89_1cut 1x1} -to {VIA89_VIAyy_DFM_P5_C 1x1} -weight 8
	add_via_mapping -from {VIA89_1cut 1x1} -to {VIA89_VIAyy_DFM_P6_C 1x1} -weight 7
	add_via_mapping -from {VIA89_1cut 1x1} -to {VIA89_VIAyy_DFM_P7_C 1x1} -weight 6
	add_via_mapping -from {VIA89_1cut 1x1} -to {VIA89_VIAyy_DFM_P8_C 1x1} -weight 5
	
	# Report DFM via mapping list
	report_via_mapping
}


## ---------------------
## Sec3:  Chip Finishing Scripts
## ---------------------

## DOC:  procs in this section need to be implemented by step in sequence

proc add_fillers {} {
	set FILL { \
		tcbn07_bwph240l11p57pd_base_lvt/FILL64BWP240H11P57PDLVT \
		tcbn07_bwph240l11p57pd_base_svt/FILL64BWP240H11P57PDSVT \
		tcbn07_bwph240l11p57pd_base_ulvt/FILL64BWP240H11P57PDULVT \
		tcbn07_bwph240l8p57pd_base_lvt/FILL64BWP240H8P57PDLVT \
		tcbn07_bwph240l8p57pd_base_svt/FILL64BWP240H8P57PDSVT \
		tcbn07_bwph240l8p57pd_base_ulvt/FILL64BWP240H8P57PDULVT \
		tcbn07_bwph240l11p57pd_base_lvt/FILL32BWP240H11P57PDLVT \
		tcbn07_bwph240l11p57pd_base_svt/FILL32BWP240H11P57PDSVT \
		tcbn07_bwph240l11p57pd_base_ulvt/FILL32BWP240H11P57PDULVT \
		tcbn07_bwph240l8p57pd_base_lvt/FILL32BWP240H8P57PDLVT \
		tcbn07_bwph240l8p57pd_base_svt/FILL32BWP240H8P57PDSVT \
		tcbn07_bwph240l8p57pd_base_ulvt/FILL32BWP240H8P57PDULVT \
		tcbn07_bwph240l11p57pd_base_lvt/FILL16BWP240H11P57PDLVT \
		tcbn07_bwph240l11p57pd_base_svt/FILL16BWP240H11P57PDSVT \
		tcbn07_bwph240l11p57pd_base_ulvt/FILL16BWP240H11P57PDULVT \
		tcbn07_bwph240l8p57pd_base_lvt/FILL16BWP240H8P57PDLVT \
		tcbn07_bwph240l8p57pd_base_svt/FILL16BWP240H8P57PDSVT \
		tcbn07_bwph240l8p57pd_base_ulvt/FILL16BWP240H8P57PDULVT \
		tcbn07_bwph240l11p57pd_base_lvt/FILL12BWP240H11P57PDLVT \
		tcbn07_bwph240l11p57pd_base_svt/FILL12BWP240H11P57PDSVT \
		tcbn07_bwph240l11p57pd_base_ulvt/FILL12BWP240H11P57PDULVT \
		tcbn07_bwph240l8p57pd_base_lvt/FILL12BWP240H8P57PDLVT \
		tcbn07_bwph240l8p57pd_base_svt/FILL12BWP240H8P57PDSVT \
		tcbn07_bwph240l8p57pd_base_ulvt/FILL12BWP240H8P57PDULVT \
		tcbn07_bwph240l11p57pd_base_lvt/FILL8BWP240H11P57PDLVT \
		tcbn07_bwph240l11p57pd_base_svt/FILL8BWP240H11P57PDSVT \
		tcbn07_bwph240l11p57pd_base_ulvt/FILL8BWP240H11P57PDULVT \
		tcbn07_bwph240l8p57pd_base_lvt/FILL8BWP240H8P57PDLVT \
		tcbn07_bwph240l8p57pd_base_svt/FILL8BWP240H8P57PDSVT \
		tcbn07_bwph240l8p57pd_base_ulvt/FILL8BWP240H8P57PDULVT \
		tcbn07_bwph240l11p57pd_base_lvt/FILL4BWP240H11P57PDLVT \
		tcbn07_bwph240l11p57pd_base_svt/FILL4BWP240H11P57PDSVT \
		tcbn07_bwph240l11p57pd_base_ulvt/FILL4BWP240H11P57PDULVT \
		tcbn07_bwph240l8p57pd_base_lvt/FILL4BWP240H8P57PDLVT \
		tcbn07_bwph240l8p57pd_base_svt/FILL4BWP240H8P57PDSVT \
		tcbn07_bwph240l8p57pd_base_ulvt/FILL4BWP240H8P57PDULVT \
		tcbn07_bwph240l11p57pd_base_lvt/FILL3BWP240H11P57PDLVT \
		tcbn07_bwph240l11p57pd_base_svt/FILL3BWP240H11P57PDSVT \
		tcbn07_bwph240l11p57pd_base_ulvt/FILL3BWP240H11P57PDULVT \
		tcbn07_bwph240l8p57pd_base_lvt/FILL3BWP240H8P57PDLVT \
		tcbn07_bwph240l8p57pd_base_svt/FILL3BWP240H8P57PDSVT \
		tcbn07_bwph240l8p57pd_base_ulvt/FILL3BWP240H8P57PDULVT \
		tcbn07_bwph240l11p57pd_base_lvt/FILL2BWP240H11P57PDLVT \
		tcbn07_bwph240l11p57pd_base_svt/FILL2BWP240H11P57PDSVT \
		tcbn07_bwph240l11p57pd_base_ulvt/FILL2BWP240H11P57PDULVT \
		tcbn07_bwph240l8p57pd_base_lvt/FILL2BWP240H8P57PDLVT \
		tcbn07_bwph240l8p57pd_base_svt/FILL2BWP240H8P57PDSVT \
		tcbn07_bwph240l8p57pd_base_ulvt/FILL2BWP240H8P57PDULVT \
		tcbn07_bwph240l11p57pd_base_lvt/FILL1BWP240H11P57PDLVT \
		tcbn07_bwph240l11p57pd_base_lvt/FILL1NOBCMBWP240H11P57PDLVT \
		tcbn07_bwph240l11p57pd_base_svt/FILL1BWP240H11P57PDSVT \
		tcbn07_bwph240l11p57pd_base_svt/FILL1NOBCMBWP240H11P57PDSVT \
		tcbn07_bwph240l11p57pd_base_ulvt/FILL1BWP240H11P57PDULVT \
		tcbn07_bwph240l11p57pd_base_ulvt/FILL1NOBCMBWP240H11P57PDULVT \
		tcbn07_bwph240l8p57pd_base_lvt/FILL1BWP240H8P57PDLVT \
		tcbn07_bwph240l8p57pd_base_lvt/FILL1NOBCMBWP240H8P57PDLVT \
		tcbn07_bwph240l8p57pd_base_svt/FILL1BWP240H8P57PDSVT \
		tcbn07_bwph240l8p57pd_base_svt/FILL1NOBCMBWP240H8P57PDSVT \
		tcbn07_bwph240l8p57pd_base_ulvt/FILL1BWP240H8P57PDULVT \
		tcbn07_bwph240l8p57pd_base_ulvt/FILL1NOBCMBWP240H8P57PDULVT \
	}
	
	set GDCAP {\
		tcbn07_bwph240l8p57pd_base_ulvt/GDCAP5DHXPBWP240H8P57PDULVT \
		tcbn07_bwph240l8p57pd_base_svt/GDCAP5DHXPBWP240H8P57PDSVT \
		tcbn07_bwph240l8p57pd_base_lvt/GDCAP5DHXPBWP240H8P57PDLVT \
		tcbn07_bwph240l11p57pd_base_ulvt/GDCAP5DHXPBWP240H11P57PDULVT \
		tcbn07_bwph240l11p57pd_base_svt/GDCAP5DHXPBWP240H11P57PDSVT \
		tcbn07_bwph240l11p57pd_base_lvt/GDCAP5DHXPBWP240H11P57PDLVT \
		tcbn07_bwph240l8p57pd_base_ulvt/GDCAP4SHXPBWP240H8P57PDULVT \
		tcbn07_bwph240l8p57pd_base_svt/GDCAP4SHXPBWP240H8P57PDSVT \
		tcbn07_bwph240l8p57pd_base_lvt/GDCAP4SHXPBWP240H8P57PDLVT \
		tcbn07_bwph240l11p57pd_base_ulvt/GDCAP4SHXPBWP240H11P57PDULVT \
		tcbn07_bwph240l11p57pd_base_svt/GDCAP4SHXPBWP240H11P57PDSVT \
		tcbn07_bwph240l11p57pd_base_lvt/GDCAP4SHXPBWP240H11P57PDLVT \
		tcbn07_bwph240l8p57pd_base_ulvt/GDCAP4DHXPBWP240H8P57PDULVT \
		tcbn07_bwph240l8p57pd_base_svt/GDCAP4DHXPBWP240H8P57PDSVT \
		tcbn07_bwph240l8p57pd_base_lvt/GDCAP4DHXPBWP240H8P57PDLVT \
		tcbn07_bwph240l11p57pd_base_ulvt/GDCAP4DHXPBWP240H11P57PDULVT \
		tcbn07_bwph240l11p57pd_base_svt/GDCAP4DHXPBWP240H11P57PDSVT \
		tcbn07_bwph240l11p57pd_base_lvt/GDCAP4DHXPBWP240H11P57PDLVT \
		tcbn07_bwph240l8p57pd_base_ulvt/GDCAP3SHXPBWP240H8P57PDULVT \
		tcbn07_bwph240l8p57pd_base_svt/GDCAP3SHXPBWP240H8P57PDSVT \
		tcbn07_bwph240l8p57pd_base_lvt/GDCAP3SHXPBWP240H8P57PDLVT \
		tcbn07_bwph240l11p57pd_base_ulvt/GDCAP3SHXPBWP240H11P57PDULVT \
		tcbn07_bwph240l11p57pd_base_svt/GDCAP3SHXPBWP240H11P57PDSVT \
		tcbn07_bwph240l11p57pd_base_lvt/GDCAP3SHXPBWP240H11P57PDLVT \
		tcbn07_bwph240l8p57pd_base_ulvt/GDCAP3DHXPBWP240H8P57PDULVT \
		tcbn07_bwph240l8p57pd_base_svt/GDCAP3DHXPBWP240H8P57PDSVT \
		tcbn07_bwph240l8p57pd_base_lvt/GDCAP3DHXPBWP240H8P57PDLVT \
		tcbn07_bwph240l11p57pd_base_ulvt/GDCAP3DHXPBWP240H11P57PDULVT \
		tcbn07_bwph240l11p57pd_base_svt/GDCAP3DHXPBWP240H11P57PDSVT \
		tcbn07_bwph240l11p57pd_base_lvt/GDCAP3DHXPBWP240H11P57PDLVT \
		tcbn07_bwph240l8p57pd_base_ulvt/GDCAP2SHXPBWP240H8P57PDULVT \
		tcbn07_bwph240l8p57pd_base_svt/GDCAP2SHXPBWP240H8P57PDSVT \
		tcbn07_bwph240l8p57pd_base_lvt/GDCAP2SHXPBWP240H8P57PDLVT \
		tcbn07_bwph240l11p57pd_base_ulvt/GDCAP2SHXPBWP240H11P57PDULVT \
		tcbn07_bwph240l11p57pd_base_svt/GDCAP2SHXPBWP240H11P57PDSVT \
		tcbn07_bwph240l11p57pd_base_lvt/GDCAP2SHXPBWP240H11P57PDLVT \
		tcbn07_bwph240l8p57pd_base_ulvt/GDCAP2DHXPBWP240H8P57PDULVT \
		tcbn07_bwph240l8p57pd_base_svt/GDCAP2DHXPBWP240H8P57PDSVT \
		tcbn07_bwph240l8p57pd_base_lvt/GDCAP2DHXPBWP240H8P57PDLVT \
		tcbn07_bwph240l11p57pd_base_ulvt/GDCAP2DHXPBWP240H11P57PDULVT \
		tcbn07_bwph240l11p57pd_base_svt/GDCAP2DHXPBWP240H11P57PDSVT \
		tcbn07_bwph240l11p57pd_base_lvt/GDCAP2DHXPBWP240H11P57PDLVT \
	}
	
	set DCAP {\
		tcbn07_bwph240l11p57pd_base_lvt/DCAP64XPBWP240H11P57PDLVT \
		tcbn07_bwph240l11p57pd_base_svt/DCAP64XPBWP240H11P57PDSVT \
		tcbn07_bwph240l11p57pd_base_ulvt/DCAP64XPBWP240H11P57PDULVT \
		tcbn07_bwph240l8p57pd_base_lvt/DCAP64XPBWP240H8P57PDLVT \
		tcbn07_bwph240l8p57pd_base_svt/DCAP64XPBWP240H8P57PDSVT \
		tcbn07_bwph240l8p57pd_base_ulvt/DCAP64XPBWP240H8P57PDULVT \
		tcbn07_bwph240l11p57pd_base_lvt/DCAP64XPXNBWP240H11P57PDLVT \
		tcbn07_bwph240l11p57pd_base_svt/DCAP64XPXNBWP240H11P57PDSVT \
		tcbn07_bwph240l11p57pd_base_ulvt/DCAP64XPXNBWP240H11P57PDULVT \
		tcbn07_bwph240l8p57pd_base_lvt/DCAP64XPXNBWP240H8P57PDLVT \
		tcbn07_bwph240l8p57pd_base_svt/DCAP64XPXNBWP240H8P57PDSVT \
		tcbn07_bwph240l8p57pd_base_ulvt/DCAP64XPXNBWP240H8P57PDULVT \
		tcbn07_bwph240l11p57pd_base_lvt/DCAP32XPBWP240H11P57PDLVT \
		tcbn07_bwph240l11p57pd_base_svt/DCAP32XPBWP240H11P57PDSVT \
		tcbn07_bwph240l11p57pd_base_ulvt/DCAP32XPBWP240H11P57PDULVT \
		tcbn07_bwph240l8p57pd_base_lvt/DCAP32XPBWP240H8P57PDLVT \
		tcbn07_bwph240l8p57pd_base_svt/DCAP32XPBWP240H8P57PDSVT \
		tcbn07_bwph240l8p57pd_base_ulvt/DCAP32XPBWP240H8P57PDULVT \
		tcbn07_bwph240l11p57pd_base_lvt/DCAP32XPXNBWP240H11P57PDLVT \
		tcbn07_bwph240l11p57pd_base_svt/DCAP32XPXNBWP240H11P57PDSVT \
		tcbn07_bwph240l11p57pd_base_ulvt/DCAP32XPXNBWP240H11P57PDULVT \
		tcbn07_bwph240l8p57pd_base_lvt/DCAP32XPXNBWP240H8P57PDLVT \
		tcbn07_bwph240l8p57pd_base_svt/DCAP32XPXNBWP240H8P57PDSVT \
		tcbn07_bwph240l8p57pd_base_ulvt/DCAP32XPXNBWP240H8P57PDULVT \
		tcbn07_bwph240l11p57pd_base_lvt/DCAP16XPBWP240H11P57PDLVT \
		tcbn07_bwph240l11p57pd_base_svt/DCAP16XPBWP240H11P57PDSVT \
		tcbn07_bwph240l11p57pd_base_ulvt/DCAP16XPBWP240H11P57PDULVT \
		tcbn07_bwph240l8p57pd_base_lvt/DCAP16XPBWP240H8P57PDLVT \
		tcbn07_bwph240l8p57pd_base_svt/DCAP16XPBWP240H8P57PDSVT \
		tcbn07_bwph240l8p57pd_base_ulvt/DCAP16XPBWP240H8P57PDULVT \
		tcbn07_bwph240l11p57pd_base_lvt/DCAP16XPXNBWP240H11P57PDLVT \
		tcbn07_bwph240l11p57pd_base_svt/DCAP16XPXNBWP240H11P57PDSVT \
		tcbn07_bwph240l11p57pd_base_ulvt/DCAP16XPXNBWP240H11P57PDULVT \
		tcbn07_bwph240l8p57pd_base_lvt/DCAP16XPXNBWP240H8P57PDLVT \
		tcbn07_bwph240l8p57pd_base_svt/DCAP16XPXNBWP240H8P57PDSVT \
		tcbn07_bwph240l8p57pd_base_ulvt/DCAP16XPXNBWP240H8P57PDULVT \
		tcbn07_bwph240l11p57pd_base_lvt/DCAP8XPBWP240H11P57PDLVT \
		tcbn07_bwph240l11p57pd_base_svt/DCAP8XPBWP240H11P57PDSVT \
		tcbn07_bwph240l11p57pd_base_ulvt/DCAP8XPBWP240H11P57PDULVT \
		tcbn07_bwph240l8p57pd_base_lvt/DCAP8XPBWP240H8P57PDLVT \
		tcbn07_bwph240l8p57pd_base_svt/DCAP8XPBWP240H8P57PDSVT \
		tcbn07_bwph240l8p57pd_base_ulvt/DCAP8XPBWP240H8P57PDULVT \
		tcbn07_bwph240l11p57pd_base_lvt/DCAP8XPXNBWP240H11P57PDLVT \
		tcbn07_bwph240l11p57pd_base_svt/DCAP8XPXNBWP240H11P57PDSVT \
		tcbn07_bwph240l11p57pd_base_ulvt/DCAP8XPXNBWP240H11P57PDULVT \
		tcbn07_bwph240l8p57pd_base_lvt/DCAP8XPXNBWP240H8P57PDLVT \
		tcbn07_bwph240l8p57pd_base_svt/DCAP8XPXNBWP240H8P57PDSVT \
		tcbn07_bwph240l8p57pd_base_ulvt/DCAP8XPXNBWP240H8P57PDULVT \
		tcbn07_bwph240l11p57pd_base_lvt/DCAP4XPBWP240H11P57PDLVT \
		tcbn07_bwph240l11p57pd_base_svt/DCAP4XPBWP240H11P57PDSVT \
		tcbn07_bwph240l11p57pd_base_ulvt/DCAP4XPBWP240H11P57PDULVT \
		tcbn07_bwph240l8p57pd_base_lvt/DCAP4XPBWP240H8P57PDLVT \
		tcbn07_bwph240l8p57pd_base_svt/DCAP4XPBWP240H8P57PDSVT \
		tcbn07_bwph240l8p57pd_base_ulvt/DCAP4XPBWP240H8P57PDULVT \
	}
	########################################################################
	create_stdcell_fillers \
		-lib_cells $GDCAP \
		-prefix fillerstdgdcap
	remove_stdcell_fillers_with_violation
	#########################################################################
	create_stdcell_fillers \
		-lib_cells $DCAP \
		-prefix fillerstddcap 
	connect_pg_net  -automatic
	remove_stdcell_fillers_with_violation
	#########################################################################
	create_stdcell_fillers \
		-lib_cells $FILL \
		-prefix fillerstdfiller
	connect_pg_net  -automatic
	#########################################################################
}


proc swap_tapcell {} {
	set TAP {tcbn07_bwph240l11p57pd_base_svt/TAPCELLBWP240H11P57PDSVT}
	set TAPB {tcbn07_bwph240l11p57pd_base_svt/TAPCELLL1R1BWP240H11P57PDSVT}
	set TAPR {tcbn07_bwph240l11p57pd_base_svt/TAPCELLL2R1BWP240H11P57PDSVT}
	set TAPL {tcbn07_bwph240l11p57pd_base_svt/TAPCELLL1R2BWP240H11P57PDSVT}
	set EXFILL [get_lib_cells {*/FILL2B* */FILL1N* */FILL1B*}]
	
	replace_fillers_by_rules \
	                 -replacement_rule { od_tap_distance } \
	                 -tap_cells  {tcbn07_bwph240l11p57pd_base_svt/TAPCELLBWP240H11P57PDSVT} \
	                 -left_violation_tap {tcbn07_bwph240l11p57pd_base_svt/TAPCELLL1R2BWP240H11P57PDSVT} \
	                 -right_violation_tap {tcbn07_bwph240l11p57pd_base_svt/TAPCELLL2R1BWP240H11P57PDSVT} \
	                 -both_violation_tap {tcbn07_bwph240l11p57pd_base_svt/TAPCELLL1R1BWP240H11P57PDSVT} \
			 -tap_distance_range {0.277 1000} \
			 -adjacent_non_od_cells $EXFILL 
			
	#replace_fillers_by_rules -replacement_rule { od_tap_distance } -tap_cells $TAP -left_violation_tap $TAPL -adjacent_non_od_cells $EXFILL -right_violation_tap $TAPR -both_violation_tap $TAPB -tap_distance_range {5.01 1000}
}	


proc add_cut_metal {} {
	process_metal_extensions_cut_metals -trim_end_off_preferred_grid_extensions true
}

proc remove_cut_metal {} {
	remove_metal_extensions_cut_metals
	echo "remove cut done"
}


## ---------------------
## Sec4:  Data Dump-out Scripts
## ---------------------

proc write_pg_netlist {} {
	## DOC: write pg netlist for LVS
	connect_pg_net -net VDD   [get_pins -hierarchical */VPP]
	connect_pg_net -net VSS   [get_pins -hierarchical */VBB]
	write_verilog -split_bus -include {all} ./lvs_data/xm_cpu_lvs.v
}


proc write_post_trim_gds {} {
	## DOC: Need to trim M1 extensions before write out GDS for signoff DRC check
	write_gds -hierarchy all \
		-layer_map /proj/7nm_evl/WORK/hardyq/tool/pv_env/map/gdsout_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Z_0.9c.map \
		-long_names \
		-units 2000 \
		-write_default_layers {VIA1} \
		-lib_cell_view frame \
		-connect_below_cut_metal \
		./outputs_icc2/xm_cpu.gds
}

proc add_240_GDCAP {}	{

	set GDCAP {\
		*/GDCAP5DHXPBWP240H8P57PDULVT \
		*/GDCAP5DHXPBWP240H11P57PDULVT \
		*/GDCAP4SHXPBWP240H8P57PDULVT \
		*/GDCAP4SHXPBWP240H11P57PDULVT \
		*/GDCAP4DHXPBWP240H8P57PDULVT \
		*/GDCAP4DHXPBWP240H11P57PDULVT \
		*/GDCAP3SHXPBWP240H8P57PDULVT \
		*/GDCAP3SHXPBWP240H11P57PDULVT \
		*/GDCAP3DHXPBWP240H8P57PDULVT \
		*/GDCAP3DHXPBWP240H11P57PDULVT \
		*/GDCAP2SHXPBWP240H8P57PDULVT \
		*/GDCAP2SHXPBWP240H11P57PDULVT \
		*/GDCAP2DHXPBWP240H8P57PDULVT \
		*/GDCAP2DHXPBWP240H11P57PDULVT \
	}
	########################################################################
	create_stdcell_fillers \
		-lib_cells $GDCAP \
		-prefix fillerstdgdcap
	#connect_pg_net  -automatic
	connect_pg_net -net VDD [get_pins -phy */VDD]
    connect_pg_net -net VDD [get_pins -phy */VPP]
    connect_pg_net -net VSS [get_pins -phy */VSS]
    connect_pg_net -net VSS [get_pins -phy */VBB]

    remove_stdcell_fillers_with_violation
	
}

proc add_240_DCAP	{}	{

	set DCAP {\
		*/DCAP64XPBWP240H11P57PDULVT \
		*/DCAP64XPBWP240H8P57PDULVT \
		*/DCAP64XPXNBWP240H11P57PDULVT \
		*/DCAP64XPXNBWP240H8P57PDULVT \
		*/DCAP32XPBWP240H11P57PDULVT \
		*/DCAP32XPBWP240H8P57PDULVT \
		*/DCAP32XPXNBWP240H11P57PDULVT \
		*/DCAP32XPXNBWP240H8P57PDULVT \
		*/DCAP16XPBWP240H11P57PDULVT \
		*/DCAP16XPBWP240H8P57PDULVT \
		*/DCAP16XPXNBWP240H11P57PDULVT \
		*/DCAP16XPXNBWP240H8P57PDULVT \
		*/DCAP8XPBWP240H11P57PDULVT \
		*/DCAP8XPBWP240H8P57PDULVT \
		*/DCAP8XPXNBWP240H11P57PDULVT \
		*/DCAP8XPXNBWP240H8P57PDULVT \
		*/DCAP4XPBWP240H11P57PDULVT \
		*/DCAP4XPBWP240H8P57PDULVT \
	}
	#########################################################################
	create_stdcell_fillers \
		-lib_cells $DCAP \
		-prefix fillerstddcap 
	#connect_pg_net  -automatic
	connect_pg_net -net VDD [get_pins -phy */VDD]
    connect_pg_net -net VDD [get_pins -phy */VPP]
    connect_pg_net -net VSS [get_pins -phy */VSS]
    connect_pg_net -net VSS [get_pins -phy */VBB]
	remove_stdcell_fillers_with_violation
	#########################################################################
}

proc add_240_Fillers {}	{
	set FILL { \
                tcbn07_bwph240l11p57pd_base_lvt_ccs/FILL64BWP240H11P57PDLVT \
                tcbn07_bwph240l11p57pd_base_svt_ccs/FILL64BWP240H11P57PDSVT \
                tcbn07_bwph240l11p57pd_base_ulvt_ccs/FILL64BWP240H11P57PDULVT \
                tcbn07_bwph240l8p57pd_base_lvt_ccs/FILL64BWP240H8P57PDLVT \
                tcbn07_bwph240l8p57pd_base_svt_ccs/FILL64BWP240H8P57PDSVT \
                tcbn07_bwph240l8p57pd_base_ulvt_ccs/FILL64BWP240H8P57PDULVT \
                tcbn07_bwph240l11p57pd_base_lvt_ccs/FILL32BWP240H11P57PDLVT \
                tcbn07_bwph240l11p57pd_base_svt_ccs/FILL32BWP240H11P57PDSVT \
                tcbn07_bwph240l11p57pd_base_ulvt_ccs/FILL32BWP240H11P57PDULVT \
                tcbn07_bwph240l8p57pd_base_lvt_ccs/FILL32BWP240H8P57PDLVT \
                tcbn07_bwph240l8p57pd_base_svt_ccs/FILL32BWP240H8P57PDSVT \
                tcbn07_bwph240l8p57pd_base_ulvt_ccs/FILL32BWP240H8P57PDULVT \
                tcbn07_bwph240l11p57pd_base_lvt_ccs/FILL16BWP240H11P57PDLVT \
                tcbn07_bwph240l11p57pd_base_svt_ccs/FILL16BWP240H11P57PDSVT \
                tcbn07_bwph240l11p57pd_base_ulvt_ccs/FILL16BWP240H11P57PDULVT \
                tcbn07_bwph240l8p57pd_base_lvt_ccs/FILL16BWP240H8P57PDLVT \
                tcbn07_bwph240l8p57pd_base_svt_ccs/FILL16BWP240H8P57PDSVT \
                tcbn07_bwph240l8p57pd_base_ulvt_ccs/FILL16BWP240H8P57PDULVT \
                tcbn07_bwph240l11p57pd_base_lvt_ccs/FILL12BWP240H11P57PDLVT \
                tcbn07_bwph240l11p57pd_base_svt_ccs/FILL12BWP240H11P57PDSVT \
                tcbn07_bwph240l11p57pd_base_ulvt_ccs/FILL12BWP240H11P57PDULVT \
                tcbn07_bwph240l8p57pd_base_lvt_ccs/FILL12BWP240H8P57PDLVT \
                tcbn07_bwph240l8p57pd_base_svt_ccs/FILL12BWP240H8P57PDSVT \
                tcbn07_bwph240l8p57pd_base_ulvt_ccs/FILL12BWP240H8P57PDULVT \
                tcbn07_bwph240l11p57pd_base_lvt_ccs/FILL8BWP240H11P57PDLVT \
                tcbn07_bwph240l11p57pd_base_svt_ccs/FILL8BWP240H11P57PDSVT \
                tcbn07_bwph240l11p57pd_base_ulvt_ccs/FILL8BWP240H11P57PDULVT \
                tcbn07_bwph240l8p57pd_base_lvt_ccs/FILL8BWP240H8P57PDLVT \
                tcbn07_bwph240l8p57pd_base_svt_ccs/FILL8BWP240H8P57PDSVT \
                tcbn07_bwph240l8p57pd_base_ulvt_ccs/FILL8BWP240H8P57PDULVT \
                tcbn07_bwph240l11p57pd_base_lvt_ccs/FILL4BWP240H11P57PDLVT \
                tcbn07_bwph240l11p57pd_base_svt_ccs/FILL4BWP240H11P57PDSVT \
                tcbn07_bwph240l11p57pd_base_ulvt_ccs/FILL4BWP240H11P57PDULVT \
                tcbn07_bwph240l8p57pd_base_lvt_ccs/FILL4BWP240H8P57PDLVT \
                tcbn07_bwph240l8p57pd_base_svt_ccs/FILL4BWP240H8P57PDSVT \
                tcbn07_bwph240l8p57pd_base_ulvt_ccs/FILL4BWP240H8P57PDULVT \
                tcbn07_bwph240l11p57pd_base_lvt_ccs/FILL3BWP240H11P57PDLVT \
                tcbn07_bwph240l11p57pd_base_svt_ccs/FILL3BWP240H11P57PDSVT \
                tcbn07_bwph240l11p57pd_base_ulvt_ccs/FILL3BWP240H11P57PDULVT \
                tcbn07_bwph240l8p57pd_base_lvt_ccs/FILL3BWP240H8P57PDLVT \
                tcbn07_bwph240l8p57pd_base_svt_ccs/FILL3BWP240H8P57PDSVT \
                tcbn07_bwph240l8p57pd_base_ulvt_ccs/FILL3BWP240H8P57PDULVT \
                tcbn07_bwph240l11p57pd_base_lvt_ccs/FILL2BWP240H11P57PDLVT \
                tcbn07_bwph240l11p57pd_base_svt_ccs/FILL2BWP240H11P57PDSVT \
                tcbn07_bwph240l11p57pd_base_ulvt_ccs/FILL2BWP240H11P57PDULVT \
                tcbn07_bwph240l8p57pd_base_lvt_ccs/FILL2BWP240H8P57PDLVT \
                tcbn07_bwph240l8p57pd_base_svt_ccs/FILL2BWP240H8P57PDSVT \
                tcbn07_bwph240l8p57pd_base_ulvt_ccs/FILL2BWP240H8P57PDULVT \
                tcbn07_bwph240l11p57pd_base_lvt_ccs/FILL1BWP240H11P57PDLVT \
                tcbn07_bwph240l11p57pd_base_svt_ccs/FILL1BWP240H11P57PDSVT \
                tcbn07_bwph240l11p57pd_base_ulvt_ccs/FILL1BWP240H11P57PDULVT \
                tcbn07_bwph240l8p57pd_base_lvt_ccs/FILL1BWP240H8P57PDLVT \
                tcbn07_bwph240l8p57pd_base_svt_ccs/FILL1BWP240H8P57PDSVT \
                tcbn07_bwph240l8p57pd_base_ulvt_ccs/FILL1BWP240H8P57PDULVT \

	}
#
#		*/FILL1NOBCMBWP240H11P57PDULVT \
#		*/FILL1NOBCMBWP240H8P57PDULVT \
	#########################################################################
	create_stdcell_fillers \
		-lib_cells $FILL \
		-prefix fillerstdfiller
	connect_pg_net -net VDD [get_pins -phy */VDD]
    connect_pg_net -net VDD [get_pins -phy */VPP]
    connect_pg_net -net VSS [get_pins -phy */VSS]
    connect_pg_net -net VSS [get_pins -phy */VBB]
	#connect_pg_net  -automatic
	#########################################################################
}

proc add_300_GDCAP {}	{

	set GDCAP {\
		tcbn07_bwph300l8p64pd_base_ulvt_ccs/GDCAP5DHXPBWP300H8P64PDULVT \
		tcbn07_bwph300l8p64pd_base_svt_ccs/GDCAP5DHXPBWP300H8P64PDSVT \
		tcbn07_bwph300l8p64pd_base_lvt_ccs/GDCAP5DHXPBWP300H8P64PDLVT \
		tcbn07_bwph300l11p64pd_base_ulvt_ccs/GDCAP5DHXPBWP300H11P64PDULVT \
		tcbn07_bwph300l11p64pd_base_svt_ccs/GDCAP5DHXPBWP300H11P64PDSVT \
		tcbn07_bwph300l11p64pd_base_lvt_ccs/GDCAP5DHXPBWP300H11P64PDLVT \
		tcbn07_bwph300l8p64pd_base_ulvt_ccs/GDCAP4SHXPBWP300H8P64PDULVT \
		tcbn07_bwph300l8p64pd_base_svt_ccs/GDCAP4SHXPBWP300H8P64PDSVT \
		tcbn07_bwph300l8p64pd_base_lvt_ccs/GDCAP4SHXPBWP300H8P64PDLVT \
		tcbn07_bwph300l11p64pd_base_ulvt_ccs/GDCAP4SHXPBWP300H11P64PDULVT \
		tcbn07_bwph300l11p64pd_base_svt_ccs/GDCAP4SHXPBWP300H11P64PDSVT \
		tcbn07_bwph300l11p64pd_base_lvt_ccs/GDCAP4SHXPBWP300H11P64PDLVT \
		tcbn07_bwph300l8p64pd_base_ulvt_ccs/GDCAP4DHXPBWP300H8P64PDULVT \
		tcbn07_bwph300l8p64pd_base_svt_ccs/GDCAP4DHXPBWP300H8P64PDSVT \
		tcbn07_bwph300l8p64pd_base_lvt_ccs/GDCAP4DHXPBWP300H8P64PDLVT \
		tcbn07_bwph300l11p64pd_base_ulvt_ccs/GDCAP4DHXPBWP300H11P64PDULVT \
		tcbn07_bwph300l11p64pd_base_svt_ccs/GDCAP4DHXPBWP300H11P64PDSVT \
		tcbn07_bwph300l11p64pd_base_lvt_ccs/GDCAP4DHXPBWP300H11P64PDLVT \
		tcbn07_bwph300l8p64pd_base_ulvt_ccs/GDCAP3SHXPBWP300H8P64PDULVT \
		tcbn07_bwph300l8p64pd_base_svt_ccs/GDCAP3SHXPBWP300H8P64PDSVT \
		tcbn07_bwph300l8p64pd_base_lvt_ccs/GDCAP3SHXPBWP300H8P64PDLVT \
		tcbn07_bwph300l11p64pd_base_ulvt_ccs/GDCAP3SHXPBWP300H11P64PDULVT \
		tcbn07_bwph300l11p64pd_base_svt_ccs/GDCAP3SHXPBWP300H11P64PDSVT \
		tcbn07_bwph300l11p64pd_base_lvt_ccs/GDCAP3SHXPBWP300H11P64PDLVT \
		tcbn07_bwph300l8p64pd_base_ulvt_ccs/GDCAP3DHXPBWP300H8P64PDULVT \
		tcbn07_bwph300l8p64pd_base_svt_ccs/GDCAP3DHXPBWP300H8P64PDSVT \
		tcbn07_bwph300l8p64pd_base_lvt_ccs/GDCAP3DHXPBWP300H8P64PDLVT \
		tcbn07_bwph300l11p64pd_base_ulvt_ccs/GDCAP3DHXPBWP300H11P64PDULVT \
		tcbn07_bwph300l11p64pd_base_svt_ccs/GDCAP3DHXPBWP300H11P64PDSVT \
		tcbn07_bwph300l11p64pd_base_lvt_ccs/GDCAP3DHXPBWP300H11P64PDLVT \
		tcbn07_bwph300l8p64pd_base_ulvt_ccs/GDCAP2SHXPBWP300H8P64PDULVT \
		tcbn07_bwph300l8p64pd_base_svt_ccs/GDCAP2SHXPBWP300H8P64PDSVT \
		tcbn07_bwph300l8p64pd_base_lvt_ccs/GDCAP2SHXPBWP300H8P64PDLVT \
		tcbn07_bwph300l11p64pd_base_ulvt_ccs/GDCAP2SHXPBWP300H11P64PDULVT \
		tcbn07_bwph300l11p64pd_base_svt_ccs/GDCAP2SHXPBWP300H11P64PDSVT \
		tcbn07_bwph300l11p64pd_base_lvt_ccs/GDCAP2SHXPBWP300H11P64PDLVT \
		tcbn07_bwph300l8p64pd_base_ulvt_ccs/GDCAP2DHXPBWP300H8P64PDULVT \
		tcbn07_bwph300l8p64pd_base_svt_ccs/GDCAP2DHXPBWP300H8P64PDSVT \
		tcbn07_bwph300l8p64pd_base_lvt_ccs/GDCAP2DHXPBWP300H8P64PDLVT \
		tcbn07_bwph300l11p64pd_base_ulvt_ccs/GDCAP2DHXPBWP300H11P64PDULVT \
		tcbn07_bwph300l11p64pd_base_svt_ccs/GDCAP2DHXPBWP300H11P64PDSVT \
		tcbn07_bwph300l11p64pd_base_lvt_ccs/GDCAP2DHXPBWP300H11P64PDLVT \
}
	########################################################################
	create_stdcell_fillers \
		-lib_cells $GDCAP \
		-prefix fillerstdgdcap
	#connect_pg_net  -automatic
	connect_pg_net -net VDD [get_pins -phy */VDD]
    connect_pg_net -net VDD [get_pins -phy */VPP]
    connect_pg_net -net VSS [get_pins -phy */VSS]
    connect_pg_net -net VSS [get_pins -phy */VBB]

    remove_stdcell_fillers_with_violation
	
}

proc add_300_DCAP	{}	{

	set DCAP {\
		tcbn07_bwph300l11p64pd_base_lvt_ccs/DCAP64XPBWP300H11P64PDLVT \
		tcbn07_bwph300l11p64pd_base_svt_ccs/DCAP64XPBWP300H11P64PDSVT \
		tcbn07_bwph300l11p64pd_base_ulvt_ccs/DCAP64XPBWP300H11P64PDULVT \
		tcbn07_bwph300l8p64pd_base_lvt_ccs/DCAP64XPBWP300H8P64PDLVT \
		tcbn07_bwph300l8p64pd_base_svt_ccs/DCAP64XPBWP300H8P64PDSVT \
		tcbn07_bwph300l8p64pd_base_ulvt_ccs/DCAP64XPBWP300H8P64PDULVT \
		tcbn07_bwph300l11p64pd_base_lvt_ccs/DCAP64XPXNBWP300H11P64PDLVT \
		tcbn07_bwph300l11p64pd_base_svt_ccs/DCAP64XPXNBWP300H11P64PDSVT \
		tcbn07_bwph300l11p64pd_base_ulvt_ccs/DCAP64XPXNBWP300H11P64PDULVT \
		tcbn07_bwph300l8p64pd_base_lvt_ccs/DCAP64XPXNBWP300H8P64PDLVT \
		tcbn07_bwph300l8p64pd_base_svt_ccs/DCAP64XPXNBWP300H8P64PDSVT \
		tcbn07_bwph300l8p64pd_base_ulvt_ccs/DCAP64XPXNBWP300H8P64PDULVT \
		tcbn07_bwph300l11p64pd_base_lvt_ccs/DCAP32XPBWP300H11P64PDLVT \
		tcbn07_bwph300l11p64pd_base_svt_ccs/DCAP32XPBWP300H11P64PDSVT \
		tcbn07_bwph300l11p64pd_base_ulvt_ccs/DCAP32XPBWP300H11P64PDULVT \
		tcbn07_bwph300l8p64pd_base_lvt_ccs/DCAP32XPBWP300H8P64PDLVT \
		tcbn07_bwph300l8p64pd_base_svt_ccs/DCAP32XPBWP300H8P64PDSVT \
		tcbn07_bwph300l8p64pd_base_ulvt_ccs/DCAP32XPBWP300H8P64PDULVT \
		tcbn07_bwph300l11p64pd_base_lvt_ccs/DCAP32XPXNBWP300H11P64PDLVT \
		tcbn07_bwph300l11p64pd_base_svt_ccs/DCAP32XPXNBWP300H11P64PDSVT \
		tcbn07_bwph300l11p64pd_base_ulvt_ccs/DCAP32XPXNBWP300H11P64PDULVT \
		tcbn07_bwph300l8p64pd_base_lvt_ccs/DCAP32XPXNBWP300H8P64PDLVT \
		tcbn07_bwph300l8p64pd_base_svt_ccs/DCAP32XPXNBWP300H8P64PDSVT \
		tcbn07_bwph300l8p64pd_base_ulvt_ccs/DCAP32XPXNBWP300H8P64PDULVT \
		tcbn07_bwph300l11p64pd_base_lvt_ccs/DCAP16XPBWP300H11P64PDLVT \
		tcbn07_bwph300l11p64pd_base_svt_ccs/DCAP16XPBWP300H11P64PDSVT \
		tcbn07_bwph300l11p64pd_base_ulvt_ccs/DCAP16XPBWP300H11P64PDULVT \
		tcbn07_bwph300l8p64pd_base_lvt_ccs/DCAP16XPBWP300H8P64PDLVT \
		tcbn07_bwph300l8p64pd_base_svt_ccs/DCAP16XPBWP300H8P64PDSVT \
		tcbn07_bwph300l8p64pd_base_ulvt_ccs/DCAP16XPBWP300H8P64PDULVT \
		tcbn07_bwph300l11p64pd_base_lvt_ccs/DCAP16XPXNBWP300H11P64PDLVT \
		tcbn07_bwph300l11p64pd_base_svt_ccs/DCAP16XPXNBWP300H11P64PDSVT \
		tcbn07_bwph300l11p64pd_base_ulvt_ccs/DCAP16XPXNBWP300H11P64PDULVT \
		tcbn07_bwph300l8p64pd_base_lvt_ccs/DCAP16XPXNBWP300H8P64PDLVT \
		tcbn07_bwph300l8p64pd_base_svt_ccs/DCAP16XPXNBWP300H8P64PDSVT \
		tcbn07_bwph300l8p64pd_base_ulvt_ccs/DCAP16XPXNBWP300H8P64PDULVT \
		tcbn07_bwph300l11p64pd_base_lvt_ccs/DCAP8XPBWP300H11P64PDLVT \
		tcbn07_bwph300l11p64pd_base_svt_ccs/DCAP8XPBWP300H11P64PDSVT \
		tcbn07_bwph300l11p64pd_base_ulvt_ccs/DCAP8XPBWP300H11P64PDULVT \
		tcbn07_bwph300l8p64pd_base_lvt_ccs/DCAP8XPBWP300H8P64PDLVT \
		tcbn07_bwph300l8p64pd_base_svt_ccs/DCAP8XPBWP300H8P64PDSVT \
		tcbn07_bwph300l8p64pd_base_ulvt_ccs/DCAP8XPBWP300H8P64PDULVT \
		tcbn07_bwph300l11p64pd_base_lvt_ccs/DCAP8XPXNBWP300H11P64PDLVT \
		tcbn07_bwph300l11p64pd_base_svt_ccs/DCAP8XPXNBWP300H11P64PDSVT \
		tcbn07_bwph300l11p64pd_base_ulvt_ccs/DCAP8XPXNBWP300H11P64PDULVT \
		tcbn07_bwph300l8p64pd_base_lvt_ccs/DCAP8XPXNBWP300H8P64PDLVT \
		tcbn07_bwph300l8p64pd_base_svt_ccs/DCAP8XPXNBWP300H8P64PDSVT \
		tcbn07_bwph300l8p64pd_base_ulvt_ccs/DCAP8XPXNBWP300H8P64PDULVT \
		tcbn07_bwph300l11p64pd_base_lvt_ccs/DCAP4XPBWP300H11P64PDLVT \
		tcbn07_bwph300l11p64pd_base_svt_ccs/DCAP4XPBWP300H11P64PDSVT \
		tcbn07_bwph300l11p64pd_base_ulvt_ccs/DCAP4XPBWP300H11P64PDULVT \
		tcbn07_bwph300l8p64pd_base_lvt_ccs/DCAP4XPBWP300H8P64PDLVT \
		tcbn07_bwph300l8p64pd_base_svt_ccs/DCAP4XPBWP300H8P64PDSVT \
		tcbn07_bwph300l8p64pd_base_ulvt_ccs/DCAP4XPBWP300H8P64PDULVT \
}
	#########################################################################
	create_stdcell_fillers \
		-lib_cells $DCAP \
		-prefix fillerstddcap 
	#connect_pg_net  -automatic
	connect_pg_net -net VDD [get_pins -phy */VDD]
    connect_pg_net -net VDD [get_pins -phy */VPP]
    connect_pg_net -net VSS [get_pins -phy */VSS]
    connect_pg_net -net VSS [get_pins -phy */VBB]
	remove_stdcell_fillers_with_violation
	#########################################################################
}

proc add_300_Fillers {}	{
	set FILL { \
		tcbn07_bwph300l11p64pd_base_lvt_ccs/FILL64BWP300H11P64PDLVT \
		tcbn07_bwph300l11p64pd_base_svt_ccs/FILL64BWP300H11P64PDSVT \
		tcbn07_bwph300l11p64pd_base_ulvt_ccs/FILL64BWP300H11P64PDULVT \
		tcbn07_bwph300l8p64pd_base_lvt_ccs/FILL64BWP300H8P64PDLVT \
		tcbn07_bwph300l8p64pd_base_ulvt_ccs/FILL64BWP300H8P64PDULVT \
		tcbn07_bwph300l11p64pd_base_lvt_ccs/FILL32BWP300H11P64PDLVT \
		tcbn07_bwph300l11p64pd_base_svt_ccs/FILL32BWP300H11P64PDSVT \
		tcbn07_bwph300l11p64pd_base_ulvt_ccs/FILL32BWP300H11P64PDULVT \
		tcbn07_bwph300l8p64pd_base_lvt_ccs/FILL32BWP300H8P64PDLVT \
		tcbn07_bwph300l8p64pd_base_svt_ccs/FILL32BWP300H8P64PDSVT \
		tcbn07_bwph300l8p64pd_base_ulvt_ccs/FILL32BWP300H8P64PDULVT \
		tcbn07_bwph300l11p64pd_base_lvt_ccs/FILL16BWP300H11P64PDLVT \
		tcbn07_bwph300l11p64pd_base_svt_ccs/FILL16BWP300H11P64PDSVT \
		tcbn07_bwph300l11p64pd_base_ulvt_ccs/FILL16BWP300H11P64PDULVT \
		tcbn07_bwph300l8p64pd_base_lvt_ccs/FILL16BWP300H8P64PDLVT \
		tcbn07_bwph300l8p64pd_base_svt_ccs/FILL16BWP300H8P64PDSVT \
		tcbn07_bwph300l8p64pd_base_ulvt_ccs/FILL16BWP300H8P64PDULVT \
		tcbn07_bwph300l11p64pd_base_lvt_ccs/FILL12BWP300H11P64PDLVT \
		tcbn07_bwph300l11p64pd_base_svt_ccs/FILL12BWP300H11P64PDSVT \
		tcbn07_bwph300l11p64pd_base_ulvt_ccs/FILL12BWP300H11P64PDULVT \
		tcbn07_bwph300l8p64pd_base_lvt_ccs/FILL12BWP300H8P64PDLVT \
		tcbn07_bwph300l8p64pd_base_svt_ccs/FILL12BWP300H8P64PDSVT \
		tcbn07_bwph300l8p64pd_base_ulvt_ccs/FILL12BWP300H8P64PDULVT \
		tcbn07_bwph300l11p64pd_base_lvt_ccs/FILL8BWP300H11P64PDLVT \
		tcbn07_bwph300l11p64pd_base_svt_ccs/FILL8BWP300H11P64PDSVT \
		tcbn07_bwph300l11p64pd_base_ulvt_ccs/FILL8BWP300H11P64PDULVT \
		tcbn07_bwph300l8p64pd_base_lvt_ccs/FILL8BWP300H8P64PDLVT \
		tcbn07_bwph300l8p64pd_base_svt_ccs/FILL8BWP300H8P64PDSVT \
		tcbn07_bwph300l8p64pd_base_ulvt_ccs/FILL8BWP300H8P64PDULVT \
		tcbn07_bwph300l11p64pd_base_lvt_ccs/FILL4BWP300H11P64PDLVT \
		tcbn07_bwph300l11p64pd_base_svt_ccs/FILL4BWP300H11P64PDSVT \
		tcbn07_bwph300l11p64pd_base_ulvt_ccs/FILL4BWP300H11P64PDULVT \
		tcbn07_bwph300l8p64pd_base_lvt_ccs/FILL4BWP300H8P64PDLVT \
		tcbn07_bwph300l8p64pd_base_svt_ccs/FILL4BWP300H8P64PDSVT \
		tcbn07_bwph300l8p64pd_base_ulvt_ccs/FILL4BWP300H8P64PDULVT \
		tcbn07_bwph300l11p64pd_base_lvt_ccs/FILL3BWP300H11P64PDLVT \
		tcbn07_bwph300l11p64pd_base_svt_ccs/FILL3BWP300H11P64PDSVT \
		tcbn07_bwph300l11p64pd_base_ulvt_ccs/FILL3BWP300H11P64PDULVT \
		tcbn07_bwph300l8p64pd_base_lvt_ccs/FILL3BWP300H8P64PDLVT \
		tcbn07_bwph300l8p64pd_base_svt_ccs/FILL3BWP300H8P64PDSVT \
		tcbn07_bwph300l8p64pd_base_ulvt_ccs/FILL3BWP300H8P64PDULVT \
		tcbn07_bwph300l11p64pd_base_lvt_ccs/FILL2BWP300H11P64PDLVT \
		tcbn07_bwph300l11p64pd_base_svt_ccs/FILL2BWP300H11P64PDSVT \
		tcbn07_bwph300l11p64pd_base_ulvt_ccs/FILL2BWP300H11P64PDULVT \
		tcbn07_bwph300l8p64pd_base_lvt_ccs/FILL2BWP300H8P64PDLVT \
		tcbn07_bwph300l8p64pd_base_svt_ccs/FILL2BWP300H8P64PDSVT \
		tcbn07_bwph300l8p64pd_base_ulvt_ccs/FILL2BWP300H8P64PDULVT \
		tcbn07_bwph300l11p64pd_base_lvt_ccs/FILL1BWP300H11P64PDLVT \
		tcbn07_bwph300l11p64pd_base_lvt_ccs/FILL1NOBCMBWP300H11P64PDLVT \
		tcbn07_bwph300l11p64pd_base_svt_ccs/FILL1BWP300H11P64PDSVT \
		tcbn07_bwph300l11p64pd_base_svt_ccs/FILL1NOBCMBWP300H11P64PDSVT \
		tcbn07_bwph300l11p64pd_base_ulvt_ccs/FILL1BWP300H11P64PDULVT \
		tcbn07_bwph300l11p64pd_base_ulvt_ccs/FILL1NOBCMBWP300H11P64PDULVT \
		tcbn07_bwph300l8p64pd_base_lvt_ccs/FILL1BWP300H8P64PDLVT \
		tcbn07_bwph300l8p64pd_base_lvt_ccs/FILL1NOBCMBWP300H8P64PDLVT \
		tcbn07_bwph300l8p64pd_base_svt_ccs/FILL1BWP300H8P64PDSVT \
		tcbn07_bwph300l8p64pd_base_svt_ccs/FILL1NOBCMBWP300H8P64PDSVT \
		tcbn07_bwph300l8p64pd_base_ulvt_ccs/FILL1BWP300H8P64PDULVT \
		tcbn07_bwph300l8p64pd_base_ulvt_ccs/FILL1NOBCMBWP300H8P64PDULVT \
	}
#
#		*/FILL1NOBCMBWP240H11P57PDULVT \
#		*/FILL1NOBCMBWP240H8P57PDULVT \
	#########################################################################
	create_stdcell_fillers \
		-lib_cells $FILL \
		-prefix fillerstdfiller
	connect_pg_net -net VDD [get_pins -phy */VDD]
    connect_pg_net -net VDD [get_pins -phy */VPP]
    connect_pg_net -net VSS [get_pins -phy */VSS]
    connect_pg_net -net VSS [get_pins -phy */VBB]
	#connect_pg_net  -automatic
	#########################################################################
}



proc remove_fillers {} {
	remove_cells [get_cells *fillerstdfiller* -quiet]
	remove_cells [get_cells *fillerstdgdcap* -quiet]
	remove_cells [get_cells *fillerstddcap* -quiet]
}

proc swap_240_tapcell {} {

set TAP  {tcbn07_bwph240l11p57pd_base_ulvt_*/TAPCELLBWP240H11P57PDULVT}
set TAPB {tcbn07_bwph240l11p57pd_base_ulvt_*/TAPCELLL1R1BWP240H11P57PDULVT}
set TAPR {tcbn07_bwph240l11p57pd_base_ulvt_*/TAPCELLL2R1BWP240H11P57PDULVT}
set TAPL {tcbn07_bwph240l11p57pd_base_ulvt_*/TAPCELLL1R2BWP240H11P57PDULVT}
set EXFILL [get_lib_cells {*/FILL2B* */FILL1N* */FILL1B*}]

replace_fillers_by_rules \
       -replacement_rule {od_tap_distance} \
       -tap_distance_range {0.277 1000} \
       -tap_cells $TAP \
       -left_violation_tap $TAPL \
       -right_violation_tap $TAPR \
       -both_violation_tap $TAPB \
       -adjacent_non_od_cells $EXFILL 
}

proc swap_300_tapcell {} {
	set TAP {tcbn07_bwph300l11p64pd_base_svt_ccs/TAPCELLBWP300H11P64PDSVT}
	set TAPB {tcbn07_bwph300l11p64pd_base_svt_ccs/TAPCELLL1R1BWP300H11P64PDSVT}
	set TAPR {tcbn07_bwph300l11p64pd_base_svt_ccs/TAPCELLL2R1BWP300H11P64PDSVT}
	set TAPL {tcbn07_bwph300l11p64pd_base_svt_ccs/TAPCELLL1R2BWP300H11P64PDSVT}
	set EXFILL [get_lib_cells {*/FILL2B* */FILL1N* */FILL1B*}]
	
	replace_fillers_by_rules \
	                 -replacement_rule { od_tap_distance } \
	                 -tap_cells  {tcbn07_bwph300l11p64pd_base_svt_ccs/TAPCELLBWP300H11P64PDSVT} \
	                 -left_violation_tap {tcbn07_bwph300l11p64pd_base_svt_ccs/TAPCELLL1R2BWP300H11P64PDSVT} \
	                 -right_violation_tap {tcbn07_bwph300l11p64pd_base_svt_ccs/TAPCELLL2R1BWP300H11P64PDSVT} \
	                 -both_violation_tap {tcbn07_bwph300l11p64pd_base_svt_ccs/TAPCELLL1R1BWP300H11P64PDSVT} \
			 -tap_distance_range {0.277 1000} \
			 -adjacent_non_od_cells $EXFILL 
			
	#replace_fillers_by_rules -replacement_rule { od_tap_distance } -tap_cells $TAP -left_violation_tap $TAPL -adjacent_non_od_cells $EXFILL -right_violation_tap $TAPR -both_violation_tap $TAPB -tap_distance_range {5.01 1000}
}	

### for 22nm ULP
proc add_22nm_DCAP {} {
echo "need to be complete add_DCAP"
	set DCAP {\
	}
	create_stdcell_fillers \
		-lib_cells $DCAP \
		-prefix fillerstddcap
    connect_pg_net -net VDD [get_pins -phy */VDD]
    connect_pg_net -net VDD [get_pins -phy */VPP]
    connect_pg_net -net VSS [get_pins -phy */VSS]
    connect_pg_net -net VSS [get_pins -phy */VBB]

}
proc add_22nm_GDCAP {} {
echo "need to be complete add_GDCAP"
	set GDCAP {\
}
	create_stdcell_fillers \
		-lib_cells $GDCAP \
		-prefix fillerstdgdcap
    connect_pg_net -net VDD [get_pins -phy */VDD]
    connect_pg_net -net VDD [get_pins -phy */VPP]
    connect_pg_net -net VSS [get_pins -phy */VSS]
    connect_pg_net -net VSS [get_pins -phy */VBB]
}

proc add_22nm_Fillers {} {
echo "need to be complete add_fillers"
	set FILL {\
}
	create_stdcell_fillers \
		-lib_cells $FILL \
		-prefix fillerstdfiller
    connect_pg_net -net VDD [get_pins -phy */VDD]
    connect_pg_net -net VDD [get_pins -phy */VPP]
    connect_pg_net -net VSS [get_pins -phy */VSS]
    connect_pg_net -net VSS [get_pins -phy */VBB]
}

### for 40nm LP
proc add_40nm_9T_DCAP {} {
echo "need to be complete add_DCAP"
set DCAP {\
           */DCAP64BWPHVT \
           */DCAP32BWPHVT \
           */DCAP16BWPHVT \
           */DCAP8BWPHVT \
           */DCAP4BWPHVT \
           }
        create_stdcell_fillers \
                -lib_cells [get_lib_cells $DCAP] \
                -prefix fillerstddcap \
		-rules no_1x

remove_stdcell_fillers_with_violation
#    connect_pg_net -net VDD [get_pins -phy */VDD]
#    connect_pg_net -net VDD [get_pins -phy */VPP]
#    connect_pg_net -net VSS [get_pins -phy */VSS]
#    connect_pg_net -net VSS [get_pins -phy */VBB]
}

proc add_40nm_9T_GDCAP {} {
echo "need to be complete add_GDCAP"
set GDCAP {\
          */GDCAP10BWP \
          */GDCAP4BWP \
          */GDCAP3BWP \
          */GDCAP2BWP \
          */GDCAPBWP \
          }
          create_stdcell_fillers \
                -lib_cells [get_lib_cells $GDCAP] \
                -prefix fillerstddcap \
		-rule no_1x

remove_stdcell_fillers_with_violation
#    connect_pg_net -net VDD [get_pins -phy */VDD]
#    connect_pg_net -net VDD [get_pins -phy */VPP]
#    connect_pg_net -net VSS [get_pins -phy */VSS]
#    connect_pg_net -net VSS [get_pins -phy */VBB]
}

proc add_40nm_9T_Fillers {} {
echo "need to be complete add_fillers"
set FILL {\
          */FILL64BWPHVT \
          */FILL32BWPHVT \
          */FILL16BWPHVT \
          */FILL8BWPHVT \
          */FILL4BWPHVT \
          */FILL3BWPHVT \
          */FILL2BWPHVT \
          */FILL1BWPHVT \
          }
        create_stdcell_fillers \
                -lib_cells [get_lib_cells $FILL] \
                -prefix fillerstdfiller
#    connect_pg_net -net VDD [get_pins -phy */VDD]
#    connect_pg_net -net VDD [get_pins -phy */VPP]
#    connect_pg_net -net VSS [get_pins -phy */VSS]
#    connect_pg_net -net VSS [get_pins -phy */VBB]
}


proc add_40nm_12T_DCAP {} {
echo "need to be complete add_DCAP"
set DCAP {\
           */DCAP64BWP12TM1PHVT \
           */DCAP32BWP12TM1PHVT \
           */DCAP16BWP12TM1PHVT \
           */DCAP8BWP12TM1PHVT \
           */DCAP4BWP12TM1PHVT \
           }
        create_stdcell_fillers \
                -lib_cells [get_lib_cells $DCAP] \
                -prefix fillerstddcap \
		-rules no_1x

remove_stdcell_fillers_with_violation
#    connect_pg_net -net VDD [get_pins -phy */VDD]
#    connect_pg_net -net VDD [get_pins -phy */VPP]
#    connect_pg_net -net VSS [get_pins -phy */VSS]
#    connect_pg_net -net VSS [get_pins -phy */VBB]
}

proc add_40nm_12T_GDCAP {} {
echo "need to be complete add_GDCAP"
set GDCAP {\
          */GDCAP10BWP12TM1P \
          */GDCAP4BWP12TM1P \
          */GDCAP3BWP12TM1P \
          */GDCAP2BWP12TM1P \
          */GDCAPBWP12TM1P \
          }
          create_stdcell_fillers \
                -lib_cells [get_lib_cells $GDCAP] \
                -prefix fillerstddcap \
		-rule no_1x

remove_stdcell_fillers_with_violation
#    connect_pg_net -net VDD [get_pins -phy */VDD]
#    connect_pg_net -net VDD [get_pins -phy */VPP]
#    connect_pg_net -net VSS [get_pins -phy */VSS]
#    connect_pg_net -net VSS [get_pins -phy */VBB]
}

proc add_40nm_12T_Fillers {} {
echo "need to be complete add_fillers"
set FILL {\
          */FILL64BWP12TM1PHVT \
          */FILL32BWP12TM1PHVT \
          */FILL16BWP12TM1PHVT \
          */FILL8BWP12TM1PHVT \
          */FILL4BWP12TM1PHVT \
          */FILL3BWP12TM1PHVT \
          */FILL2BWP12TM1PHVT \
          */FILL1BWP12TM1PHVT \
          }
        create_stdcell_fillers \
                -lib_cells [get_lib_cells $FILL] \
                -prefix fillerstdfiller
#    connect_pg_net -net VDD [get_pins -phy */VDD]
#    connect_pg_net -net VDD [get_pins -phy */VPP]
#    connect_pg_net -net VSS [get_pins -phy */VSS]
#    connect_pg_net -net VSS [get_pins -phy */VBB]
}

proc add_16ffpgl_Fillers {} {
echo "need to be complete add_fillers"
set FILL {\
#          */FILL64BWP12TM1PHVT \
#          */FILL32BWP12TM1PHVT \
#          */FILL16BWP12TM1PHVT \
#          */FILL8BWP12TM1PHVT \
#          */FILL4BWP12TM1PHVT \
#          */FILL3BWP12TM1PHVT \
#          */FILL2BWP12TM1PHVT \
#          */FILL1BWP12TM1PHVT \
#          }
#        create_stdcell_fillers \
#                -lib_cells [get_lib_cells $FILL] \
#                -prefix fillerstdfiller
#    connect_pg_net -net VDD [get_pins -phy */VDD]
#    connect_pg_net -net VDD [get_pins -phy */VPP]
#    connect_pg_net -net VSS [get_pins -phy */VSS]
#    connect_pg_net -net VSS [get_pins -phy */VBB]
}

proc add_16ffpgl_DCAP {} {
echo "need to be complete add_fillers"
#set FILL {\
#          */FILL64BWP12TM1PHVT \
#          */FILL32BWP12TM1PHVT \
#          */FILL16BWP12TM1PHVT \
#          */FILL8BWP12TM1PHVT \
#          */FILL4BWP12TM1PHVT \
#          */FILL3BWP12TM1PHVT \
#          */FILL2BWP12TM1PHVT \
#          */FILL1BWP12TM1PHVT \
#          }
#        create_stdcell_fillers \
#                -lib_cells [get_lib_cells $FILL] \
#                -prefix fillerstdfiller
#    connect_pg_net -net VDD [get_pins -phy */VDD]
#    connect_pg_net -net VDD [get_pins -phy */VPP]
#    connect_pg_net -net VSS [get_pins -phy */VSS]
#    connect_pg_net -net VSS [get_pins -phy */VBB]
}

proc add_16ffpgl_GDCAP {} {
echo "need to be complete add_fillers"
#set FILL {\
#          */FILL64BWP12TM1PHVT \
#          */FILL32BWP12TM1PHVT \
#          */FILL16BWP12TM1PHVT \
#          */FILL8BWP12TM1PHVT \
#          */FILL4BWP12TM1PHVT \
#          */FILL3BWP12TM1PHVT \
#          */FILL2BWP12TM1PHVT \
#          */FILL1BWP12TM1PHVT \
#          }
#        create_stdcell_fillers \
#                -lib_cells [get_lib_cells $FILL] \
#                -prefix fillerstdfiller
#    connect_pg_net -net VDD [get_pins -phy */VDD]
#    connect_pg_net -net VDD [get_pins -phy */VPP]
#    connect_pg_net -net VSS [get_pins -phy */VSS]
#    connect_pg_net -net VSS [get_pins -phy */VBB]
}


