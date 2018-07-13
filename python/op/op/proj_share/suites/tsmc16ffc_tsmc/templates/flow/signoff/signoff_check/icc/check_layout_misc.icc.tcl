##################################################################################
# PROGRAM:     check_layout_misc.icc.tcl
# CREATOR:     Michael Mo <michaelm@alchport.com>
# DATE:        Fri Mar 17 11:38:31 CST 2017
# DESCRIPTION: Check layout in IC Compiler
#	             For ??
# USAGE:       check_layout_misc 
##################################################################################

proc check_layout_misc { } {
	sh rm -rf check_layout
	sh mkdir check_layout
	set physopt_check_site_array_overlap FALSE ; # for multiple row design
	report_design -physical > check_layout/pr_summary.rep
	check_legality -verbose  > check_layout/check_legality.rep
	report_routing_rules > check_layout/report_routing_rules.rep
	report_zrt_shield -per_layer true -output check_layout/report_zrt_shield.rep
}
