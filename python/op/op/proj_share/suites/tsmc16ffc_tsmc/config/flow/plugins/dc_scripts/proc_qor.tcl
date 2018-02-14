# REFERENCE IMPLEMENTATION (RI) SCRIPTS
# OPTIMIZED FOR ARM PROCESSOR CORES & OTHER CORES
#
# TERMS AND CONDITIONS
#
# THIS NOTICE MAY NOT BE REMOVED
#
# Synopsys CONFIDENTIAL
# Copyright (c) 2015 by Synopsys, Inc. All rights reserved.
#
# These Reference Implementation (RI) scripts are optimized for an ARM Limited
# ("ARM") processor core or other core in an ARM Product Family ("Scripts");
# they are for reference purposes and are not designed to run in their current form.
#
# ARM Product Families:
#      * V8A (e.g., Cortex-A57)
#      * V8R
#      * V8M
#      * V7A (e.g., Cortex-A15)
#      * V7R (e.g., Cortex-R4)
#      * V7M (e.g., Cortex-M3)
#      * GPU (e.g., Mali T760)
#      * System IP (e.g., ARM CoreLink CCI-400)
#
# You represent that you either:
# a.) have a valid license from ARM under a commercial technology license
# agreement to design, manufacture and distribute integrated circuits
# incorporating an ARM processor or other core, delivered to you by ARM, in
# the relevant ARM Product Family for this Script (“ARM Licensee”), or
# b.) are a contractor providing services to an ARM Licensee and are working
# under their have designed rights from ARM.
#
# The Scripts may be used only for designing or having designed ARM Licensee’s
# integrated circuits that incorporate ARM(R) products under license from ARM,
# and only with Synopsys EDA products. The Scripts may not be used for any other
# purpose.
#
# ARM Licensee’s employees and those of ARM Licensee’s contractors under
# ARM Licensee’s have designed rights from ARM may use these Scripts internally,
# with or without modification, solely for ARM Licensee’s benefit and subject
# to these terms and conditions.
#
# Except as set forth above, these Scripts may not be repackaged
# or redistributed to any third party.
#
# The Scripts are the confidential information of Synopsys and/or its licensors,
# who own and shall retain all right, title and interest in and to the Scripts,
# including all intellectual property rights embodied therein. You shall
# maintain the confidentiality of the Scripts indefinitely and shall apply
# security measures no less stringent than those used to protect your own like
# confidential information, but not less than a reasonable degree of care, to
# prevent any unauthorized use or disclosure of the Scripts to any third party.
# The confidentiality obligations stated herein shall not apply to information
# that: (a) is or becomes generally known or available by publication,
# commercial use, or otherwise through no fault of your own; (b) is known to
# you, and has been reduced to tangible form, at the time of disclosure and is
# not subject to restriction; (c) you lawfully obtained from a third party who
# has the right to make such disclosure; or (d) is in the public domain at the
# time of receipt or later becomes part of the public domain without breach of
# your confidentiality obligations.
#
# You shall have no rights with respect to the Scripts other than the rights
# expressly set forth in these terms and conditions. All rights not expressly
# granted to you herein this are retained by Synopsys. Synopsys's licensors are
# third-party beneficiaries of, and thus may enforce against you, the use
# restrictions and confidentiality obligations in these terms and conditions
# with respect to their intellectual property and proprietary information.
#
# THE SCRIPTS ARE PROVIDED "AS IS" AND ANY EXPRESS, STATUTORY OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE OR NON INFRINGEMENT
# AND ANY WARRANTIES ARISING FROM A COURSE OF DEALING OR USAGE OF TRADE, ARE
# DISCLAIMED. IN NO EVENT SHALL SYNOPSYS OR ITS LICENSORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THE
# SCRIPTS, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Version 27 March 2015


# © 2014 Synopsys, Inc. All rights reserved. 
# # This script is proprietary and confidential information of 
# Synopsys, Inc. and may be used and disclosed only as authorized 
# per your agreement with Synopsys, Inc. controlling such use and disclosure.
# proc_histogram proc_qor and proc_compare_qor scripts

#################################################
#Author Narendra Akilla
#Applications Consultant
#Company Synopsys Inc.
#Not for Distribution without Consent of Synopsys
#proc to reformat report_qor output into a table 
#################################################

proc proc_histogram {args} {

#dont take the below echo, used by proc_compare_qor
echo "\nStarting  Histogram"

parse_proc_arguments -args $args results

set s_flag  [info exists results(-slack_lesser_than)]
set gs_flag [info exists results(-slack_greater_than)]

if {[info exists results(-number_of_bins)]} { set numbins $results(-number_of_bins) } else { set numbins 10 }
if {[info exists results(-slack_lesser_than)]} { set slack $results(-slack_lesser_than) } else { set slack 0.0 }
if {[info exists results(-slack_greater_than)]} { set gslack $results(-slack_greater_than) }
if {$::synopsys_program_name == "pt_shell"} {
  echo "In PrimeTime only rise slack is considered for histogram" 
  set sub_attr "rise_" 
} else { set sub_attr "" }
if {[info exists results(-hold)]} { set attr "min_${sub_attr}slack" } else { set attr "max_${sub_attr}slack" }
if {[info exists results(-number_of_critical_hierarchies)]} { set number $results(-number_of_critical_hierarchies) } else { set number 10 }

if {$gs_flag&&!$s_flag} { echo "Error!! -slack_greater_than can only be used with -slack_lesser_than ....Exiting\n" ; return }
if {$gs_flag&&$gslack>$slack} { echo "Error!! -slack_greater_than should be more than -slack_lesser_than ....Exiting\n" ; return }

foreach_in_collection clock [all_clocks] { if {[get_attribute -quiet $clock sources] != "" } { append_to_collection -unique real_clocks $clock } }
set min_period [lindex [lsort -real [get_attr -quiet $real_clocks period]] 0]
catch {redirect -var y {report_units}}
regexp {(\S+)\s+Second} $y match unit
if {[info exists unit]} {
  if {[regexp {e-12} $unit]} { set unit 1000000 } else { set unit 1000 }
} else { set unit 1000 }

if {$min_period<=0} { echo "Error!! Failed to calculate min_period of real clocks .... Exiting\n" ; return }

if {$gs_flag} {
  echo "Acquiring Endpoints ($gslack > Slack < $slack) - ignores REGOUT\n"
} else {
  echo "Acquiring Endpoints (Slack < $slack) - ignores REGOUT\n"
}

set coll   [sort_coll [filter_coll [all_registers -data_pins] "$attr<$slack"] $attr]
if {$gs_flag} { set coll [sort_coll [filter_coll $coll "$attr>$gslack"] $attr] }

if {[sizeof $coll]<1} { 
  echo "No Violations Found"
  return
}
set values [lsort -real [get_attr -quiet $coll $attr]]
set min    [lindex $values 0]
set max    [lindex $values [expr {[llength $values]-1}]]
set range  [expr {$max-$min}]
set width  [expr {$range/$numbins}]

for {set i 1} {$i<=$numbins} {incr i} { 
  set compare($i) [expr {$min+$i*$width}] 
  set histogram($i) 0
}
#to avoid rounding errors adding a small value
set compare($i) [expr $slack+0.01]

set i 1
foreach v $values {
  if {$v<=$compare($i)} { incr histogram($i) } else { incr i ; incr histogram($i) }
}

echo "==================================="
echo "        WNS RANGE      -  Endpoints"
echo "==================================="
if {[llength $values]>0} {
  for {set i $numbins} {$i>=1} {incr i -1} {
    set low [expr {$min+$i*$width}]
    set high [expr {$min+($i-1)*$width}]
    set f_low [format %.3f $low]
    set f_high [format %.3f $high]
    set pct [expr {100.0*$histogram($i)/[llength $values]}]
    echo -n "[format "% 8s" $f_low] to [format "% 8s" $f_high]   -  [format %9i $histogram($i)] ([format %4.1f $pct]%)"
    if {$attr=="max_slack"} {
      if {[expr {($min_period-$high)*$unit}]>0} { set freq [expr {(1.0/($min_period-$high))*$unit}] } else { set freq 0.0 }
      echo " - [format %4.0f ${freq}]Mhz"
    } else {
      echo ""
    }
  }
}
echo "==================================="
echo "Total Endpoints        - [format %10i [llength $values]]"
if {$attr=="max_slack"} { echo "Clock Frequency        - [format %10.0f [expr (1.0/$min_period)*$unit]]Mhz (estimated)" }
echo "==================================="
echo ""

set allicgs [get_cells -quiet -hi -f "is_hierarchical==false&&clock_gating_integrated_cell=~*"]
set slkff [remove_from_coll [get_cells -quiet -of $coll] $allicgs]

foreach c [get_attr -quiet $slkff full_name] {
  set cell $c
  for {set i 1} {$i<50} {incr i} {
    set parent [file dir $cell]
    if {$parent=="."} { break }
    set parent_coll [get_cells -quiet $parent -f "is_hierarchical==true"]
    if {[sizeof $parent_coll]<1} { set cell $parent ; continue }
    if {[info exists hier_repeat($parent)]} { incr hier_repeat($parent) } else { set hier_repeat($parent) 1 }
    set cell $parent
  }
}

echo "==================================="
echo " Viol.   $number Critical"
echo " Count - Hierarchies"
echo "==================================="

if {![array exists hier_repeat]} { 
  echo "No Critial Hierarchies found\n"
  return
}

foreach {a b} [array get hier_repeat] { lappend repeat_list [list $a $b] }

set cnt 0
foreach i [lsort -real -decreasing -index 1 $repeat_list] { 
  echo "[format %6i [lindex $i 1]] - [lindex $i 0]" 
  incr cnt
  if {$cnt==$number} { break }
}
echo "================================="
echo ""

}

