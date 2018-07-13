####
####

# /user/home/i_saber/my_script/ediSH/ediProc.tcl

proc ifCellExist {arg} {

	set exist	0
	set name	[get_cells -intersect $arg -quiet]
	if {[llength ${name}] > 0}	{set exist 1}

	return	${exist}
}

proc calculateRefRowloc2 {pinPT refDistxy} {

#	set rowH	0.24
	set rowH	[lsort -u [get_attribute [get_site_rows] site_height]]
	set site	[lsort -u [get_attribute [get_site_rows] site_width]]
	set pinX	[lindex $pinPT 0]
	set pinY	[lindex $pinPT 1]
	set refX	[lindex $refDistxy 0]
	set refY	[lindex $refDistxy 1]
	set core2L	[lindex [get_attribute [get_core_area] bbox] 0 0]
	set core2B	[lindex [get_attribute [get_core_area] bbox] 0 1]
	set RpinX	[expr $pinX - $core2L + $refX]
	set RpinY	[expr $pinY - $core2B + $refY]
	set numsR	[expr int($RpinY/$rowH)]
	set numsS	[expr int($RpinX/$site)]
#	set RpinPT	[concat [expr $RpinX + $core2L] [expr ${rowH}*${nums} + $core2B] $nums]
	set RpinPT	[concat [expr ${site}*${numsS} + $core2L] [expr ${rowH}*${numsR} + $core2B]]
	return		$RpinPT

}

proc calculateRefRowloc {pinPT refDistxy} {

#	set rowH	0.24
	set rowH	[lsort -u [get_attribute [get_site_rows] site_height]]
	set site	[lsort -u [get_attribute [get_site_rows] site_width]]
	set pinX	[lindex $pinPT 0]
	set pinY	[lindex $pinPT 1]
	set refX	[lindex $refDistxy 0]
	set refY	[lindex $refDistxy 1]
	set core2L	[lindex [get_attribute [get_core_area] bbox] 0 0]
	set core2B	[lindex [get_attribute [get_core_area] bbox] 0 1]
	set RpinX	[expr $pinX - $core2L + $refX]
	set RpinY	[expr $pinY - $core2B + $refY]
	set numsR	[expr int($RpinY/$rowH)]
	set numsS	[expr int($RpinX/$site)]
#	set RpinPT	[concat [expr $RpinX + $core2L] [expr ${rowH}*${nums} + $core2B] $nums]
	set RpinPT	[concat [expr ${site}*${numsS} + $core2L] [expr ${rowH}*${numsR} + $core2B] $numsR]
	return		$RpinPT

}

proc getCoreMid {} {
	set boxes	[get_attribute [get_core_area] bbox]
	set xMid	[expr [lindex $boxes 0 0]/2 + [lindex $boxes 1 0]/2]
	set yMid	[expr [lindex $boxes 0 1]/2 + [lindex $boxes 1 1]/2]
	set midPoint	[concat $xMid $yMid]
	return	$midPoint
}

proc arrangPinInc {pinLists XorY} {

	if {$XorY == "X"}	{set aa 1}
	if {$XorY == "Y"}	{set aa 2}
	set newPinList	""
	set Lists	""

	foreach pin $pinLists {
		change_selection [get_ports $pin]
		set pinPT	[lindex [get_attribute [get_selection ] bbox] 0]
		set Alist	[concat $pin [lindex $pinPT 0] [lindex $pinPT 1]]
		lappend Lists $Alist
	} 
	set Lists [lsort -increasing -index $aa -real $Lists]
	foreach pin $Lists { lappend newPinList [lindex $pin 0]}
	return	$newPinList
}

proc getOrien	{flipX flipY} {

	set OrienO	"R0"
	if {$flipX == 0 && $flipY == 0	}	{set OrienO "R0"}
	if {$flipX == 1 && $flipY == 0	}	{set OrienO "MX"}
	if {$flipX == 1 && $flipY == 1	}	{set OrienO "R180"}
	if {$flipX == 0 && $flipY == 1	}	{set OrienO "MY"}
	return	$OrienO
}

