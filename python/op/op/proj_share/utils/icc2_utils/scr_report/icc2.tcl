source ${blk_utils_dir}/icc2_utils/scr_report/timing.tcl
alias la "list_attributes -application -nosplit -class "

#proc SelectPGNets {nets} {
#   set nets_n 1
#   foreach net $nets {
#      if {$nets_n == 1} {set owner_net_type "owner_net == $net"} else {set owner_net_type "$owner_net_type || owner_net == $net"}
#      incr nets_n
#   }
#   set nets_shapes [get_shapes -hierarchical -filter $owner_net_type]
#   set nets_shapes_layers [lsort -u [get_attribute $nets_shapes layer]]
#   change_selection $nets_shapes
#   puts "PGNets layers: $nets_shapes_layers"
#}
proc GetNetsInfo {nets {puts_loading_num 40}} {
   set allNets [get_nets -all  $nets ]
   foreach_in_collection net $allNets {
      if {[info exist Width]} {unset Width}; if {[info exist TLength]} {unset TLength};
      set nd [gd $net]
      set nd_type [get_attr $nd object_class]
      if {$nd_type == "port"} {
         set nd_ref_name "Port"
      } else {
         set nd_ref_name [get_attr [get_cells -of $nd] ref_name]
      }
      set nl [gl $net]
      set nets_shapes [get_shapes -q -of $net ]
      set net_name [get_object_name $net]
      if {[sizeof $nets_shapes]} {
         set net_length [get_attr $net route_length]
         set net_rule  [get_attr $net routing_rule]
         set total_length 0
         foreach enl $net_length {
              set l [lindex i$enl 1]
              set total_length [expr $total_length + $l]
         }
         puts "## Net Info: $net_name: Use ([llength $net_length]) layers, <Rule>: $net_rule, <Length>:$total_length ([lsort -index 0  -dic $net_length])\n\tDriver ([sizeof $nd]): [get_object_name $nd] ($nd_ref_name)\n\tLoading ([sizeof $nl]):"
         if {[sizeof $nl] <= $puts_loading_num} {
#            puts "\t\t[join [get_object_name $nl] "\n\t\t"]"
            foreach_in_collection l $nl {
               puts "\t\t[get_object_name $l] ([get_attr [get_cells -of $l] ref_name])"
            }
         }
         foreach_in_collection wire $nets_shapes {
            set m [get_attr $wire layer_name]
            set w [get_attr $wire width]
            set l [get_attr $wire length]
            if {[info exist Width($m)]} {lappend Width($m) $w} else {set Width($m) $w}
            if {[info exist TLength(${m}_${w})]} {set TLength(${m}_${w}) [expr $TLength(${m}_${w}) + $l]} else {set TLength(${m}_${w}) $l}
         }
         puts "## Wire Info: <Layer>  <Width> (<Length>)"
         set wire_total_length 0
         foreach mn [lsort -dic [array name Width]] {
            set Width($mn) [lsort -u $Width($mn)]
            set info "\t$mn:\t"
            foreach mw $Width($mn) {
               set info "$info $mw ($TLength(${mn}_${mw}))"
               set wire_total_length [expr $wire_total_length + $TLength(${mn}_${mw})]
            }
            puts "$info"
         }
         puts "\tWire Total Length: $wire_total_length"
      } else {
         puts "$net_name: No Shapes.\n\tDriver ([sizeof $nd]): [get_object_name $nd] ($nd_ref_name)\n\tLoading ([sizeof $nl]):"
         if {[sizeof $nl] <= $puts_loading_num} {
            puts "\t\t[join [get_object_name $nl] "\n\t\t"]"
         }
      }
   }
}
proc GetWiresMetalWidth {nets_shapes} {
   global LN;
   CollectionAttrCondition $nets_shapes layer_name LN
   puts "##OBJ: $obj##"
   foreach mn [lsort -dic [array name LN] ] {
      set w [lsort -u [get_attr $LN($mn) width]]
      puts "$mn: $w"
   }
}
   
