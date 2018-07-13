#!/bin/csh
##########################################################################################
# Tool  : Strar-RC
# Script:05_starrc_log_signoff.tcl
# Alchip Onepiece3p
##########################################################################################
puts "Alchip-info : Running signoff-check script--> starrc_log.check [info script]\n"

set src_stage icc2_route 
set dst_stage signoff 
set op4_dst_eco signoff_check
set eco_version 0130

exec mkdir -p {{env.RUN_DATA}}
exec mkdir -p {{env.RUN_RPT}}
exec mkdir -p {{env.RUN_LOG}}

# check starrc log 
# Usage: check_starrc_log.csh <starrc_run_dir> <block_name> <ECO_string>
{{env.PROJ_SHARE_TMP}}/${dst_stage}/${op4_dst_eco}/csh/check_starrc_log.csh {{env.RUN_LOG}}/star {{env.BLK_NAME}} ${eco_version} > {{env.RUN_RPT}}/${op4_dst_eco}/{{env.BLK_NAME}}.starrc_log.check.log


puts "Alchip-info : Completed signoff-check script--> starrc_log.check [info script]\n"	
