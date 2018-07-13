set S_TR = `echo $TR1 $TR_ratio | awk '{ sum = $2 * $1 }; END { print sum }'`
set C_TR = `echo $TR2 $TR_ratio | awk '{ sum = $2 * $1 }; END { print sum }'`
if ( $Redhawk_func == "signalEM" ) then
   set S_TR = 1
   set C_TR = 2
endif
set REDHAWK_FREQ = `grep "^FREQUENCY" ./$Redhawk_work_dir/scripts/gsr/design.gsr | awk '{print $2}'`
echo "TOGGLE_RATE $S_TR $C_TR" >! ./$Redhawk_inputgsr
if ( $istop == 0 ) then
   echo "DEF_FILES {" >> ./$Redhawk_inputgsr
   echo "   $Redhawk_def" >> ./$Redhawk_inputgsr
   echo "}" >> ./$Redhawk_inputgsr
   echo "" >> ./$Redhawk_inputgsr
   if ($flag_Redhawk_spef == 1) then
      echo "CELL_RC_FILE {" >> ./$Redhawk_inputgsr
      echo "   EXTRACT_RC 0" >> ./$Redhawk_inputgsr
      echo "   CONDITION worst" >> ./$Redhawk_inputgsr
      echo "   $Redhawk_top $Redhawk_spef" >> ./$Redhawk_inputgsr
      echo "}" >> ./$Redhawk_inputgsr
      echo "" >> ./$Redhawk_inputgsr
   endif
   if ($flag_sta == 1 ) then
      echo "STA_FILE {" >> ./$Redhawk_inputgsr
      echo "   FREQ_OF_MISSING_INSTANCES $REDHAWK_FREQ" >> ./$Redhawk_inputgsr
      echo "   EXTRACT_CLOCK_NETWORK 0" >> ./$Redhawk_inputgsr
      echo "   $Redhawk_top $Redhawk_timing_file" >> ./$Redhawk_inputgsr
      echo "}" >> ./$Redhawk_inputgsr
      echo "" >> ./$Redhawk_inputgsr
   else if ($flag_session == 1) then
      echo "STA_FILE {" >> ./$Redhawk_inputgsr
      echo "   FREQ_OF_MISSING_INSTANCES $REDHAWK_FREQ" >> ./$Redhawk_inputgsr
      echo "   EXTRACT_CLOCK_NETWORK 0" >> ./$Redhawk_inputgsr
      echo "   $Redhawk_top ./timing/$Redhawk_top.timing" >> ./$Redhawk_inputgsr
      echo "}" >> ./$Redhawk_inputgsr
      echo "" >> ./$Redhawk_inputgsr
   endif
   echo "PAD_FILES {" >> ./$Redhawk_inputgsr
   echo "   $Redhawk_ploc" >> ./$Redhawk_inputgsr
   if ( -e "$Redhawk_ploc_dir/pad/${Redhawk_top}.pad" ) then
      echo "   $Redhawk_ploc_dir/pad/${Redhawk_top}.pad" >> ./$Redhawk_inputgsr 
   endif
   echo "}" >> ./$Redhawk_inputgsr
   echo "" >> ./$Redhawk_inputgsr
else if ( $istop == 1 ) then
## read def for top
#   set def_num = `echo $Redhawk_def | wc -w`
#   @ def_num = $def_num / 2
   echo "DEF_FILES {" >> ./$Redhawk_inputgsr
   set d = 1
   while ( $d )
      set tdef = `echo $Redhawk_def[$d] | awk '{print $1}'`
      set bort = `echo $Redhawk_def[$d] | awk '{print $2}'`
      echo "   $tdef $bort" >> ./$Redhawk_inputgsr
      @ f_def = ( $d < $def_num )
      if ( $f_def != 0 ) then
         @ d = $d + 1
      else
         break
      endif
   end
   echo "}" >> ./$Redhawk_inputgsr
   echo "" >> ./$Redhawk_inputgsr
## read spef
   if ( $flag_Redhawk_spef == 1) then
      echo "CELL_RC_FILE {" >> ./$Redhawk_inputgsr
      echo "   EXTRACT_RC 0" >> ./$Redhawk_inputgsr
      echo "   CONDITION worst" >> ./$Redhawk_inputgsr
#      set spef_num = `echo $Redhawk_spef | wc -w`
#      @ spef_num = $spef_num / 2
      set sp = 1
      while ( $sp )
         set tblock = `echo $Redhawk_spef[$sp] | awk '{print $1}'`
         set spef_file = `echo $Redhawk_spef[$sp] | awk '{print $2}'`
         echo "   $tblock $spef_file" >> ./$Redhawk_inputgsr
         @ f_spef = ($sp < $spef_num)
         if ($f_spef != 0 ) then
            @ sp = $sp + 1
         else
            break
         endif
      end
      echo "}" >> ./$Redhawk_inputgsr
      echo "" >> ./$Redhawk_inputgsr
   endif
## read timing file
   if ( $flag_sta_block == 1 && $flag_sta == 1) then
      echo "BLOCK_STA_FILES {" >> ./$Redhawk_inputgsr
      echo "   FREQ_OF_MISSING_INSTANCES $REDHAWK_FREQ" >> ./$Redhawk_inputgsr
      echo "   EXTRACT_CLOCK_NETWORK 0" >> ./$Redhawk_inputgsr
#      set sta_num = `echo $Redhawk_timing_file | wc -w`
#      @ sta_num = $sta_num / 2
      set st = 1
      while ( $st )
         set blockname = `echo $Redhawk_timing_file[$st] | awk '{print $1}'`
         set stafile = `echo $Redhawk_timing_file[$st] | awk '{print $2}'`
         echo "   $blockname $stafile" >> ./$Redhawk_inputgsr
         @ f_sta = ( $st < $sta_num )
         if ( $f_sta != 0 ) then
            @ st = $st + 1
         else
            break
         endif
      end
      echo "}" >> ./$Redhawk_inputgsr
      echo "" >> ./$Redhawk_inputgsr
   else if ($flag_sta_block == 0 && $flag_sta == 1) then
      echo "STA_FILE {" >> ./$Redhawk_inputgsr
      echo "   FREQ_OF_MISSING_INSTANCES $REDHAWK_FREQ" >> ./$Redhawk_inputgsr
      echo "   EXTRACT_CLOCK_NETWORK 0" >> ./$Redhawk_inputgsr
      echo "   $Redhawk_top $Redhawk_timing_file" >> ./$Redhawk_inputgsr
      echo "}" >> ./$Redhawk_inputgsr
      echo "" >> ./$Redhawk_inputgsr
   endif
## read ploc
   echo "PAD_FILES {" >> ./$Redhawk_inputgsr
   echo "   $Redhawk_ploc" >> ./$Redhawk_inputgsr
   if ( -e "$Redhawk_ploc_dir/pad/${Redhawk_top}.pad" ) then
      echo "   $Redhawk_ploc_dir/pad/${Redhawk_top}.pad" >> ./$Redhawk_inputgsr
   endif
   echo "}" >> ./$Redhawk_inputgsr
   echo "" >> ./$Redhawk_inputgsr
endif