proc SelectNets {nets} {
   set allNets [get_nets -all $nets]
   change_selection $allNets
}
proc GetNetsInfoDetial {nets} {
 #  set all_macros_pins [get_pins -of [all_macro_cells ] -all]
   set allNets [get_nets -all $nets]
   foreach_in_collection net $allNets {
      set ports [get_ports -all  -of $net]
      set net_name [get_object_name $net]
      set nets_shapes [get_shapes  -q -hierarchical -filter "owner_net == $net_name"]
      if {[sizeof $nets_shapes]} {
        set nets_shapes_layers [lsort -u [get_attribute $nets_shapes layer]]
        puts "$net_name (is_hier: [get_attribute $net is_hierarchical]): ([llength $nets_shapes_layers]) $nets_shapes_layers"
      } else {
        puts "$net_name (is_hier: [get_attribute $net is_hierarchical]): No Shapes."
      }
      if {[sizeof $ports]} {puts "\tPorts : ([sizeof $ports]) [get_object_name $ports] ([get_attribute $ports direction])"} else {puts "Ports : 0"}
      set pins [get_pins -leaf -all -of_objects $net]
#      set macros_pins [comment_collection $pins $all_macros_pins]
#      puts "\tPins: [sizeof $macros_pins] Macros Pins, [expr [sizeof $pins] - [sizeof $macros_pins]] STD Pins."
      puts "\t[format "%-50s %-30s %-15s %-20s" "# pin_name" "# (cell_name)" "# direction" "# is_hier"]"
      puts "\t---------------------------------------------------------------------------------------------"
      foreach_in_collection pin $pins {
         puts "\t[format "%-50s %-30s %-15s %-20s" [get_object_name $pin] "([get_attribute [get_cells -all -of $pin] ref_name])" [get_attribute $pin direction] [get_attribute $pin is_hierarchical]]"
      }
   }
}
   
#proc SelectPins {pins} {
#   set allPins [get_pins -hierarchical -all $pins ]
#   change_selection $allPins
#   foreach_in_collection pin $allPins {
#      puts "[get_object_name $pin] : [get_attribute $pin direction]"
#   }
#}

proc SelectRefCells {ref_cells} {
   set puts_info ""
   set ref_n 1
   foreach ref $ref_cells {
      if {$ref_n == 1} {set cell_type "ref_name =~ $ref"} else {set cell_type "$cell_type || ref_name =~ $ref"}
      incr ref_n
   }
   set cells [get_cells -q -hierarchical -all -filter $cell_type]
   if {[sizeof $cells] } {
      set cells_refs [lsort -u [get_attribute $cells ref_name ]]
      lappend puts_info "Cells : [sizeof $cells] ([llength $cells_refs] types cells)"
      foreach cells_ref $cells_refs {
         lappend puts_info "\t$cells_ref : [sizeof [get_cells  -hierarchical -all -filter "ref_name =~ $cells_ref"]]"
      }
       change_selection $cells
   } else {
      lappend puts_info "Cells : 0; No cells ref name match: $ref_cells"
   }
   puts [join $puts_info "\n"]
}


proc GetPGRail {nets_names} {
   set nets_n 1
   foreach net $nets_names {
      if {$nets_n == 1} {set owner_net_type "owner_net =~ $net"} else {set owner_net_type "$owner_net_type || owner_net =~ $net"}
      incr nets_n
   }
   set filter_types "($owner_net_type) && route_type =~ P/G*Std*Cell*Pin*Conn*"
   set nets_shapes [get_shapes -q  -hierarchical -filter $filter_types]
   set nets_shapes_layers [lsort -u [get_attribute $nets_shapes layer]]
   puts "PGNets layers: $nets_shapes_layers"
   return $nets_shapes
}

proc SelectPGRail {nets_names} {
   set nets_shapes [GetPGRail $nets_names]
   change_selection $nets_shapes
   return $nets_shapes
}

proc GetShapesCoors {shapes} {
   set shapes [get_shapes $shapes]
   set bbox_llx [lindex [lsort -dic -incr [get_attribute $shapes bbox_llx]] 0]
   set bbox_lly [lindex [lsort -dic -incr [get_attribute $shapes bbox_lly]] 0]
   set bbox_urx [lindex [lsort -dic -dec [get_attribute $shapes bbox_urx]] 0]
   set bbox_ury [lindex [lsort -dic -dec [get_attribute $shapes bbox_ury]] 0]
   puts "$bbox_llx $bbox_lly $bbox_urx $bbox_ury"
}
   
