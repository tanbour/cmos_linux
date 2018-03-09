#
# DFT
#
puts "DFT Scan checking..."

puts "---------------------------------------------------------------"
puts "current_goal dft/dft_scan_ready -top ${TOP}..."
puts "---------------------------------------------------------------"
#current_goal dft/dft_scan_ready -top ${TOP}
#foreach waive_rule ${WAIVE_dft_dft_scan_ready} {  waive -rule $waive_rule }
#run_goal
#save_goal
##capture ./reports/soc_dft_scan_ready.rpt {write_report sypglass_violations}


puts "---------------------------------------------------------------"
puts "current_goal dft/dft_best_practice -top ${TOP}..."
puts "---------------------------------------------------------------"
#current_goal dft/dft_best_practice -top ${TOP}
#foreach waive_rule ${WAIVE_dft_dft_best_practice} {  waive -rule $waive_rule }
#run_goal
#save_goal
##capture ./reports/soc_dft_best_practice.rpt {write_report sypglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal dft/dft_bist_ready -top ${TOP}..."
puts "---------------------------------------------------------------"
#current_goal dft/dft_bist_ready -top ${TOP}
#foreach waive_rule ${WAIVE_dft_dft_bist_ready} {  waive -rule $waive_rule }
#run_goal
#save_goal
##capture ./reports/soc_dft_bist_ready.rpt {write_report sypglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal dft/dft_dsm_best_practice -top ${TOP}..."
puts "---------------------------------------------------------------"
#current_goal dft/dft_dsm_best_practice -top ${TOP}
#foreach waive_rule ${WAIVE_dft_dft_dsm_best_practice} {  waive -rule $waive_rule }
#run_goal
#save_goal
##capture ./reports/soc_dft_dsm_best_practice.rpt {write_report sypglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal dft/dft_dsm_random_resistance -top ${TOP}..."
puts "---------------------------------------------------------------"
#current_goal dft/dft_dsm_random_resistance -top ${TOP}
#foreach waive_rule ${WAIVE_dft_dft_dam_random_resistance} {  waive -rule $waive_rule }
#run_goal
#save_goal
##capture ./reports/soc_dft_dsm_random_resistance.rpt {write_report sypglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal dft/dft_abstract -top ${TOP}..."
puts "---------------------------------------------------------------"
#current_goal dft/dft_abstract -top ${TOP}
#foreach waive_rule ${WAIVE_dft_dft_abstract} {  waive -rule $waive_rule }
#run_goal
#save_goal
##capture ./reports/soc_dft_bstract.rpt {write_report sypglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal dft/dft_dsm_best_practice -top ${TOP}..."
puts "---------------------------------------------------------------"
#current_goal dft/dft_dsm_best_practice -top ${TOP}
#foreach waive_rule ${WAIVE_dft_dft_dsm_best_practice} {  waive -rule $waive_rule }
#run_goal
#save_goal
##capture ./reports/soc_dftt_practice.rpt {write_report sypglass_violations}



