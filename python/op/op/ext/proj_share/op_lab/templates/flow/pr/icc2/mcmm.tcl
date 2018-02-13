

##########################################################################################
# Script: mcmm_setup
##########################################################################################

puts "Alchip-info : Start MCMM setup\n"

remove_scenarios -all
remove_modes -all
remove_corners -all

##########################################################################################
#                                   !WARNING!                                           ##
# YOU NEEED FILL BELLOW WITH YOUR MODE/CONER NAME                                       ##
##########################################################################################

##################################################################################################################################
#                                   !WARNING!                                                                                   ##
# YOU NEEED FILL BELLOW TABLE ACCORDING TO SCENARIO NUMBER                                                                      ## 
# Example                                                                                                                       ##
#set tech_ndm                          "tech_only";#fill tech_ndm name, example tech_only                                       ##
#set scenario_list                     "func.ss125c                     func.ff125c      test.ss_125"                           ##
#set early_tlu_name_list               "rcworst_CCworst_T               rcworst_CCworst_T rcworst_CCworst_T"                    ##
#set late_tlu_name_list                "rcworst_CCworst_T               rcworst_CCworst_T rcworst_CCworst_T"                    ##
#set temprture_list                    "125                             125                125"                                 ##
#set process_list                      "1                                1                  1"                                  ##
#set sdc_file_list                     "func.ss125c.sdc                 func.ff125c.sdc  test.ss_125.sdc"                       ##
#set aocv_file_list                    "func.ss125c.aocv                func.ff125c.aocv  test.ss_125.aocv"                     ##
#set pocv_file_list                    "func.ss125c.pocv                func.ff125c.pocv  test.ss_125.pocv"                     ##
#set scenario_status_setup             "true                            false             false"                                ##
#set scenario_status_hold              "false                            true              true"                                ##
#set scenario_status_leakage_power     "true                             false             false"                               ## 
#set scenario_status_dynamic_power     "false                            true              false"                               ##
#set scenario_status_max_transition    "true                             true              false"                               ## 
#set scenario_status_max_capacitance   "true                             true              false"                               ##
#set voltage_list                     "{VDD-0.9 VSS-0.0 VDDH-1.16}  {VDD-0.8 VSS-0.0 VDDH-1.16}  {VDD-0.9 VSS-0.0 VDDH-0.95}"   ##
#set global_max_transition_list       " 0.2                               0.2                {} "                               ##
#set global_max_capacitance_list      " 0.2                               0.2                {} "                               ##
#set cts_max_transition_list          " 0.2                               0.2                {} "                               ##
#set cts_max_capacitance_list         " 0.2                               0.2                {} "                               ##
#set data_max_transition_list         " 0.2                               0.2                {} "                               ##
#set data_max_capacitance_list        " 0.2                               0.2                {} "                               ##
##################################################################################################################################

