
#!/bin/csh -f
set pre_stage = "{{pre.sub_stage}}"
set cur_stage = "{{cur.sub_stage}}"

set pre_stage = `echo $pre_stage | cut -d . -f 1`

set design_style = "{{local.design_style}}"
set pv_func      = "{{local._multi_inst}}"
set cur_stage    = "{{local._multi_inst}}"
set clbre_drc_CPU_NUMBER = `echo "{{local._job_cpu_number}}" | cut -d " " -f 2`

#========================================================================
#===================  set input files ===================================
#========================================================================
#----------------------- set key word based on src  ---------------------
{% if "opus." in  pre.sub_stage %}
set input_file     = "${pre_stage}.{{env.BLK_NAME}}.merge"
set output_file    = "${cur_stage}.{{env.BLK_NAME}}.merge"
set run_dir        = "./"
set plugin_file    = "{{cur.config_plugins_dir}}/calibre_scripts/clbre_drc_plugin.rule"
{%-elif "opus_dummy." in pre.sub_stage %}
set input_file     = "${pre_stage}.{{env.BLK_NAME}}.dummy_merge"
set output_file    = "${cur_stage}.{{env.BLK_NAME}}.dummy_merge"
set run_dir        = "./"
set plugin_file    = "{{cur.config_plugins_dir}}/calibre_scripts/clbre_drc_plugin.rule"
{%- endif %}

#----------------------- set input files ---------------------------------
{% if local.design_style == "top" %}
{% if local.cal_decks_drc_for_top %}
set rule_deck     = "{{local.cal_decks_drc_for_top}}"
{% else %}
set rule_deck     = "{{liblist.CAL_DECKS_DRC}}"
{% endif %}
{% elif local.design_style == "block" %}
{% if local.cal_decks_drc_for_block %}
set rule_deck     = "{{local.cal_decks_drc_for_block}}"
{% else %}
set rule_deck     = "{{liblist.CAL_DECKS_DRC}}"
{% endif %}
{% endif %}
set top_name      = "{{env.BLK_NAME}}"
{%- if sourceme_14lpp_drc_file %}
set sourceme_file = "{{local.sourceme_14lpp_drc_file}}"
source ${sourceme_file}
{%- endif %}
set gds_file      = "{{pre.flow_data_dir}}/{{pre.stage}}/${input_file}.gds.gz" 
set drc_run       = "{{cur.flow_scripts_dir}}/{{cur.stage}}/${pv_func}/${output_file}.rule"
set run_time      = "{{cur.cur_flow_rpt_dir}}/${pv_func}/${cur_stage}.run_time"
#----------------------- delete exist rule deck file ---------------------
if ( -e ${drc_run} ) then
rm -f ${drc_run}
endif
mkdir -p {{cur.cur_flow_rpt_dir}}/${pv_func}
mkdir -p {{cur.cur_flow_data_dir}}/${pv_func}
mkdir -p {{cur.cur_flow_log_dir}}/${pv_func}
#==========================================================================
#========= generate DRC check script ======================================
#==========================================================================
cat <<drc_setting >! ${drc_run}
LAYOUT ERROR ON INPUT NO

LAYOUT PRIMARY "${top_name}"
LAYOUT PATH    "${gds_file}"
LAYOUT SYSTEM GDSII

DRC RESULTS DATABASE "{{cur.cur_flow_rpt_dir}}/${pv_func}/${output_file}.db"
DRC SUMMARY REPORT   "{{cur.cur_flow_rpt_dir}}/${pv_func}/${output_file}.drc.rpt"

DRC ICSTATION YES
drc_setting

echo include "${plugin_file}" >> ${drc_run}
echo include "${rule_deck}" >> ${drc_run}

#==========================================================================
#========= run DRC check ==================================================
#==========================================================================
echo "clbre_drc" >! ${run_time}
echo "start " `date "+%F %T %a"` >> ${run_time}

#----------------------- use remote file to run drc check ----------------
#set HOSTS_UNIQ = `echo $LSB_HOSTS|sed 's/ /\n/g'|uniq -c|awk '{print $2}'`
#foreach HOST ($HOSTS_UNIQ)
#  set HOST_NUM = `echo $LSB_HOSTS|sed 's/ /\n/g'|grep $HOST|uniq -c|awk '{print $1}'`
#  echo "REMOTE HOST  $HOST $HOST_NUM  RSH /usr/bin/ssh" >>! remote.$LSB_JOBID.conf
#  end
#echo "LAUNCH AUTOMATIC" >> remote.$LSB_JOBID.conf

{%- if local.calibre_drc_user_run_cmd  %}
echo "{{local.calibre_drc_user_run_cmd}} ${drc_run} "
eval "{{local.calibre_drc_user_run_cmd}} ${drc_run} "
{%- else %} 
#-- user command is not fill, will run pre-set calibre drc command -------------
#calibre -drc -hier -turbo -hyper -64 -remotefile remote.$LSB_JOBID.conf  ${drc_run}  
{%- if local.calibre_drc_absub_cmd  %}
echo '''{{local.calibre_drc_absub_cmd}} "calibre -drc -hier -turbo ${clbre_drc_CPU_NUMBER} -hyper -64  ${drc_run}"'''
eval '''{{local.calibre_drc_absub_cmd}} "calibre -drc -hier -turbo ${clbre_drc_CPU_NUMBER} -hyper -64  ${drc_run}"'''
{%- else %}
calibre -drc -hier -turbo ${clbre_drc_CPU_NUMBER} -hyper -64  ${drc_run}  
{%- endif %}
{%- endif %}
echo "finish" `date "+%F %T %a"` >> $run_time
#==========================================================================
#========= grep the report ================================================
#==========================================================================
grep -v "NOT EXECUTED" {{cur.cur_flow_rpt_dir}}/${pv_func}/${output_file}.drc.rpt | grep -v "TOTAL Result Count = 0" >! {{cur.cur_flow_rpt_dir}}/${pv_func}/pv.drc.rpt.sum
grep RULECHECK {{cur.cur_flow_rpt_dir}}/${pv_func}/pv.drc.rpt.sum  >! {{cur.cur_flow_rpt_dir}}/${pv_func}/pv.drc.CHECKRULE.sum.sort

echo "{{env.FIN_STR}}"