proc moveIObufferA {ports LoBoRoT refDistxy} {
# set inst mcu_u/dwc_ddrphy/u_DWC_DDRPHYACX4_0;set libCell BUFFD8BWP16P90CPDULVT; set libCells DCCKBD8BWP16P90CPDLVT; set refDistxy {0 13}; set LorRorBorT T
#	set height	0.576; # row height
	set offsetX	0.0;
	set cDelX	0.1
	set site	[lsort -u [get_attribute [get_site_rows] site_width]]
	set cDelY	-0.01 ; # delta of cell boxes to check cell exist of not
	#set corePins	[getDiffIPPins $inst 0.1 1]
	set corePins	[arrangPinInc $ports X]
	set midP	[getCoreMid]
	set pinLoc	0
	set inde	0
	set symb	"+"; set aa 0; set bb 1
	if {$LoBoRoT == "B"}	{set symb "-"}
	if {$LoBoRoT == "L"}	{set symb "-"; set aa 1; set bb 0}
	if {$LoBoRoT == "R"}	{set symb "+"; set aa 1; set bb 0}

	foreach pin $corePins {
		set flipX	0
		set flipY	0
		set OrienO	"R0"
#		echo "$pin"
		set aaNum	[sizeof_collection [remove_from_collection [get_pins -of [get_nets -of $pin] -leaf] [get_ports $pin]]]
		if {$aaNum == 0}	{continue}
		set pinA	[get_attribute [remove_from_collection [get_pins -of [get_nets -of $pin] -leaf] [get_ports $pin]] full_name]
		set dire	[get_attribute [get_pins $pinA] direction]
		set cellA	[get_attribute [get_cells -of $pinA] full_name]
		if {[llength $cellA] != 1 }	{echo "port: $pin exists not single buffer" ; continue}
		set cellref	[get_attribute [get_cells -of $pinA] ref_name]
		set area	[lindex [get_attribute [get_lib_cells */$cellref] area] 0]
		set cellX	[ get_attribute [get_cells $cellA] height ]
		set cellY	[ get_attribute [get_cells $cellA] width  ]
		set Cheight	$cellX
		set Cweight	$cellY

		set ii	0

		set pinPT	[lindex [get_attribute [get_ports $pin ] bbox] 0]
		set RpinPT	[calculateRefRowloc $pinPT $refDistxy]
		if { [lindex $midP ${inde}] < [lindex ${RpinPT} ${inde}]}	{set pinLoc 1 ;set offsetX 0.0}
#		if {$dire == "out" && ${pinLoc} ==0}	{set flipY 1}
#		if {$dire == "in" && ${pinLoc} ==1}	{set flipY 1}


		set Rx		[expr [lindex $RpinPT 0] $symb ${aa}*${ii}*${site}*1 - $offsetX]
		set Ry		[expr [lindex $RpinPT 1] $symb ${bb}*${ii}*${Cweight}]
		set boxes	""
		lappend boxes	[concat [expr $Rx - $cDelX]  [expr $Ry + $cDelY]]
		lappend boxes	[concat [expr $Rx + $Cweight + $cDelX] [expr $Ry + $Cheight - $cDelY]]

		while {[ifCellExist $boxes]} {
			incr ii
			set Rx		[expr [lindex $RpinPT 0] $symb ${aa}*${ii}*${site}*1 - $offsetX]
			set Ry		[expr [lindex $RpinPT 1] $symb ${bb}*${ii}*${Cheight}]
			set boxes	""
			lappend boxes	[concat [expr $Rx - $cDelX]  [expr $Ry - $cDelY]]
			lappend boxes	[concat [expr $Rx + $Cweight + $cDelX] [expr $Ry + $Cheight + $cDelY]]
			if {$ii > 50 }	{echo "issue in port : $pin" ; continue}
		}
		set flipX	[expr int([lindex $RpinPT 2] + 1 + $ii * $bb)%2]
		set OrienO	[getOrien $flipX $flipY]

		set_cell_location -coordinates "${Rx} ${Ry}" -orientation ${OrienO} ${cellA}
		echo "set_cell_location -coordinates {${Rx} ${Ry}} -orientation ${OrienO} ${cellA}"

	
	}
}

