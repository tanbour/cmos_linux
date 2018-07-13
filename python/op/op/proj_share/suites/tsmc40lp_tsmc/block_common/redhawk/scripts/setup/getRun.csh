if ($Redhawk_func == "signalEM" || $Redhawk_func == "top_signalEM" ) then
cat <<runredhawk > ./$Redhawk_work_dir/run
#sed_wait_def
#sed_wait_spef
#sed_wait_timingfile
#sed_wait_ptsession
#===================================================================
#=================== license setting ===============================
#===================================================================
source /apps/setenv_license.csh
#source /apps/wx_license.csh
#setenv APACHEDA_LICENSE_FILE 1881@B02
#setenv APACHEDA_LICENSE_FILE 1881@lic41
#setenv APACHEDA_LICENSE_FILE 1881@lansing
#setenv APACHEDA_LICENSE_FILE 27770@cs03
#setenv APACHEROOT /tools_lib3/apps/redhawk/RedHawk_Linux64e5_V14.1.3p1
#setenv APACHEROOT /tools_lib3/apps/redhawk/RedHawk_Linux64e5_V15.2.4
#setenv APACHEROOT /tools_lib3/apps/redhawk/RedHawk_Linux64e5_V14.2.8
#setenv APACHEROOT /proj/Mars2_new/WORK/donid/from_customer/20161219/RedHawk_Linux64e5_V15.2.4
setenv APACHEROOT /tools_lib3/apps/redhawk/RedHawk_Linux64e5_V18.0.3p2
source \$APACHEROOT/setup.csh
source /opt/openlava/etc/openlava.csh
#===================================================================
#=================== run redhawk ===================================
#===================================================================
echo "time : start redhawk at \`date\`" >> ./info.txt
#redhawk -b ./scripts/redhawk.cmd -lmwait
bsub -q fjr -P FJR1300 -Is -n 16  -R "span[hosts=1] rusage[mem=50000]" "redhawk -b ./scripts/redhawk.cmd -lmwait"
#redhawk
echo "time : end redhawk at \`date\`"  >> ./info.txt
#===================================================================
#=================== get info ======================================
#===================================================================
$Redhawk_cp_dir/scripts/scr/getSum.csh
$Redhawk_cp_dir/scripts/scr/rm.csh
runredhawk

else if ($flag_session == 1 && $flag_sta == 0) then
cat <<runredhawk > ./$Redhawk_work_dir/run
#sed_wait_def
#sed_wait_spef
#sed_wait_timingfile
#sed_wait_ptsession
#===================================================================
#=================== pt_session2timingfile =========================
#===================================================================

echo "time : start pt at \`date\`" >> ./info.txt
cd timing
source timing.csh
cd ..
echo "time : end pt at \`date\`" >> ./info.txt

#===================================================================
#=================== license setting ===============================
#===================================================================

rm ~/.flexlmrc
source /apps/setenv_license.csh
#setenv APACHEDA_LICENSE_FILE 1881@lic41
#setenv APACHEROOT /tools_lib3/apps/redhawk/RedHawk_Linux64e5_V14.1.3p1
#setenv APACHEROOT /tools_lib3/apps/redhawk/RedHawk_Linux64e5_V15.2.4
setenv APACHEROOT /tools_lib3/apps/redhawk/RedHawk_Linux64e5_V18.0.3p2
source \$APACHEROOT/setup.csh
source /opt/openlava/etc/openlava.csh

#===================================================================
#=================== run redhawk ===================================
#===================================================================
#we can use -f to call the redhawk window [-b]
echo "time : start redhawk at \`date\`" >> ./info.txt
#redhawk -b ./scripts/redhawk.cmd -lmwait
bsub -q fjr -P FJR1300 -Is -n 16  -R "span[hosts=1] rusage[mem=50000]" "redhawk -b ./scripts/redhawk.cmd -lmwait"
#redhawk
echo "time : end redhawk at \`date\`"  >> ./info.txt
echo "" >> ./info.txt

#===================================================================
#=================== get info ======================================
#===================================================================
$Redhawk_cp_dir/scripts/scr/getSum.csh
$Redhawk_cp_dir/scripts/scr/rm.csh
runredhawk

else
cat <<runredhawk > ./${Redhawk_work_dir}/run
#sed_wait_def
#sed_wait_spef
#sed_wait_timingfile
#sed_wait_ptsession
#===================================================================
#=================== license setting ===============================
#===================================================================

rm ~/.flexlmrc
source /apps/setenv_license.csh
#setenv APACHEDA_LICENSE_FILE 1881@lic41
#setenv APACHEROOT /tools_lib3/apps/redhawk/RedHawk_Linux64e5_V14.1.3p1
#setenv APACHEROOT /tools_lib3/apps/redhawk/RedHawk_Linux64e5_V15.2.4
setenv APACHEROOT /tools_lib3/apps/redhawk/RedHawk_Linux64e5_V18.0.3p2
source \$APACHEROOT/setup.csh
source /opt/openlava/etc/openlava.csh

#===================================================================
#=================== run redhawk ===================================
#===================================================================
#we can use -f to call the redhawk window [-b]
echo "time : start redhawk at \`date\`" >> ./info.txt
#redhawk -b ./scripts/redhawk.cmd -lmwait
bsub -q fjr -P FJR1300 -Is -n 16  -R "span[hosts=1] rusage[mem=50000]" "redhawk -b ./scripts/redhawk.cmd -lmwait"
#redhawk
echo "time : end redhawk at \`date\`"  >> ./info.txt
echo "" >> ./info.txt

#===================================================================
#=================== get info ======================================
#===================================================================
$Redhawk_cp_dir/scripts/scr/getSum.csh
$Redhawk_cp_dir/scripts/scr/rm.csh
runredhawk

endif
