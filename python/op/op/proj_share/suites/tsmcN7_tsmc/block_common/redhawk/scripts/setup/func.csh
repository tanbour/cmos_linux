switch ($Redhawk_func)
   case FP :
      set flag_sta = 0
      set flag_session = 0
      set flag_Redhawk_spef = 0
      mkdir -p ./${Redhawk_work_dir}/scripts/gsr
      cp -rf $Redhawk_cp_dir/scripts/gsr/*/default_*.gsr ./$Redhawk_work_dir/scripts/gsr/
      cp -rf $Redhawk_cp_dir/scripts/cmd/gridCheck.cmd ./$Redhawk_work_dir/scripts/redhawk.cmd
      cp -rf $Redhawk_cp_dir/scripts/scr/runGridCheck.tcl ./$Redhawk_work_dir/scripts/
      cp -rf $Redhawk_cp_dir/scripts/gsr/design/IP.info ./$Redhawk_work_dir/scripts/gsr/
      cp -rf $Redhawk_cp_dir/scripts/gsr/design/mem.info ./$Redhawk_work_dir/scripts/gsr/
   breaksw
   case power :
      mkdir -p ./${Redhawk_work_dir}/scripts/gsr
      cp -rf $Redhawk_cp_dir/scripts/gsr/*/default_*.gsr ./$Redhawk_work_dir/scripts/gsr/
      cp -rf $Redhawk_cp_dir/scripts/cmd/redhawk_for_power.cmd ./$Redhawk_work_dir/scripts/redhawk.cmd
      cp -rf $Redhawk_cp_dir/scripts/gsr/design/IP.info ./$Redhawk_work_dir/scripts/gsr/
      cp -rf $Redhawk_cp_dir/scripts/gsr/design/mem.info ./$Redhawk_work_dir/scripts/gsr/
   breaksw
   case static :
      mkdir -p ./${Redhawk_work_dir}/scripts/gsr
      cp -rf $Redhawk_cp_dir/scripts/gsr/*/default_*.gsr ./$Redhawk_work_dir/scripts/gsr/
      cp -rf $Redhawk_cp_dir/scripts/cmd/redhawk_for_static.cmd ./$Redhawk_work_dir/scripts/redhawk.cmd
      cp -rf $Redhawk_cp_dir/scripts/gsr/design/IP.info ./$Redhawk_work_dir/scripts/gsr/
      cp -rf $Redhawk_cp_dir/scripts/gsr/design/mem.info ./$Redhawk_work_dir/scripts/gsr/
   breaksw
   case dynamic :
      mkdir -p ./${Redhawk_work_dir}/scripts/gsr
      cp -rf $Redhawk_cp_dir/scripts/gsr/*/default_*.gsr ./$Redhawk_work_dir/scripts/gsr/
      cp -rf $Redhawk_cp_dir/scripts/cmd/redhawk_for_dynamic.cmd ./$Redhawk_work_dir/scripts/redhawk.cmd
      cp -rf $Redhawk_cp_dir/scripts/gsr/design/IP.info ./$Redhawk_work_dir/scripts/gsr/
      cp -rf $Redhawk_cp_dir/scripts/gsr/design/mem.info ./$Redhawk_work_dir/scripts/gsr/
      sed -i "s?#import gsr ./scripts/gsr/apl.gsr?import gsr ./scripts/gsr/apl.gsr?g" ./$Redhawk_work_dir/scripts/redhawk.cmd
   breaksw
   case S_A_DV :
      mkdir -p ./${Redhawk_work_dir}/scripts/gsr
      cp -rf $Redhawk_cp_dir/scripts/gsr/*/default_*.gsr ./$Redhawk_work_dir/scripts/gsr/
      cp -rf $Redhawk_cp_dir/scripts/cmd/redhawk_for_all_flow.cmd ./$Redhawk_work_dir/scripts/redhawk.cmd
      cp -rf $Redhawk_cp_dir/scripts/gsr/design/IP.info ./$Redhawk_work_dir/scripts/gsr/
      cp -rf $Redhawk_cp_dir/scripts/gsr/design/mem.info ./$Redhawk_work_dir/scripts/gsr/
      sed -i "s?#import gsr ./scripts/gsr/apl.gsr?import gsr ./scripts/gsr/apl.gsr?g" ./$Redhawk_work_dir/scripts/redhawk.cmd
   breaksw
   case signalEM :
      mkdir -p ./${Redhawk_work_dir}/scripts/gsr
      cp -rf $Redhawk_cp_dir/scripts/gsr/*/default_*.gsr ./$Redhawk_work_dir/scripts/gsr/
      cp -rf $Redhawk_cp_dir/scripts/cmd/redhawk_for_signalEM.cmd ./$Redhawk_work_dir/scripts/redhawk.cmd
   breaksw
   case timing :
      if ($flag_session == 1) then
         mkdir -p ./${Redhawk_work_dir}
         cp -rf $Redhawk_cp_dir/scripts/scr/timing.csh ./$Redhawk_work_dir
         sed -i "s#sed_file_sta#${Redhawk_pt_session}#g" ./${Redhawk_work_dir}/timing.csh
         echo "create env successfully !"
         exit
      else
         echo "Error : please input Redhawk_pt_session dir !"
         exit
      endif
   breaksw
   case res :
      mkdir -p ./${Redhawk_work_dir}/scripts/gsr
      cp -rf $Redhawk_cp_dir/scripts/gsr/*/default_*.gsr ./$Redhawk_work_dir/scripts/gsr/
      cp -rf $Redhawk_cp_dir/scripts/cmd/redhawk_for_res.cmd ./$Redhawk_work_dir/scripts/redhawk.cmd
      cp -rf $Redhawk_cp_dir/scripts/gsr/design/IP.info ./$Redhawk_work_dir/scripts/gsr/
   breaksw
   case CPM :
      mkdir -p ./${Redhawk_work_dir}/scripts/gsr
      cp -rf $Redhawk_cp_dir/scripts/gsr/*/default_*.gsr ./$Redhawk_work_dir/scripts/gsr/
      cp -rf $Redhawk_cp_dir/scripts/cmd/redhawk_for_CPM.cmd ./$Redhawk_work_dir/scripts/redhawk.cmd
      cp -rf $Redhawk_cp_dir/scripts/gsr/design/IP.info ./$Redhawk_work_dir/scripts/gsr/
      cp -rf $Redhawk_cp_dir/scripts/gsr/design/mem.info ./$Redhawk_work_dir/scripts/gsr/
      sed -i "s?#import gsr ./scripts/gsr/apl.gsr?import gsr ./scripts/gsr/apl.gsr?g" ./$Redhawk_work_dir/scripts/redhawk.cmd
      echo "GENERATE_CPM 1" >> ./$Redhawk_work_dir/scripts/gsr/default_common.gsr
      echo "DEFER_VIA_CREATION 1" >> ./$Redhawk_work_dir/scripts/gsr/default_common.gsr
      echo "DYNAMIC_TIME_STEP 10ps" >> ./$Redhawk_work_dir/scripts/gsr/default_common.gsr
      echo "DYNAMIC_SOLVER_MODE 1" >> ./$Redhawk_work_dir/scripts/gsr/default_common.gsr
      echo "DYNAMIC_PRESIM_TIME 10n 1" >> ./$Redhawk_work_dir/scripts/gsr/default_common.gsr
   breaksw
   default:
      echo "Error : Please input the correct Redhawk_func name !"
      echo "Please input : [power] [static] [dynamic] [S_A_DV] [signalEM] [res] [timing] [FP] [CPM]"
      exit
   breaksw
