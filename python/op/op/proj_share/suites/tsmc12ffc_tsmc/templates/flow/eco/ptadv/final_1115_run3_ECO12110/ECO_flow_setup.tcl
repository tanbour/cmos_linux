set FIX_POWER 0; # 0 or 1
set VTH_SWAPPING 0; # 0 or 1
set DOWNSIZING 0; # 0 or 1
set REMOVE_BUFFER 0; # 0 or 1
set SAVE_SESSION_FIX_POWER 0; # 0 or 1

set FIX_DRC 0; # 0 or 1
set FIX_SLEW 0; # 0 or 1
set FIX_CAP 0; # 0 or 1
set FIX_FANOUT 0; # 0 or 1
set FIX_NOISE 0; # 0 or 1
set SAVE_SESSION_FIX_DRC 0; # 0 or 1

set FIX_TIMING 1; # 0 or 1
set FIX_HOLD 0; # 0 or 1
set FIX_SETUP 1; # 0 or 1
set SAVE_SESSION_FIX_TIMING 0; # 0 or 1


set eco_alternative_area_ratio_threshold 2 ; # max area ratio during eco, 0 for no restriction , default is 2
if {[file exists ECO_flow_setup.warning.log]} {
	exec rm ECO_flow_setup.warning.log
}

###FIX POWER###
if {$FIX_POWER} {
	if {!($VTH_SWAPPING || $DOWNSIZING || $REMOVE_BUFFER)} {
		echo "Warning: FIX_POWER = ${FIX_POWER}, but have not use vth swapping , downsize and remove buffers.(VTH_SWAPPING=$VTH_SWAPPING, DOWNSIZING=$DOWNSIZING, REMOVE_BUFFER=$REMOVE_BUFFER)" >> ECO_flow_setup.warning.log
	}
	#$#lappend FIX_POWER_CMD ""
	if {$VTH_SWAPPING} {
		set FIX_POWER_CMD(VTH_SWAPPING) ""
		lappend FIX_POWER_CMD(VTH_SWAPPING) "fix_eco_power -pba_mode path -setup_margin 0.05 -attribute eco_pattern -pattern_priority {RVT LVT ULVT} -verbose"
	}
	if {$DOWNSIZING} {
		set FIX_POWER_CMD(DOWNSIZING) ""
		lappend FIX_POWER_CMD(DOWNSIZING) "fix_eco_power -pba_mode path -setup_margin 0.05 -verbose"
	}
	if {$REMOVE_BUFFER} {
		set FIX_POWER_CMD(REMOVE_BUFFER) ""
		lappend FIX_POWER_CMD(REMOVE_BUFFER) "fix_eco_power -pba_mode path -setup_margin 0.05 -methods remove_buffer"
	}
} else { 
	if {$VTH_SWAPPING || $DOWNSIZING || $REMOVE_BUFFER} {
		echo "Warning: FIX_POWER = ${FIX_POWER}, so no to fix power.(VTH_SWAPPING=$VTH_SWAPPING, DOWNSIZING=$DOWNSIZING, REMOVE_BUFFER=$REMOVE_BUFFER)" >> ECO_flow_setup.warning.log
	}
}

###FIX DRC##
if {$FIX_DRC} {
	if {!($FIX_SLEW || $FIX_CAP || $FIX_FANOUT || $FIX_NOISE)} {
		echo "Warning: FIX_DRC = ${FIX_DRC}, but have not fix slew or fix cap.(FIX_SLEW=$FIX_SLEW, FIX_CAP=$FIX_CAP, FIX_FANOUT=$FIX_FANOUT, FIX_NOISE=$FIX_NOISE)" >> ECO_flow_setup.warning.log
	}
	#$#lappend FIX_DRC_CMD ""
	if {$FIX_SLEW} {
		set FIX_DRC_CMD(FIX_SLEW) ""
	        ## FOR FAST RUNTIME : FOR EARLY ECO
	        # PHYSICAL MODE : OCCUPIED_SITE
	        lappend FIX_DRC_CMD(FIX_SLEW) "fix_eco_drc -type max_transition -setup_margin 0 -physical_mode occupied_site -buffer_list \{$DRC_BUFFER_LIST\} -verbose"
	
	        ## FOR FAST RUNTIME : FOR EARLY ECO
	        # PHYSICAL MODE : OPEN_SITE
	        #lappend FIX_DRC_CMD(FIX_SLEW) "fix_eco_drc -type max_transition -setup_margin 0 -physical_mode open_site -buffer_list $DRC_BUFFER_LIST -verbose -max_iteration 5"
	
	        ## FOR BEST QoR : FOR FINAL ECO
	        # PHYSICAL MODE : OCCUPIED_SITE  
	        ##lappend FIX_DRC_CMD(FIX_SLEW) "fix_eco_drc -type max_transition -setup_margin 0 -physical_mode occupied_site -buffer_list $DRC_BUFFER_LIST -verbose "

	}
	if {$FIX_CAP} {
		set FIX_DRC_CMD(FIX_CAP) ""
	        ## FOR FAST RUNTIME : FOR EARLY ECO
	        # PHYSICAL MODE : OCCUPIED_SITE  
	        lappend FIX_DRC_CMD(FIX_CAP) "fix_eco_drc -type max_capacitance -physical_mode occupied_site -buffer_list \{$DRC_BUFFER_LIST\} -setup_margin 0 -verbose"
	
	        ## FOR FAST RUNTIME : FOR EARLY ECO
	        # PHYSICAL MODE : OPEN_SITE
	        #lappend FIX_DRC_CMD(FIX_CAP) "fix_eco_drc -type max_capacitance -physical_mode open_site -buffer_list $DRC_BUFFER_LIST -setup_margin 0 -verbose -max_iteration 5"
	
	        ### FOR BEST QoR : FOR FINAL ECO
	        ## PHYSICAL MODE : OCCUPIED_SITE  
	        #lappend FIX_DRC_CMD(FIX_CAP) "fix_eco_drc -type max_capacitance -physical_mode occupied_site -buffer_list $DRC_BUFFER_LIST -setup_margin 0 -verbose" 

	}
	if {$FIX_FANOUT} {
		set FIX_DRC_CMD(FIX_FANOUT) ""
		lappend FIX_DRC_CMD(FIX_FANOUT) "fix_eco_drc -type max_fanout -physical_mode occupied_site -buffer_list \{$DRC_BUFFER_LIST\} -setup_margin 0 -verbose"
	}
	if {$FIX_NOISE} {
		set FIX_DRC_CMD(FIX_NOISE) ""
		lappend FIX_DRC_CMD(FIX_NOISE)  "fix_eco_drc -type noise -physical_mode occupied_site -buffer_list \{$DRC_BUFFER_LIST\} -setup_margin 0 -verbose"
	}
} else { 
	if {$FIX_SLEW || $FIX_CAP || $FIX_FANOUT || $FIX_NOISE} {
		echo "Warning: FIX_DRC = ${FIX_DRC}, so no to fix drc.(FIX_SLEW=$FIX_SLEW, FIX_CAP=$FIX_CAP, FIX_FANOUT=$FIX_FANOUT,  FIX_NOISE=$FIX_NOISE.)" >> ECO_flow_setup.warning.log
	}
}


