
#!/bin/csh -f
set pre_stage = "{{pre.sub_stage}}"
set cur_stage = "{{cur.sub_stage}}"

set pre_stage = `echo $pre_stage | cut -d . -f 1`

set design_style = "{{local.design_style}}"
set pv_func      = "{{local._multi_inst}}"
set cur_stage    = "{{local._multi_inst}}"
set clbre_ant_CPU_NUMBER = `echo "{{local._job_cpu_number}}" | cut -d " " -f 2`

#======================================================================
#=================== set input files ==================================
#======================================================================
#----------------------- set key word based on src ---------------------------
{% if "opus." in  pre.sub_stage %}
set input_file     = "${pre_stage}.{{env.BLK_NAME}}.merge"
set output_file    = "${cur_stage}.{{env.BLK_NAME}}.merge"
set run_dir        = "./"
set plugin_file    = "{{cur.config_plugins_dir}}/calibre_scripts/clbre_ant_plugin.rule"
{%-elif "opus_dummy." in pre.sub_stage %}
set input_file     = "${pre_stage}.{{env.BLK_NAME}}.dummy_merge"
set output_file    = "${cur_stage}.{{env.BLK_NAME}}.dummy_merge"
set run_dir        = "./"
set plugin_file    = "{{cur.config_plugins_dir}}/calibre_scripts/clbre_ant_plugin.rule"
{%- endif %}

#----------------------- set input files ---------------------------------
{% if local.design_style == "top" %}
{% if local.cal_decks_ant_for_top %}
set rule_deck     = "{{local.cal_decks_ant_for_top}}"
{% else %}
set rule_deck     = "{{liblist.CAL_DECKS_ANT}}"
{% endif %}
{% elif local.design_style == "block" %}
{% if local.cal_decks_ant_for_block %}
set rule_deck     = "{{local.cal_decks_ant_for_block}}"
{% else %}
set rule_deck     = "{{liblist.CAL_DECKS_ANT}}"
{% endif %}
{% endif %}

set top_name      = "{{env.BLK_NAME}}"
{%- if local.sourceme_14lpp_ant_file %}
set sourceme_file = "{{local.sourceme_14lpp_ant_file}}"
source ${sourceme_file}
{%- endif %}
set gds_file      = "{{pre.flow_data_dir}}/{{pre.stage}}/${input_file}.gds.gz" 
set ant_run       = "{{cur.flow_scripts_dir}}/{{cur.stage}}/${pv_func}/${output_file}.rule"
set run_time      = "{{cur.cur_flow_rpt_dir}}/${pv_func}/${cur_stage}.run_time"

#----------------------- delete exist rule deck file ---------------------
if ( -e ${ant_run} ) then
rm -rf ${ant_run}
endif
mkdir -p {{cur.cur_flow_rpt_dir}}/${pv_func}
mkdir -p {{cur.cur_flow_data_dir}}/${pv_func}
mkdir -p {{cur.cur_flow_log_dir}}/${pv_func}
#======================================================================
#================== generate antenna check script =====================
#======================================================================
cat <<ant_setting >! ${ant_run}
LAYOUT ERROR ON INPUT NO

LAYOUT PRIMARY "${top_name}"
LAYOUT PATH    "${gds_file}"
LAYOUT SYSTEM GDSII

DRC RESULTS DATABASE "{{cur.cur_flow_rpt_dir}}/${pv_func}/${output_file}.db"
DRC SUMMARY REPORT   "{{cur.cur_flow_rpt_dir}}/${pv_func}/${output_file}.rpt"

DRC ICSTATION YES
ant_setting

echo include  "${plugin_file}" >> ${ant_run}
echo include "${rule_deck}" >> ${ant_run}

#==========================================================================
#========= run ANT check ==================================================
#==========================================================================
echo "clbre_ant" >! ${run_time}
echo "start " `date "+%F %T %a"` >> ${run_time}

{%- if local.calibre_ant_user_run_cmd %}
echo "{{local.calibre_ant_user_run_cmd}} ${ant_run}"
eval "{{local.calibre_ant_user_run_cmd}} ${ant_run}"
{%- else %}
calibre  -drc -hier -hyper -turbo ${clbre_ant_CPU_NUMBER} -64 ${ant_run}        
{%- endif %}

echo "finish" `date "+%F %T %a"` >> ${run_time}

#==========================================================================
#========= grep the report ================================================
#==========================================================================
grep -v "NOT EXECUTED" {{cur.cur_flow_rpt_dir}}/${pv_func}/${output_file}.rpt | grep -v "TOTAL Result Count = 0" >! {{cur.cur_flow_rpt_dir}}/${pv_func}/pv.ant.rpt.sum
grep RULECHECK {{cur.cur_flow_rpt_dir}}/${pv_func}/pv.ant.rpt.sum  >! {{cur.cur_flow_rpt_dir}}/${pv_func}/pv.ant.CHECKRULE.rpt.sum.sort

echo "{{env.FIN_STR}}"

