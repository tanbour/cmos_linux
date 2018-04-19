proc check_clock_tree_object {  } {
    suppress_message ATTR-3
    suppress_message UITE-416
	set real_clocks [list ]
	set all_clocks [list ]
	set clocks  [get_clocks *]
	foreach_in_collection clock $clocks {
	lappend all_clocks $clock
	}
	foreach clock $all_clocks {
	set source_num [llength [get_attr [get_clock $clock] sources]]
	if {$source_num!=0} {
       	 lappend real_clocks $clock
       	 }
	}

  foreach clock $real_clocks {
    set clock_name [ get_attribute $clock full_name ]
    set leaf_pin_count [ sizeof_collection [ all_registers -clock $clock ] ]
	echo [ format "########################################################################" ]
	echo [ format "# %s (%d)" $clock_name $leaf_pin_count ]
	echo [ format "#" ]

    foreach_in_collection source [ get_attribute $clock sources ] {
      set leaf_pin_count [ sizeof_collection [ filter_collection [ all_fanout -flat -from $source -endpoints_only ] "is_clock_pin == true" ] ]
      set clock_source_name [get_attr $source full_name] 
       echo [ format "# Source: %s (%s)" $clock_source_name $leaf_pin_count ]
       check_clock_tree_object_sub $source 0 20 
    }
  }
  unsuppress_message ATTR-3
  unsuppress_message UITE-416
}

proc check_clock_tree_object_sub { drive_pin { level_count 0 } { level_count_limit 20 } } {
  set cell_types { OUT ENB BUF INV CMB ETC SEQ MEM AND NAND LATCH NOR OR MUX AOI AO OAI OA INR IND IOA IO_CELL IAO XNR MAOI MOAI IIND XOR}

  set net [ all_connected $drive_pin ]
  if { [ sizeof_collection $net ] == 0 } return
  set pins [ all_fanout -flat -from $net -levels 1 ]
  if { [ sizeof_collection $pins ] == 0 } { return }
  set load_pins [ filter_collection $pins "( object_class == pin && direction != out ) || ( object_class == port && direction != in )" ]
  if { [ sizeof_collection $load_pins ] == 0 } { return }
  set all_pins [ all_fanout -flat -from $net ]
  set all_load_pins [ filter_collection $all_pins "( object_class == pin && direction == in )" ]
  set is_clock_pin_or_not 0;
  foreach_in_collection all_load_pin $all_load_pins {
        if { [ get_attribute  $all_load_pin is_clock_pin  ] == "true" } {
             set is_clock_pin_or_not 1;
        }
  }
  
  # initialize counter
  foreach cell_type $cell_types {
    set count($cell_type) 0
  }

  set next_load_pins ""
  foreach_in_collection load_pin $load_pins {
    set load_pin_name [ get_attribute $load_pin full_name ]
    set object_class [ get_attribute $load_pin object_class ]
    set direction  [ get_attribute $load_pin direction  ]
    if { $object_class == "port" } {
      incr count(OUT)
    } else {
      set load_cell [ get_cells -of_objects $load_pin ]
      if { [ get_attribute $load_cell is_hierarchical ] != "true" } {
        set cell_type [ get_cell_type $load_cell ]
        incr count($cell_type)
        if { [ lsearch { "SEQ" "MEM" "LATCH" } $cell_type ] == -1 } {
          set next_load_pins [ add_to_collection $next_load_pins $load_pin ]
        }
      }
    }
  }

  echo -n [ string repeat " " $level_count ]
    if { [ get_attribute $drive_pin object_class ] == "port" } {
    echo -n [ format "L%d %s (%s)" $level_count [ get_attribute $drive_pin full_name ] [ get_attribute $drive_pin direction ] ]
  } else {
    echo -n [ format "L%d %s (%s)" $level_count [ get_attribute $drive_pin full_name ] [ get_cell_type [ get_cells -of_objects $drive_pin ] ] ]
  }
  foreach cell_type $cell_types {
    if { $count($cell_type) != 0 } {
      echo -n [ format " %s=%d" $cell_type $count($cell_type) ]
    }
  }
  if { $is_clock_pin_or_not == 0 } {
     echo -n  " \[DATA\] STOP"   
  }
  echo ""
 if { $is_clock_pin_or_not == 1 } { 
  foreach_in_collection next_load_pin $next_load_pins {
    set load_pin_name [ get_attribute $next_load_pin full_name ]
    if { $level_count > $level_count_limit } {
      echo [ format "Warning: Exceeded level count limit(%d). Stop to trace." $level_count_limit ]
     } else {
      foreach_in_collection next_drive_pin [ get_pins -of_objects [ get_cells -of_objects $next_load_pin ] -filter "direction == out" ] {
        check_clock_tree_object_sub $next_drive_pin [ expr $level_count + 1 ] $level_count_limit
      }
    }
  }
 }
}

