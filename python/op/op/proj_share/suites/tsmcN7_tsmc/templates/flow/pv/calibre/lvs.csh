
#!/bin/csh -f

set pre_stage = "{{pre.sub_stage}}"
set cur_stage = "{{cur.sub_stage}}"

set pre_stage = `echo $pre_stage | cut -d . -f 1`
set cur_stage = `echo $cur_stage | cut -d . -f 1`

set clbre_lvs_CPU_NUMBER = `echo "{{local._job_cpu_number}}" | cut -d " " -f 2`

# source liblsit by strategy
{%- if local.lib_cell_height == "240" %}
source {{env.PROJ_SHARE_CMN}}/process_strategy/liblist/liblist_6T.csh
{%- elif local.lib_cell_height == "300" %}
source {{env.PROJ_SHARE_CMN}}/process_strategy/liblist/liblist_7d5T.csh
{%- endif %}

#===================================================================
#===================  delete existing run file and folder ==========
#===================================================================
#----------------------- set key word based on src -----------------
{% if  local.lvs_check_use_dummy_merge_gds == "false" %}
set input_file     = "${pre_stage}.{{env.BLK_NAME}}.merge"
set output_file    = "${cur_stage}.{{env.BLK_NAME}}.merge"
set run_dir        = "./"
set plugin_file    = "{{cur.config_plugins_dir}}/calibre_scripts/clbre_lvs_plugin.rule"
{%- elif local.lvs_check_use_dummy_merge_gds == "true" %}
set input_file     = "${pre_stage}.{{env.BLK_NAME}}.dummy_merge"
set output_file    = "${cur_stage}.{{env.BLK_NAME}}.dummy_merge"
set run_dir        = "./"
set plugin_file    = "{{cur.config_plugins_dir}}/calibre_scripts/clbre_lvs_plugin.rule"
{%- endif %}

#-------------------   set input files    --------------------------
set rule_deck     = "${CAL_DECKS_LVS}"
set top_name      = "{{env.BLK_NAME}}"
{%- if local.sourceme_14lpp_lvs_file %}
set sourceme_file = "{{local.sourceme_14lpp_lvs_file}}"
source ${sourceme_file}
{%- endif %}
set gds_file      = "{{pre.flow_data_dir}}/{{pre.stage}}/${input_file}.gds.gz"
set net_file      = "{{pre.flow_data_dir}}/{{pre.stage}}/${pre_stage}.{{env.BLK_NAME}}.cdl"
set lvs_run       = "{{cur.flow_scripts_dir}}/{{cur.stage}}/${output_file}.rule"
set run_time      = "{{cur.cur_flow_rpt_dir}}/${cur_stage}.run_time"
set hcell_file    = "{{local.hcell_file_lvs}}"
set power_name    = "{{local.power_name_lvs}}"
set ground_name   = "{{local.ground_name_lvs}}"

#----------------------- delete exist rule deck file ----------------
if ( -e ${lvs_run} ) then
rm -rf ${lvs_run}
endif

#===================================================================
#=========  generate LVS check  script =============================
#===================================================================
cat <<lvs_setting >! ${lvs_run}
#!tvf

tvf::VERBATIM {
LAYOUT ERROR ON INPUT NO

LVS CHECK PORT NAMES  YES
LVS IGNORE PORTS      YES
LVS GLOBALS ARE PORTS YES
LVS SPICE PREFER PINS      NO
LVS Spice Override Globals YES
LVS RECOGNIZE GATES NONE
LVS Expand Unbalanced Cells NO
LVS abort on softchk no
LVS SPICE CULL PRIMITIVE SUBCIRCUITS YES

LAYOUT CASE YES
SOURCE CASE YES

LAYOUT PATH "$gds_file"
LAYOUT PRIMARY "$top_name"
LAYOUT SYSTEM GDSII

SOURCE PATH "$net_file"
SOURCE PRIMARY "$top_name"
SOURCE SYSTEM SPICE
LVS ISOLATE SHORTS YES flat //<LVS_REPORT>.shorts
LVS REPORT OPTION  S V R F
LVS REPORT "{{cur.cur_flow_rpt_dir}}/${cur_stage}.{{env.BLK_NAME}}.rpt"
LVS EXECUTE ERC YES
ERC SELECT CHECK ERC_WELL_TO_PG_CHECK 
ERC SELECT CHECK ERC_DS_TO_PG_CHECK   
ERC SELECT CHECK ERC_FLOATING_WELL_CHECK

ERC RESULTS DATABASE "{{cur.cur_flow_rpt_dir}}/${output_file}.erc.db" ASCII
ERC SUMMARY REPORT   "{{cur.cur_flow_rpt_dir}}/${output_file}.erc.rpt" HIER
ERC MAXIMUM RESULTS ALL
ERC MAXIMUM VERTEX ALL


DRC ICSTATION YES
lvs_setting

echo include ${plugin_file} >> ${lvs_run}
echo include ${rule_deck} >> ${lvs_run}
echo "}" >> ${lvs_run}

#==========================================================================
#========= run LVS check ==================================================
#==========================================================================
echo "clbre_lvs" >! ${run_time}
echo "start " `date "+%F %T %a"` >> ${run_time}

{%- if local.calibre_lvs_user_run_cmd %}
echo "{{local.calibre_lvs_user_run_cmd}} ${lvs_run}"
eval "{{local.calibre_lvs_user_run_cmd}} ${lvs_run}"
{%- else %}
 #-- user command is not fill, will use default command -------------------
calibre -lvs -hier -hyper -turbo ${clbre_lvs_CPU_NUMBER} -64 -hcell ${hcell_file} ${lvs_run} 
{%- endif %}

echo "finish" `date "+%F %T %a"` >> ${run_time}
#==========================================================================
#========= grep the report ================================================
#==========================================================================
echo RULECHECK RESULTS STATISTICS >! {{cur.cur_flow_rpt_dir}}/lvs.erc.rpt.sum
grep "^RULECHECK " {{cur.cur_flow_rpt_dir}}/${output_file}.erc.rpt   >> {{cur.cur_flow_rpt_dir}}/lvs.erc.rpt.sum
echo RULECHECK RESULTS STATISTICS BY CELL                 >> {{cur.cur_flow_rpt_dir}}/lvs.erc.rpt.sum
grep "TOTAL Result Count = "{{cur.cur_flow_rpt_dir}}/${output_file}.erc.rpt | sed "/RULECHECK/d" >> {{cur.cur_flow_rpt_dir}}/lvs.erc.rpt.sum

echo "{{env.FIN_STR}}"

