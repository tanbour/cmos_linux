#!/usr/local/bin/tclsh

# Tcl version of :runGridCheck

proc runGridCheck {} {
		
	set INPUT_FILENAME "adsRpt/apache.gridcheck"
	set OUTPUT_FILENAME "resistance.rpt"
	set IN [open $INPUT_FILENAME r]
	set OUT [open $OUTPUT_FILENAME w]
	
	while { [gets $IN readLine] >= 0 } {
		if { [regexp {R_MAX: *([0-9.]+)} $readLine all p1] } {
			set Rmax $p1
			puts $readLine
			puts $OUT $readLine
		} elseif { [regexp {R_MIN: *([0-9.]+)} $readLine all p1] } {
			set Rmin $p1
			puts $readLine
			puts $OUT $readLine
		} elseif { [regexp {([0-9.]+)(	| )+([0-9.]+)(	| )+([0-9.]+)} $readLine all pTotal p1 pVDD p2 pVSS]
			&& ![regexp {^#} $readLine]
			&& ![regexp {\{} $readLine]
			&& ![regexp {floating} $readLine]} {
			set Total_R [expr $Rmin + ($Rmax - $Rmin) * $pTotal / 100]
			set VDD_R [format %.3f [expr $Total_R * $pVDD / 100]]
			set VSS_R [format %.3f [expr $Total_R * $pVSS / 100]]
			set mod_line [lreplace $readLine 0 2 [format %.3f $Total_R] $VDD_R $VSS_R]
			regsub -all { } $mod_line {   } mod_line
			puts $OUT $mod_line
			puts $mod_line
		} elseif { [regexp {floating} $readLine] } {
		} else {
			regsub -all {relative strength} $readLine {absolute strength} readLine
			regsub -all {percent_vdd\*R_total} $readLine {Total - Rvss} readLine
			regsub -all {percent_vss\*R_total} $readLine {Total - Rvdd} readLine
			regsub -all {R_MIN \+ \%_strength\*\(R_MAX - R_MIN\)} $readLine {Rvdd + Rvss} readLine
			regsub -all {\(\%\)} $readLine {} readLine
			puts $OUT $readLine
			puts $readLine
		}
	}
	close $IN
	close $OUT
}