###FIX TIMING##
if {$FIX_TIMING} {
	if {!($FIX_HOLD || $FIX_SETUP)} {
		echo "Warning: FIX_TIMING = ${FIX_TIMING}, but have not fix hold or setup.(FIX_HOLD=$FIX_HOLD, FIX_SETUP=$FIX_SETUP)" >> ECO_flow_setup.warning.log
	}
	#$#lappend FIX_TIMING_CMD ""
	if {$FIX_HOLD} {
		set  FIX_TIMING_CMD(FIX_HOLD) ""
		
		# FOR FAST RUNTIME : FOR EARLY ECO
		# PHYSICAL MODE : OCCUPIED_SITE
		lappend FIX_TIMING_CMD(FIX_HOLD) "fix_eco_timing -type hold -physical_mode occupied_site -pba_mode path -buffer_list \{$HOLD_BUFFER_LIST\} -verbose"
		
		# FOR FAST RUNTIME : FOR EARLY ECO
		## PHYSICAL MODE : OPEN_SITE
		# lappend FIX_TIMING_CMD "fix_eco_timing -verbose -type hold -physical_mode open_site -pba_mode path -buffer_list \{$HOLD_BUFFER_LIST\} -verbose -max_iteration 5"
		
		## FOR BEST QoR : FOR FINAL ECO
		## PHYSICAL MODE : OPEN_SITE
		# lappend FIX_TIMING_CMD "fix_eco_timing -verbose -type hold -physical_mode open_site -pba_mode path -buffer_list \{$HOLD_BUFFER_LIST\} -verbose"
	}
	if {$FIX_SETUP} {
		set  FIX_TIMING_CMD(FIX_SETUP) ""	
	
		## FOR FAST RUNTIME : FOR EARLY ECO
		# PHYSICAL MODE : OCCUPIED_SITE
		lappend FIX_TIMING_CMD(FIX_SETUP) "fix_eco_timing -type setup -pba_mode path -verbose -hold_margin 0.05"
      lappend FIX_TIMING_CMD(FIX_SETUP) "fix_eco_timing -type setup -physical_mode occupied_site -pba_mode path -methods {insert_buffer} -buffer_list \{$FIXSETUP_BUF\} -verbose -hold_margin 0.05"
		
		## FOR FAST RUNTIME : FOR EARLY ECO
		## PHYSICAL MODE : OPEN_SITE
		# lappend FIX_TIMING_CMD(FIX_SETUP) "fix_eco_timing -verbose -type setup -physical_mode open_site -pba_mode path -verbose -max_iteration 5"
		
		## FOR BEST QoR : FOR FINAL ECO
		## PHYSICAL MODE : OPEN_SITE
		# lappend FIX_TIMING_CMD(FIX_SETUP) "fix_eco_timing -verbose -type setup -cell_type combinational -physical_mode open_site -pba_mode path -verbose"
		# lappend FIX_TIMING_CMD(FIX_SETUP) "fix_eco_timing -verbose -type setup -cell_type sequential    -physical_mode open_site -pba_mode path -verbose"
	}

} else {
	if {$FIX_HOLD || $FIX_SETUP} {
		echo "Warning:  FIX_TIMING = ${FIX_TIMING},so not to fix timing.(FIX_HOLD=$FIX_HOLD, FIX_SETUP=$FIX_SETUP)" >> ECO_flow_setup.warning.log
	}
}
