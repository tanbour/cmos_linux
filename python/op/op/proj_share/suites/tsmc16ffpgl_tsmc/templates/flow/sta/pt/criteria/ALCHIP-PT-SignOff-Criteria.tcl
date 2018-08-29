#====================================== Part 1: Timing Margin  =================================================
#--> 1b. Clock jitter + DPT+
set jitter 0.050
set flat_ocv_hold_uncertainty 0.050

set DPT_setup 0.005
set DPT_hold  0.003

set setup_margin [expr $jitter + $DPT_setup]
set hold_margin [expr $flat_ocv_hold_uncertainty + $DPT_hold]
set_clock_uncertainty $setup_margin -setup  [ all_clocks ]
set_clock_uncertainty $hold_margin -hold [ all_clocks ]
#==================== OCV / AOCV / POCV ===============
# --> 1a --> 1e
{% include 'pt/tcl/derating.tcl' %}

#================================== Part 2: Set DRC  ============================================
set_max_fanout 50 [ current_design ]
remove_max_transition [all_clocks ]
set_max_transition 0.25 [ current_design ]
set_max_transition 0.15 -clock_path [all_clocks ]

#================================== Part 3: Noise Margin ============================================
# set_noise_margin

