proc genM10M11 {net layer offset width pitch direction} {
    set design_bbox [get_attr [current_block] boundary_bbox]
    set design_width [get_attr [current_block] width]
    set design_height [get_attr [current_block] height]
    if {$direction == "H"} {
        set num [expr int(($design_height - $offset)/$pitch) + 1]
    } elseif {$direction == "V"} {
        set num [expr int(($design_width - $offset)/$pitch) + 1]
    }
    set n 1
    while {$n <= $num} {
        if {$direction == "H"} {
            set rect [list [list 0 [expr $offset + ($n -1) * $pitch]] [list $design_width [expr $offset + ($n - 1) *  $pitch + $width]]]
        } elseif {$direction == "V"} {
            set rect [list [list [expr $offset + ($n -1) * $pitch] 0] [list [expr $offset + ($n - 1) * $pitch + $width] $design_height]]
        }
        set rect_geo [create_geo_mask -objects [create_poly_rect -boundary $rect]]
        if {![info exist geo]} {
            set geo $rect_geo
        } else {
            set geo [compute_polygons -operation or -objects1 $geo -objects2 $rect_geo]
        }
        incr n
    }
    set design_geo [create_geo_mask -objects [get_attr [current_block] boundary]]
    #set design_geo [resize_polygons -objects $design_geo -size 12]
    set geo [compute_polygons -operation and -objects1 $design_geo -objects2 $geo]
    copy_to_layer -geo_masks $geo -layer $layer -net $net -shape_use stripe
}
genM10M11 VDD M10 -9.08 10 24 H
genM10M11 VSS M10 -21.08 10 24 H
genM10M11 VDD M11 15.89 10 24 V
genM10M11 VSS M11 3.89 10 24 V
create_pg_vias -nets VDD -from_layers M10 -to_layers M9 -drc no_check -via_masters {default} -within_bbox [get_attribute [current_block] boundary] -from_types stripe -to_types stripe
create_pg_vias -nets VSS -from_layers M10 -to_layers M9 -drc no_check -via_masters {default} -within_bbox [get_attribute [current_block] boundary] -from_types stripe -to_types stripe
create_pg_vias -nets VDD -from_layers M11 -to_layers M10 -drc no_check -via_masters {default} -within_bbox [get_attribute [current_block] boundary] -from_types stripe -to_types stripe
create_pg_vias -nets VSS -from_layers M11 -to_layers M10 -drc no_check -via_masters {default} -within_bbox [get_attribute [current_block] boundary] -from_types stripe -to_types stripe
