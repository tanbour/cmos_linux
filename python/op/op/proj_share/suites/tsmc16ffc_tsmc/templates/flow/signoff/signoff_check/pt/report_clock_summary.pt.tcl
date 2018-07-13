proc report_clock_summary { } {
  suppress_message ATTR-3
  suppress_message ENV-003
  suppress_message PTE-003
  suppress_message PTE-016

 #set clocks [ sort_collection [ all_clocks ] full_name ]
  set clocks [ sort_collection [ all_clocks ] period ]

  echo " +----------------------------------------------------------------------------------------------------------------------------------+"
  echo " | Clock Name   |  Frequency |     Period |       Rise |       Fall |    # of FF | Source Pin/Port                                  |"
  echo " |--------------+------------+------------+------------+------------+------------+--------------------------------------------------|"
       # | AU1BCLK      |     33.750 |     29.630 |      0.000 |     14.815 |        203 | AU1BCLK                                          |
       # | AU2BCLK      |     33.750 |     29.630 |      0.000 |     14.815 |        203 | AU2BCLK                                          |
  foreach_in_collection clock $clocks {
    set clock_name [ get_attribute $clock full_name ]

    set period [ get_attribute $clock period ]
    if { $period == "" } {
      set period    "-"
      set freq      "-"
      set rise_time "-"
      set fall_time "-"
    } else {
      set period    [ format "%.3f" $period ]
      set freq      [ format "%.3f" [ expr 1000.0 / $period ] ]
      set waveform  [ lindex [ get_attribute $clock waveform ] 0 ]
      set rise_time [ format "%.3f" [ lindex $waveform 0 ] ]
      set fall_time [ format "%.3f" [ lindex $waveform 1 ] ]
    }
    if { [ string length $clock_name ] > 12 } {
      set display_name [ format "%s%s" \
        [ string repeat "." 3 ] \
        [ string range $clock_name [ expr [ string length $clock_name ] - [ expr 12 - 3 ] ] end ] ]
    } else {
      set display_name $clock_name
    }

    foreach_in_collection source [ get_attribute $clock sources ] {
      set source_name [ get_attribute $source full_name ]
      if { [ string length $source_name ] > 48 } {
        set source_name [ format "%s%s" \
          [ string repeat "." 3 ] \
          [ string range $source_name [ expr [ string length $source_name ] - [ expr 48 - 3 ] ] end ] ]
      }
     #set number_of_registers [ sizeof_collection [ all_registers -clock $clock ] ]
     #set number_of_registers [ sizeof_collection [ filter_collection [ all_fanout -flat -from $source -endpoints_only ] "is_clock_pin == true" ] ]
      set leaf_pins [ filter_collection [ all_fanout -flat -from $source -endpoints_only ] "is_clock_pin == true" ]
      set leaf_pins [ filter_collection $leaf_pins "direction == in" ]
      set number_of_registers [ sizeof_collection $leaf_pins ]

      echo [ format " | %-12s | %10s | %10s | %10s | %10s | %10s | %-48s |" \
        $display_name $freq $period $rise_time $fall_time \
        $number_of_registers $source_name ]
    }
  }
  
  echo " +----------------------------------------------------------------------------------------------------------------------------------+"

  unsuppress_message ATTR-3
  unsuppress_message ENV-003
  unsuppress_message PTE-003
  unsuppress_message PTE-016
}

