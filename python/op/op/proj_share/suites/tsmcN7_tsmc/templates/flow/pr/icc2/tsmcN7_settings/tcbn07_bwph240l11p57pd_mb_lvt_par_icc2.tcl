###############################################################################
#                   TSMC Standard Cell Placement Constraints
#                          KITS VERSION V0.9_161208
#              Constraints Generated Date: Wed Jan  4 15:45:54 2017
###############################################################################

######################################################################
# TSMC Standard Cell Abutment Placement Constraints for ICC2
######################################################################
# Version 3.4
# Last Modified Date: 2016/08/15
######################################################################

if {![info exist RULE_NW_LEFT]} {set RULE_NW_LEFT ""}
if {$RULE_NW_LEFT != ""} {
    set_placement_spacing_label -name "CELL_NW_LEFT" -side left -lib_cells [get_lib_cells "$RULE_NW_LEFT"]
}

if {![info exist RULE_NW_RIGHT]} {set RULE_NW_RIGHT ""}
if {$RULE_NW_RIGHT != ""} {
    set_placement_spacing_label -name "CELL_NW_RIGHT" -side right -lib_cells [get_lib_cells "$RULE_NW_RIGHT"]
}

if {$RULE_NW_LEFT != "" && $RULE_NW_RIGHT != ""} {
    set_placement_spacing_rule -labels {CELL_NW_LEFT CELL_NW_RIGHT} { 0 2 }
}
if {$RULE_NW_LEFT != ""} {
    set_placement_spacing_rule -labels {CELL_NW_LEFT CELL_NW_LEFT} { 0 2 }
}
if {$RULE_NW_RIGHT != ""} {
    set_placement_spacing_rule -labels {CELL_NW_RIGHT CELL_NW_RIGHT} { 0 2 }
}

if {![info exist RULE_NW2_LEFT]} {set RULE_NW2_LEFT ""}
if {$RULE_NW2_LEFT != ""} {
    set_placement_spacing_label -name "CELL_NW2_LEFT" -side left -lib_cells [get_lib_cells "$RULE_NW2_LEFT"]
}

if {![info exist RULE_NW2_RIGHT]} {set RULE_NW2_RIGHT ""}
if {$RULE_NW2_RIGHT != ""} {
    set_placement_spacing_label -name "CELL_NW2_RIGHT" -side right -lib_cells [get_lib_cells "$RULE_NW2_RIGHT"]
}

if {$RULE_NW2_LEFT != "" && $RULE_NW2_RIGHT != ""} {
    set_placement_spacing_rule -labels {CELL_NW2_LEFT CELL_NW2_RIGHT} { 0 4 }
}
if {$RULE_NW2_LEFT != ""} {
    set_placement_spacing_rule -labels {CELL_NW2_LEFT CELL_NW2_LEFT} { 0 4 }
}
if {$RULE_NW2_RIGHT != ""} {
    set_placement_spacing_rule -labels {CELL_NW2_RIGHT CELL_NW2_RIGHT} { 0 4 }
}

if {![info exist RULE_NW_AREA_LEFT]} {set RULE_NW_AREA_LEFT ""}
if {$RULE_NW_AREA_LEFT != ""} {
    set_placement_spacing_label -name "CELL_NW_AREA_LEFT" -side left -lib_cells [get_lib_cells "$RULE_NW_AREA_LEFT"]
}

if {![info exist RULE_NW_AREA_RIGHT]} {set RULE_NW_AREA_RIGHT ""}
if {$RULE_NW_AREA_RIGHT != ""} {
    set_placement_spacing_label -name "CELL_NW_AREA_RIGHT" -side right -lib_cells [get_lib_cells "$RULE_NW_AREA_RIGHT"]
}

if {$RULE_NW_AREA_LEFT != "" && $RULE_NW_AREA_RIGHT != ""} {
    set_placement_spacing_rule -labels {CELL_NW_AREA_LEFT CELL_NW_AREA_RIGHT} { 0 5 }
}
if {$RULE_NW_AREA_LEFT != ""} {
    set_placement_spacing_rule -labels {CELL_NW_AREA_LEFT CELL_NW_AREA_LEFT} { 0 5 }
}
if {$RULE_NW_AREA_RIGHT != ""} {
    set_placement_spacing_rule -labels {CELL_NW_AREA_RIGHT CELL_NW_AREA_RIGHT} { 0 5 }
}

if {![info exist RULE_NW_AREA2_LEFT]} {set RULE_NW_AREA2_LEFT ""}
if {$RULE_NW_AREA2_LEFT != ""} {
    set_placement_spacing_label -name "CELL_NW_AREA2_LEFT" -side left -lib_cells [get_lib_cells "$RULE_NW_AREA2_LEFT"]
}

