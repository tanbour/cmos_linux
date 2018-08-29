#source -e ./rm_setup/icc2_pnr_setup.tcl
#create_lib $DESIGN_LIBRARY -use_technology_lib $TECH_LIB -ref_libs $REFERENCE_LIBRARY
#report_ref_libs
#read_verilog -top $DESIGN_NAME $VERILOG_NETLIST_FILES
#current_block $DESIGN_NAME
#link_block
#save_lib
#start_gui
set_host_options -max_cores 16



### initialize floorplan

# Die
set core_llx [lindex [lindex [get_attribute [get_core_area] bbox] 0] 0]
set core_lly [lindex [lindex [get_attribute [get_core_area] bbox] 0] 1]
set core_urx [lindex [lindex [get_attribute [get_core_area] bbox] 1] 0]
set core_ury [lindex [lindex [get_attribute [get_core_area] bbox] 1] 1]
# Core
set die_llx [lindex [lindex [get_attribute [current_block] boundary_bbox] 0] 0]
set die_lly [lindex [lindex [get_attribute [current_block] boundary_bbox] 0] 1]
set die_urx [lindex [lindex [get_attribute [current_block] boundary_bbox] 1] 0]
set die_ury [lindex [lindex [get_attribute [current_block] boundary_bbox] 1] 1]

set tile_height [lindex [get_attribute [get_site_rows] site_height] 0]
set tile_height2 [expr 2*$tile_height]
	

################################################################################
#Create Tracks fro M0 ~ M9
################################################################################
# 1P13M PROCESS
# Layer:  	M0 	 M1 	  M2 	   M3 	    M4 	     M5       M6       M7       M8 	 M9 	  M10 	   M11 	    M12      M13
# min_width:	0.020000 0.034000 0.020000 0.020000 0.038000 0.038000 0.038000 0.038000 0.038000 0.038000 0.062000 0.062000 0.360000 0.360000
# min_spacing:	0.020000 0.020000 0.020000 0.020000 0.038000 0.038000 0.038000 0.038000 0.038000 0.038000 0.064000 0.064000 0.360000 0.360000
# pitch:	0.040000 0.057000 0.040000 0.044000 0.076000 0.076000 0.076000 0.076000 0.076000 0.076000 0.126000 0.126000 0.720000 0.720000

# 1P9M PROCESS WITH 2X1Ya3Y2Z METAL OPTION
# Layer:  	M0 	 M1 	  M2 	   M3 	    M4 	     M5       M6       M7       M8      M9
# min_width:	0.020000 0.034000 0.020000 0.020000 0.038000 0.038000 0.038000 0.038000 0.360000 0.360000
# min_spacing:	0.020000 0.020000 0.020000 0.020000 0.038000 0.038000 0.038000 0.038000 0.360000 0.360000
# pitch:	0.040000 0.057000 0.040000 0.044000 0.076000 0.076000 0.076000 0.076000 0.720000 0.720000
	
set My_pitch_p76  0.0760
set My_pitch_p126 0.1260 
set My_pitch_p720 0.7200

set M0_pitch 0.0400
set M1_pitch 0.0570
set M2_pitch 0.0400
set M3_pitch 0.0440
set M4_pitch $My_pitch_p76; set M6_pitch $My_pitch_p76; set M8_pitch $My_pitch_p720
set M5_pitch $My_pitch_p76; set M7_pitch $My_pitch_p76; set M9_pitch $My_pitch_p720
#set M10_pitch $My_pitch_p126; set M11_pitch $My_pitch_p126
#set M12_pitch $My_pitch_p720; set M13_pitch $My_pitch_p720
	
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
#set M10_track_offset $M1_track_offset;
#set M11_track_offset $M1_track_offset;
#set M12_track_offset $M1_track_offset;
#set M13_track_offset $M1_track_offset;
	
