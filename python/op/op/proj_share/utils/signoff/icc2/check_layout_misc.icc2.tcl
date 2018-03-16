##################################################################################
# PROGRAM:     check_layout_misc.icc2.tcl
# CREATOR     : Michael Mo <michaelm@alchport.com>
# DATE        : Mon Mar 27 16:03:45 CST 2017
# DESCRIPTION : Check layout in IC Compiler II
# UPDATER     : Felix Yuan <felix_yuan@alchip.com>  
# USAGE       : check_layout_misc
# ITEM        :  
##################################################################################

proc check_layout_misc { } {
     puts "Alchip-info: Starting to signoff check layout infomation in ICC2\n"
	set physopt_check_site_array_overlap FALSE     ; # for multiple row design
	report_design -physical > ./report_design.rpt
	check_legality -verbose  > ./check_legality.rpt
	report_routing_rules > ./report_routing_rules.rpt
	report_shield -per_layer true -output ./report_shield.rpt
        puts "Alchip-info: Completed to signoff check layout infomation in ICC2\n"
}