proc get_cell_type { cell } {
# # Sony/K2
# set pattern(ENB) "*FCM2T*"
# set pattern(BUF) "*BF1*"
# set pattern(INV) "*VF1*"
# set pattern(AND) "*AD2*"

# TSMC
  set pattern(ENB) "^CKLNQ.*|^CKLHQ.*"
  set pattern(BUF) "^BUFF.*D.*|^BUFT.*D.*|^CKB.*D.*|^CKBX.*D.*"
  set pattern(INV) "^INV.*D.*|^CKN.*D.*|^CKNX.*D.*"
  set pattern(AND) "^AN.*D.*|^CKAN2.*D.*"
  set pattern(NAND) "^ND.*D.*|^CKND.*D.*"
  set pattern(MEM) "^ts.g.*|^TS.G.*"
  set pattern(LATCH) "^LN.*D.*|^LH.*D"
  set pattern(NOR) "^NR.*D.*"
  set pattern(OR) "^OR.*D.*"
  set pattern(AOI) "^AOI.*D.*"
  set pattern(AO) "^AO.*D.*"
  set pattern(OAI) "^OAI.*D.*"
  set pattern(OA) "^OA.*D.*"
  set pattern(INR) "^INR.*D.*"
  set pattern(IND) "^IND.*D.*"
  set pattern(IOA) "^IOA.*D.*"
  set pattern(IAO) "^IAO.*D.*"
  set pattern(XNR) "^XNR.*D.*"
  set pattern(MAOI) "^MAOI.*D.*"
  set pattern(MOAI) "^MOAI.*D.*"
  set pattern(IO_CELL) "^PD.*|^PVDD.*|^PVSS.*|^PXOE.*|^PR.*"
  set pattern(IIND) "^IIND.*D.*"
  set pattern(XOR) "^XOR.*D.*"

  set number_of_pins(MEM) 10

  if { [ get_attribute $cell is_sequential ] == "true" } {
    if { [ regexp $pattern(ENB) [ get_attribute $cell ref_name ] ] == 1 } {
      return ENB
    } elseif { [ regexp $pattern(LATCH) [ get_attribute $cell ref_name ] ] == 1 } {
      return LATCH 
    } elseif { [ get_attribute $cell number_of_pins ] > $number_of_pins(MEM) } {
      return MEM
    } else {
      return SEQ
    }
  } elseif { [ get_attribute $cell is_combinational ] == "true" } {
    if { [ get_attribute $cell is_mux ] == "true" } {
      return MUX
    } elseif { [ regexp $pattern(BUF) [ get_attribute $cell ref_name ] ] == 1 } {
      return BUF
    } elseif { [ regexp $pattern(AND) [ get_attribute $cell ref_name ] ] == 1 } {
      return AND 
    } elseif { [ regexp $pattern(NAND) [ get_attribute $cell ref_name ] ] == 1 } {
      return NAND 
    } elseif { [ regexp $pattern(NOR) [ get_attribute $cell ref_name ] ] == 1 } {
      return NOR
    } elseif { [ regexp $pattern(INV) [ get_attribute $cell ref_name ] ] == 1 } {
      return INV
    } elseif { [ regexp $pattern(OR) [ get_attribute $cell ref_name ] ] == 1 } {
      return OR
    } elseif { [ regexp $pattern(AOI) [ get_attribute $cell ref_name ] ] == 1 } {
      return AOI
    } elseif { [ regexp $pattern(AO) [ get_attribute $cell ref_name ] ] == 1 } {
      return AO
    } elseif { [ regexp $pattern(OAI) [ get_attribute $cell ref_name ] ] == 1 } {
      return OAI
    } elseif { [ regexp $pattern(OA) [ get_attribute $cell ref_name ] ] == 1 } {
      return OA
    } elseif { [ regexp $pattern(MEM) [ get_attribute $cell ref_name ] ] == 1 } {
      return MEM 
    } elseif { [ regexp $pattern(INR) [ get_attribute $cell ref_name ] ] == 1 } {
      return INR
    } elseif { [ regexp $pattern(IND) [ get_attribute $cell ref_name ] ] == 1 } {
      return IND
    } elseif { [ regexp $pattern(IOA) [ get_attribute $cell ref_name ] ] == 1 } {
      return IOA
    } elseif { [ regexp $pattern(IAO) [ get_attribute $cell ref_name ] ] == 1 } {
      return IAO
    } elseif { [ regexp $pattern(MOAI) [ get_attribute $cell ref_name ] ] == 1 } {
      return MOAI
    } elseif { [ regexp $pattern(MAOI) [ get_attribute $cell ref_name ] ] == 1 } {
      return MAOI
    } elseif { [ regexp $pattern(XNR) [ get_attribute $cell ref_name ] ] == 1 } {
      return XNR
    } elseif { [ regexp $pattern(IO_CELL) [ get_attribute $cell ref_name ] ] == 1 } {
      return IO_CELL
    } elseif { [ regexp $pattern(IIND) [ get_attribute $cell ref_name ] ] == 1 } {
      return IIND
    } elseif { [ regexp $pattern(XOR) [ get_attribute $cell ref_name ] ] == 1 } {
      return XOR
    } else {
      return CMB
    }
  } else {
    return ETC
  }
} 
