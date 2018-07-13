
#############################################################################################
# Prime-Time  PX
#############################################################################################

{#
#1. not support upf flow
#2. not support multi-scenario
#3. not support multi-voltage/power-domain power flow
-#}

set pre_stage "{{pre.sub_stage}}"
set cur_stage "{{cur.sub_stage}}"

set pre_stage [lindex [split $pre_stage .] 0]
set cur_stage [lindex [split $cur_stage .] 0]
##==================================================================##
##  Session Setting                                                 ##
##==================================================================##
 set BLOCK_NAME                      "{{env.BLK_NAME}}"
 set SESSION                         "{{local.scenario}}"
 set MODE                            "[lindex [split $SESSION .] 0]"
 set VOLT                            "[lindex [split $SESSION .] 1]"
 set LIB_CORNER                      "[lindex [split $SESSION .] 2]"
 set RC_CORNER                       "[lindex [split $SESSION .] 3]"
 set CHECK_TYPE                      "[lindex [split $SESSION .] 4]"

###==================================================================##
###  source liblist                                                  ##
###==================================================================##
{%- if local.lib_cell_height == "240" %}
source {{env.PROJ_SHARE_CMN}}/process_strategy/liblist/liblist_6T.tcl
{%- elif local.lib_cell_height == "300" %}
source {{env.PROJ_SHARE_CMN}}/process_strategy/liblist/liblist_7d5T.tcl
{%- endif %}

###==================================================================##
## Design Data Setting                                               ##
##===================================================================##
 set TOP                                     "{{env.BLK_NAME}}"
 set CPU_NUM                                 "[lindex "{{local._job_cpu_number}}" end]"
 set MV_DESIGN                               "{{local.mv_design}}"
 set BLOCK_DESIGN_NAMES                      "{{local.sub_block_names}}"
 set BBOX		     	                     "{{local.link_bbox}}" 		
 set ANNOTATED_FILE_FORMAT                   "{{local.annotated_file_format}}" 
 set BLOCK_RELEASE_DIR                       "{{local.block_release_dir}}" 
 set POWER_ANALYSIS_MODE                     "{{local.power_analysis_mode}}"

###==================================================================##
## Power analysis Setting                                            ##
##===================================================================##
set DATA_TOGGLE_RATE                          "{{local.data_toggle_rate}}"          
set CLOCK_TOGGLE_RATE                         "{{local.clock_toggle_rate}}"          
set PTPX_SWITCH_ACTIVITY_FILE                 "{{local.ptpx_switch_activity_file}}"          
set PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH      "{{local.ptpx_switch_activity_file_strip_path}}"          
set PTPX_SWITCH_ACTIVITY_FILE_PATH            "{{local.ptpx_switch_activity_file_path}}"          
set PTPX_SWITCH_ACTIVITY_FILE_TIME_RANGE      "{{local.ptpx_switch_activity_file_time_range}}"          
set PTPX_SWITCH_ACTIVITY_FILE_FORMAT          "{{local.ptpx_switch_activity_file_format}}"          
set PTPX_SWITCH_ACTIVITY_FILE_NAME_MAP_FILE   "{{local.ptpx_switch_activity_file_name_map_file}}"          
set PTPX_SWITCH_ACTIVITY_FILE_ZERO_DELAY      "{{local.ptpx_switch_activity_file_zero_delay}}"           

###==================================================================##
## Netlist Check                                                     ##
##===================================================================##
 set check_flag 0
 set VNET_LIST  "{{pre.flow_data_dir}}/{{pre.stage}}/{{local.scenario}}/{{pre.stage}}.{{env.BLK_NAME}}.pt.v.gz"
 if {$BLOCK_DESIGN_NAMES != ""} {
     foreach block_name $BLOCK_DESIGN_NAMES {
        set vnet "${block_release_dir}/netlist/${block_name}.pt.v"
        lappend VNET_LIST  $vnet 
     }
 } else {
 }
 foreach vnet $VNET_LIST {
     if {[file exists $vnet] == 0} {
        incr check_flag
        puts "Error: NETLIST $vnet can not be found, please check!"
     } else {
     }
 }
 echo $VNET_LIST

###==================================================================##
## Sdc Check                                                         ##
##===================================================================##
 set SDC_LIST "{{env.BLK_SDC}}/{{ver.sdc}}/{{env.BLK_NAME}}.$MODE.sdc"
 if { [ file exists $SDC_LIST  ] == 0 } {
        incr check_flag
        puts "Error: SDC $SDC_LIST can not be found, please check!"
 } else {
 }

###==================================================================##
## Spef Check                                                        ##
##===================================================================##
 set SPEF_LISTS  "{{pre.flow_data_dir}}/{{pre.stage}}/{{local.scenario}}/${pre_stage}.{{env.BLK_NAME}}.$RC_CORNER.spef.gz"
 if {$BLOCK_DESIGN_NAMES != ""} {
     foreach block_name $BLOCK_DESIGN_NAMES {
         set blk_spef "${block_release_dir}/SPEF/${block_name}.${RC_CORNER}.spef.gz"
         lappend SPEF_LISTS  "${block_release_dir}/SPEF/${block_name}.${RC_CORNER}.spef.gz"
     }
 } else {
 }
 if {$ANNOTATED_FILE_FORMAT == "spef"} {
     foreach blk_spef $SPEF_LISTS {
         if {[file exists $blk_spef] == 0} {
            puts "Error: RC_FILE $blk_spef can not be found, please check!"
         } else {
         }
     }
 }
 echo $SPEF_LISTS
 puts "SPEF check ....."
 foreach spef_file $SPEF_LISTS {
    if { [file exists $spef_file] == 0 } {
          puts "Error:  $spef_file can not be found, please check!"
            incr check_flag
    } else {
          puts "$spef_file is found"
    }
 }
###==================================================================##
## Check Status Report                                               ##
##===================================================================##
 if { $check_flag } {
         puts "Error: total $check_flag check fail, please check"
         exit
 } else {
         puts "INITIAL CHECK PASS, continue ..."
 }

###==================================================================##
## Setting According to AC timing check                              ##
##===================================================================##
 set PRE_PTPX_PLUGIN_TCL	     "{{cur.config_plugins_dir}}/ptpx_scripts/pre_ptpx_plugin.tcl"
 set POST_PTPX_PLUGIN_TCL	     "{{cur.config_plugins_dir}}/ptpx_scripts/post_ptpx_plugin.tcl"

###==================================================================##
## Directory Definition                                              ##
##===================================================================##
 set RPT_DIR		      "{{cur.cur_flow_rpt_dir}}/$SESSION" 
 set ORI_RPT_DIR          "{{cur.cur_flow_rpt_dir}}" 
 set LOG_DIR 		      "{{cur.cur_flow_log_dir}}" 
 set DATA_DIR             "{{cur.cur_flow_data_dir}}" 
 file mkdir  $RPT_DIR
 set sh_command_log_file "${LOG_DIR}/ptpx_command.log"

###==================================================================##
## Link Library                                                      ##
##===================================================================##
 set_host_option -max $CPU_NUM
 set link_create_black_boxes  ${BBOX}
 if {${MV_DESIGN} == "false"} {
    set link_library  { * }
    set std_lib_name [set [join "DB STD [string toupper $VOLT] [string toupper $LIB_CORNER]" "_"]]
    set mem_lib_name [set [join "DB MEM [string toupper $VOLT] [string toupper $LIB_CORNER]" "_"]]
    set ip_lib_name  [set [join "DB IP  [string toupper $VOLT] [string toupper $LIB_CORNER]" "_"]]
    set io_lib_name  [set [join "DB IO  [string toupper $VOLT] [string toupper $LIB_CORNER]" "_"]]
    set lib_name "$std_lib_name $mem_lib_name $ip_lib_name $io_lib_name"
    puts "$lib_name"
        foreach db  $lib_name {
         read_db $db
         set link_library [ concat $link_library $db ]
        }
 } else {
    set link_path  {*}
    set lib_type [string toupper $LIB_CORNER]
    foreach db_list [info vars DB_${lib_type}] {
        foreach db [set $db_list] {
         read_db $db
         set link_path [ concat $link_path $db ]
        }
    }
    set sub_path {*}
 }
puts  "$link_library"
 ###########################################################################################
 # READ DESIGN 
 ###########################################################################################
 file delete -force ${LOG_DIR}/read_verilog.log
 foreach VNET ${VNET_LIST} {
 	read_verilog ${VNET} >> ${LOG_DIR}/read_verilog.log
 }
 current_design ${TOP}
 link_design ${TOP} > ${LOG_DIR}/link_design.log

########################################################################
# READ SDC
########################################################################
 file delete -force ${LOG_DIR}/read_sdc.${MODE}.log
 foreach sdc $SDC_LIST {
 	source -echo -verbose ${sdc} >> ${LOG_DIR}/read_sdc.${MODE}.log
 }
###########################################################################################
# READ SPEF
###########################################################################################
 set parasitics_log_file  "${LOG_DIR}/read_parasitics.log"
 if { [ llength $SPEF_LISTS ] == 0 } {
    echo [ format "Warning: No 'SPEF' given." ]
 } else {
   file delete -force ${LOG_DIR}/read_parasitics.log
   foreach SPEF_LIST $SPEF_LISTS {
     if { [ file readable ${SPEF_LIST} ] == 0 } {
       echo [ format "Error: Cannot open '%s'." ${SPEF_LIST} ]
     } else {
       if { [ llength $SPEF_LISTS ] == 1 } {
         echo "Reading ${SPEF_LIST} ..."                                     >> ${LOG_DIR}/read_parasitics.log
         read_parasitics -format SPEF -keep_capacitive_coupling ${SPEF_LIST} >> ${LOG_DIR}/read_parasitics.log
       } else {
         set cell_names ""
         foreach block_design_name $BLOCK_DESIGN_NAMES {
           if { [ string match */${block_design_name}_${RC_CORNER}* ${SPEF_LIST} ] == 1 } {
               set cell_name [ get_attribute [ get_cells * -hierarchical -filter "ref_name == ${block_design_name}" -quiet ] full_name ]
               set cell_names [ concat $cell_names $cell_name ]
             }
           }
         if { [ llength $cell_names ] > 0 } {
           foreach cell_name $cell_names {
             echo "Reading ${SPEF_LIST} ..."                                                                 >> ${LOG_DIR}/read_parasitics.log
             echo "<CMD>: read_parasitics -format SPEF -keep_capacitive_coupling -path $cell_name ${SPEF_LIST}" >> ${LOG_DIR}/read_parasitics.log
             read_parasitics -format SPEF -keep_capacitive_coupling -path $cell_name ${SPEF_LIST} >> ${LOG_DIR}/read_parasitics.log
           }
         } else {
           echo "Reading ${SPEF_LIST} ..."                                                >> ${LOG_DIR}/read_parasitics.log
           read_parasitics -format SPEF -keep_capacitive_coupling ${SPEF_LIST} >> ${LOG_DIR}/read_parasitics.log
         }
       }
     }
   } 
 }

 update_timing > ${LOG_DIR}/update_timing.log
 report_annotated_parasitics -list_not_annotated -constant_arcs -max_nets 10000000                                 > ${RPT_DIR}/annotated_parasitics.rpt
 report_annotated_parasitics -list_not_annotated -constant_arcs -max_nets 10000000 -internal_nets -pin_to_pin_nets > ${RPT_DIR}/annotated_parasitics.internal_nets.pin_to_pin.nets.rpt
 report_annotated_parasitics -list_not_annotated -constant_arcs -max_nets 10000000 -internal_nets -driverless_nets > ${RPT_DIR}/annotated_parasitics.internal_nets.driverless_nets.rpt
 report_annotated_parasitics -list_not_annotated -constant_arcs -max_nets 10000000 -internal_nets -loadless_nets   > ${RPT_DIR}/annotated_parasitics.internal_nets.loadless_nets.rpt
 report_annotated_parasitics -list_not_annotated -constant_arcs -max_nets 10000000 -boundary_nets -pin_to_pin_nets > ${RPT_DIR}/annotated_parasitics.boundary_nets.pin_to_pin.nets.rpt
 report_annotated_parasitics -list_not_annotated -constant_arcs -max_nets 10000000 -boundary_nets -driverless_nets > ${RPT_DIR}/annotated_parasitics.boundary_nets.driverless_nets.rpt
 report_annotated_parasitics -list_not_annotated -constant_arcs -max_nets 10000000 -boundary_nets -loadless_nets   > ${RPT_DIR}/annotated_parasitics.boundary_nets.loadless_nets.rpt

#############################################################################################
# Power setting
#############################################################################################
 set power_enable_analysis TRUE
 set power_analysis_mode $POWER_ANALYSIS_MODE
 reset_switching_activity
#############################################################################################
# pre ptpx user scripts
#############################################################################################

source {{cur.config_plugins_dir}}/ptpx_scripts/pre_ptpx_plugin.tcl

#############################################################################################
# Setting global toggle rate
#############################################################################################
 if {$DATA_TOGGLE_RATE != ""} {
 set_switching_activity -static_probability 0.5 -toggle_rate $DATA_TOGGLE_RATE  -base_clock "*" [remove_from_collection [get_nets * -top_net_of_hierarchical_group -segments -hier] [get_nets -top_net_of_hierarchical_group -segments -of_object [all_fanout -clock -flat]]]
 }
 if {$CLOCK_TOGGLE_RATE != ""} {
 set_switching_activity -static_probability 0.5 -toggle_rate $CLOCK_TOGGLE_RATE -base_clock "*" [get_nets -top_net_of_hierarchical_group -segments -of_object [all_fanout -clock -flat]]
 }
#############################################################################################
# Read activity file
#############################################################################################
 set cmd ""
 if {$PTPX_SWITCH_ACTIVITY_FILE != ""} {
    if {[regexp saif $PTPX_SWITCH_ACTIVITY_FILE]} {
            if {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH != ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH == ""} {
               set cmd "read_saif -strip_path $PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH $PTPX_SWITCH_ACTIVITY_FILE"
            } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH == ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH != ""} {
               set cmd "read_saif -path $PTPX_SWITCH_ACTIVITY_FILE_PATH $PTPX_SWITCH_ACTIVITY_FILE"
            } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH == ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH == ""} {
               set cmd "read_saif $PTPX_SWITCH_ACTIVITY_FILE"
            } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH != ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH != ""} {
               set cmd "read_saif -strip_path $PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH -path $PTPX_SWITCH_ACTIVITY_FILE_PATH $PTPX_SWITCH_ACTIVITY_FILE"
            } else {
            }
    } elseif {[regexp vcd $PTPX_SWITCH_ACTIVITY_FILE]} { 
            if {$PTPX_SWITCH_ACTIVITY_FILE_TIME_RANGE != ""} {
                if {$PTPX_SWITCH_ACTIVITY_FILE_ZERO_DELAY && $PTPX_SWITCH_ACTIVITY_FILE_NAME_MAP_FILE == "" } {
                   if {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH != ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH == ""} {
                  set cmd "read_vcd -zero_delay -strip_path $PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT -time $PTPX_SWITCH_ACTIVITY_FILE_TIME_RANGE"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH == ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH != ""} {
                  set cmd "read_vcd -zero_delay -path $PTPX_SWITCH_ACTIVITY_FILE_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT -time $PTPX_SWITCH_ACTIVITY_FILE_TIME_RANGE"
                   } elseif  {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH == ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH == ""} {
                    set cmd "read_vcd -zero_delay  -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT -time $PTPX_SWITCH_ACTIVITY_FILE_TIME_RANGE $PTPX_SWITCH_ACTIVITY_FILE"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH != ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH != ""} {
                    set cmd "read_vcd -zero_delay -strip_path $PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH -path $PTPX_SWITCH_ACTIVITY_FILE_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT -time $PTPX_SWITCH_ACTIVITY_FILE_TIME_RANGE"
                   } else {
                   }
                } elseif {!$PTPX_SWITCH_ACTIVITY_FILE_ZERO_DELAY && $PTPX_SWITCH_ACTIVITY_FILE_NAME_MAP_FILE != ""} {
                   source -e -v $PTPX_SWITCH_ACTIVITY_FILE_NAME_MAP_FILE
                   if {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH != ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH == ""} {
                    set cmd "read_vcd -rtl -strip_path $PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT -time $PTPX_SWITCH_ACTIVITY_FILE_TIME_RANGE"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH == ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH != ""} {
                    set cmd "read_vcd -rtl -path $PTPX_SWITCH_ACTIVITY_FILE_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT -time $PTPX_SWITCH_ACTIVITY_FILE_TIME_RANGE"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH == ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH == ""} {
                    set cmd "read_vcd -rtl -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT -time $PTPX_SWITCH_ACTIVITY_FILE_TIME_RANGE $PTPX_SWITCH_ACTIVITY_FILE"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH != ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH != ""} {
                    set cmd "read_vcd -rtl -strip_path $PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH -path $PTPX_SWITCH_ACTIVITY_FILE_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT -time $PTPX_SWITCH_ACTIVITY_FILE_TIME_RANGE"
                   } else {
                   }
                } elseif {!$PTPX_SWITCH_ACTIVITY_FILE_ZERO_DELAY && $PTPX_SWITCH_ACTIVITY_FILE_NAME_MAP_FILE == ""} {
                   if {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH != ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH == ""} {
                    set cmd "read_vcd -strip_path $PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT -time $PTPX_SWITCH_ACTIVITY_FILE_TIME_RANGE"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH == ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH != ""} {
                    set cmd "read_vcd -path $PTPX_SWITCH_ACTIVITY_FILE_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT -time $PTPX_SWITCH_ACTIVITY_FILE_TIME_RANGE"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH == ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH == ""} {
                    set cmd "read_vcd $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT -time $PTPX_SWITCH_ACTIVITY_FILE_TIME_RANGE"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH != ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH != ""} {
                    set cmd "read_vcd -strip_path $PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH -path $PTPX_SWITCH_ACTIVITY_FILE_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT -time $PTPX_SWITCH_ACTIVITY_FILE_TIME_RANGE"
                   } else {
                   }
                } elseif {$PTPX_SWITCH_ACTIVITY_FILE_ZERO_DELAY && $PTPX_SWITCH_ACTIVITY_FILE_NAME_MAP_FILE != ""} {
                    puts "Warning: Please make sure, it is no need set zero delay with -rtl"
                } else {
                }
            } else {
               if {$PTPX_SWITCH_ACTIVITY_FILE_ZERO_DELAY && $PTPX_SWITCH_ACTIVITY_FILE_NAME_MAP_FILE == ""} {
                   if {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH != ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH == ""} {
                    set cmd "read_vcd -zero_delay -strip_path $PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH == ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH != ""} {
                    set cmd "read_vcd -zero_delay -path $PTPX_SWITCH_ACTIVITY_FILE_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH == ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH == ""} {
                    set cmd "read_vcd -zero_delay  -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT $PTPX_SWITCH_ACTIVITY_FILE"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH != ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH != ""} {
                    set cmd "read_vcd -zero_delay -strip_path $PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH -path $PTPX_SWITCH_ACTIVITY_FILE_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT"
                   } else {
                   }
               } elseif {!$PTPX_SWITCH_ACTIVITY_FILE_ZERO_DELAY && $PTPX_SWITCH_ACTIVITY_FILE_NAME_MAP_FILE != ""} {
                   source -e -v $PTPX_SWITCH_ACTIVITY_FILE_NAME_MAP_FILE
                   if {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH != ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH == ""} {
                    set cmd "read_vcd -rtl -strip_path $PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH == ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH != ""} {
                    set cmd "read_vcd -rtl -path $PTPX_SWITCH_ACTIVITY_FILE_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH == ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH == ""} {
                    set cmd "read_vcd -rtl -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT $PTPX_SWITCH_ACTIVITY_FILE "
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH != ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH != ""} {
                    set cmd "read_vcd -rtl -strip_path $PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH -path $PTPX_SWITCH_ACTIVITY_FILE_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT"
                   } else {
                   }
                } elseif {!$PTPX_SWITCH_ACTIVITY_FILE_ZERO_DELAY && $PTPX_SWITCH_ACTIVITY_FILE_NAME_MAP_FILE == ""} {
                   if {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH != ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH == ""} {
                    set cmd "read_vcd -strip_path $PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH == ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH != ""} {
                    set cmd "read_vcd -path $PTPX_SWITCH_ACTIVITY_FILE_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH == ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH == ""} {
                    set cmd "read_vcd $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH != ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH != ""} {
                    set cmd "read_vcd -strip_path $PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH -path $PTPX_SWITCH_ACTIVITY_FILE_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT"
                   } else {
                   }
                } elseif {$PTPX_SWITCH_ACTIVITY_FILE_ZERO_DELAY && $PTPX_SWITCH_ACTIVITY_FILE_NAME_MAP_FILE != ""} {
                    puts "Warning: Please make sure, it is no need set zero delay with -rtl"
                } else {
                }
                }
    } elseif {[regexp fsdb $PTPX_SWITCH_ACTIVITY_FILE]} { 
            if {$PTPX_SWITCH_ACTIVITY_FILE_TIME_RANGE != ""} {
                if {$PTPX_SWITCH_ACTIVITY_FILE_ZERO_DELAY && $PTPX_SWITCH_ACTIVITY_FILE_NAME_MAP_FILE == "" } {
                   if {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH != ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH == ""} {
                   set cmd "read_fsdb -zero_delay -strip_path $PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT -time $PTPX_SWITCH_ACTIVITY_FILE_TIME_RANGE"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH == ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH != ""} {
                   set cmd "read_fsdb -zero_delay -path $PTPX_SWITCH_ACTIVITY_FILE_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT -time $PTPX_SWITCH_ACTIVITY_FILE_TIME_RANGE"
                   } elseif  {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH == ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH == ""} {
                   set cmd "read_fsdb -zero_delay  -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT -time $PTPX_SWITCH_ACTIVITY_FILE_TIME_RANGE $PTPX_SWITCH_ACTIVITY_FILE"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH != ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH != ""} {
                   set cmd "read_fsdb -zero_delay -strip_path $PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH -path $PTPX_SWITCH_ACTIVITY_FILE_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT -time $PTPX_SWITCH_ACTIVITY_FILE_TIME_RANGE"
                   } else {
                   }
                } elseif {!$PTPX_SWITCH_ACTIVITY_FILE_ZERO_DELAY && $PTPX_SWITCH_ACTIVITY_FILE_NAME_MAP_FILE != ""} {
                   source -e -v $PTPX_SWITCH_ACTIVITY_FILE_NAME_MAP_FILE
                   if {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH != ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH == ""} {
                   set cmd "read_fsdb -rtl -strip_path $PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT -time $PTPX_SWITCH_ACTIVITY_FILE_TIME_RANGE"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH == ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH != ""} {
                   set cmd "read_fsdb -rtl -path $PTPX_SWITCH_ACTIVITY_FILE_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT -time $PTPX_SWITCH_ACTIVITY_FILE_TIME_RANGE"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH == ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH == ""} {
                   set cmd "read_fsdb -rtl -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT -time $PTPX_SWITCH_ACTIVITY_FILE_TIME_RANGE $PTPX_SWITCH_ACTIVITY_FILE "
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH != ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH != ""} {
                   set cmd "read_fsdb -rtl -strip_path $PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH -path $PTPX_SWITCH_ACTIVITY_FILE_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT -time $PTPX_SWITCH_ACTIVITY_FILE_TIME_RANGE"
                   } else {
                   }
                } elseif {!$PTPX_SWITCH_ACTIVITY_FILE_ZERO_DELAY && $PTPX_SWITCH_ACTIVITY_FILE_NAME_MAP_FILE == ""} {
                   if {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH != ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH == ""} {
                   set cmd "read_fsdb -strip_path $PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT -time $PTPX_SWITCH_ACTIVITY_FILE_TIME_RANGE"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH == ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH != ""} {
                   set cmd "read_fsdb -path $PTPX_SWITCH_ACTIVITY_FILE_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT -time $PTPX_SWITCH_ACTIVITY_FILE_TIME_RANGE"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH == ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH == ""} {
                   set cmd "read_fsdb $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT -time $PTPX_SWITCH_ACTIVITY_FILE_TIME_RANGE"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH != ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH != ""} {
                   set cmd "read_fsdb -strip_path $PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH -path $PTPX_SWITCH_ACTIVITY_FILE_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT -time $PTPX_SWITCH_ACTIVITY_FILE_TIME_RANGE"
                   } else {
                   }  
                }
                } elseif {$PTPX_SWITCH_ACTIVITY_FILE_ZERO_DELAY && $PTPX_SWITCH_ACTIVITY_FILE_NAME_MAP_FILE != ""} {
                    puts "Warning: Please make sure, it is no need set zero delay with -rtl"
                } else {
                }
            } else {
               if {$PTPX_SWITCH_ACTIVITY_FILE_ZERO_DELAY && $PTPX_SWITCH_ACTIVITY_FILE_NAME_MAP_FILE == "" } {
                   if {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH != ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH == ""} {
                   set cmd "read_fsdb -zero_delay -strip_path $PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH == ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH != ""} {
                   set cmd "read_fsdb -zero_delay -path $PTPX_SWITCH_ACTIVITY_FILE_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH == ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH == ""} {
                   set cmd "read_fsdb -zero_delay  -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT $PTPX_SWITCH_ACTIVITY_FILE"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH != ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH != ""} {
                   set cmd "read_fsdb -zero_delay -strip_path $PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH -path $PTPX_SWITCH_ACTIVITY_FILE_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT"
                   } else {
                   }
               } elseif {!$PTPX_SWITCH_ACTIVITY_FILE_ZERO_DELAY && $PTPX_SWITCH_ACTIVITY_FILE_NAME_MAP_FILE != ""} {
                   source -e -v $PTPX_SWITCH_ACTIVITY_FILE_NAME_MAP_FILE
                   if {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH != ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH == ""} {
                   set cmd "read_fsdb -rtl -strip_path $PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH == ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH != ""} {
                   set cmd "read_fsdb -rtl -path $PTPX_SWITCH_ACTIVITY_FILE_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH == ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH == ""} {
                   set cmd "read_fsdb -rtl  -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT $PTPX_SWITCH_ACTIVITY_FILE"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH != ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH != ""} {
                   set cmd "read_fsdb -rtl -strip_path $PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH -path $PTPX_SWITCH_ACTIVITY_FILE_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT"
                   } else {
                   }
                } elseif {!$PTPX_SWITCH_ACTIVITY_FILE_ZERO_DELAY && $PTPX_SWITCH_ACTIVITY_FILE_NAME_MAP_FILE == ""} {
                   if {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH != ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH == ""} {
                   set cmd "read_fsdb -strip_path $PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH == ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH != ""} {
                   set cmd "read_fsdb -path $PTPX_SWITCH_ACTIVITY_FILE_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH == ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH == ""} {
                   set cmd "read_fsdb $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT"
                   } elseif {$PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH != ""  && $PTPX_SWITCH_ACTIVITY_FILE_PATH != ""} {
                   set cmd "read_fsdb -strip_path $PTPX_SWITCH_ACTIVITY_FILE_STRIP_PATH -path $PTPX_SWITCH_ACTIVITY_FILE_PATH $PTPX_SWITCH_ACTIVITY_FILE -format $PTPX_SWITCH_ACTIVITY_FILE_FORMAT"
                   } else {
                   }
                } elseif {$PTPX_SWITCH_ACTIVITY_FILE_ZERO_DELAY && $PTPX_SWITCH_ACTIVITY_FILE_NAME_MAP_FILE != ""} {
                    puts "Warning: Please make sure, it is no need set zero delay with -rtl"
                } else {
                }
            }
 } else {
 }

 if {$cmd !=""} {
 eval $cmd
 }
