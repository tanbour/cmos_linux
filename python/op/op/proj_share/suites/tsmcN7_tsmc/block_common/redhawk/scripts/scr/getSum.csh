#!/bin/csh -e
set scr_dir = `dirname $0`
#set scr_dir = "/alchip/home/vivian_lu/ELE/env/EDA/redhawk/GRAPE-PFN2/tt_0p55v/scripts/scr"
if ( -e info.txt ) then
   set func = `grep "Redhawk_func" info.txt | awk '{print $NF}'`
   set timingFile = `grep "timing" ./scripts/gsr/inputData.gsr | awk '{print $NF}'`
else 
   set func = "power"
endif

if ($func == "CPM") then
   exit
endif

set sum_dir = "summary"
#source $scr_dir/get_info.csh
if ( ! -e $sum_dir ) then
   mkdir $sum_dir
endif
source $scr_dir/check_result.csh > ${sum_dir}/report_need_check.sum
if ( $func == "power" ) then
   perl $scr_dir/redhawk_sum_for_static.pl adsRpt/power_summary.rpt > ${sum_dir}/power.sum
   cat ${sum_dir}/power.sum
endif

if ( $func == "static" || $func == "S_A_DV" || $func == "top_static" ) then
   perl $scr_dir/redhawk_sum_for_static.pl adsRpt/power_summary.rpt adsRpt/Static/*.inst.worst adsRpt/Static/*inst adsRpt/Static/*em.worst  > ${sum_dir}/redhawk_static.sum 
   cat ${sum_dir}/redhawk_static.sum | sed "s?static_ir_violation_cell.rpt?$sum_dir/static_ir_violation_cell.rpt?g" | sed "s?\.\.\/??g"
   if ( -e static_ir_violation_cell.rpt ) then
      mv static_ir_violation_cell.rpt $sum_dir
   endif
   if ( -e ./scripts/gsr/IP.info ) then
      perl ${scr_dir}/get_Redhawk_static_info.pl  ./adsRpt/*.power.rpt ./adsRpt/Static/*.inst.pin ./adsRpt/Static/*.inst.arc ./scripts/gsr/IP.info 1 ./adsRpt/*.res_calc
      mv PIN_static.info $sum_dir
   endif
   set ip_flag = `grep '#perform res_calc -cellFile ./scripts/gsr/IP.info' ./scripts/redhawk.cmd -c`
   if ( $ip_flag == 0 ) then
      perl $scr_dir/get_Static_violation.pl all ${sum_dir}/IP_static_violation ./scripts/gsr/IP.info ./adsRpt/*.power.rpt ./adsRpt/Static/*.inst ./adsRpt/*.res_calc
   endif
endif

if ( $func == "dynamic" || $func == "S_A_DV") then
   perl $scr_dir/get_Dynaimc_violation.pl $timingFile ./adsRpt/Dynamic/*.dvd > ${sum_dir}/dynamic_ir.sum
   perl $scr_dir/redhawk_sum_for_EM.pl adsRpt/Dynamic/*.worst.peak adsRpt/Dynamic/*.worst.rms adsRpt/Dynamic/*.worst.avg > ${sum_dir}/dynamic_em.sum
   perl $scr_dir/get_Redhawk_dynamic_info.pl ./adsRpt/power_summary.rpt ./adsRpt/Dynamic/*.dvd.pin ./adsRpt/Dynamic/*.dvd.arc $timingFile ./scripts/gsr/IP.info
   mv PIN_dynamic.info $sum_dir
   echo ""
   grep SUM ${sum_dir}/dynamic_ir.sum | sed "s?^##??"
   cat ${sum_dir}/dynamic_em.sum | sed "s?\.\.\/??g"
endif

if ( $func == "signalEM" ) then
   perl $scr_dir/redhawk_sum_for_EM.pl adsRpt/SignalEM/*.worst.peak adsRpt/SignalEM/*.worst.rms adsRpt/SignalEM/*.worst.avg > ${sum_dir}/signalEM.sum
   cat ${sum_dir}/signalEM.sum | sed "s?\.\.\/??g"
endif
