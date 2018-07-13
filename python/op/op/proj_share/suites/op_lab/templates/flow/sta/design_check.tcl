###===================================================================###
###   pt setup                                                        ###
###===================================================================###
set pre_stage "{{pre.sub_stage}}"
set cur_stage "{{cur.sub_stage}}"

set pre_stage [lindex [split $pre_stage .] 0]
set cur_stage [lindex [split $cur_stage .] 0]

set SESSION                         "{{local._multi_inst}}" 
set MODE                            [lindex [split $SESSION .] 0]
set VOLT                            [lindex [split $SESSION .] 1]
set LIB_CORNER                      [lindex [split $SESSION .] 2]
set RC_CORNER                       [lindex [split $SESSION .] 3]
set CHECK_TYPE                      [lindex [split $SESSION .] 4]

set TOP                             "{{env.BLK_NAME}}"
set SUB_BLOCKS                      "{{local.SUB_BLOCKS}}"
set SUB_BLOCKS_FILE                 "{{local.SUB_BLOCKS_FILE}}"

set VNET                            "{{local.VNET}}"
set SDC_LIST                        "{{local.SDC_LIST}}"
set rpt_dir                         "{{cur.cur_flow_rpt_dir}}/${SESSION}"
set dont_use_file                   "{{cur.config_plugins_dir}}/pt_scripts/dont_use_list"
###===================================================================###
###  source liblist                                                   ###
###===================================================================###
source {{cur.flow_liblist_dir}}/liblist/liblist.tcl
source {{cur.cur_flow_sum_dir}}/${SESSION}/{{cur.sub_stage}}.op._job.tcl

set pt_cpu_number          "[lindex "${_job_cpu_number}" end]"

set_host_options -max_cores $pt_cpu_number

###==================================================================##
##  LIBRARY                                                          ##
##===================================================================##
{% include 'pt/tcl/mv_library_setup.tcl' %}

###==================================================================##
## PT SETUP                                                          ##
##===================================================================##
{% include 'pt/setting/ALCHIP-PT-SignOff-CommonSetting.tcl' %} 

###==================================================================##
## READ DESIGN                                                       ##
##===================================================================##
exec mkdir -p $rpt_dir
file delete -force $rpt_dir/read_verilog.log
redirect -append $rpt_dir/read_verilog.log {puts "read_verilog ${VNET}"}
redirect -append $rpt_dir/read_verilog.log {read_verilog ${VNET}}
foreach type [array names SUB_BLOCKS_CELL_MAP] {
    foreach blk $SUB_BLOCKS_CELL_MAP($type) {
        set SVNET $BLOCK_RELEASE_DIR/$blk/vnet/${blk}.v.gz
        redirect -append $rpt_dir/read_verilog.log {puts "read_verilog ${SVNET}"}
        redirect -append $rpt_dir/read_verilog.log {read_verilog ${SVNET}}
    }
}

current_design ${TOP}
link_design ${TOP}

foreach sdc $SDC_LIST {
   source -echo -verbose ${sdc}
}

##===================================================================##
## common pts procs                                                  ##
##===================================================================##
source {{env.PROJ_UTILS}}/pt_utils/pts_procs.tcl

##===================================================================##
## check items                                                       ##
##===================================================================##

update_timing
redirect -tee $rpt_dir/check_timing.rpt {check_timing}

# check input floating
redirect -tee $rpt_dir/check_open_input_pin.rpt {pts::check_open_input_pin}

# check dont use cell based on the dont_use_list
redirect -tee $rpt_dir/check_dont_use_cell.rpt {pts::check_dont_use_cell -dont_use_file {{cur.config_plugins_dir}}/pt_scripts/dont_use_list}

# check the multiple drive
redirect -tee $rpt_dir/check_multi_drive.rpt {pts::check_multi_drive}

# report the cell type of clock tree.
redirect -tee $rpt_dir/report_clock_cell_type.rpt {pts::report_clock_cell_type}

puts "Alchip_info: op stage finished."
exit
