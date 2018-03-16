#!/usr/bin/tclsh
#############################################################################################################################
# PROGRAM:     check_ip_duty.pt.tcl
# CREATOR:     Jarir <jarir@alchip.com>
# DATE:        Thu Mar 23 14:00:48 CST 2017
# DESCRIPTION: Set min_pulse_width for ip clock pin and get report 
# USAGE:       check_ip_duty ?<ip_clock_duty_spec_file> ?<pt_cmd_file>  ?<report_name>?
# UPDATE:      updated by Felix <felix_yuan@alchip.com>    2018-03-07
# ITEM:        CK-01-19
#############################################################################################################################

proc check_ip_duty { ip_clock_duty_spec_file  {pt_cmd_file set_min_pulse_width.tcl}  {output_rpt_ip_duty ip_duty.rpt} } {
     puts "Alchip-info: Starting to signoff check ip clock duty cycle in PrimeTime\n"

set all_ip_pins ""

  if {![file exist $ip_clock_duty_spec_file]} {
    puts "Error: the spec file not exist"
    return
  }

set in1   [open $ip_clock_duty_spec_file r]
set out1 [open $pt_cmd_file  w]

   while { [gets $in1 line] >=0 } {
         set ip_pin   [lindex $line 0 ]
         set llength  [llength $line]

         ###### check spec format ######
         if {([regexp ^# $ip_pin] == 0) && ($llength > 0 )} {
             if {[llength $line] != 4} { 
                 echo "Warning duty spec llength is not 4 , please following the spec format"
                 echo "Warning duty spec llength is not 4 , please following the spec format"
                 puts $out1 "#Warning: duty spec llength is not 4 , please following the spec format"
                 puts $out1 "#failed line : $line"
             } else {
                 set period   [lindex $line 1 ]
                 set min_duty [lindex $line 2 ]
                 set max_duty [lindex $line 3 ]

         ###### check spec reasonabl ###### 
         if {$min_duty >= 0.5 } {
            puts "Warning : the min_duty >= 0.5 , please double check duty spec"
            puts $out1 "#Warning : the min_duty >= 0.5 , please double check duty spec"
         }

         if { [expr $min_duty + $max_duty ] != 1.0} {
            puts "Warning : min_duty + max_duty is not equal 1.0 , please double check duty spec"
            puts $out1 "#Warning : min_duty + max_duty is not equal 1.0 , please double check duty spec"
         }

################ set min_pulse_width and put cmd to pt_cmd_file ##############
set min_pulse_width [expr int($period * $min_duty*10000)/10000.00]

if { ![get_attribute [get_pins $ip_pin] is_hierarchical]} {
    puts $out1 "set_min_pulse_width $min_pulse_width \[get_pins $ip_pin \]"
    set  all_ip_pins [concat $all_ip_pins $ip_pin]
    set_min_pulse_width $min_pulse_width [get_pins $ip_pin ]
  } else {
    puts "Warning: the $ip_pin is hierarchical pin , cann't set min pulse_width on it "
    puts $out1 "#Warning: the $ip_pin is hierarchical pin , cann't set min pulse_width on it "
  }
###########################################################################
 }

}
######
 }
close $out1


##### get duty report ######
alias rpt_pw { report_min_pulse_width -significant_digits 3 -nosplit -path_type full_clock_expanded -input_pins -derate -nets}
    foreach pin $all_ip_pins {
         redirect -append $output_rpt_ip_duty {rpt_pw [get_pins $pin ] }
     }
############################

     puts "Alchip-info: Completed to signoff check ip clock duty cycle in PrimeTime\n"

}

# duty define
#set h_max_duty [expr ($max_fall  - $min_rise  + $period*0.5)/$period ]
#set h_min_duty [expr ($min_fall  - $max_rise  + $period*0.5)/$period ]
#set l_max_duty [expr ($max_rise  - $min_fall  + $period*0.5)/$period ]
#set l_min_duty [expr ($min_rise  - $max_fall  + $period*0.5)/$period ]

#suppress_message UITE-416
#set timing_report_unconstrained_paths true
#remove_min_pulse_width 

# source /proj/PS02_new2/WORK/jarir/inputs/IP_check/ES2/check_ip_duty.pt.tcl
# check_ip_duty /proj/PS02_new2/WORK/jarir/inputs/IP_check/ES2/clock_duty_spec /proj/PS02_new2/WORK/jarir/inputs/IP_check/ES2/set_min_pulse_width.tcl /proj/PS02_new2/WORK/jarir/inputs/IP_check/ES2/ip_duty.rpt

#This new value overrides the old one but for value define by lib only more restrictive value overrides the old one .


###