## M0 track 
#ROW1
remove_track -layer M0
create_track -layer M0 -coord [expr ${core_lly} + 0.000] -space $tile_height2 -mask_pattern mask_two
create_track -layer M0 -coord [expr ${core_lly} + $M0_track_offset + $M0_pitch] -space $tile_height2 -mask_pattern mask_one
create_track -layer M0 -coord [expr ${core_lly} + $M0_track_offset + 2 * $M0_pitch] -space $tile_height2 -mask_pattern mask_two
create_track -layer M0 -coord [expr ${core_lly} + $M0_track_offset + 3 * $M0_pitch] -space $tile_height2 -mask_pattern mask_one
create_track -layer M0 -coord [expr ${core_lly} + $M0_track_offset + 4 * $M0_pitch] -space $tile_height2 -mask_pattern mask_two
#ROW2
create_track -layer M0 -coord [expr ${core_lly} + $tile_height + 0.00] -space $tile_height2 -mask_pattern mask_one
create_track -layer M0 -coord [expr ${core_lly} + $tile_height + $M0_track_offset + $M0_pitch] -space $tile_height2 -mask_pattern mask_two
create_track -layer M0 -coord [expr ${core_lly} + $tile_height + $M0_track_offset + 2 * $M0_pitch] -space $tile_height2 -mask_pattern mask_one
create_track -layer M0 -coord [expr ${core_lly} + $tile_height + $M0_track_offset + 3 * $M0_pitch] -space $tile_height2 -mask_pattern mask_two
create_track -layer M0 -coord [expr ${core_lly} + $tile_height + $M0_track_offset + 4 * $M0_pitch] -space $tile_height2 -mask_pattern mask_one
## M0 track with end_grid
	
#Create M1 track for TSMC H240 library
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

set library_name [expr int([expr $tile_height * 1000])]
set M1_pitch [get_attribute [get_layers M1] pitch]
set M1_2X_pitch [expr $M1_pitch * 2]
set M1_P [expr int([expr $M1_pitch * 1000])]

set boundary_to_core_distance [expr $core_llx - $die_llx]
set number_of_track [expr int( [expr $boundary_to_core_distance/$M1_2X_pitch])]
set track_coord [expr $core_llx - [expr $number_of_track * $M1_2X_pitch]]

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

while {$first_track_end_grid_high_offset  < 0} {set first_track_end_grid_high_offset  [expr $first_track_end_grid_high_offset  + $tile_height] }
while {$first_track_end_grid_low_offset   < 0} {set first_track_end_grid_low_offset   [expr $first_track_end_grid_low_offset   + $tile_height] }
while {$second_track_end_grid_high_offset < 0} {set second_track_end_grid_high_offset [expr $second_track_end_grid_high_offset + $tile_height] }
while {$second_track_end_grid_low_offset  < 0} {set second_track_end_grid_low_offset  [expr $second_track_end_grid_low_offset  + $tile_height] }

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
create_track -layer M4  -coord 0 -space $M4_pitch -dir Y -count $count

## M5 track
set track_x [expr $core_llx + $M5_track_offset - (int (($core_llx - $die_llx + $M5_track_offset)/$M5_pitch)*$M5_pitch)]
set count [expr 1 + int (($die_urx - $track_x)/$M5_pitch)]
remove_tracks -layer M5
create_track -layer M5  -coord 0 -space $M5_pitch -dir X -count $count

## M6 track
set track_y [expr $core_lly + $M6_track_offset - (int (($core_lly - $die_lly + $M6_track_offset)/$M6_pitch)*$M6_pitch)]
set count [expr 1 + int (($die_ury - $track_y)/$M6_pitch)]
remove_tracks -layer M6
create_track -layer M6  -coord 0 -space $M6_pitch -dir Y -count $count

## M7 track
set track_x [expr $core_llx + $M7_track_offset - (int (($core_llx - $die_llx + $M7_track_offset)/$M7_pitch)*$M7_pitch)]
set count [expr 1 + int (($die_urx - $track_x)/$M7_pitch)]
remove_tracks -layer M7
create_track -layer M7  -coord 0 -space $M7_pitch -dir X -count $count 

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
	

