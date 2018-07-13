set S_TR = `echo $TR1 $TR_ratio | awk '{ sum = $2 * $1 }; END { print sum }'`
set C_TR = `echo $TR2 $TR_ratio | awk '{ sum = $2 * $1 }; END { print sum }'`
if ( $Redhawk_func == "signalEM" ) then
   set S_TR = 0.5
   set C_TR = 2
endif
set REDHAWK_FREQ = `grep "^FREQUENCY" ./$Redhawk_work_dir/scripts/gsr/design.gsr | awk '{print $2}'`
echo "TOGGLE_RATE $S_TR $C_TR" >! ./$Redhawk_inputgsr
if ( $Redhawk_func != "Redhawk_top_static" && $Redhawk_func != "Redhawk_top_signalEM" ) then
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
endif