proc GetPGStrap {nets_names {layers *}} {
   set nets_n 1
   foreach net $nets_names {
      if {$nets_n == 1} {set owner_net_type "owner_net =~ $net"} else {set owner_net_type "$owner_net_type || owner_net =~ $net"}
      incr nets_n
   }
   set layers_n 1
   foreach layer $layers {
      if {$layers_n  == 1} {set layer_type "layer =~ $layer"} else {set layer_type "$layer_type || layer =~ $layer"}
      incr layers_n
   }
   set filter_types "($owner_net_type) && ($layer_type) && route_type =~ P/G*Strap"
   set nets_shapes [get_shapes -hierarchical -filter $filter_types]
   set nets_shapes_layers [lsort -u [get_attribute $nets_shapes layer]]
   return $nets_shapes
}
proc GetNetsShapes {nets_names {layers *}} {
   set nets_n 1
   foreach net $nets_names {
      if {$nets_n == 1} {set owner_net_type "owner_net =~ $net"} else {set owner_net_type "$owner_net_type || owner_net =~ $net"}
      incr nets_n
   }
   set layers_n 1
   foreach layer $layers {
      if {$layers_n  == 1} {set layer_type "layer =~ $layer"} else {set layer_type "$layer_type || layer =~ $layer"}
      incr layers_n
   }
   set filter_types "($owner_net_type) && ($layer_type)"
   set nets_shapes [get_shapes -hierarchical -filter $filter_types]
   set nets_shapes_layers [lsort -u [get_attribute $nets_shapes layer]]
   return $nets_shapes
}



proc GetShapesbox {shapes_c {lly_offset 0} {ury_offset 0}} {
   set boxes ""
   set llxs [lsort -u -incr -dic [get_attribute $shapes_c bbox_llx]]
   foreach llx $llxs {
      set shapes [filter_collection $shapes_c "bbox_llx == $llx"]
      set urxs [lsort -u -incr -dic [get_attribute $shapes bbox_urx]]
      foreach urx $urxs {
         set shapes2 [filter_collection $shapes "bbox_urx == $urx"]
         set lly [lindex [lsort -u -incr -dic [get_attribute $shapes2 bbox_lly]] 0]
         set ury [lindex [lsort -u -incr -dic [get_attribute $shapes2 bbox_ury]] end]
         set lly [expr $lly + $lly_offset]
         set ury [expr $ury + $ury_offset]
         set boxes "$boxes {{$llx $lly} {$urx $ury}}"
      }
   }
  # puts $boxes
#   puts "create_voltage_area -cycle_color -coordinate {$boxes} -power_domain "
   return $boxes
}


proc GetVAPolys {VA} {
   set VA_points [get_attribute [get_voltage_area_shapes -filter "owner == $VA"] points]
   set VA_polys_c [convert_to_polygon $VA_points]
   set polys [get_attr $VA_polys_c coordinate]
   if {[sizeof $VA_polys_c] > 1} {
      set cm_poly [Merger_polys $polys]
   } else {
      set cm_poly $polys
   }
}
         
proc ChangeVA_cmd {VA} {
   set VA_points [get_attribute [get_voltage_area_shapes -filter "owner == $VA"] points]
   set VA_polys_c [convert_to_polygon $VA_points]
   set polys [get_attr $VA_polys_c coordinate]
   if {[sizeof $VA_polys_c] > 1} {
      foreach poly $polys {
         if {[info exist cm_poly]} {
            set cmd "set cm_poly \[compute_polygons -boolean or {$cm_poly} {$poly}\]";
      #      puts $cmd;
            eval $cmd;
         } else {
            set cm_poly $poly
         }
      } 
   } else {
      set cm_poly $polys
   }
    puts "create_voltage_area -cycle_color -polygons {$cm_poly} -power_domain $VA"
}
proc GetBoundCmds {VA {txt "B"}} {
   set VA_points [get_attribute [get_voltage_area_shapes -filter "owner == $VA"] points]
   set VA_polys_c [convert_to_polygon $VA_points]
   if {[sizeof $VA_polys_c] > 1} {
      set polys [get_attr $VA_polys_c coordinate]
      foreach poly $polys {
         if {[info exist cm_poly]} {
            set cmd "set cm_poly \[compute_polygons -boolean or {$cm_poly} {$poly}\]";
      #      puts $cmd;
            eval $cmd;
         } else {
            set cm_poly $poly
         }
      }
   } else {
      set cm_poly $VA_points
   }
   set boxex [convert_from_polygon $cm_poly]
   puts "create_bounds -exclusive -name ${VA}_${txt} -coordinate {$boxex} [get_object_name [get_attr [get_voltage_area $VA] modules]]"
}

  
proc Merger_polys {polys} {
      foreach poly $polys {
      if {[info exist cm_poly]} {
         set cmd "set cm_poly \[compute_polygons -boolean or {$cm_poly} {$poly}\]";
   #      puts $cmd;
         eval $cmd;
      } else {
         set cm_poly $poly
      }
   }
   return $cm_poly
}