#############################################################################################
# Report Power
#############################################################################################
report_power_analysis_options                                    > ${RPT_DIR}/power_analysis_option.rpt
update_power                                                     > ${RPT_DIR}/update_power.rpt
check_power -verbose -significant_digits 3                       > ${RPT_DIR}/check_power.rpt
report_switching_activity -list_not_annotated                    > ${RPT_DIR}/switching_activity.rpt
report_switching_activity -coverage                              > ${RPT_DIR}/switching_activity_coverage.rpt
report_power -nosplit -verbose -hierarchy                        > ${RPT_DIR}/hier_power.rpt
report_power -nosplit -verbose                                   > ${RPT_DIR}/total_power.rpt
report_power -nosplit -leaf -cell_power -sort_by total_power     > ${RPT_DIR}/cell_power.rpt
report_clock_gate_savings -sequential -hierarchical -nosplit     > ${RPT_DIR}/clock_gate_saving_sequential.rpt
report_clock_gate_savings       -nosplit                         > ${RPT_DIR}/clock_gate_saving.rpt
report_clock_gate_savings  -by_clock_gate     -nosplit           > ${RPT_DIR}/clock_gate_saving_clock_gate.rpt
#############################################################################################
# Save Session
#############################################################################################
save_session {{cur.cur_flow_data_dir}}/{{local.scenario}}.session

#############################################################################################
# Post Ptpx User Scripts 
#############################################################################################
source {{cur.config_plugins_dir}}/ptpx_scripts/post_ptpx_plugin.tcl