set tech_ndm                           "tech_only";# *fill tech_ndm name, example tech_only,remember it's not tech ndm library path! only tech ndm name is OK.
set scenario_list                      "func.wcl";# *fill scenario table ,example func.ss_125c test.ss_125c, it's restricted to fill as mode.corner for scenario naming style
set early_tlu_name_list                "rcworst_CCworst_T";# *fill early tlu plus name table which is used in tech_only.ndm with set parasitic, example rcworst_CCworst_T
set late_tlu_name_list                 "rcworst_CCworst_T";# *fill late tlu plus name table which is used in tech_only.ndm with set parasitic, example rcworst_CCworst_T
set temprture_list                     "-40";# *fill temprature talbe, example 125 125
set process_list                       "1";# *fill process table, example 1 0.9
set process_label_list                 "";#optional,fill process label table, example fast slow
set sdc_file_list                      "{{env.BLK_SDC}}/{{env.VERSION_SDC}}/{{env.BLK_NAME}}.func.sdc";# *fill sdc table file according to scenario
set aocv_file_list                     "{{liblist.AOCV_TT0P8V_WCL_SETUP}}";#optional,fill acov table file accroding to scenario
set pocv_file_list                     "";#optional,fill pcov file accroding to scenario
set scenario_status_setup              "true";# *fill setup table with true/false
set scenario_status_hold               "false";#optional,fill setup table with true/false
set scenario_status_leakage_power      "false";#optional,fill setup table with true/false
set scenario_status_dynamic_power      "false";#optional,fill setup table with true/false
set scenario_status_max_transition     "true";#optional,fill setup table with true/false
set scenario_status_max_capacitance    "true";#optional,fill setup table with true/false
set voltage_list                       "{VDD-0.72 VSS-0.0}";# *fill voltage1 table, example "{VDD-0.9 VSS-0.0 VDDH-1.16}"
set global_max_transition_list         "0.15";# *global max clock tree transition for current design
set global_max_capacitance_list        "0.12";#optional,global max clock tree capacitance for current design
set cts_max_transition_list            "0.03";# *cts max clock tree transition for all clock
set cts_max_capacitance_list           "";#optional,cts max clock tree capacitance for all clock
set data_max_transition_list           "0.12";# *data path max transition 
set data_max_capacitance_list          "";#optional,data path max capacitance
###############################################
##No need touch bellow                       ##
###############################################
set i_mcmm 0

