
#!/bin/csh -f

set pre_stage = "{{pre.sub_stage}}"
set cur_stage = "{{cur.sub_stage}}"

set pre_stage = `echo $pre_stage | cut -d . -f 1`
set cur_stage = `echo $cur_stage | cut -d . -f 1`

#==========================================================================
#=================== delete the exist adsRpt/adsPower/DB ==================
#==========================================================================
if ( -d ./${cur_stage} ) then 
rm -rf ./${cur_stage}
endif
mkdir ./${cur_stage}
#==========================================================================
#=================== setting                     ==========================
#==========================================================================
set analysis_cmd_file         = "{{cur.flow_scripts_dir}}/{{cur.stage}}/${cur_stage}.${env.BLK_NAME}.cmd"
set run_time                  = "{{cur.cur_flow_rpt_dir}}/${cur_stage}.run_time"
set LEF_FILES                 =  "{{liblist.LEF_TECH}} {{liblist.LEF_STD}}  {{liblist.LEF_MEM}} {{liblist.LEF_IP}}  {{liblist.LEF_IO}}"
set SCENARIO_NAME             = {{local.scenario}}

set MODE                      = `echo $SCENARIO_NAME | cut -d . f 1`
set VOLT                      = `echo $SCENARIO_NAME | cut -d . f 2` 
set LIB_CORNER                = `echo $SCENARIO_NAME | cut -d . f 3`
set RC_CORNER                 = `echo $SCENARIO_NAME | cut -d . f 4` 
set CHECK_TYPE                = `echo $SCENARIO_NAME | cut -d . f 5` 

#========================= lib corner =====================================
set LIB_CORNER_UPPER = `echo $LIB_CORNER | tr '[a-z]' '[A-Z]'`
set VOLT_UPPER       = `echo $VOLT | tr '[a-z]' '[A-Z]'`
set STD_LIB          = `echo LIB_STD_${VOLT_UPPER}_${LIB_CORNER_UPPER}`
set MEM_LIB          = `echo LIB_MEM_${VOLT_UPPER}_${LIB_CORNER_UPPER}`
set IP_LIB           = `echo LIB_IP_${VOLT_UPPER}_${LIB_CORNER_UPPER}`
set IO_LIB           = `echo LIB_IO_${VOLT_UPPER}_${LIB_CORNER_UPPER}`
set STD_APL          = `echo APL_STD_${VOLT_UPPER}_${APL_CORNER_UPPER}`
set MEM_APL          = `echo APL_MEM_${VOLT_UPPER}_${APL_CORNER_UPPER}`
set IP_APL           = `echo APL_IP_${VOLT_UPPER}_${APL_CORNER_UPPER}`
set IO_APL           = `echo APL_IO_${VOLT_UPPER}_${APL_CORNER_UPPER}`

set LIB_FILES = "${STD_LIB} ${MEM_LIB} ${IP_LIB} ${IO_LIB}"
set APL_FILES = "${STD_APL} ${MEM_APL} ${IP_APL} ${IO_APL}"

#=================================================================================
#=================== generate Redhawk Dynamic main command =======================
#=================================================================================
cat<< redhawk_import_gsr >! ${analysis_cmd_file}
#=================== Redhawk import files ========================================
import gsr  {{cur.config_plugins_dir}}/redhawk_scripts/*.gsr
redhawk_import_gsr

cat<< redhawk_analysis_cmd >> ${analysis_cmd_file} 
#===================Redhawk Dynamic Analysis ======================================
#-- setup design -----------------------
setup design
perform pwrcalc
#-- dynamic analysis ---------------------
perform extraction -power -ground -l -c
setup pad
setup wirebond
setup package
perform analysis -dynamic
perform emcheck
export db  ./DB_dynamic_analysis
redhawk_analysis_cmd
#===============================================================================
#=================== Run redhawk Dynamic =======================================
#===============================================================================
echo "redhawk_dynamic" >! ${run_time}
echo "start" `date "+%F %T %a"` >> ${run_time}
redhawk -lmwait  -b  ${analysis_cmd_file}
echo "finish" `date "+%F %T %a"` >> ${run_time}

