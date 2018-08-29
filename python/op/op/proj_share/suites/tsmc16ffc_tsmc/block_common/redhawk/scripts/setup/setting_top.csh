set def_n = `echo $Redhawk_def | wc -w`
if ($def_n == 1) then
   set istop = 0
endif
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
else
#   set def_n = `echo $Redhawk_def | wc -w`
   @ flag_top_def = $def_n % 2
   @ def_num = $def_n / 2
   set sta_n = `echo $Redhawk_timing_file | wc -w`
   @ flag_top_sta = $sta_n % 2
   @ sta_num = $sta_n / 2
   set spef_n = `echo $Redhawk_spef | wc -w`
   @ flag_top_spef = $spef_n % 2
   @ spef_num = $spef_n / 2
   if ( $flag_top_def != 0 ) then
      echo "Error (redhaek) : Redhawk_def format for top is wrong,please check!"
      set flag = 1
   endif
   if ( $flag_top_sta != 0 && $sta_n != 1 ) then
      echo "Error (redhawk) : Redhawk_sta format for top is wrong , please check!"
      set flag = 1
   endif
   if ( $flag_top_spef != 0 && $spef_n != 1) then
      echo "Error (redhawk) : Redhawk_spef format for top is wrong , please check!"
      set flag = 1
   endif
# check def
   set n = 1
   while ($n)
      set def_file = `echo $Redhawk_def[$n] | awk '{print $1}'`
      if ( ! -e $def_file && $Redhawk_wait_file == 0 ) then
         echo "Error (redhawk) : $def_file is not exists!"
         set flag = 1
      endif
      @ f = ( $n < $def_num )
      if ( $f != 0 ) then
         @ n = $n + 1
      else
         break
      endif
   end
# check spef
   if ($Redhawk_wait_file == 1 ) then
      set flag_Redhawk_spef = 1
   else if ($spef_n == 1) then
      if ($Redhawk_spef == "MISS") then
         set flag_Redhawk_spef = 0
      endif
   else
      set flag_Redhawk_spef = 1
      set n = 1
      while ($n)
         set spef_file = `echo $Redhawk_spef[$n] | awk '{print $2}'`
         if ( ! -e $spef_file ) then
            echo "Error (redhawk) : $spef_file is not exists!"
            set flag = 1
            set flag_Redhawk_spef = 0
         endif
         @ f = ($n < $spef_num)
         if ( $f != 0 ) then
            @ n = $n + 1
         else
            break
         endif
      end
   endif
# check timing file
   if ( $sta_n == 1) then
      if ($Redhawk_timing_file == "MISS") then
         set flag_sta = 0
         set flag_sta_block = "MISS"
      else if ( -e $Redhawk_timing_file ) then
         set flag_sta_block = 0
         set flag_sta = 1
      else
         echo "Error (redhawk) : $Redhawk_timing_file is not exists!"
         set flag = 1
      endif
   else
      set flag_sta_block = 1
   endif
   if ($Redhawk_wait_file == 1 ) then
      set flag_sta = 1
   else if ($flag_sta_block == 1) then
      set flag_sta = 1
      set n = 1
      while ($n)
         set sta_file = `echo $Redhawk_timing_file[$n] | awk '{print $2}'`
         if ( ! -e $sta_file ) then
            echo "Error (redhawk) : $sta_file is not exists!"
            set flag = 1
            set flag_sta = 0
         endif
         @ f = ($n < $sta_num)
         if ( $f != 0 ) then
            @ n = $n + 1
         else
            break
         endif
      end
   endif
   if ($Redhawk_ploc == "MISS" ) then
      set Redhawk_ploc = `ls -d --file-type $Redhawk_ploc_dir/${Redhawk_top}.ploc`
   else if (! -e $Redhawk_ploc ) then
      echo "ERROR (redhawk) : Redhawk_ploc file not exists!"
      set flag = 1
   endif
set flag_session = 0
endif