if {![info exist RULE_NW_AREA2_RIGHT]} {set RULE_NW_AREA2_RIGHT ""}
if {$RULE_NW_AREA2_RIGHT != ""} {
    set_placement_spacing_label -name "CELL_NW_AREA2_RIGHT" -side right -lib_cells [get_lib_cells "$RULE_NW_AREA2_RIGHT"]
}

if {$RULE_NW_AREA_LEFT != "" && $RULE_NW_AREA2_LEFT != ""} {
    set_placement_spacing_rule -labels {CELL_NW_AREA_LEFT CELL_NW_AREA2_LEFT} { 0 0 }
}
if {$RULE_NW_AREA_LEFT != "" && $RULE_NW_AREA2_RIGHT != ""} {
    set_placement_spacing_rule -labels {CELL_NW_AREA_LEFT CELL_NW_AREA2_RIGHT} { 0 0 }
}
if {$RULE_NW_AREA_RIGHT != "" && $RULE_NW_AREA2_LEFT != ""} {
    set_placement_spacing_rule -labels {CELL_NW_AREA_RIGHT CELL_NW_AREA2_LEFT} { 0 0 }
}
if {$RULE_NW_AREA_RIGHT != "" && $RULE_NW_AREA2_RIGHT != ""} {
    set_placement_spacing_rule -labels {CELL_NW_AREA_RIGHT CELL_NW_AREA2_RIGHT} { 0 0 }
}

if {![info exist RULE_NP_LEFT]} {set RULE_NP_LEFT ""}
if {$RULE_NP_LEFT != ""} {
    set_placement_spacing_label -name "CELL_NP_LEFT" -side left -lib_cells [get_lib_cells "$RULE_NP_LEFT"]
}

if {![info exist RULE_NP_RIGHT]} {set RULE_NP_RIGHT ""}
if {$RULE_NP_RIGHT != ""} {
    set_placement_spacing_label -name "CELL_NP_RIGHT" -side right -lib_cells [get_lib_cells "$RULE_NP_RIGHT"]
}

if {$RULE_NP_LEFT != "" && $RULE_NP_RIGHT != ""} {
    set_placement_spacing_rule -labels {CELL_NP_LEFT CELL_NP_RIGHT} { 0 2 }
}
if {$RULE_NP_LEFT != ""} {
    set_placement_spacing_rule -labels {CELL_NP_LEFT CELL_NP_LEFT} { 0 2 }
}
if {$RULE_NP_RIGHT != ""} {
    set_placement_spacing_rule -labels {CELL_NP_RIGHT CELL_NP_RIGHT} { 0 2 }
}

if {![info exist RULE_NP_TOP]} {set RULE_NP_TOP ""}
if {$RULE_NP_TOP != ""} {
    set_placement_spacing_label -name "CELL_NP_TOP" -side left -lib_cells [get_lib_cells "$RULE_NP_TOP"]
}

if {![info exist RULE_NP_BOTTOM]} {set RULE_NP_BOTTOM ""}
if {$RULE_NP_BOTTOM != ""} {
    set_placement_spacing_label -name "CELL_NP_BOTTOM" -side right -lib_cells [get_lib_cells "$RULE_NP_BOTTOM"]
}

if {$RULE_NP_TOP != "" && $RULE_NP_BOTTOM != ""} {
    set_placement_spacing_rule -labels {CELL_NP_TOP CELL_NP_BOTTOM} { 0 0 } -adjacent_rows
}
if {$RULE_NP_TOP != ""} {
    set_placement_spacing_rule -labels {CELL_NP_TOP CELL_NP_TOP} { 0 0 } -adjacent_rows
}
if {$RULE_NP_BOTTOM != ""} {
    set_placement_spacing_rule -labels {CELL_NP_BOTTOM CELL_NP_BOTTOM} { 0 0 } -adjacent_rows
}

if {![info exist RULE_ODMAX_1D5OD_LEFT]} {set RULE_ODMAX_1D5OD_LEFT ""}
set RULE_ODMAX_1D5OD_LEFT [lsort -unique [concat $RULE_ODMAX_1D5OD_LEFT "\
*/MB2SRLSDFQD1BWP* \
*/MB2SRLSDFQD2BWP* \
*/MB2SRLSDFRPQD2BWP* \
*/MB4SRLSDFQD1BWP* \
*/MB4SRLSDFQD2BWP* \
*/MB4SRLSDFRPQD1BWP* \
*/MB4SRLSDFRPQD2BWP* \
*/MB4SRLSDFSNQD1BWP* \
*/MB6SRLSDFQD1BWP* \
*/MB6SRLSDFQD2BWP* \
*/MB6SRLSDFRPQD1BWP* \
*/MB6SRLSDFRPQD2BWP* \
*/MB6SRLSDFSNQD1BWP* \
*/MB8SRLSDFQD1BWP* \
*/MB8SRLSDFQD2BWP* \
*/MB8SRLSDFRPQD1BWP* \
*/MB8SRLSDFRPQD2BWP* \
*/MB8SRLSDFSNQD1BWP* \
" ] ]
if {$RULE_ODMAX_1D5OD_LEFT != ""} {
    set_placement_spacing_label -name "CELL_ODMAX_1D5OD_LEFT" -side left -lib_cells [get_lib_cells "$RULE_ODMAX_1D5OD_LEFT"]
}

