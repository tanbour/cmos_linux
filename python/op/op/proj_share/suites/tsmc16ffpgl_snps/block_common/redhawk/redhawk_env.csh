#!/bin/csh -e
set Redhawk_func = $1
set Redhawk_top = $2
set Redhawk_def = $3
set Redhawk_spef = $4
set Redhawk_pt_session = $5
set Redhawk_timing_file = $6
set Redhawk_enable_dynamic = $7
set Redhawk_ploc = $8
set Redhawk_work_dir = $9
set Redhawk_dynamic_file = $10
set Redhawk_flag_sigEM = 0
set Redhawk_res_cp_dir = `dirname $0`
set Redhawk_cp_dir = "$Redhawk_res_cp_dir"
set Redhawk_blockinfo_dir = "$Redhawk_res_cp_dir/block.info"
set Redhawk_inputgsr = "./$Redhawk_work_dir/scripts/gsr/inputData.gsr"
set Redhawk_ploc_dir = "$Redhawk_cp_dir/scripts/gsr/ploc"
set Redhawk_wait_file = 0
set Redhawk_assign_enabble = 1
set Redhawk_update = 0
#===================================================================
#=================== internal run ==================================
#===================================================================
if ( -e $Redhawk_work_dir ) then
   echo "Error (redhawk) : please change Redhawk_work_dir name"
   exit
endif

if ( $USER != "vivian_lu" && $USER != "cheiikx" ) then
   if ($Redhawk_update == 1 ) then
      echo "INFO redhawk : redhawk env is updating please wait"
      exit
   endif
endif
set TR1 = `grep -v "^#" $Redhawk_blockinfo_dir | grep "$Redhawk_top " | awk '{print $2}'`
set TR2 = `grep -v "^#" $Redhawk_blockinfo_dir | grep "$Redhawk_top " | awk '{print $3}'`
set TR_ratio = `grep -v "^#" $Redhawk_blockinfo_dir | grep "$Redhawk_top " | awk '{print $4}'`
set memTR_assign = `grep -v "^#" $Redhawk_blockinfo_dir | grep "$Redhawk_top " | awk '{print $5}'`
set ipPower_assign = `grep -v "^#" $Redhawk_blockinfo_dir | grep "$Redhawk_top " | awk '{print $6}'`
set istop = `grep -v "^#" $Redhawk_blockinfo_dir | grep "$Redhawk_top " | awk '{print $7}'`
if ( $Redhawk_func == "signalEM" ) then
   set Redhawk_enable_dynamic = 0
endif
if ( $TR_ratio == "" ) then
   echo "Error (redhawk) : please check Redhawk_top name"
   exit
endif
source $Redhawk_cp_dir/scripts/setup/setting.csh
if ($flag == 1) then
   echo "create env fail"
   exit
endif
source $Redhawk_cp_dir/scripts/setup/func.csh
source $Redhawk_cp_dir/scripts/setup/output.csh
source $Redhawk_cp_dir/scripts/setup/getRun.csh

############################# special setting ######################
#if ( $Redhawk_func == "static" || $Redhawk_func == "S_A_DV" || $Redhawk_func == "top_static" ) then
#   echo "#perl $Redhawk_cp_dir/scripts/scr/get_Static_violation.pl all IP_static_violation ./scripts/gsr/IP.info ./adsRpt/*.power.rpt ./adsRpt/Static/*.inst ./adsRpt/*.res_calc" >> ./${Redhawk_work_dir}/run
#   echo "#perl $Redhawk_cp_dir/scripts/scr/get_Static_violation.pl all MEMORY_static_violation ./scripts/gsr/mem.info ./adsRpt/*.power.rpt ./adsRpt/Static/*.inst ./adsRpt/*.res_calc" >> ./${Redhawk_work_dir}/run
#   echo "#perl $Redhawk_cp_dir/scripts/scr/redhawk_sum_for_static.pl ./adsRpt/power_summary.rpt ./adsRpt/Static/*.inst.worst ./adsRpt/Static/*inst ./adsRpt/Static/*em.worst" >> ./${Redhawk_work_dir}/run
#endif
#if ( $Redhawk_func == "power" ) then
#   echo "#perl $Redhawk_cp_dir/scripts/scr/redhawk_sum_for_static.pl ./adsRpt/power_summary.rpt" >> ./${Redhawk_work_dir}/run
#endif
#if ( $Redhawk_func == "signalEM" ) then
#   echo "#perl $Redhawk_cp_dir/scripts/scr/redhawk_sum_for_EM.pl adsRpt/SignalEM/*.worst.peak adsRpt/SignalEM/*.worst.rms adsRpt/SignalEM/*.worst.avg" >> ./${Redhawk_work_dir}/run
#endif
#if ( $Redhawk_func == "dynamic" ) then
#   echo "#perl $Redhawk_cp_dir/scripts/scr/get_Dynaimc_violation.pl $Redhawk_timing_file ./adsRpt/Dynamic/*.dvd  > dynamic_ir" >> ./${Redhawk_work_dir}/run
#   echo "#perl $Redhawk_cp_dir/scripts/scr/redhawk_sum_for_EM.pl ./adsRpt/Dynamic/*.worst.peak ./adsRpt/Dynamic/*.worst.rms /adsRpt/Dynamic/*.worst.avg" >> ./${Redhawk_work_dir}/run
#endif
#if ( $Redhawk_func == "dynamic" || $Redhawk_func == "S_A_DV") then
#   sed -i "s?FILE_TYPE       RTL_FSDB?FILE_TYPE       FSDB?g" $Redhawk_work_dir/scripts/gsr/VCD.gsr
#   sed -i "s?VCD_DRIVEN 1?#VCD_DRIVEN 1?g" $Redhawk_work_dir/scripts/gsr/VCD.gsr
#   sed -i "s?TRUE_TIME       0?TRUE_TIME       1?g" $Redhawk_work_dir/scripts/gsr/VCD.gsr
#   if ( $Redhawk_timing_file != "MISS" ) then
#      if ( $Redhawk_top == "lmu_we" ) then
#         echo "#perl $Redhawk_cp_dir/scripts/scr/get_Redhawk_dynamic_info.pl $Redhawk_timing_file ./adsRpt/Dynamic/*.dvd 12 20 25 > dynamic_IR_violation" >> ./${Redhawk_work_dir}/run
#      else
#         echo "#perl $Redhawk_cp_dir/scripts/scr/get_Redhawk_dynamic_info.pl $Redhawk_timing_file ./adsRpt/Dynamic/*.dvd 15 20 25 > dynamic_IR_violation" >> ./${Redhawk_work_dir}/run
#      endif
#   endif
#endif
#if ($Redhawk_enable_dynamic == "1" && $Redhawk_dynamic_file != "MISS" ) then
#   sed -i "s?hash_top sed_vcd?hash_top $Redhawk_dynamic_file?g" $Redhawk_work_dir/scripts/gsr/VCD.gsr
#endif
##########################get info #################################
source $Redhawk_cp_dir/scripts/setup/getinfo.csh
