echo "create env $cwd/${Redhawk_work_dir} successfully !"
echo "#------------------$Redhawk_top---------------------" > ./${Redhawk_work_dir}/info.txt
echo "sever name : `hostname`" >> ./${Redhawk_work_dir}/info.txt
echo "user name : $USER" >> ./${Redhawk_work_dir}/info.txt
echo "date new env : `date`" >> ./${Redhawk_work_dir}/info.txt
echo "work dir : ${cwd}/${Redhawk_work_dir}" >> ./${Redhawk_work_dir}/info.txt
echo "Redhawk_func : $Redhawk_func"  >> ./${Redhawk_work_dir}/info.txt
echo "Redhawk_def : $Redhawk_def" >> ./${Redhawk_work_dir}/info.txt
if ($flag_Redhawk_spef == 1) then
   echo "Redhawk_spef : $Redhawk_spef" >> ./${Redhawk_work_dir}/info.txt
endif
if ($flag_session == 1) then
   echo "Redhawk_pt_session file : $Redhawk_pt_session" >> ./${Redhawk_work_dir}/info.txt
endif
if ($flag_sta == 1) then
   echo "timing file : $Redhawk_timing_file" >> ./${Redhawk_work_dir}/info.txt
endif