proc ExcludePoly {polys exclude_polys} {
   set polys_c [convert_to_polygon $polys]
   set exclude_polys_c [convert_to_polygon $exclude_polys]
   if {[sizeof $polys_c] > 1} {
      foreach poly $polys {
        if {[info exist cm_poly]} {unset cm_poly}
        if {[sizeof $exclude_polys_c] > 1} {
           foreach exclude_poly $exclude_polys {
              if {[info exist cm_poly]} {
                 set cmd "set cm_poly \[compute_polygons -boolean not {$cm_poly} {$exclude_poly}\]";
               } else {
                  set cmd "set cm_poly \[compute_polygons -boolean not {$poly} {$exclude_poly}\]";
               }
               eval $cmd
           }
        } else {
            set exclude_poly $exclude_polys
            set cmd "set cm_poly \[compute_polygons -boolean not {$poly} {$exclude_poly}\]";
            eval $cmd
        }
        if {[info exist cm2_poly]} {
            set cmd "set cm2_poly \[compute_polygons -boolean or {$cm_poly} {$cm2_poly}\]";
         } else {
            set cmd "set cm2_poly \$cm_poly"
         } 
         eval $cmd
        }
      } else {
         set poly $polys
         if {[sizeof $exclude_polys_c] > 1} {
          foreach exclude_poly $exclude_polys {
             if {[info exist cm_poly]} {
                set cmd "set cm_poly \[compute_polygons -boolean not {$cm_poly} {$exclude_poly}\]";
              } else {
                 set cmd "set cm_poly \[compute_polygons -boolean not {$poly} {$exclude_poly}\]";
              }
              eval $cmd
          }
         } else {
           set exclude_poly $exclude_polys
           set cmd "set cm_poly \[compute_polygons -boolean not {$poly} {$exclude_poly}\]";
           eval $cmd
         }
       set cmd "set cm2_poly \$cm_poly"
       eval $cmd
      }
      return $cm2_poly
}


proc GetCellsPlaceCmds {cells} {
   set puts_info ""
   set cells [get_cells -all $cells]
   foreach_in_collection cell $cells {
      lappend puts_info "set obj \[get_cells {\"[get_object_name $cell]\"} -all\]"
      lappend puts_info "set_attribute -quiet \$obj orientation [get_attr $cell orientation]"
      lappend puts_info "set_attribute -quiet \$obj origin {[get_attr $cell origin]}"
      lappend puts_info "set_attribute -quiet \$obj is_placed [get_attr $cell is_placed]"
      lappend puts_info "set_attribute -quiet \$obj is_fixed [get_attr $cell is_fixed]"
      lappend puts_info "set_attribute -quiet \$obj is_soft_fixed [get_attr $cell is_soft_fixed]"
      lappend puts_info "set_attribute -quiet \$obj eco_status [get_attr $cell eco_status]\n"
   }
   puts [join $puts_info "\n"]
}

proc GetFP_PBLKCmds {pblks} {
   set puts_info ""
   set pblks [get_placement_blockage $pblks]
   foreach_in_collection pblk $pblks {
      set type [get_attr $pblk type]
      if {$type == "partial"} {
         lappend puts_info "create_placement_blockage -name [get_object_name $pblk] -bbox {[get_attr $pblk bbox]} -type $type -blocked_percentage [get_attr $pblk blocked_percentage]"
      } else {
         lappend puts_info "create_placement_blockage -name [get_object_name $pblk] -bbox {[get_attr $pblk bbox]} -type $type"
      }
   }
   puts [join $puts_info "\n"]
}