if {![info exist RULE_ODMAX_1D5OD_RIGHT]} {set RULE_ODMAX_1D5OD_RIGHT ""}
set RULE_ODMAX_1D5OD_RIGHT [lsort -unique [concat $RULE_ODMAX_1D5OD_RIGHT "\
*/MB2SRLSDFQD1BWP* \
*/MB2SRLSDFQD2BWP* \
*/MB2SRLSDFRPQD2BWP* \
*/MB4SRLSDFQD1BWP* \
*/MB4SRLSDFQD2BWP* \
*/MB4SRLSDFRPQD1BWP* \
*/MB4SRLSDFRPQD2BWP* \
*/MB4SRLSDFSNQD1BWP* \
*/MB6SRLSDFQD1BWP* \
*/MB6SRLSDFQD2BWP* \
*/MB6SRLSDFRPQD1BWP* \
*/MB6SRLSDFRPQD2BWP* \
*/MB6SRLSDFSNQD1BWP* \
*/MB8SRLSDFQD1BWP* \
*/MB8SRLSDFQD2BWP* \
*/MB8SRLSDFRPQD1BWP* \
*/MB8SRLSDFRPQD2BWP* \
*/MB8SRLSDFSNQD1BWP* \
" ] ]
if {$RULE_ODMAX_1D5OD_RIGHT != ""} {
    set_placement_spacing_label -name "CELL_ODMAX_1D5OD_RIGHT" -side right -lib_cells [get_lib_cells "$RULE_ODMAX_1D5OD_RIGHT"]
}

if {![info exist RULE_ODMAX_2D5OD_LEFT]} {set RULE_ODMAX_2D5OD_LEFT ""}
if {$RULE_ODMAX_2D5OD_LEFT != ""} {
    set_placement_spacing_label -name "CELL_ODMAX_2D5OD_LEFT" -side left -lib_cells [get_lib_cells "$RULE_ODMAX_2D5OD_LEFT"]
}

if {![info exist RULE_ODMAX_2D5OD_RIGHT]} {set RULE_ODMAX_2D5OD_RIGHT ""}
if {$RULE_ODMAX_2D5OD_RIGHT != ""} {
    set_placement_spacing_label -name "CELL_ODMAX_2D5OD_RIGHT" -side right -lib_cells [get_lib_cells "$RULE_ODMAX_2D5OD_RIGHT"]
}

if {$RULE_ODMAX_1D5OD_LEFT != "" && $RULE_ODMAX_2D5OD_LEFT != ""} {
    set_placement_spacing_rule -labels {CELL_ODMAX_1D5OD_LEFT CELL_ODMAX_2D5OD_LEFT} { 2 2 }
}
if {$RULE_ODMAX_1D5OD_LEFT != "" && $RULE_ODMAX_2D5OD_RIGHT != ""} {
    set_placement_spacing_rule -labels {CELL_ODMAX_1D5OD_LEFT CELL_ODMAX_2D5OD_RIGHT} { 2 2 }
}
if {$RULE_ODMAX_1D5OD_RIGHT != "" && $RULE_ODMAX_2D5OD_LEFT != ""} {
    set_placement_spacing_rule -labels {CELL_ODMAX_1D5OD_RIGHT CELL_ODMAX_2D5OD_LEFT} { 2 2 }
}
if {$RULE_ODMAX_1D5OD_RIGHT != "" && $RULE_ODMAX_2D5OD_RIGHT != ""} {
    set_placement_spacing_rule -labels {CELL_ODMAX_1D5OD_RIGHT CELL_ODMAX_2D5OD_RIGHT} { 2 2 }
}

if {$RULE_ODMAX_2D5OD_LEFT != "" && $RULE_ODMAX_2D5OD_RIGHT != ""} {
    set_placement_spacing_rule -labels {CELL_ODMAX_2D5OD_LEFT CELL_ODMAX_2D5OD_RIGHT} { 1 2 }
}
if {$RULE_ODMAX_2D5OD_LEFT != ""} {
    set_placement_spacing_rule -labels {CELL_ODMAX_2D5OD_LEFT CELL_ODMAX_2D5OD_LEFT} { 1 2 }
}
if {$RULE_ODMAX_2D5OD_RIGHT != ""} {
    set_placement_spacing_rule -labels {CELL_ODMAX_2D5OD_RIGHT CELL_ODMAX_2D5OD_RIGHT} { 1 2 }
}

set_app_options -list {place.legalize.vertical_abutment_forbidden_pairs "1-1,1-4,1-5,2-3,2-5,3-4,4-4,4-5,5-5,1-6,4-6,5-6,7-8"}
