proc addMetalShapesRDL {net layer width start_cx start_cy end_cx end_cy} {
   set yy [expr $end_cy - $start_cy]
   set xx [expr $end_cx - $start_cx]
   if {$xx >= 0 && $yy >= 0} {
      if {$xx == 0 && $yy > 0 || $yy == 0 && $xx > 0 || $xx > 0 && [expr $yy / $xx] == 1} {
         create_shape -layer $layer -net $net -width $width -shape_type path -path "{$start_cx $start_cy} {$end_cx $end_cy}"
      } else {
         puts "please input point again"
      }
   } else {
      puts "please input point again"
   }
}

proc createRoutingBlk {prefix lx ly ux uy} {
   create_routing_blockage -layers RV -name_prefix ${prefix}_RV -boundary "{$lx $ly} {$ux $uy}" -net_types {power ground}
}

proc createRDLfield {net cx cy width height layer} {
   set dt 0
   set dh 0
   if {[expr $width % 2] != 0} {
      set dt 0.5
   } 
   if {[expr $height % 2] != 0} {
      set dh 0.5
   }
   addMetalShapesRDL $net $layer $width [expr $cx - $height / 2 + $width / 2 + $dt - $dh] [expr $cy - $height / 2 - $dh] [expr $cx - $height / 2 + $width / 2 + $dt - $dh] [expr $cy + $height / 2 + $dh]
   addMetalShapesRDL $net $layer $width $cx [expr $cy - $height / 2 - $dh] $cx [expr $cy + $height / 2 + $dh]
   addMetalShapesRDL $net $layer $width [expr $cx + $height / 2 - $width / 2 - $dt + $dh] [expr $cy - $height / 2 - $dh] [expr $cx + $height / 2 - $width / 2 - $dt + $dh] [expr $cy + $height / 2 + $dh]
   addMetalShapesRDL $net $layer $width [expr $cx - $height / 2 - $dh] [expr $cy - $height / 2 + $width / 2 + $dt - $dh] [expr $cx + $height / 2 + $dh] [expr $cy - $height / 2 + $width / 2 + $dt - $dh]
   addMetalShapesRDL $net $layer $width [expr $cx - $height / 2 - $dh] $cy [expr $cx + $height / 2 + $dh] $cy
   addMetalShapesRDL $net $layer $width [expr $cx - $height / 2 - $dh] [expr $cy + $height / 2 - $width / 2 - $dt + $dh] [expr $cx + $height / 2 + $dh] [expr $cy + $height / 2 - $width / 2 - $dt + $dh]
   createRoutingBlk RDL_RV [expr $cx - $height / 2 + $width + 1 - $dh] [expr $cy - $height / 2 + $width / 2 + 1 - $dh] [expr $cx + $height / 2 - $width - 1 + $dh] [expr $cy + $height / 2 - $width - 1 + $dh]
}

proc selectBumpRDL {} {
   
}
proc RDLblock {width length pitch layer} {
   set top_name [get_attribute [get_blocks] design_name]
   set lx [lindex [lindex [get_attribute [get_blocks] bbox] 0] 0]
   set ly [lindex [lindex [get_attribute [get_blocks] bbox] 0] 1]
   set ux [lindex [lindex [get_attribute [get_blocks] bbox] 1] 0]
   set uy [lindex [lindex [get_attribute [get_blocks] bbox] 1] 1]
   set numx [expr int($ux / $pitch) - 1]
   set numy [expr int($uy / $pitch) - 1]
   set checknum [expr $numy + 1]
   set startx [expr ($ux - $numx * $pitch) / 2]
   set starty [expr ($uy - $numy * $pitch) / 2]
   set lx 0
   set ly 0
   puts "$top_name"
   echo "ux uy numx numy startx starty"
   echo $ux $uy $numx $numy $startx $starty
   sh rm -rf ${top_name}.ploc
set sum 0
   if {$checknum % 2 != 0} {
      while { $startx < $ux } {
         while { $starty < $uy } {
            set flag [expr $sum % 2]
            if { $flag == 0 } {
               createRDLfield VDD $startx $starty $width $length $layer
               echo "VDD_$sum $startx $starty $layer POWER" >> ${top_name}.ploc
            } else {
               createRDLfield VSS $startx $starty $width $length $layer
               echo "VSS_$sum $startx $starty $layer GROUND" >> ${top_name}.ploc
            }
            set sum [expr $sum + 1]
            set starty [expr $starty + $pitch]
         }
         set starty [expr ($uy - $numy * $pitch) / 2 + $ly / 2]
         set startx [expr $startx + $pitch]
      }
   } else {
      while { $startx < $ux } {
         while { $starty < $uy } {
            set flag [expr $sum % 2]
            if { $flag == 0 } {
               createRDLfield VDD $startx $starty $width $length $layer
               echo "VDD_$sum $startx $starty $layer POWER" >> ${top_name}.ploc
            } else {
               createRDLfield VSS $startx $starty $width $length $layer
               echo "VSS_$sum $startx $starty $layer GROUND" >> ${top_name}.ploc
            }
            set sum [expr $sum + 1]
            set starty [expr $starty + $pitch]
         }
         set sum [expr $sum + 1]
         set starty [expr ($uy - $numy * $pitch) / 2 + $ly / 2]
         set startx [expr $startx + $pitch]
      }
   }
   createRDLviaRV
}

proc createRDLviaRV {} {
   if {[sizeof_collection [get_vias -filter "tag == RV_FOR_RDL" -quiet]] != 0} {
      cleanRDLlayerAndVia via
   }
   create_pg_vias -from_layers AP -to_layers M11 -nets VDD -allow_parallel_objects -tag RV_FOR_RDL -via_masters {default}
   create_pg_vias -from_layers AP -to_layers M11 -nets VSS -allow_parallel_objects -tag RV_FOR_RDL -via_masters {default}
   if {[sizeof_collection [get_routing_blockages -filter "full_name =~ RDL_RV*" -quiet]] != 0} {
      remove_routing_blockages [get_routing_blockages -filter "full_name =~ RDL_RV*" -quiet]
   }   
}

proc cleanRDLlayerAndVia { flag } {
   if { $flag == "all"} {
      remove_vias [get_vias -filter "tag == RV_FOR_RDL" -quiet]
      remove_shapes [get_shapes -filter "layer_name == AP && net_type == power" -quiet]
      remove_shapes [get_shapes -filter "layer_name == AP && net_type == ground" -quiet]
   } elseif {$flag == "layer"} {
      remove_shapes [get_shapes -filter "layer_name == AP && net_type == power" -quiet]
      remove_shapes [get_shapes -filter "layer_name == AP && net_type == ground" -quiet]
   } elseif {$flag == "via"} {
      remove_vias [get_vias -filter "tag == RV_FOR_RDL" -quiet]
   } else {
      puts "please collect input : flag "
   }
}
