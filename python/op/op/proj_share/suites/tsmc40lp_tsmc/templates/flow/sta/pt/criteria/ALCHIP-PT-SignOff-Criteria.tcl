#==================================== Part 0: history ===============================================
# 1. Reduce 10% for (cell, data, late) base Jack Lu's OCV table.
# 2. Hold use sansung's criteria to replace Jack Lu's
# 3. Delta V/T derating for tt0p4v use James Huang's criteria @5mV, @5C
#
# Default: POCV ONLY

#====================================== Part 1: OCV =================================================
# ENABLE_OCV
#if {[info exists ENABLE_OCV] & $ENABLE_OCV == "true"} {
if {[regexp {max|setup} $CHECK_TYPE]} {
	switch $LIB_CORNER {
		"wc"   {set_timing_derate -early 0.93}
		"wcz"  {set_timing_derate -early 0.93}
		"wcl"  {set_timing_derate -early 0.93}
	}
} elseif {[regexp {min|hold} $CHECK_TYPE]} {
	switch $LIB_CORNER {
		"wc"   {set_timing_derate -early 0.93}
		"wcz"  {set_timing_derate -early 0.93}
		"wcl"  {set_timing_derate -early 0.93}
		"lt"   {set_timing_derate -late 1.10}
		"ltz"  {set_timing_derate -late 1.10}
		"ml"   {set_timing_derate -late 1.10}
	}
}
set_clock_uncertainty -hold 0.050 [ all_clocks ]
set_clock_uncertainty -setup 0.050 [ all_clocks ]

#==================================== Part 4: MaxTrans ==============================================
set_max_fanout 16 [ current_design ]
set_max_transition 0.400 [ current_design ]
set clocks [ add_to_collection [ get_clocks * -quiet ] [ get_generated_clocks * -quiet ] ]
if { [ sizeof_collection $clocks ] > 0 } {
   set_max_transition 0.200 $clocks -clock_path
}

#================================== Part 5: Noise Margin ============================================
switch $LIB_CORNER {
  "wc" {
      set noise_margin [expr 0.99*0.3]
   }
  "wcz" {
      set noise_margin [expr 0.99*0.3]
   }
  "wcl" {
      set noise_margin [expr 0.99*0.3]
   }
  "lt" {
      set noise_margin [expr 1.21*0.3]
   }
  "ltz" {
      set noise_margin [expr 1.21*0.3]
   }
  "ml" {
      set noise_margin [expr 1.21*0.3]
   }
  "tt25" {
      set noise_margin [expr 1.1*0.3]
   }
}
set_noise_margin $noise_margin [get_pins -of_objects [get_cells -hierarchical  -filter "ref_name !~*BWP*"] -filter "direction == in"]