proc conver_boxes_to_poly {box} {
   set org_llx [lindex [lindex $box 0] 0]
   set org_lly [lindex [lindex $box 0] 1]
   set org_urx [lindex [lindex $box 1] 0]
   set org_ury [lindex [lindex $box 1] 1]
   set poly "{{$org_llx $org_lly} {$org_urx $org_lly} {$org_urx $org_ury} {$org_llx $org_ury} {$org_llx $org_lly}}"
   return $poly
}



proc CreatePBlks {prefix_blk_name boxex {type hard}} {
   global a
   set blk_name "${prefix_blk_name}_$a"
   while {[sizeof [get_placement_blockage -q $blk_name]]} {
      incr a
      set blk_name "${prefix_blk_name}_$a"
   }
   set cmd "create_placement_blockage -bbox {$boxex} -name $blk_name -type $type"
   eval $cmd
}


proc CreateCellsPBlks {all_cells offset prefix_blk_name {type hard}} {
   global a
   foreach_in_collection cell $all_cells {
     set loc [get_attribute [get_cells -hierarchical $cell] bbox]
     set loc_lx [lindex [lindex $loc 0] 0 ]
     set loc_ly [lindex [lindex $loc 0] 1 ]
     set loc_rx [lindex [lindex $loc 1] 0 ]
     set loc_ry [lindex [lindex $loc 1] 1 ]
     set blk_bbox [concat [expr $loc_lx - $offset] [expr $loc_ly - $offset] [expr $loc_rx + $offset] [expr $loc_ry + $offset]]
     CreatePBlks $prefix_blk_name $blk_bbox $type
     incr a
   }
}


proc GetNetsShapesCMs {shapes} {
   set shapes [get_shapes $shapes]
   foreach_in_collection shape $shapes {
#      set net_type [get_attr $shape net_type]
      set layer [get_attr $shape layer]
      set net  [get_object_name [get_net -of $shape]]
      set route_type [get_attr $shape route_type]
      set object_type [get_attr $shape object_type]
      if {$object_type == "PATH"} {
         set points [get_attr $shape points]
         set width  [get_attr $shape width]
#         set length [get_attr $shape length]
#         set cmd "create_net_shape -points {$points} -layer $layer -net $net -length $length -width $width -route_type $route_type"
         set cmd "create_net_shape -points {$points} -layer $layer -net $net -width $width -route_type $route_type"

      } else {
         set bbox [get_attr $shape bbox]
         set cmd "create_net_shape  -bbox {$bbox} -layer $layer -net $net -route_type $route_type"
      }
      puts $cmd
   }
}

   
proc RF {inst_name {all 0}} {if {$all} {return [get_attr [get_cells -all $inst_name] ref_name]} else {return [get_attr [get_cells $inst_name] ref_name]}}

source /alchip/home/juliaz/scr/my_scr/my_tcl/CellPinCondition.proc.tcl 
source /alchip/home/juliaz/scr/my_scr/my_tcl/icc/Add_BDCells.proc.tcl

##baron
#if {[file exist /proj/Baron/]} {
#source /proj/Baron/WORK/juliaz/PT/ViewPT/use_proc.tcl
#source /proj/Baron/WORK/juliaz/PT/ViewPT/check_pinPD.tcl
#source /proj/Baron/WORK/juliaz/PT/ViewPT/pd_Vol_V.lst ; # Vol_V AWO PRN
#}

source /alchip/home/juliaz/scr/my_scr/my_tcl/icc/trace_in.tcl
source /alchip/home/juliaz/scr/my_scr/my_tcl/icc/trace_in_repeater.tcl
source /alchip/home/juliaz/scr/my_scr/my_tcl/icc/trace_out.tcl
source /alchip/home/juliaz/scr/my_scr/my_tcl/icc/trace_out_TP.tcl
source /alchip/home/juliaz/scr/my_scr/my_tcl/icc/trace_out_repeater.tcl
source /alchip/home/juliaz/scr/my_scr/my_tcl/icc/debug.leakage_power.tcl 


