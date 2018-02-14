#===================================================================
#=================== common setting ================================
#===================================================================
#
set TOP "{{env.BLK_NAME}}"
#
set RC_CORNER     "{{local.rc_corner}}"
set TECH_FILE   "{{liblist.ICC2_TECH_FILE}}"
set MAP_FILE      "{{liblist.TLUPLUS_MAPPING_FILE}}"
set DEF_FILE      "{{ver.fp}}/{{BLK_NAME}}.def.gz"
set MODE          "{{local.mode}}"
set LIB_CORNER    "{{local.lib_corner}}"
set RC_CORNER     "{{local.rc_corner}}"
set SDC_FILE      "{{ver.sdc}}/{{env.BLK_NAME}}.{{local.mode}}.sdc"
set DDC_FILE      "{{local.ddc_file}}"
#set use_vt_list {11psvt 11plvt 11pulvt 8psvt 8plvt 8pulvt}
set use_vt_list  "{{local.use_vt_list}}"
set syn_mode     "{{local.syn_mode}}"

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

set DW_PATH "{{local.dw_path}}"
set search_path ". $search_path $DW_PATH  {{ver.rtl}} {{ver.sdc}} {{ver.upf}} "
set synthetic_library "{{local.synthetic_library}}"
set link_library "$link_library $synthetic_library"

{% include 'dc/common_settings/DCG_common_setting.tcl' %}
