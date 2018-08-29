
#===================================================================
#=================== license setting ===============================
#===================================================================
#source /apps/setenv_license.csh
#setenv APACHEROOT /tools_lib3/apps/redhawk/RedHawk_Linux64e5_V18.0.3p2
#source \$APACHEROOT/setup.csh
#===================================================================
#=================== run redhawk ===================================
#===================================================================
cd {{local._multi_inst}}
echo "time : start redhawk at `date`" >> ./info.txt
#bsub {{local._job_queue}} -P FJR1300 -Is {{local._job_cpu_number}}  {{local._job_resource}} "redhawk -b ./scripts/redhawk.cmd -lmwait"
redhawk -b ./scripts/redhawk.cmd -lmwait
#redhawk
echo "time : end redhawk at `date`"  >> ./info.txt
#===================================================================
#=================== get info ======================================
#===================================================================
echo "run $Redhawk_res_cp_dir/scripts/scr/getSum.csh"
$Redhawk_res_cp_dir/scripts/scr/getSum.csh
echo "run $Redhawk_res_cp_dir/scripts/scr/rm.csh"
$Redhawk_res_cp_dir/scripts/scr/rm.csh
echo "{{env.FIN_STR}}"