proc sc {cells {add 0}} {if {$add} {change_selection [get_cells -all $cells] -add } else {change_selection [get_cells -all $cells]}}
proc sn {nets {add 0}} {if {$add} {change_selection [get_nets -all $nets] -add} else { change_selection [get_nets -all $nets]}}
proc sp {nets {add 0}} {if {$add} {change_selection [get_pins -all $pins] -add} else {change_selection [get_pins -all $pins]}}
alias ds "change_selection"

proc GetTotalArea {cells} {
   set cells [get_cells -all $cells ]
   set total_area 0
   foreach_in_collection cell $cells {
      set area [get_attr $cell area]
      set total_area [expr $total_area + $area]
   }
   puts "[sizeof $cells] cells\tarea: $total_area"
}


proc PN {pins {pins_nets_all 0}} {
   set put_info ""
   lappend put_info "[sizeof $pins] pins"
   foreach_in_collection pin $pins {
      if {$pins_nets_all} {set net [get_nets -q -all -of $pin]} else { set net [get_nets -q -of $pin]}
      if {[sizeof $net]} {
         lappend put_info "\t[get_attr $pin direction]\t([get_attr $pin name] : [get_attr $net name]) [get_object_name $pin] : [get_object_name $net]"
      } else {
         lappend put_info "\t[get_attr $pin direction]\t([get_attr $pin name] : [get_attr $net name]) [get_object_name $pin] :"
      }
   }
   puts [join $put_info "\n"]
}

proc CNPN {cells {pins_nets_all 1} {cells_all 0} } {
   if {$cells_all} {set cells [get_cells -all $cells]} else {set cells [get_cells $cells]}
   foreach_in_collection cell  $cells {
      set put_info ""
      if {$pins_nets_all} { set pins [get_pins -all -of $cell]} else {set pins [get_pins -of $cell]}
      lappend put_info "[sizeof $pins] pins,\tCell: [get_object_name $cell] ([get_attr $cell ref_name])"
      foreach_in_collection pin $pins {
         if {$pins_nets_all} {set net [get_nets -q -all -of $pin]} else { set net [get_nets -q -of $pin]}
         if {[sizeof $net]} { 
            lappend put_info "\t[get_attr $pin direction]\t([get_attr $pin lib_pin_name] : [get_attr $net base_name]) [get_object_name $pin] : [get_object_name $net]"
         } else {
            lappend put_info "\t[get_attr $pin direction]\t([get_attr $pin lib_pin_name] : [get_attr $net base_name]) [get_object_name $pin] :"
         }
      }
      puts [join $put_info "\n"]
   }
} 



proc SUM {list} {
   set sum 0
   foreach l1 $list {
      set sum [expr $sum + $l1]
   }
   return $sum
}
proc LCM_for_digit_list { digit_list {max_limit 99}} {
  set max 0
  foreach dig_num $digit_list {
    if {$dig_num > 0} {
      if {$dig_num > $max} {
        set max $dig_num
      }
    } else {
      return "vl-Error:Please input dig num > 0"
    }
  }
  #puts "max $max"
  set current $max
  while {$current < $max_limit} {
    set is_LCM 1
    foreach dig_num $digit_list {
      set times [expr $current * 1.000/$dig_num]
      set int_times [expr int($times)]
#      puts "current $current times $times int_times $int_times"
      if {[expr $int_times - $times] != 0} {
         #puts "int_times $int_times times $times";
         set is_LCM 0
      }
    }
   # puts "is_LCM $is_LCM"
    if {$is_LCM} {
      break
    }
    set current [expr $current + $max]
  }
  if {$is_LCM} {return $current} else {return 9999999}
  return $max
}

proc DivInt {num div} {
   set num [expr $num * 1.0]
   set int_num [expr int ($num / $div + 0.5)]
   set new_num  [expr $int_num * $div]
   return $new_num
}

proc CheckZroutShortCondition {} {
   global ZroutShortNetType; global ZroutShortNetLayer
   set data [open_drc_error_data -name zroute.err]
   open_drc_error_data -name zroute.err
   set short_drc_errors [get_drc_errors -error_data zroute.err -filter "type_name==Short"]
   set short_nets [get_attr $short_drc_errors objects]
   CollectionAttrCondition $short_drc_errors layers.name ZroutShortNetLayer
   CollectionAttrCondition $short_nets net_type ZroutShortNetType
}

