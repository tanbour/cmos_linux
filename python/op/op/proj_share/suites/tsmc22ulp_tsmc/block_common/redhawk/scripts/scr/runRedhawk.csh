cat <<runredhawkGo > $ELE_redhawkWorkdir/runRedhawk.go
#! /bin/csh
#===================================================================
#=================== input data setting ============================
#===================================================================
set top = "$ELE_top"
set def = "$ELE_def"
set spef = "$ELE_spef"
set timing_file = "$ELE_timing_file"
set work_dir = "$ELE_sub_dir"
#===================================================================
#=================== default setting ===============================
#===================================================================
set func = "$ELE_func" 
set saif_VCD = "$ELE_enable_dynamic"
set source_ploc = "$ELE_ploc"
set pt_session = "$ELE_pt_session"

source $ELE_res_all/redhawk/Default/redhawkenv.csh \$func \$top \$def \$spef \$pt_session \$timing_file \$saif_VCD \$source_ploc \$work_dir
runredhawkGo
