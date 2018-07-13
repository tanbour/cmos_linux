# /bin/csh 
set dir = `ls -d $cwd`
if ( -e ./adsRpt/power_summary.rpt ) then 
   cat ./info.txt >> /proj/Mars2_new2/WORK/cheiik/INFO/redhawk_run_data.txt
endif  
#ls -d $cwd/*.timing >> /proj/Jupiter_gcs/WORK/cheiik/redhawk/tool/Log/run_data.txt
#ls -d $dir/adsPower/power_summary.rpt >> /proj/Jupiter_gcs/WORK/cheiik/redhawk/tool/Log/run_data.txt
echo "run_dir : $dir" >> /proj/Mars2_new2/WORK/cheiik/INFO/redhawk_run_data.txt
