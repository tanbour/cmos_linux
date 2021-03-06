######################################################################
# Tool: Formality
######################################################################
  puts "Alchip-info : Running script [info script]\n"

##===================================================================##
## SETUP                                                             ##
##===================================================================##
 {%- if local.lib_cell_height == "240" %}
 source {{env.PROJ_SHARE_CMN}}/process_strategy/liblist/liblist_6T.tcl
 {%- elif local.lib_cell_height == "300" %}
 source {{env.PROJ_SHARE_CMN}}/process_strategy/liblist/liblist_7d5T.tcl
 {%- endif %}
  
  set pre_stage "{{pre.sub_stage}}"
  set cur_stage "{{cur.sub_stage}}"
  
  set pre_stage [lindex [split $pre_stage .] 0]
  set cur_stage [lindex [split $cur_stage .] 0]
  
  set blk_name          "{{env.BLK_NAME}}"
  set blk_rpt_dir       "{{cur.cur_flow_rpt_dir}}"
  set blk_utils_dir     "{{env.PROJ_UTILS}}"
  set pre_flow_data_dir "{{pre.flow_data_dir}}/{{pre.stage}}"
  set fm_cpu_number   "[lindex "{{local._job_cpu_number}}" end]"
  set_host_option -max_cores $fm_cpu_number
  
  if {[file exist {{cur.config_plugins_dir}}/fm_scripts/probe_points_list.tcl]} {
  file delete {{cur.config_plugins_dir}}/fm_scripts/probe_points_list.tcl
  }
######################################################################################################################
# implementation and reference netilst setting
######################################################################################################################
{%- if local.fm_implementation_vnet_list %}
{%- if local.fm_implementation_vnet_list is string %}
  set FM_IMPLEMENTATION_VNET_LIST     "{{local.fm_implementation_vnet_list}}"
{%- elif fm_implementation_vnet_list is sequence %}
  set FM_IMPLEMENTATION_VNET_LIST     "{{local.fm_implementation_vnet_list|join(' ') }}"
{%- endif %}
{%- else %}
  set FM_IMPLEMENTATION_VNET_LIST     "${pre_flow_data_dir}/${pre_stage}.{{env.BLK_NAME}}.fm.v.gz" 
{%- endif %}
{%- if local.fm_reference_vnet_list is string %}
  set FM_REFERENCE_VNET_LIST          "{{local.fm_reference_vnet_list}}"
{%- elif fm_implementation_vnet_list is sequence %}
  set FM_REFERENCE_VNET_LIST          "{{local.fm_reference_vnet_list|join(' ') }}"
{%- endif %}
  set FM_IMPLEMENTATION_BLOCK_NAME    "{{env.BLK_NAME}}"
  set FM_REFERENCE_BLOCK_NAME         "{{env.BLK_NAME}}"
  set FM_SESSION                      "{{cur.cur_flow_data_dir}}/$cur_stage.{{env.BLK_NAME}}.session"
  set FM_SAVE_SESSION		          "{{local.fm_save_session}}"
  set PROBE_LIST		              "{{cur.config_plugins_dir}}/fm_scripts/probe_list.tcl" 
  set PROBE_POINTS_LIST               "{{cur.config_plugins_dir}}/fm_scripts/probe_points_list.tcl"
  set FM_DB                           "{{local.fm_db}}"
######################################################################################################################
# option setting 
######################################################################################################################
  set verification_failing_point_limit              "{{local.verification_failing_point_limit}}" ;#1000
  set hdlin_unresolved_modules                      "{{local.hdlin_unresolved_modules}}" ;#black_box
  set verification_set_undriven_signals             "{{local.verification_set_undriven_signals}}" ;#X
  
  {%- if local.fm_svf_file %}
  set_svf  {{local.fm_svf_file}}
  {% endif %}
######################################################################################################################
# read design
######################################################################################################################
  set_host_options -max_cores $fm_cpu_number
  read_db "$FM_DB"
  
  read_verilog -container r -libname WORK $FM_REFERENCE_VNET_LIST
  set_top r:/WORK/$FM_REFERENCE_BLOCK_NAME
  
  read_verilog -container i -libname WORK $FM_IMPLEMENTATION_VNET_LIST
  set_top i:/WORK/$FM_IMPLEMENTATION_BLOCK_NAME
######################################################################################################################
# case/dont_verify and other setting
######################################################################################################################
  source -e -v {{cur.config_plugins_dir}}/fm_scripts/user_defined_options.tcl
######################################################################################################################
# implementation and reference compare
######################################################################################################################
  match
  report_unmatched_points         > $blk_rpt_dir/$cur_stage.unmatched_points.rpt
  report_matched_points           > $blk_rpt_dir/$cur_stage.matched_points.rpt

  set result [verify r:/WORK/$FM_REFERENCE_BLOCK_NAME i:/WORK/$FM_IMPLEMENTATION_BLOCK_NAME]

  report_failing                  > $blk_rpt_dir/$cur_stage.failing.rpt
  report_passing                  > $blk_rpt_dir/$cur_stage.passing.rpt
  report_aborted                  > $blk_rpt_dir/$cur_stage.aborted.rpt
  printvar                        > $blk_rpt_dir/$cur_stage.printvar.rpt
  report_constants                > $blk_rpt_dir/$cur_stage.constants.rpt
  report_black_boxes              > $blk_rpt_dir/$cur_stage.black_boxes.rpt
  report_user_matches             > $blk_rpt_dir/$cur_stage.user_matches.rpt
  report_dont_match_points        > $blk_rpt_dir/$cur_stage.dont_match_points.rpt
  report_dont_verify_points       > $blk_rpt_dir/$cur_stage.dont_verify_points.rpt
  report_unverified_points        > $blk_rpt_dir/$cur_stage.unverified_points.rpt
######################################################################################################################
# generate probe_points file, if probe list is not empty
######################################################################################################################

# prob points list is generated automatically base on probe list
  set probe_p [open $PROBE_POINTS_LIST w] 
  set probe_f [open $PROBE_LIST r]

  while {[gets $probe_f line1] >= 0} {
     puts "Alchip-info : $line1"
     puts $probe_p "set_probe_points r:/WORK/$FM_REFERENCE_BLOCK_NAME/$line1 i:/WORK/$FM_IMPLEMENTATION_BLOCK_NAME/$line1"
  } 
  close $probe_p
  close $probe_f
  
  set probe_p [open $PROBE_POINTS_LIST r]
  
  if {[gets $probe_p line1] >= 0} {
    source -e -v $PROBE_POINTS_LIST 
    verify -type pin -incremental -probe
    report_probe_status > $blk_rpt_dir/$cur_stage.probe_status.rpt
  }
  close $probe_p
######################################################################################################################
# save FM session
######################################################################################################################
{% if local.fm_save_session == "true" %} 
  if {[file exist $FM_SESSION]} {
    file delete $FM_SESSION
   }
  save_session -replace $FM_SESSION
{% endif %}
######################################################################################################################
# exit
######################################################################################################################
  if { $result == 1 } {
  puts "Alchip_info: op stage finished."
  exit
    } else {
  start_gui
  }