endsw
foreach gsr_dir ( `ls -d ./$Redhawk_work_dir/scripts/gsr/default_*.gsr` )
   set gsr_dirchange = `echo "$gsr_dir" | sed 's?default_??g'`
   mv $gsr_dir  $gsr_dirchange
end
if ($Redhawk_enable_dynamic == 1 ) then
   if ( -e $Redhawk_cp_dir/scripts/gsr/vcd/VCD_${Redhawk_top}.gsr ) then
      cp -rf $Redhawk_cp_dir/scripts/gsr/vcd/VCD_${Redhawk_top}.gsr ./$Redhawk_work_dir/scripts/gsr/VCD.gsr
      sed -i "s?#import gsr ./scripts/gsr/VCD.gsr?import gsr ./scripts/gsr/VCD.gsr?g" ./$Redhawk_work_dir/scripts/redhawk.cmd
   endif
endif
if ( $flag_sta == 0 && $flag_session == 1 ) then
   mkdir -p ./$Redhawk_work_dir/timing
   cp -rf $Redhawk_cp_dir/scripts/scr/timing.csh ./$Redhawk_work_dir/timing
   sed -i "s#sed_file_sta#$Redhawk_pt_session#g" ./${Redhawk_work_dir}/timing/timing.csh
endif
if ( $Redhawk_assign_enabble == 1 ) then
   if ( $memTR_assign == 1) then
      if ( -e $Redhawk_cp_dir/scripts/gsr/assign/mem/${Redhawk_top}_mem.gsr ) then
         cp -rf $Redhawk_cp_dir/scripts/gsr/assign/mem/${Redhawk_top}_mem.gsr ./$Redhawk_work_dir/scripts/gsr/assign_memTR.gsr
         sed -i "s?#import gsr ./scripts/gsr/assign_memTR.gsr?import gsr ./scripts/gsr/assign_memTR.gsr?g" ./$Redhawk_work_dir/scripts/redhawk.cmd
      endif
   endif
   if ( $ipPower_assign == 1 ) then
      cp -rf $Redhawk_cp_dir/scripts/gsr/assign/ip/assign_instIP_power.gsr ./$Redhawk_work_dir/scripts/gsr/
      sed -i "s?#import gsr ./scripts/gsr/assign_instIP_power.gsr?import gsr ./scripts/gsr/assign_instIP_power.gsr?g" ./$Redhawk_work_dir/scripts/redhawk.cmd
   endif
endif