proc GetNetLength {net} {
   set net [get_nets $net]
   set net_l [expr [get_attr $net dr_x_length] + [get_attr $net dr_y_length]]
   return $net_l
}
proc PutsNetsLengthSum {nets} {
   set nets [get_nets $nets]
   foreach_in_collection net $nets {
      set net_l [GetNetLength $net]
      if {[info exist NetlInfo($net_l)]} {set NetlInfo(($net_l) "$NetlInfo($net_l)\n$net_l\t[get_object_name $net]"} else {set NetlInfo($net_l) "$net_l\t[get_object_name $net]"}
   }
   foreach A [lsort -real [array name NetlInfo]] {
      puts "$NetlInfo($A)"
   }
}
proc FilterNetsLength {nets std_length {is_bigger 0}} {
   set nets [get_nets $nets]
   set return_nets [get_nets -q ""]
   if {$is_bigger} {
      foreach_in_collection n $nets {
         set n_l [GetNetLength $n]
         if {$n_l >= $std_length} {
            append_to_collection return_nets $n
         }
      }
      puts "##INFO: [sizeof $nets] nets , length >= $std_length nets num: [sizeof $return_nets] ."
   } else {
      foreach_in_collection n $nets {
         set n_l [GetNetLength $n]
         if {$n_l <= $std_length} {
            append_to_collection return_nets $n
         }
      }
      puts "##INFO: [sizeof $nets] nets , length <= $std_length nets num: [sizeof $return_nets] ."
   }
   return $return_nets
}

proc UniqCollection {c} {set d [add_to_collection -u $c $c]; return $d}


source /alchip/home/juliaz/scr/my_scr/my_tcl/FixEM/ICC2/GetEMNetsDetailInfo.proc2.tcl

source /alchip/home/juliaz/scr/my_scr/my_tcl/icc2/trace_in.tcl
source /alchip/home/juliaz/scr/my_scr/my_tcl/icc2/trace_out.tcl
source /alchip/home/juliaz/scr/my_scr/my_tcl/echo_tcl.proc.tcl
source /alchip/home/juliaz/scr/my_scr/my_tcl/DoubleCheckNet.proc.tcl
source /alchip/home/juliaz/scr/my_scr/my_tcl/icc2/SelectDrcError.proc.tcl
source /alchip/home/juliaz/scr/my_scr/my_tcl/icc2/GetHierCellName.proc.tcl

proc GetCellsArea {cells} {
   set cells [get_cells $cells]
   set total_area 0
   foreach_in_collection c  $cells {
      set total_area [expr $total_area + [get_attr $c area]]
   }
   return $total_area
}
proc SelectBoxShapes {bbox_list {filter_cnd ""} {reset_select 1} } {
   if {$reset_select} {change_selection}; 
   if {$filter_cnd != ""} {
      foreach b $bbox_list {
    #     set ll [lindex $b 0]; set ll_x [lindex $ll 0]; set lly [lindex $ll 1]
    #     set ur [lindex $b 1]; set ur_x [lindex $ur 0]; set ury [lindex $ur 1]
    #     change_selection -add [get_shapes -filter "bounding_box.ll_x == $ll_x && bounding_box.ll_y == $lly && bounding_box.ur_x == $ur_x && bounding_box.ur_y == $ury && $filter_cnd" -hierarchical]
         change_selection -add [get_shapes -touching $b -filter $filter_cnd -hierarchical]
      }     
   } else {
      foreach b $bbox_list {
     #    set ll [lindex $b 0]; set ll_x [lindex $ll 0]; set lly [lindex $ll 1]
     #    set ur [lindex $b 1]; set ur_x [lindex $ur 0]; set ury [lindex $ur 1]
     #    change_selection -add [get_shapes -hierarchical -filter "bounding_box.ll_x == $ll_x && bounding_box.ll_y == $lly && bounding_box.ur_x == $ur_x && bounding_box.ur_y == $ury"]
         change_selection -add [get_shapes -touching $b -hierarchical]
      }
   }
}

proc PutsRptFullDir {rpt} {
   if {[regexp {^/} $rpt]} {puts $rpt} else {puts "[pwd]/$rpt"}
}
 proc sc {m} {change_selection [get_cells $m]}
