#! /bin/csh -e
set block = "{{env.BLK_NAME}}"
set EDA_def = "{{local.EDA_def}}"
set EDA_spef = "{{local.EDA_spef}}"
set EDA_timingFile = "{{local.EDA_timingFile}}"
set EDA_ploc = "{{local.EDA_ploc}}"
set EDA_ptSession = "{{local.EDA_ptSession}}"
set EDA_enableDynamic = "{{local.EDA_enableDynamic}}"
set EDA_dynamicFile = '{{local.EDA_dynamicFile}}'
##########   set env value 
set func = '{{local.func}}'
set subworkdir = "{{local.func}}"
set Redhawk_res_cp_dir = "{{env.BLK_ROOT}}/block_common/redhawk"
########## new add 
{{env.BLK_ROOT}}/block_common/redhawk/redhawk_env.csh $func $block $EDA_def $EDA_spef $EDA_ptSession $EDA_timingFile $EDA_enableDynamic $EDA_ploc $subworkdir $EDA_dynamicFile $Redhawk_res_cp_dir