foreach scenario $scenario_list {
  set mode   [ lindex [ split $scenario "." ] 0 ]
  set corner [ lindex [ split $scenario "." ] 1 ]
  echo "INFO: $mode $corner"
  if { [ sizeof_coll [ get_modes $mode -quiet ] ] == 0 } {
    create_mode $mode
  }
  if { [ sizeof_coll [ get_corners $corner -quiet ] ] == 0 } {
    create_corner $corner
  }
  create_scenario -mode $mode -corner $corner -name $scenario
  current_scenario $scenario
  echo "INFO: Setting scenario $scenario anaysis status"
  echo "$i_mcmm"
  set status_setup              [lindex $scenario_status_setup $i_mcmm]
  set status_hold               [lindex $scenario_status_hold  $i_mcmm]
  set status_leakage_power      [lindex $scenario_status_leakage_power $i_mcmm]
  set status_dynamic_power      [lindex $scenario_status_dynamic_power $i_mcmm]
  set status_max_transition     [lindex $scenario_status_max_transition $i_mcmm]
  set status_max_capacitance    [lindex $scenario_status_max_capacitance $i_mcmm]
 
  set_scenario_status  $scenario -setup $status_setup -hold $status_hold -leakage_power $status_leakage_power -dynamic_power $status_dynamic_power -max_transition $status_max_transition -max_capacitance $status_max_capacitance

  echo "INFO: set additional MCMM constraint in ICCII"
  set temp                       [lindex $temprture_list $i_mcmm]
  set procs                      [lindex $process_list $i_mcmm]
  set procs_l                    [lindex $process_label_list $i_mcmm]
  set early_tlu_name             [lindex $early_tlu_name_list $i_mcmm]
  set late_tlu_name              [lindex $late_tlu_name_list $i_mcmm]
  set sdc_file_name              [lindex $sdc_file_list $i_mcmm]
  if {$aocv_file_list != ""} {
  set aocv_file_name             [lindex $aocv_file_list $i_mcmm]
  } else {
  set aocv_file_name ""
  }
  if {$pocv_file_list != ""} {
  set pocv_file_name             [lindex $pocv_file_list $i_mcmm]
  } else {
  set pocv_file_name ""
  }
  set global_max_transition         [lindex $global_max_transition_list $i_mcmm]
  set global_max_capacitance        [lindex $global_max_capacitance_list $i_mcmm]
  set cts_max_transition            [lindex $cts_max_transition_list $i_mcmm]
  set cts_max_capacitance           [lindex $cts_max_capacitance_list $i_mcmm]
  set data_max_transition           [lindex $data_max_transition_list $i_mcmm]
  set data_max_capacitance          [lindex $data_max_capacitance_list $i_mcmm]
  
  echo "INFO: Setting PVT $temp   $procs,use sdc file $sdc_file_name, aocv table $aocv_file_name, pocv file $pocv_file_name early_tlu $early_tlu_name, late_tlu $late_tlu_name"
  
  if {$temp != ""} {
  set_temperature $temp
  } else {
  echo "Warning: Temprature for scenario $scenario is not set, please fill temprature list table"
  }
  if {$procs != ""} {
  set_process_number    $procs 
  } else {
  echo "Information: Process for scenario $scenario is not set, please fill process list table"
  }
  if {$procs_l != ""} {
  set_process_label    $procs_l 
  } else {
  echo "Information: Process for scenario $scenario is not set, please fill process list table"
  }

  set volt  [lindex $voltage_list $i_mcmm]
  
  foreach volt_l $volt {
  
  if {$volt_l != ""} {
  set voltage_name  [ lindex [ split $volt_l "-" ] 0 ]
  set voltage_value [ lindex [ split $volt_l "-" ] 1 ]
  set_voltage $voltage_value -object_list $voltage_name
  } else {
  echo "Warning: Voltage $voltage_name for scenario $scenario is not set, please fill voltage list table"
  }
  }
  
  echo "INFO: Reading tlupus for corner $corner"
  set_parasitic_parameters -corners $corner -late_spec $late_tlu_name -early_spec $early_tlu_name -library $tech_ndm
  
  if {$sdc_file_name != ""} {
  echo "INFO: source sdc file $sdc_file_name for scenario $scenario"
  source -e -v $sdc_file_name
  } else {
  echo "Warning: sdc file for scenario $scenario doe not exist, please fill sdc file list table"
  }  
  
  if {$aocv_file_name != ""} {
  echo "INFO: source aocv file $aocv_file_name for scenario $scenario"
  read_ocvm -corners $corner "$aocv_file_name"
  } else {
  echo "Information: aocv file for scenario $scenario doe not exist, please fill aocv file list table"
  }

  if {$pocv_file_name != ""} {
  echo "INFO: source pocv file $pocv_file_name for scenario $scenario"
  read_ocvm -corners $corner "$pocv_file_name"
  } else {
  echo "Information: pocv file for scenario $scenario doe not exist, please fill pocv file list table"
  }

  ##max capacitance/max transition
  echo "INFO: set max capacitance/max transition for current scenario $scenario"
  
  if {$global_max_capacitance != ""} {
  set_max_capacitance $global_max_capacitance [current_design]
  }
  if {$global_max_transition != ""} {
  set_max_transition $global_max_transition [current_design]
  }
  if {$data_max_capacitance != ""} {
  set_max_capacitance -data_path $data_max_capacitance [all_clocks]
  }
  if {$data_max_transition != ""} {
  set_max_transition -data_path $data_max_transition [all_clocks]
  }
  if {$cts_max_capacitance != ""} {
  set_max_capacitance -clock_path $cts_max_capacitance [all_clocks]
  }
  if {$cts_max_transition != ""} {
  set_max_transition -clock_path $cts_max_transition [all_clocks]
  }
  

  incr i_mcmm
  echo "$i_mcmm"
}

##########################################
##   Completed MCMM setup               ##
##########################################

puts "Alchip-info : Completed MCMM setup\n"

foreach_in_collection mode [all_modes] {
	current_mode $mode
	remove_propagated_clocks [all_clocks]
	remove_propagated_clocks [get_ports]
	remove_propagated_clocks [get_pins -hierarchical]
}
current_mode 

report_mode

##########################################
##   Completed MCMM setup               ##
##########################################
#source $FLOW_BRANCH_DIR/$BLOCK_NAME.timing_derate.$OP4_dst_branch.icc2
