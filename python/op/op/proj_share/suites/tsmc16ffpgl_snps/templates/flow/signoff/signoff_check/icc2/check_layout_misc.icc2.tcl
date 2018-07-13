##################################################################################
# PROGRAM:     check_layout_misc.icc2.tcl
# CREATOR:     Michael Mo <michaelm@alchport.com>
# DATE:        Mon Mar 27 16:03:45 CST 2017
# DESCRIPTION: Check layout in IC Compiler II
#	             For ??
# USAGE:       check_layout_misc 
##################################################################################

proc check_layout_misc { } {
     puts "Alchip-info: Starting to signoff check layout infomation in ICC2\n"
	sh rm -rf check_layout
	sh mkdir check_layout
	set physopt_check_site_array_overlap FALSE ; # for multiple row design
	report_design -physical > check_layout/pr_summary.rpt
	check_legality -verbose  > check_layout/check_legality.rpt
	report_routing_rules > check_layout/report_routing_rules.rpt
	report_shield -per_layer true -output check_layout/report_shield.rpt
        puts "Alchip-info: Completed to signoff check layout infomation in ICC2\n"
}
