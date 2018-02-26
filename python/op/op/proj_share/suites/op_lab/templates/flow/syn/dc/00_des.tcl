#===================================================================
#=================== common setting ================================
#===================================================================
#
set TOP "{{env.BLK_NAME}}"
#
set RC_CORNER     "{{local.rc_corner}}"
set TECH_FILE   "{{liblist.ICC2_TECH_FILE}}"
set MAP_FILE      "{{liblist.TLUPLUS_MAPPING_FILE}}"
set DEF_FILE      "{{env.BLK_RTL}}/{{ver.fp}}/{{env.BLK_NAME}}.def.gz"
set MODE          "{{local.mode}}"
set LIB_CORNER    "{{local.lib_corner}}"
set RC_CORNER     "{{local.rc_corner}}"
set SDC_FILE      "{{env.BLK_SDC}}/{{ver.sdc}}/{{env.BLK_NAME}}.{{local.mode}}.sdc"
set DDC_FILE      "{{local.ddc_file}}"
#set use_vt_list {11psvt 11plvt 11pulvt 8psvt 8plvt 8pulvt}
set use_vt_list  "{{local.use_vt_list}}"
set syn_mode     "{{local.syn_mode}}"
##mkdir tool output dirctory
set pre_stage "{{pre.sub_stage}}"
set cur_stage "{{cur.sub_stage}}"

set pre_stage [lindex [split $pre_stage .] 0]
set cur_stage [lindex [split $cur_stage .] 0]

set cur_flow_data_dir "{{cur.flow_data_dir}}/$cur_stage"
set pre_flow_data_dir "{{pre.flow_data_dir}}/$pre_stage"
set cur_flow_rpt_dir "{{cur.flow_rpt_dir}}/$cur_stage"
set cur_flow_log_dir "{{cur.flow_log_dir}}/$cur_stage"
set cur_flow_sum_dir "{{cur.flow_sum_dir}}/$cur_stage"

exec mkdir -p $cur_flow_data_dir
exec mkdir -p $cur_flow_rpt_dir
exec mkdir -p $cur_flow_log_dir
exec mkdir -p $cur_flow_sum_dir

{% if local.rc_corner == "cworst" %}
set TLUP_{{local.rc_corner}}  "{{liblist.CWORST_TLUPLUS_FILE}}"
{% elif local.rc_corner == "rcworst" %}
set TLUP_{{local.rc_corner}}           "{{liblist.RCWORST_TLUPLUS_FILE}}"
{% elif local.rc_corner == "cworst_ccworst" %}
set TLUP_{{local.rc_corner}}    "{{liblist.CWORST_CCWORST_TLUPLUS_FILE}}"
{% elif local.rc_corner == "cworst_ccworst_T" %}
set TLUP_{{local.rc_corner}}    "{{liblist.CWORST_CCWORST_T_TLUPLUS_FILE}}"
{% elif local.rc_corner == "rcworst_ccworst" %}
set TLUP_{{local.rc_corner}}    "{{liblist.RCWORST_CCWORST_TLUPLUS_FILE}}}"
{% elif local.rc_corner == "rcworst_ccworst_T" %}
set TLUP_{{local.rc_corner}}    "{{liblist.RCWORST_CCWORST_T_TLUPLUS_FILE}}"
{% elif local.rc_corner == "cbest" %}
set TLUP_{{local.rc_corner}}  "{{liblist.CBEST_TLUPLUS_FILE}}"
{% elif local.rc_corner == "rcbest" %}
set TLUP_{{local.rc_corner}}   "{{liblist.RCBEST_TLUPLUS_FILE}}"
{% elif local.rc_corner == "cbest_ccbest" %}
set TLUP_{{local.rc_corner}}    "{{liblist.CBEST_CCBEST_TLUPLUS_FILE}}"
{% elif local.rc_corner == "cbest_ccbest_T" %}
set TLUP_{{local.rc_corner}}    "{{liblist.CBEST_CCBEST_T_TLUPLUS_FILE}}"
{% elif local.rc_corner == "rcbest_ccbest" %}
set TLUP_{{local.rc_corner}}    "{{liblist.RCBEST_CCBEST_TLUPLUS_FILE}}"
{% elif local.rc_corner == "rcbest_ccbest_T" %}
set TLUP_{{local.rc_corner}}    "{{liblist.RCBEST_CCBEST_T_TLUPLUS_FILE}}"
{% endif %}

#===================================================================
#=================== set library ===================================
#===================================================================
#-- timing lib -------------------------

#-- dc setup -------------------------

{% include 'dc/setup/setup.tcl' %}
#-- dc setting -------------------------

set DW_PATH "{{local.dw_path|join(' ')}}"
set search_path ". $search_path $DW_PATH  {{env.BLK_RTL}}/{{ver.rtl}} {{env.BLK_SDC}}/{{ver.sdc}} {{env.BLK_UPF}}/{{ver.upf}} {{env.BLK_FP}}/{{ver.fp}}"
set synthetic_library "{{local.synthetic_library|join(' ')}}"
set link_library "$link_library $synthetic_library"

{% include 'dc/common_settings/DCG_common_setting.tcl' %}
