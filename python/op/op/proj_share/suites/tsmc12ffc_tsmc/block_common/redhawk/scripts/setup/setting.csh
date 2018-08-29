set istop = 0
set flag = 0
if ( $istop == 0 ) then
if ( ! -e $Redhawk_def ) then
   if ( $Redhawk_def == "MISS") then
      echo "Error (redhawk) : Redhawk_def file not exist !"
      set flag = 1
   else if ( $Redhawk_wait_file == 0 ) then
      echo "Error (redhawk) : Redhawk_def file not exist !"
      set flag = 1
   endif
endif
if ( $Redhawk_spef != "MISS" && -e $Redhawk_spef ) then
   set flag_Redhawk_spef = 1
else if ($Redhawk_spef == "MISS") then
   set flag_Redhawk_spef = 0
else if ($Redhawk_wait_file == 1) then
   set flag_Redhawk_spef = 1
else
   echo "Error (redhawk) : Redhawk_spef file not exist !"
   set flag = 1
endif
if ( $Redhawk_pt_session != "MISS" && -e $Redhawk_pt_session ) then
   set flag_session = 1
else if ($Redhawk_pt_session == "MISS") then
   set flag_session = 0
else if ( $Redhawk_wait_file == 1) then
   set flag_session = 1
else
   echo "Error (redhawk) : Redhawk_pt_session file not exist !"
   set flag = 1
endif
if ( $Redhawk_timing_file != "MISS" && -e $Redhawk_timing_file ) then
   set flag_sta = 1
else if ($Redhawk_timing_file == "MISS") then
   set flag_sta = 0
else if ( $Redhawk_wait_file == 1 ) then
   set flag_sta = 1
else
   echo "Error (redhawk) : timing file not exist !"
   set flag = 1
endif
if ($Redhawk_ploc == "MISS" ) then
   set Redhawk_ploc = `ls -d --file-type $Redhawk_ploc_dir/${Redhawk_top}.ploc`
else if (! -e $Redhawk_ploc ) then
   echo "ERROR (redhawk) : Redhawk_ploc file not exists!"
   set flag = 1
endif
endif