define_proc_attributes proc_histogram -info "USER_PROC: Prints histogram of setup or hold slack endpoints" \
  -define_arg { \
  {-number_of_bins      "Optional - number of bins for histgram, default 10"			"<int>"               int  optional}
  {-slack_lesser_than   "Optional - histogram for endpoints with slack less than, default 0" 	"<float>"               float  optional}
  {-slack_greater_than  "Optional - histogram for endpoints with slack greater than, can only be used with -slack_greater_than, default wns" 	"<float>"               float  optional}
  {-hold		"Optional - Generates histogram for hold slack, default is setup"	""                      boolean  optional}
  {-number_of_critical_hierarchies      "Optional - number of critical hierarchies to display viol. count, default 10" "<int>" int  optional}
}
 

#################################################
#Author Narendra Akilla
#Applications Consultant
#Company Synopsys Inc.
#Not for Distribution without Consent of Synopsys
#################################################

#Version 1.74
#pt bug fix for histogram
#handles uninit for some path groups
#fixed a dmsa bug
#added histogram option
#added error check for unwritable csv file
#added -no_pathgroup_info
#uses new Design tns/nvp printed in report_qor

proc proc_qor {args} {

  echo "\nVersion 1.73\n"
  parse_proc_arguments -args $args results
  set skew_flag [info exists results(-skew)]
  set scenario_flag [info exists results(-scenarios)]
  set pba_flag  [info exists results(-pba)]
  set file_flag [info exists results(-existing_qor_file)]
  set hist_flag [info exists results(-histogram)]
  set unit_flag [info exists results(-units)]
  set no_pg_flag   [info exists results(-no_pathgroup_info)]
  set uncert_flag [info exists results(-signoff_uncertainty_adjustment)]
  if {[info exists results(-csv_file)]} {set csv_file $results(-csv_file)} else { set csv_file "qor.csv" }
  if {$file_flag&&$skew_flag} { echo "Warning!! -existing_qor_file is ignored when -skew is given" }
  if {$file_flag&&$hist_flag} { echo "Warning!! -histogram flag is ignored when -existing_qor_file is given" }
  if {$file_flag} { set qor_file  $results(-existing_qor_file) } else { set qor_file "" }
  if {[info exists results(-units)]} {set unit $results(-units)}

  set ::collection_deletion_effort low

  if {$uncert_flag} {
    echo "-signoff_uncertainty_adjustment only changes Frequency Column, report still sorted by WNS"
    set signoff_uncert $results(-signoff_uncertainty_adjustment)
  }

  if {(!$skew_flag)&&[file exists $qor_file]} { 
    set tmp [open $qor_file "r"]
    set x [read $tmp]
    close $tmp
  } else {
    if {$::synopsys_program_name != "pt_shell"} {
      if {$scenario_flag} {
        echo -n "Running report_qor -nosplit -scenarios $results(-scenarios) ... "
        redirect -var x { report_qor -nosplit -scenarios $results(-scenarios) }
        echo "Done"
      } else {
        echo -n "Running report_qor -nosplit ... "
        redirect -var x { report_qor -nosplit }
        echo "Done"
      }
    }
  }
  
  if {$::synopsys_program_name == "pt_shell"} {
    if {$::pt_shell_mode=="primetime_master"} {return "proc_qor not supported in DMSA Master"}
    set uncons $::timing_report_unconstrained_paths
    if {$uncert_flag} {
      echo "-signoff_uncertainty_adjustment is ignored in PrimeTime"
      unset -nocomplain uncert_flag signoff_uncert
    }
  }

  if {(!$unit_flag)} {
    catch {redirect -var y {report_units}}
    #regexp {Second\((\S+)\)\n} $y match unit
    regexp {(\S+)\s+Second} $y match unit
  }
  if {[info exists unit]} {
    if {[regexp {e-12} $unit]} { set unit 1000000 } else { set unit 1000 }
  } else { set unit 1000 }
  
  set drc 0
  set cella 0
  set buf 0
  set leaf 0
  set tnets 0
  set cbuf 0
  set seqc 0
  set tran 0
  set cap 0
  set fan 0
  set combc 0
  set macroc 0
  set comba 0
  set seqa 0
  set desa 0
  set neta 0
  set netl 0
  set netx 0
  set nety 0
  set hierc 0
  if {![file writable [file dir $csv_file]]} {
    echo "$csv_file not writable, Writing to /dev/null instead"
    set csv_file "/dev/null"
  }
  set csv [open $csv_file "w"]

  if {$::synopsys_program_name != "pt_shell"||[file exists $qor_file]} {
  #in dc or icc, process qor file lines
  set i 0
  foreach line [split $x "\n"] {
  
    incr i
    #echo "Processing $i : $line"

    if {[regexp {^\s*Scenario\s+\'(\S+)\'} $line match scenario]} {
    } elseif {[regexp {^\s*Timing Path Group\s+\'(\S+)\'} $line match group]} {
      if {[info exists scenario]} { set group ${group}_$scenario }
      set group_data [list $group]
      unset -nocomplain lol cpl wns cp tns nvp wnsh tnsh nvph fr
    } elseif {[regexp {^\s*Levels of Logic\s*:\s*(\S+)} $line match lol]} {
      lappend group_data $lol
    } elseif {[regexp {^\s*Critical Path Length\s*:\s*(\S+)} $line match cpl]} {
      lappend group_data $cpl
    } elseif {[regexp {^\s*Critical Path Slack\s*:\s*(\S+)} $line match wns]} { 
      if {$wns == "uninit" } { set wns 0 }
      set wns [expr {double($wns)}]
      lappend group_data $wns
    } elseif {[regexp {^\s*Critical Path Clk Period\s*:\s*(\S+)} $line match cp]} { 
      if { $cp == "n/a"} { set cp 0 }
      set cp [expr {double($cp)}]
      lappend group_data $cp
    } elseif {[regexp {^\s*Total Negative Slack\s*:\s*(\S+)} $line match tns]} {
      lappend group_data $tns
    } elseif {[regexp {^\s*No\. of Violating Paths\s*:\s*(\S+)} $line match nvp]} {
      lappend group_data $nvp
    } elseif {[regexp {^\s*Worst Hold Violation\s*:\s*(\S+)} $line match wnsh]} {
      lappend group_data $wnsh
    } elseif {[regexp {^\s*Total Hold Violation\s*:\s*(\S+)} $line match tnsh]} {
      lappend group_data $tnsh
    } elseif {[regexp {^\s*No\. of Hold Violations\s*:\s*(\S+)} $line match nvph]} {
      lappend group_data $nvph
      lappend all_group_data $group_data

    } elseif {[regexp {^\s*Hierarchical Cell Count\s*:\s*(\S+)} $line match hierc]} {
    } elseif {[regexp {^\s*Hierarchical Port Count\s*:\s*(\S+)} $line match hierp]} {
    } elseif {[regexp {^\s*Leaf Cell Count\s*:\s*(\S+)} $line match leaf]} {
      set leaf [expr {$leaf/1000}]
    } elseif {[regexp {^\s*Buf/Inv Cell Count\s*:\s*(\S+)} $line match buf]} {
      set buf [expr {$buf/1000}]
    } elseif {[regexp {^\s*CT Buf/Inv Cell Count\s*:\s*(\S+)} $line match cbuf]} {
    } elseif {[regexp {^\s*Combinational Cell Count\s*:\s*(\S+)} $line match combc]} {
      set combc [expr $combc/1000]
    } elseif {[regexp {^\s*Sequential Cell Count\s*:\s*(\S+)} $line match seqc]} {
    } elseif {[regexp {^\s*Macro Count\s*:\s*(\S+)} $line match macroc]} {
 
    } elseif {[regexp {^\s*Combinational Area\s*:\s*(\S+)} $line match comba]} {
      set comba [expr {int($comba)}]
    } elseif {[regexp {^\s*Noncombinational Area\s*:\s*(\S+)} $line match seqa]} {
      set seqa [expr {int($seqa)}]
    } elseif {[regexp {^\s*Net Area\s*:\s*(\S+)} $line match neta]} {
      set neta [expr {int($neta)}]
    } elseif {[regexp {^\s*Net XLength\s*:\s*(\S+)} $line match netx]} {
    } elseif {[regexp {^\s*Net YLength\s*:\s*(\S+)} $line match nety]} {
    } elseif {[regexp {^\s*Cell Area\s*:\s*(\S+)} $line match cella]} {
      set cella [expr {int($cella)}]
    } elseif {[regexp {^\s*Design Area\s*:\s*(\S+)} $line match desa]} {
      set desa [expr {int($desa)}]
    } elseif {[regexp {^\s*Net Length\s*:\s*(\S+)} $line match netl]} {
      set netl [expr {int($netl)}]

    } elseif {[regexp {^\s*Total Number of Nets\s*:\s*(\S+)} $line match tnets]} {
      set tnets [expr {$tnets/1000}]
    } elseif {[regexp {^\s*Nets With Violations\s*:\s*(\S+)} $line match drc]} {
    } elseif {[regexp {^\s*Max Trans Violations\s*:\s*(\S+)} $line match tran]} {
    } elseif {[regexp {^\s*Max Cap Violations\s*:\s*(\S+)} $line match cap]} {
    } elseif {[regexp {^\s*Max Fanout Violations\s*:\s*(\S+)} $line match fan]} {
    } elseif {[regexp {^\s*Design\s+WNS:\s*\S+\s*TNS:\s*(\S+).*Paths:\s*(\S+)} $line match setup_tns setup_nvp]} {
    } elseif {[regexp {^\s*Design\s+\(Hold\)\s*WNS:\s*\S+\s*TNS:\s*(\S+).*Paths:\s*(\S+)} $line match hold_tns hold_nvp]} {
    } elseif {[regexp {^\s*Error} $line]} {
      echo "Error in report_qor. Exiting ..."
      return
    }

  }
  #all lines of qor file read
  } else {
    #in pt shell need to get qor data thru get_timing commands
    set ::timing_report_unconstrained_paths false
    if {$pba_flag} {
      echo "In PBA mode only failing paths upto 1000 are reported"
      set elimit $::pba_exhaustive_endpoint_path_limit
      echo "Setting pba_exhaustive_endpoint_path_limit to 10"
      set ::pba_exhaustive_endpoint_path_limit 10
    } else {
      echo "In PrimeTime only 25000 paths per path group are analyzed for TNS and NVP"
    }
    set grps [get_attribute [get_path_groups] full_name]
    foreach group $grps {
      #if {[string match $group **default**]} { echo "Skipping path group $group" ; continue }
      echo -n "\nProcessing Path Group $group"
      set group_coll [get_path_group $group]
      set group_coll [index_coll $group_coll [expr [sizeof $group_coll]-1]]
      redirect /dev/null { set wpath [get_timing_paths -group $group_coll] }
      redirect /dev/null { set whpath [get_timing_paths -delay min -group $group_coll] }
      if {[sizeof $wpath]>0&&[sizeof $whpath]>0} {
        #append group data only if setup and hold paths exists for that group
        unset -nocomplain wns cp tns nvp wnsh tnsh nvph
        #wns
        set wns [get_attribute $wpath slack]
        if {[string is alpha $wns]} { echo -n " : No real paths in group $group" ; continue }  
        set wns [expr {double($wns)}]
        #cp
        set cp [get_attribute [get_attribute $wpath endpoint_clock] period]
        if {$cp<=0} {set cp 0 }
        set cp [expr {double($cp)}]
        #tns and nvp
        set tns 0
        set nvp 0
        if {$wns<0} {
          if {$pba_flag} {
            redirect /dev/null { set vpaths [get_timing_paths -pba_mode exhaustive -group $group_coll -slack_less 0 -max_paths 1000] }
            append_to_coll tvpaths $vpaths
          } else {
            redirect /dev/null { set vpaths [get_timing_paths -group $group_coll -slack_less 0 -max_paths 25000] }
            append_to_coll tvpaths $vpaths
          }
          if {[sizeof $vpaths]>0} { 
            set wns [get_attribute [index_coll $vpaths 0] slack]
          } else { set wns 0.0 }
          set wns [expr {double($wns)}]
          set nvp [sizeof $vpaths]
          set slacks [get_attribute $vpaths slack]
          foreach s $slacks {set tns [expr {$tns+$s}] }
        }
        #wnsh
        set wnsh [get_attribute $whpath slack]
        set wnsh [expr {double($wnsh)}]
        lappend group_data $wnsh
        #tnsh and nvph
        set tnsh 0
        set nvph 0
        if {$wnsh<0} {
          if {$pba_flag} {
            redirect /dev/null { set vhpaths [get_timing_paths -pba_mode exhaustive -delay min -group $group_coll -slack_less 0 -max_paths 1000] }
            append_to_coll tvhpaths $vhpaths
          } else {
            redirect /dev/null { set vhpaths [get_timing_paths -delay min -group $group_coll -slack_less 0 -max_paths 25000] }
            append_to_coll tvhpaths $vhpaths
          }
          if {[sizeof $vhpaths]>0} {
            set wnsh [get_attribute [index_coll $vhpaths 0] slack]
          } else { set wnsh 0.0 }
          set wnsh [expr {double($wnsh)}]
          set nvph [sizeof $vhpaths]
          set slacks [get_attribute $vhpaths slack]
          foreach s $slacks {set tnsh [expr {$tnsh+$s}] }
        }
        #designs stats
        set all  [get_cells -hi * -f "is_hierarchical==false"]
        set seqc [sizeof [all_registers]]
        set leaf [expr {[sizeof $all]/1000}]
        #set tnets [sizeof [get_nets -hi *]]
        #foreach area [get_attr $all area] { set cella [expr {$cella+$area}] }
        #group
        set group_data [list $group]
        #for lol and cpl
        lappend group_data 0
        lappend group_data 0
        lappend group_data $wns
        lappend group_data $cp
        lappend group_data $tns
        lappend group_data $nvp
        lappend group_data $wnsh
        lappend group_data $tnsh
        lappend group_data $nvph
        lappend all_group_data $group_data
      }
    }
    echo "\n"
  }

  if {![info exists all_group_data]} {
    echo "Error!! no QoR data found to reformat"
    return
  }
  set maxl 0
  foreach g [lsort -real -index 3 $all_group_data] {
    set l [string length [lindex $g 0]]
    if {$maxl < $l} { set maxl $l }
  }
  set maxl [expr {$maxl+2}]
  if {$maxl < 20} { set maxl 20 }
  set drccol [expr {$maxl-13}]

  for {set i 0} {$i<$maxl} {incr i} { append bar - }

  if {$skew_flag} {
    if {$::timing_remove_clock_reconvergence_pessimism=="false"} {
      echo "WARNING!! crpr is not turned on, skew values reported could be pessimistic"
    }
    echo "Skews numbers reported include any ocv derates, crpr value is close, but may not match report_timing UITE-468"
    if {$::synopsys_program_name != "pt_shell"} {
      echo "Getting setup timing paths for skew analysis"
      redirect /dev/null {set paths [get_timing_paths -slack_less 0 -max_paths 100000] } 
      #workaround to populate crpr values, pre 12.06 ICC
      #set junk [index_collection $paths 0]
      #redirect /dev/null {report_crpr -from [get_attr $junk startpoint] -to [get_attr $junk endpoint]}
    } else { set paths $tvpaths }

    foreach_in_collection p $paths {

      set g [get_attribute [get_attribute -quiet $p path_group] full_name]
      set scenario [get_attribute -quiet $p scenario]
      if {$scenario !=""} { set g ${g}_$scenario }
      set e [get_attribute -quiet $p endpoint_clock_latency]
      set s [get_attribute -quiet $p startpoint_clock_latency]
      set crpr [get_attribute -quiet $p crpr_value]
      if {$::synopsys_program_name == "pt_shell"} { set crpr [get_attribute -quiet $p common_path_pessimism] }

      set skew [expr {$e-$s}]

      if {$skew<0}       { set skew [expr {$skew+$crpr}]
      } elseif {$skew>0} { set skew [expr {$skew-$crpr}]
      } elseif {$skew==0} {}

      if {![info exists g_wns($g)]} { set g_wns($g) $skew }
      if {![info exists g_tns($g)]} { set g_tns($g) $skew } else { set g_tns($g) [expr {$g_tns($g)+$skew}] }
    }

    if {$::synopsys_program_name != "pt_shell"} {
      echo "Getting hold  timing paths for skew analysis"
      redirect /dev/null { set paths [get_timing_paths -slack_less 0 -max_paths 100000 -delay min] }
    } else { set paths $tvhpaths }

    foreach_in_collection p $paths {

      set g [get_attribute [get_attribute -quiet $p path_group] full_name]
      set scenario [get_attribute -quiet $p scenario]
      if {$scenario !=""} { set g ${g}_$scenario }
      set e [get_attribute -quiet $p endpoint_clock_latency]
      set s [get_attribute -quiet $p startpoint_clock_latency]
      set crpr [get_attribute -quiet $p crpr_value]
      if {$::synopsys_program_name == "pt_shell"} { set crpr [get_attribute -quiet $p common_path_pessimism] }

      set skew [expr {$e-$s}]

      if {$skew<0}       { set skew [expr {$skew+$crpr}]
      } elseif {$skew>0} { set skew [expr {$skew-$crpr}]
      } elseif {$skew==0} {}

      if {![info exists g_wnsh($g)]} { set g_wnsh($g) $skew }
      if {![info exists g_tnsh($g)]} { set g_tnsh($g) $skew } else { set g_tnsh($g) [expr {$g_tnsh($g)+$skew}] }
    }

    set tns  0.0
    set nvp  0
    set tnsh 0.0
    set nvph 0

    echo ""
    echo "SKEW      - Skew on WNS Path"
    echo "AVGSKW    - Average Skew on TNS Paths"
    echo "NVP       - No. of Violating Paths"
    echo "FREQ      - Estimated Frequency, not accurate in some cases, multi/half-cycle, etc" 
    echo "WNS(H)    - Hold WNS"
    echo "SKEW(H)   - Skew on Hold WNS Path"
    echo "TNS(H)    - Hold TNS"
    echo "AVGSKW(H) - Average Skew on Hold TNS Paths"
    echo "NVP(H)    - Hold NVP"
    echo ""
    puts $csv "Path Group, WNS, SKEW, TNS, AVGSKW, NVP, FREQ, WNS(H), SKEW(H), TNS(H), AVGSKW(H), NVP(H)"
    echo [format "%-${maxl}s % 10s % 10s % 10s % 10s % 7s % 9s    % 8s % 10s % 10s % 10s % 7s" \
    "Path Group" "WNS" "SKEW" "TNS" "AVGSKW" "NVP" "FREQ" "WNS(H)" "SKEW(H)" "TNS(H)" "AVGSKW(H)" "NVP(H)"]
    echo "${bar}-------------------------------------------------------------------------------------------------------------------"

    foreach g [lsort -real -index 3 $all_group_data] {

      set wns  [expr {double([lindex $g 3])}]
      set per  [expr {double([lindex $g 4])}]
      if {$wns >= $per} { set freq 0.0
      } else {
        if {$uncert_flag} {
          set freq [expr {1.0/($per-$wns-$signoff_uncert)*$unit}]
        } else {
          set freq [expr {1.0/($per-$wns)*$unit}] 
        }
      }
      if {![info exists wfreq]} { set wfreq $freq }

      if {![info exists g_wns([lindex $g 0])]} { 
        set g_wns([lindex $g 0]) 0.0
        set g_tns([lindex $g 0]) 0.0
      } else {
        set g_tns([lindex $g 0]) [expr {$g_tns([lindex $g 0])/[lindex $g 6]}]
        if {![info exists maxskew]} { set maxskew $g_wns([lindex $g 0]) }
        if {![info exists maxavg]} { set maxavg $g_tns([lindex $g 0]) }
        if {$maxskew>$g_wns([lindex $g 0])} { set maxskew $g_wns([lindex $g 0]) }
        if {$maxavg>$g_tns([lindex $g 0])} { set maxavg $g_tns([lindex $g 0]) }
      }

      if {![info exists g_wnsh([lindex $g 0])]} { 
        set g_wnsh([lindex $g 0]) 0.0
        set g_tnsh([lindex $g 0]) 0.0
      } else {
        set g_tnsh([lindex $g 0]) [expr {$g_tnsh([lindex $g 0])/[lindex $g 9]}]
        if {![info exists maxskewh]} { set maxskewh $g_wnsh([lindex $g 0]) }
        if {![info exists maxavgh]} { set maxavgh $g_tnsh([lindex $g 0]) }
        if {$maxskewh<$g_wnsh([lindex $g 0])} { set maxskewh $g_wnsh([lindex $g 0]) }
        if {$maxavgh<$g_tnsh([lindex $g 0])} { set maxavgh $g_tnsh([lindex $g 0]) }
      }

      puts $csv "[lindex $g 0], \
[lindex $g 3], \
$g_wns([lindex $g 0]), \
[format "%.1f" [lindex $g 5]], \
$g_tns([lindex $g 0]), \
[lindex $g 6], \
[format "%.0fMHz" $freq], \
[lindex $g 7], \
$g_wnsh([lindex $g 0]), \
[format "%.1f" [lindex $g 8]], \
$g_tnsh([lindex $g 0]), \
[lindex $g 9] \
"

      if {!$no_pg_flag} {
        echo [format "%-${maxl}s % 10.3f % 10.3f % 10.1f % 10.3f % 7.0f % 7.0fMHz % 10.3f % 10.3f % 10.1f % 10.3f % 7.0f" \
        [lindex $g 0] \
        [lindex $g 3] \
        $g_wns([lindex $g 0]) \
        [lindex $g 5] \
        $g_tns([lindex $g 0]) \
        [lindex $g 6] \
        $freq         \
        [lindex $g 7] \
        $g_wnsh([lindex $g 0]) \
        [lindex $g 8] \
        $g_tnsh([lindex $g 0]) \
        [lindex $g 9] \
        ]
      }

      set tns  [expr {$tns+[lindex $g 5]}]
      set nvp  [expr {$nvp+[lindex $g 6]}]
      set tnsh [expr {$tnsh+[lindex $g 8]}]
      set nvph [expr {$nvph+[lindex $g 9]}]

    }
    #if total tns/nvp read from report_qor then use them
    if {[info exists setup_tns]} { set tns $setup_tns }
    if {[info exists setup_nvp]} { set nvp $setup_nvp }
    if {[info exists hold_tns]} { set tnsh $hold_tns }
    if {[info exists hold_nvp]} { set nvph $hold_nvp }

    if {![info exists maxskew]} { set maxskew 0.0 }
    if {![info exists maxavg]} { set maxavg 0.0 }
    if {![info exists maxskewh]} { set maxskewh 0.0 }
    if {![info exists maxavgh]} { set maxavgh 0.0 }
    if {!$no_pg_flag} {
      echo "${bar}-------------------------------------------------------------------------------------------------------------------"
    }

    set wwns  [lindex [lindex [lsort -real -index 3 $all_group_data] 0] 3]
    set wwnsh [lindex [lindex [lsort -real -index 7 $all_group_data] 0] 7]
  
    puts $csv "Summary, $wwns, $maxskew, [format "%.1f" $tns], $maxavg, $nvp, [format "%.0fMHz" $wfreq], $wwnsh, $maxskewh, [format "%.1f" $tnsh], $maxavgh, $nvph"

    echo [format "%-${maxl}s % 10.3f % 10.3f % 10.1f % 10.3f % 7.0f % 7.0fMHz % 10.3f % 10.3f % 10.1f % 10.3f % 7.0f" \
    "Summary" "$wwns" "$maxskew" "$tns" "$maxavg" "$nvp" "$wfreq" "$wwnsh" "$maxskewh" "$tnsh" "$maxavgh" "$nvph"]
    echo "${bar}-------------------------------------------------------------------------------------------------------------------"

    puts $csv "CAP, FANOUT, TRAN, TDRC, CELLA, BUFS, LEAFS, TNETS, CTBUF, REGS"

    echo [format "% 7s % 7s % 7s % ${drccol}s % 10s % 10s % 10s % 7s % 10s % 10s" \
     "CAP" "FANOUT" "TRAN" "TDRC" "CELLA" "BUFS" "LEAFS" "TNETS" "CTBUF" "REGS"]
    echo "${bar}-------------------------------------------------------------------------------------------------------------------"

    puts $csv "$cap, $fan, $tran, $drc, $cella, ${buf}K, ${leaf}K, ${tnets}K, $cbuf, $seqc"

    echo [format "% 7s % 7s % 7s % ${drccol}s % 10s % 9sK % 9sK % 6sK % 10s % 10s" \
     $cap $fan $tran $drc $cella $buf $leaf $tnets $cbuf $seqc]
    echo "${bar}-------------------------------------------------------------------------------------------------------------------"

  } else {

    set tns  0.0
    set nvp  0
    set tnsh 0.0
    set nvph 0

     echo ""
     echo "NVP    - No. of Violating Paths"
     echo "FREQ   - Estimated Frequency, not accurate in some cases, multi/half-cycle, etc"
     echo "WNS(H) - Hold WNS"
     echo "TNS(H) - Hold TNS"
     echo "NVP(H) - Hold NVP"
     echo ""
     puts $csv "Path Group, WNS, TNS, NVP, FREQ, WNS(H), TNS(H), NVP(H)"
     echo [format "%-${maxl}s % 10s % 10s % 7s % 9s    % 8s % 10s % 7s" \
    "Path Group" "WNS" "TNS" "NVP" "FREQ" "WNS(H)" "TNS(H)" "NVP(H)"]
    echo "${bar}-----------------------------------------------------------------------"
  
    foreach g [lsort -real -index 3 $all_group_data] {
  
      set wns  [expr {double([lindex $g 3])}]
      set per  [expr {double([lindex $g 4])}]
      if {$wns >= $per} { set freq 0.0
      } else {
        if {$uncert_flag} {
          set freq [expr {1.0/($per-$wns-$signoff_uncert)*$unit}]
        } else {
          set freq [expr {1.0/($per-$wns)*$unit}] 
        }
      }
      if {![info exists wfreq]} { set wfreq $freq }
  
      puts $csv "[lindex $g 0], \
[lindex $g 3], \
[format "%.1f" [lindex $g 5]], \
[lindex $g 6], \
[format "%.0fMHz" $freq], \
[lindex $g 7], \
[format "%.1f" [lindex $g 8]], \
[lindex $g 9] \
"

      if {!$no_pg_flag} {
        echo [format "%-${maxl}s % 10.3f % 10.1f % 7.0f % 7.0fMHz % 10.3f % 10.1f % 7.0f" \
        [lindex $g 0] \
        [lindex $g 3] \
        [lindex $g 5] \
        [lindex $g 6] \
        $freq         \
        [lindex $g 7] \
        [lindex $g 8] \
        [lindex $g 9] \
        ]
      }
  
      set tns  [expr {$tns+[lindex $g 5]}]
      set nvp  [expr {$nvp+[lindex $g 6]}]
      set tnsh [expr {$tnsh+[lindex $g 8]}]
      set nvph [expr {$nvph+[lindex $g 9]}]
  
    }

    #if total tns/nvp read from report_qor then use them
    if {[info exists setup_tns]} { set tns $setup_tns }
    if {[info exists setup_nvp]} { set nvp $setup_nvp }
    if {[info exists hold_tns]} { set tnsh $hold_tns }
    if {[info exists hold_nvp]} { set nvph $hold_nvp }

    if {!$no_pg_flag} {
      echo "${bar}-----------------------------------------------------------------------"
    }

    set wwns  [lindex [lindex [lsort -real -index 3 $all_group_data] 0] 3]
    set wwnsh [lindex [lindex [lsort -real -index 7 $all_group_data] 0] 7]
  
    puts $csv "Summary, $wwns, [format "%.1f" $tns], $nvp, [format "%.0fMHz" $wfreq], $wwnsh, [format "%.1f" $tnsh], $nvph"

    echo [format "%-${maxl}s % 10.3f % 10.1f % 7.0f % 7.0fMHz % 10.3f % 10.1f % 7.0f" \
    "Summary" "$wwns" "$tns" "$nvp" "$wfreq" "$wwnsh" "$tnsh" "$nvph"]
    echo "${bar}-----------------------------------------------------------------------"

    puts $csv "CAP, FANOUT, TRAN, TDRC, CELLA, BUFS, LEAFS, TNETS, CTBUF, REGS"

    echo [format "% 7s % 7s % 7s % ${drccol}s % 10s % 7s % 9s % 11s % 10s % 7s" \
     "CAP" "FANOUT" "TRAN" "TDRC" "CELLA" "BUFS" "LEAFS" "TNETS" "CTBUF" "REGS"]
    echo "${bar}-----------------------------------------------------------------------"

    puts $csv "$cap, $fan, $tran, $drc, $cella, ${buf}K, ${leaf}K, ${tnets}K, $cbuf, $seqc"

    echo [format "% 7s % 7s % 7s % ${drccol}s % 10s % 6sK % 8sK % 10sK % 10s % 7s" \
     $cap $fan $tran $drc $cella $buf $leaf $tnets $cbuf $seqc]
    echo "${bar}-----------------------------------------------------------------------"

  }
  close $csv
  if {$::synopsys_program_name == "pt_shell"} { set ::timing_report_unconstrained_paths $uncons ; if {$pba_flag} { set ::pba_exhaustive_endpoint_path_limit $elimit } }
  echo "Written $csv_file"

  if {!$file_flag&&$hist_flag} { proc_histogram }

}

define_proc_attributes proc_qor -info "USER PROC: reformats report_qor" \
          -define_args {
          {-histogram "Optional - Prints text histogram for setup corner" "" boolean optional}
          {-existing_qor_file "Optional - Existing report_qor file to reformat" "<report_qor file>" string optional}
          {-scenarios "Optional - report qor on specified set of scenarios, skip on inactive scenarios" "{ scenario_name1 scenario_name2 ... }" string optional}
          {-no_pathgroup_info "Optional - to suppress individual pathgroup info" "" boolean optional}
          {-skew     "Optional - reports skew and avg skew on failing path groups" "" boolean optional}
          {-csv_file "Optional - Output csv file name, default is qor.csv" "<output csv file>" string optional}
          {-units    "Optional - override the automatic units calculation" "<ps or ns>" one_of_string {optional value_help {values {ps ns}}}}
          {-pba      "Optional - to run exhaustive pba when in PrimeTime" "" boolean optional}
          {-signoff_uncertainty_adjustment "Optional - adjusts ONLY the frequency column with signoff uncertainty, default 0." "" float optional}
          }

#################################################
#Author Narendra Akilla
#Applications Consultant
#Company Synopsys Inc.
#Not for Distribution without Consent of Synopsys
#################################################

#Version 1.1

proc proc_compare_qor {args} {

#######################
#SUB PROC
#######################

proc proc_myformat {file} {

  set tmp [open $file "r"]
  set x [read $tmp]
  close $tmp
  set start_flag 0

  foreach line [split $x "\n"] {
 
    #skip lines until the table
    if {!$start_flag} { if {![regexp {^\s*Path Group\s+WNS\s+} $line match]} { continue } }
    if {[regexp {^\s*Starting\s+Histogram} $line]} { break}

    if {[regexp {^\s*Path Group\s+WNS\s+} $line match]} {
      set start_flag 1
    } elseif {[regexp {^\s*CAP\s+FANOUT\s+TRAN\s+} $line match]} {
    } elseif {[regexp {^\s*Summary\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)} $line match wwns ttns tnvp wfreq wwnsh ttnsh tnvph]} {
      set summary [list total $wwns $ttns $tnvp $wfreq $wwnsh $ttnsh $tnvph]
    } elseif {[regexp {^\s*\S+\s+\S+\s+\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)} $line match drc cella buf leaf tnets cbuf seqc]} {
      set stat [list $drc $cella $buf $leaf $cbuf $seqc $tnets]
    } elseif {[regexp {^\s*(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)} $line match group wns tns nvp freq wnsh tnsh nvph]} {
      lappend all_group_data [list $group $wns $tns $nvp $freq $wnsh $tnsh $nvph]
    }

  }

  if {![info exists all_group_data]} { echo "Error!! Unsupported QoR file $file, provide report_qor or proc_qor outputs only. No csv or other formats. Exiting" ; return 0 }

  return [list $all_group_data $summary $stat]

}

proc proc_myskewformat {file} {

  set tmp [open $file "r"]
  set x [read $tmp]
  close $tmp
  set start_flag 0

  foreach line [split $x "\n"] {

    #skip lines until the table
    if {!$start_flag} { if {![regexp {^\s*Path Group\s+WNS\s+} $line match]} { continue } }
    if {[regexp {^\s*Starting\s+Histogram} $line]} { break}

    if {[regexp {^\s*Path Group\s+WNS\s+} $line match]} {
      set start_flag 1
    } elseif {[regexp {^\s*CAP\s+FANOUT\s+TRAN\s+} $line match]} {
    } elseif {[regexp {^\s*Summary\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)} $line match wwns maxskew ttns maxavgskew tnvp wfreq wwnsh maxskewh ttnsh maxavgskewh tnvph]} {
      set summary [list total $wwns $maxskew $ttns $maxavgskew $tnvp $wfreq $wwnsh $maxskewh $ttnsh $maxavgskewh $tnvph]
    } elseif {[regexp {^\s*(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)} $line match group wns skew tns avgskew nvp freq wnsh skewh tnsh avgskewh nvph]} {
      lappend all_group_data [list $group $wns $skew $tns $avgskew $nvp $freq $wnsh $skewh $tnsh $avgskewh $nvph]
    } elseif {[regexp {^\s*\S+\s+\S+\s+\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)} $line match drc cella buf leaf tnets cbuf seqc]} {
      set stat [list $drc $cella $buf $leaf $cbuf $seqc $tnets]
    }

  }

  if {![info exists all_group_data]} { echo "Error!! QoR data not found in given files, provide only report_qor or proc_qor outputs. Exiting" ; return 0 }

  return [list $all_group_data $summary $stat]

}

#######################
#END OF SUB PROC
#######################

parse_proc_arguments -args $args results

set unit_flag [info exists results(-units)]
if {[info exists results(-units)]} {set unit $results(-units)}
if {[info exists results(-csv_file)]} {set csv_file $results(-csv_file)} else { set csv_file "compare_qor.csv" }

if {(!$unit_flag)} {
  catch {redirect -var y {report_units}}
  regexp {Second\((\S+)\)\n} $y match unit
}

if {![info exists unit]} { set unit ns }

set file_list $results(-qor_file_list)
if {[info exists results(-tag_list)]} { 
  set tag_list  $results(-tag_list) 
} else {
  set i 0 
  foreach file $file_list { lappend tag_list "qor_$i" ; incr i }
}

if {[llength $file_list] != [llength $tag_list]} { return "-tag_list and -qor_file_list should have same number of elements" }

if {[llength $file_list] <2} { return "Need atleast 2 files" }
if {[llength $file_list] >6} { return "Supports only upto 6 files" }

foreach file $file_list { if {![file exists $file]} { return "Given file $file does not exist" } }


set i 0
set skew_flag 0
foreach file $file_list {

  if {![catch {exec grep "Path Group.*AVGSKW" $file}]} {
    set skew_flag 1
    set qor_data($i) [proc_myskewformat $file]
  } elseif {![catch {exec grep "Path Group.*WNS" $file}]} {
    set qor_data($i) [proc_myformat $file]
  } else {
    proc_qor -existing_qor_file $file -units $unit > .junk
    set qor_data($i) [proc_myformat .junk]
    file delete .junk
    file delete qor.csv
  }
  if {[llength $qor_data($i)] !=3} { return "Unable to process $file. Aborting ...." }
  incr i

}

if {![file writable [file dir $csv_file]]} {
  echo "$csv_file not writable, Writing to /dev/null instead"
  set csv_file "/dev/null"
}
set csv [open $csv_file "w"]

foreach ref_grps [lindex $qor_data(0) 0] {
  foreach e [list $ref_grps] { lappend ref_grp_list [lindex $e 0] }
}

foreach f [lsort -integer [array names qor_data]] {
  foreach grps_of_f [lindex $qor_data($f) 0] {
    foreach grp [list $grps_of_f]  {
      lappend all_grp_list [lindex $grp 0]
      set entry ${f}_[lindex $grp 0]
      if {$skew_flag} {
        if {[llength $grp]==8} {
          set all_data($entry) "[lindex $grp 1] 0.0 [lindex $grp 2] 0.0 [lindex $grp 3] [lindex $grp 4] [lindex $grp 5] 0.0 [lindex $grp 6] 0.0 [lindex $grp 7]"
        } else {
          set all_data($entry) "[lindex $grp 1] [lindex $grp 2] [lindex $grp 3] [lindex $grp 4] [lindex $grp 5] [lindex $grp 6] [lindex $grp 7] [lindex $grp 8] [lindex $grp 9] [lindex $grp 10] [lindex $grp 11]"
        }
      } else {
        set all_data($entry) "[lindex $grp 1] [lindex $grp 2] [lindex $grp 3] [lindex $grp 4] [lindex $grp 5] [lindex $grp 6] [lindex $grp 7]"
      }
    }
  }
}

set extra_grp_list [lminus [lsort -unique $all_grp_list] $ref_grp_list]

foreach extra $extra_grp_list { lappend ref_grp_list $extra }

set maxl 0
foreach g $ref_grp_list {
  set l [string length [lindex $g 0]]
  if {$maxl < $l} { set maxl $l }
}
set maxl [expr {$maxl+2}]
if {$maxl < 20} { set maxl 20 }
set drccol [expr {$maxl-13}]
for {set i 0} {$i<$maxl} {incr i} { append bar - }

puts -nonewline $csv ","
echo -n [format "%-${maxl}s " ""]

foreach tag $tag_list { puts -nonewline $csv "$tag,";  echo -n [format "% 8s " "$tag"] }

if {$skew_flag} {
foreach tag $tag_list { puts -nonewline $csv "$tag,";  echo -n [format "% 8s " "$tag"] }
} 

foreach tag $tag_list { puts -nonewline $csv "$tag,";  echo -n [format "% 12s " "$tag"] }

if {$skew_flag} {
foreach tag $tag_list { puts -nonewline $csv "$tag,";  echo -n [format "% 8s " "$tag"] }
}

foreach tag $tag_list { puts -nonewline $csv "$tag,";  echo -n [format "% 7s " "$tag"] }

foreach tag $tag_list { puts -nonewline $csv "$tag,";  echo -n [format "% 7s " "$tag"] }

foreach tag $tag_list { puts -nonewline $csv "$tag,";  echo -n [format "% 8s " "$tag"] }

if {$skew_flag} {
foreach tag $tag_list { puts -nonewline $csv "$tag,";  echo -n [format "% 8s " "$tag"] }
}

foreach tag $tag_list { puts -nonewline $csv "$tag,";  echo -n [format "% 12s " "$tag"] }

if {$skew_flag} {
foreach tag $tag_list { puts -nonewline $csv "$tag,";  echo -n [format "% 8s " "$tag"] }
}

foreach tag $tag_list { puts -nonewline $csv "$tag,";  echo -n [format "% 7s " "$tag"] }
puts $csv ""
echo ""

puts -nonewline $csv "Path Group,"

echo -n [format "%-${maxl}s " "Path Group"]
append line "$bar"

foreach f [lsort -integer [array names qor_data]] {
  puts -nonewline $csv "WNS,"
  echo -n [format "% 8s " "WNS"]
  append line "---------"
}

if {$skew_flag} {
  foreach f [lsort -integer [array names qor_data]] {
    puts -nonewline $csv "SKEW,"
    echo -n [format "% 8s " "SKEW"]
    append line "---------"
  }
}

foreach f [lsort -integer [array names qor_data]] {
  puts -nonewline $csv "TNS,"
  echo -n [format "% 12s " "TNS"]
  append line "-------------"
}

if {$skew_flag} {
  foreach f [lsort -integer [array names qor_data]] {
    puts -nonewline $csv "AVGSKEW,"
    echo -n [format "% 8s " "AVGSKEW"]
    append line "---------"
  }
}

foreach f [lsort -integer [array names qor_data]] {
  puts -nonewline $csv "NVP,"
  echo -n [format "% 7s " "NVP"]
  append line "--------"
}

foreach f [lsort -integer [array names qor_data]] {
  puts -nonewline $csv "FREQ,"
  echo -n [format "% 7s " "FREQ"]
  append line "--------"
}

foreach f [lsort -integer [array names qor_data]] {
  puts -nonewline $csv "WNSH,"
  echo -n [format "% 8s " "WNSH"]
  append line "---------"
}

if {$skew_flag} {
  foreach f [lsort -integer [array names qor_data]] {
    puts -nonewline $csv "SKEWH,"
    echo -n [format "% 8s " "SKEWH"]
    append line "---------"
  }
}

foreach f [lsort -integer [array names qor_data]] {
  puts -nonewline $csv "TNSH,"
  echo -n [format "% 12s " "TNSH"]
  append line "-------------"
}

if {$skew_flag} {
  foreach f [lsort -integer [array names qor_data]] {
    puts -nonewline $csv "AVGSKEWH,"
    echo -n [format "% 8s " "AVGSKEWH"]
    append line "---------"
  }
}

foreach f [lsort -integer [array names qor_data]] {
  puts -nonewline $csv "NVPH,"
  echo -n [format "% 7s " "NVPH"]
  append line "--------"
}

#unindented if
if {$skew_flag} {

puts -nonewline $csv "\n"
echo -n "\n$line"

foreach ref_grp $ref_grp_list {

  #name
  puts -nonewline $csv "\n$ref_grp,"
  echo -n [format "\n%-${maxl}s " $ref_grp]

  #wns
  foreach f [lsort -integer [array names qor_data]] {
    set entry ${f}_$ref_grp
    if {[info exists all_data($entry)]} { set value [format "% 8.3f " [lindex $all_data($entry) 0]] } else { set value [format "% 8s " NA] }
    puts -nonewline $csv "$value,"
    echo -n $value
  }

  #skew 
  foreach f [lsort -integer [array names qor_data]] {
    set entry ${f}_$ref_grp
    if {[info exists all_data($entry)]} { set value [format "% 8.3f " [lindex $all_data($entry) 1]] } else { set value [format "% 8s " NA] }
    puts -nonewline $csv "$value," 
    echo -n $value
  }

  #tns
  foreach f [lsort -integer [array names qor_data]] {
    set entry ${f}_$ref_grp
    if {[info exists all_data($entry)]} { set value [format "% 12.1f " [lindex $all_data($entry) 2]] } else { set value [format "% 12s " NA] }
    puts -nonewline $csv "$value,"
    echo -n $value
  }

  #avgskew
  foreach f [lsort -integer [array names qor_data]] {
    set entry ${f}_$ref_grp
    if {[info exists all_data($entry)]} { set value [format "% 8.3f " [lindex $all_data($entry) 3]] } else { set value [format "% 8s " NA] }
    puts -nonewline $csv "$value," 
    echo -n $value
  } 

  #nvp
  foreach f [lsort -integer [array names qor_data]] {
    set entry ${f}_$ref_grp
    if {[info exists all_data($entry)]} { set value [format "% 7.0f " [lindex $all_data($entry) 4]] } else { set value [format "% 7s " NA] }
    puts -nonewline $csv "$value,"
    echo -n $value
  }

  #freq
  foreach f [lsort -integer [array names qor_data]] {
    set entry ${f}_$ref_grp
    if {[info exists all_data($entry)]} { set value [format "% 7s " [lindex $all_data($entry) 5]] } else { set value [format "% 7s " NA] }
    puts -nonewline $csv "$value,"
    echo -n $value
  }

  #wnsh
  foreach f [lsort -integer [array names qor_data]] {
    set entry ${f}_$ref_grp
    if {[info exists all_data($entry)]} { set value [format "% 8.3f " [lindex $all_data($entry) 6]] } else { set value [format "% 8s " NA] }
    puts -nonewline $csv "$value,"
    echo -n $value
  }

  #skewh
  foreach f [lsort -integer [array names qor_data]] {
    set entry ${f}_$ref_grp
    if {[info exists all_data($entry)]} { set value [format "% 8.3f " [lindex $all_data($entry) 7]] } else { set value [format "% 8s " NA] }
    puts -nonewline $csv "$value,"
    echo -n $value
  }

  #tnsh
  foreach f [lsort -integer [array names qor_data]] {
    set entry ${f}_$ref_grp
    if {[info exists all_data($entry)]} { set value [format "% 12.1f " [lindex $all_data($entry) 8]] } else { set value [format "% 12s " NA] }
    puts -nonewline $csv "$value,"
    echo -n $value
  }

  #avgskewh
  foreach f [lsort -integer [array names qor_data]] {
    set entry ${f}_$ref_grp
    if {[info exists all_data($entry)]} { set value [format "% 8.3f " [lindex $all_data($entry) 9]] } else { set value [format "% 8s " NA] }
    puts -nonewline $csv "$value,"
    echo -n $value
  }

  #nvph
  foreach f [lsort -integer [array names qor_data]] {
    set entry ${f}_$ref_grp
    if {[info exists all_data($entry)]} { set value [format "% 7.0f " [lindex $all_data($entry) 10]] } else { set value [format "% 7s " NA] }
    puts -nonewline $csv "$value,"
    echo -n $value
  }

}
puts $csv ""
echo "\n$line" 
puts -nonewline $csv "Summary,"
echo -n [format "%-${maxl}s " "Summary"]

foreach f [lsort -integer [array names qor_data]] {
    set qor_total($f) [lindex $qor_data($f) 1]
  if {[llength $qor_total($f)]<12} {
    set qor_total($f) "[lindex $qor_total($f) 0] [lindex $qor_total($f) 1] 0.0 [lindex $qor_total($f) 2] 0.0 [lindex $qor_total($f) 3] [lindex $qor_total($f) 4] [lindex $qor_total($f) 5] 0.0 [lindex $qor_total($f) 6] 0.0 [lindex $qor_total($f) 7]"
  }
}

#twns
foreach f [lsort -integer [array names qor_data]] { echo -n [format "% 8.3f " [lindex $qor_total($f) 1]] ; puts -nonewline $csv "[lindex $qor_total($f) 1]," }

#maxskew
foreach f [lsort -integer [array names qor_data]] { echo -n [format "% 8.3f " [lindex $qor_total($f) 2]] ; puts -nonewline $csv "[lindex $qor_total($f) 2]," }

#ttns
foreach f [lsort -integer [array names qor_data]] { echo -n [format "% 12.1f " [lindex $qor_total($f) 3]] ; puts -nonewline $csv "[lindex $qor_total($f) 3]," }

#maxavgskew
foreach f [lsort -integer [array names qor_data]] { echo -n [format "% 8.3f " [lindex $qor_total($f) 4]] ; puts -nonewline $csv "[lindex $qor_total($f) 4]," }

#tnvp
foreach f [lsort -integer [array names qor_data]] { echo -n [format "% 7.0f " [lindex $qor_total($f) 5]] ; puts -nonewline $csv "[lindex $qor_total($f) 5]," }

#tfreq
foreach f [lsort -integer [array names qor_data]] { echo -n [format "% 7s " [lindex $qor_total($f) 6]] ; puts -nonewline $csv "[lindex $qor_total($f) 6]," }

#twnsh
foreach f [lsort -integer [array names qor_data]] { echo -n [format "% 8.3f " [lindex $qor_total($f) 7]] ; puts -nonewline $csv "[lindex $qor_total($f) 7]," }

#maxskewh
foreach f [lsort -integer [array names qor_data]] { echo -n [format "% 8.3f " [lindex $qor_total($f) 8]] ; puts -nonewline $csv "[lindex $qor_total($f) 8]," }

#ttnsh
foreach f [lsort -integer [array names qor_data]] { echo -n [format "% 12.1f " [lindex $qor_total($f) 9]] ; puts -nonewline $csv "[lindex $qor_total($f) 9]," }

#maxavgskewh
foreach f [lsort -integer [array names qor_data]] { echo -n [format "% 8.3f " [lindex $qor_total($f) 10]] ; puts -nonewline $csv "[lindex $qor_total($f) 10]," }

#tnvph
foreach f [lsort -integer [array names qor_data]] { echo -n [format "% 7.0f " [lindex $qor_total($f) 11]] ; puts -nonewline $csv "[lindex $qor_total($f) 11]," }

puts $csv ""
echo "\n$line"

#unindented else
} else {
#if no skew flag

puts -nonewline $csv "\n"
echo -n "\n$line"

foreach ref_grp $ref_grp_list {

  #name
  puts -nonewline $csv "\n$ref_grp,"
  echo -n [format "\n%-${maxl}s " $ref_grp]

  #wns
  foreach f [lsort -integer [array names qor_data]] {
    set entry ${f}_$ref_grp
    if {[info exists all_data($entry)]} { set value [format "% 8.3f " [lindex $all_data($entry) 0]] } else { set value [format "% 8s " NA] }
    puts -nonewline $csv "$value,"
    echo -n $value
  }

  #tns
  foreach f [lsort -integer [array names qor_data]] {
    set entry ${f}_$ref_grp
    if {[info exists all_data($entry)]} { set value [format "% 12.1f " [lindex $all_data($entry) 1]] } else { set value [format "% 12s " NA] }
    puts -nonewline $csv "$value,"
    echo -n $value
  }

  #nvp
  foreach f [lsort -integer [array names qor_data]] {
    set entry ${f}_$ref_grp
    if {[info exists all_data($entry)]} { set value [format "% 7.0f " [lindex $all_data($entry) 2]] } else { set value [format "% 7s " NA] }
    puts -nonewline $csv "$value,"
    echo -n $value
  }

  #freq
  foreach f [lsort -integer [array names qor_data]] {
    set entry ${f}_$ref_grp
    if {[info exists all_data($entry)]} { set value [format "% 7s " [lindex $all_data($entry) 3]] } else { set value [format "% 7s " NA] }
    puts -nonewline $csv "$value,"
    echo -n $value
  }

  #wnsh
  foreach f [lsort -integer [array names qor_data]] {
    set entry ${f}_$ref_grp
    if {[info exists all_data($entry)]} { set value [format "% 8.3f " [lindex $all_data($entry) 4]] } else { set value [format "% 8s " NA] }
    puts -nonewline $csv "$value,"
    echo -n $value
  }

  #tnsh
  foreach f [lsort -integer [array names qor_data]] {
    set entry ${f}_$ref_grp
    if {[info exists all_data($entry)]} { set value [format "% 12.1f " [lindex $all_data($entry) 5]] } else { set value [format "% 12s " NA] }
    puts -nonewline $csv "$value,"
    echo -n $value
  }

  #nvph
  foreach f [lsort -integer [array names qor_data]] {
    set entry ${f}_$ref_grp
    if {[info exists all_data($entry)]} { set value [format "% 7.0f " [lindex $all_data($entry) 6]] } else { set value [format "% 7s " NA] }
    puts -nonewline $csv "$value,"
    echo -n $value
  }

}
puts $csv ""
echo "\n$line" 
puts -nonewline $csv "Summary,"
echo -n [format "%-${maxl}s " "Summary"]

foreach f [lsort -integer [array names qor_data]] {
  set qor_total($f) [lindex $qor_data($f) 1]
}

#twns
foreach f [lsort -integer [array names qor_data]] { echo -n [format "% 8.3f " [lindex $qor_total($f) 1]] ; puts -nonewline $csv "[lindex $qor_total($f) 1]," }

#ttns
foreach f [lsort -integer [array names qor_data]] { echo -n [format "% 12.1f " [lindex $qor_total($f) 2]] ; puts -nonewline $csv "[lindex $qor_total($f) 2],"}

#tnvp
foreach f [lsort -integer [array names qor_data]] { echo -n [format "% 7.0f " [lindex $qor_total($f) 3]] ; puts -nonewline $csv "[lindex $qor_total($f) 3]," }

#tfreq
foreach f [lsort -integer [array names qor_data]] { echo -n [format "% 7s " [lindex $qor_total($f) 4]] ; puts -nonewline $csv "[lindex $qor_total($f) 4]," }

#twnsh
foreach f [lsort -integer [array names qor_data]] { echo -n [format "% 8.3f " [lindex $qor_total($f) 5]] ; puts -nonewline $csv "[lindex $qor_total($f) 5]," }

#ttnsh
foreach f [lsort -integer [array names qor_data]] { echo -n [format "% 12.1f " [lindex $qor_total($f) 6]] ; puts -nonewline $csv "[lindex $qor_total($f) 6]," }

#tnvph
foreach f [lsort -integer [array names qor_data]] { echo -n [format "% 7.0f " [lindex $qor_total($f) 7]] ; puts -nonewline $csv "[lindex $qor_total($f) 7]," }

puts $csv ""
echo "\n$line"

}
#end unindented no skew flag

puts -nonewline $csv " ,"
echo -n [format "%-${maxl}s " " "]
foreach tag $tag_list { puts -nonewline $csv "$tag,";  echo -n [format "% 8s " "$tag"] }
foreach tag $tag_list { puts -nonewline $csv "$tag,";  echo -n [format "% 12s " "$tag"] }
foreach tag $tag_list { puts -nonewline $csv "$tag,";  echo -n [format "% 7s " "$tag"] }
foreach tag $tag_list { puts -nonewline $csv "$tag,";  echo -n [format "% 7s " "$tag"] }
foreach tag $tag_list { puts -nonewline $csv "$tag,";  echo -n [format "% 8s " "$tag"] }
foreach tag $tag_list { puts -nonewline $csv "$tag,";  echo -n [format "% 12s " "$tag"] }
foreach tag $tag_list { puts -nonewline $csv "$tag,";  echo -n [format "% 7s " "$tag"] }
puts $csv ""
echo ""

puts -nonewline $csv " ,"
echo -n [format "%-${maxl}s " " "]

foreach f [lsort -integer [array names qor_data]] {
  puts -nonewline $csv "DRC,"
  echo -n [format "% 8s " "DRC"]
}

foreach f [lsort -integer [array names qor_data]] {
  puts -nonewline $csv "CELLA,"
  echo -n [format "% 12s " "CELLA"]
}

foreach f [lsort -integer [array names qor_data]] {
  puts -nonewline $csv "BUF,"
  echo -n [format "% 7s " "BUF"]
}

foreach f [lsort -integer [array names qor_data]] {
  puts -nonewline $csv "LEAF,"
  echo -n [format "% 7s " "LEAF"]
}

foreach f [lsort -integer [array names qor_data]] {
  puts -nonewline $csv "CBUFS,"
  echo -n [format "% 8s " "CBUFS"]
}

foreach f [lsort -integer [array names qor_data]] {
  puts -nonewline $csv "REGS,"
  echo -n [format "% 12s " "REGS"]
}

foreach f [lsort -integer [array names qor_data]] {
  puts -nonewline $csv "NETS,"
  echo -n [format "% 7s " "NETS"]
}

puts $csv ""
echo "\n$line" 

puts -nonewline $csv ","
echo -n [format "%-${maxl}s " " "]

foreach f [lsort -integer [array names qor_data]] {
  set qor_stat($f) [lindex $qor_data($f) 2]
}

#drc
foreach f [lsort -integer [array names qor_data]] { echo -n [format "% 8.0f " [lindex $qor_stat($f) 0]] ; puts -nonewline $csv " [lindex $qor_stat($f) 0]," }

#cella
foreach f [lsort -integer [array names qor_data]] { echo -n [format "% 12.0f " [lindex $qor_stat($f) 1]] ; puts -nonewline $csv " [lindex $qor_stat($f) 1]," }

#buf
foreach f [lsort -integer [array names qor_data]] { echo -n [format "% 7s " [lindex $qor_stat($f) 2]] ; puts -nonewline $csv " [lindex $qor_stat($f) 2]," }

#leaf
foreach f [lsort -integer [array names qor_data]] { echo -n [format "% 7s " [lindex $qor_stat($f) 3]] ; puts -nonewline $csv " [lindex $qor_stat($f) 3]," }

#cbuf
foreach f [lsort -integer [array names qor_data]] { echo -n [format "% 8s " [lindex $qor_stat($f) 4]] ; puts -nonewline $csv " [lindex $qor_stat($f) 4]," }

#seqc
foreach f [lsort -integer [array names qor_data]] { echo -n [format "% 12s " [lindex $qor_stat($f) 5]] ; puts -nonewline $csv " [lindex $qor_stat($f) 5]," }

#tnets
foreach f [lsort -integer [array names qor_data]] { echo -n [format "% 7s " [lindex $qor_stat($f) 6]] ; puts -nonewline $csv " [lindex $qor_stat($f) 6]," }

puts $csv ""
echo "\n$line"

close $csv
echo "Written $csv_file\n"
rename proc_myformat ""
rename proc_myskewformat ""
}

define_proc_attributes proc_compare_qor -info "USER PROC: Compares upto 6 report_qor reports" \
	-define_args { 
        {-qor_file_list "Required - List of report_qor files to compare" "<report_qor file list>" string required} 
        {-tag_list "Optional - Tag each QoR report with a name" "<qor file tag list>" string optional} 
        {-csv_file "Optional - Output csv file name, default is compare_qor.csv" "<output csv file>" string optional}
        {-units    "Optional - specify ps to override the default, default uses report_unit or ns" "<ps or ns>" one_of_string {optional value_help {values {ps ns}}}}
        }

echo "\tproc_qor"
echo "\tproc_compare_qor"
echo "\tproc_histogram"

