# 
#  run goal
#

#
# LINT check
#
puts "LINT Checking..."
puts "---------------------------------------------------------------"
puts "current_goal lint/lint_rtl -top ${TOP}..."
puts "---------------------------------------------------------------"
current_goal lint/lint_rtl -top ${TOP}
source {{cur.config_plugins_dir}}/spyglass_scripts/waive_rules/waive_lint_lint_rtl.tcl
foreach waive_rule ${WAIVE_lint_lint_rtl} {  waive -rule $waive_rule -comment {Add by Alchip}; puts "waive -rule $waive_rule -comment {Add by Alchip}"}
run_goal
save_goal
capture $REPORT_DIR/soc_lint_rtl.rpt {write_report spyglass_violations}
#current_goal lint/lint_turbo_rtl -top ${TOP}
#run_goal
#save_goal
#capture $REPORT_DIR/soc_lint_turbol_rtl.rpt {write_report spyglass_violations}

#current_goal lint/lint_functional_rtl -top ${TOP}
#run_goal
#save_goal
#capture $REPORT_DIR/soc_lint_functional_rtl.rpt {write_report spyglass_violations}

#current_goal lint/lint_abstract -top ${TOP}
#run_goal
#save_goal
#capture $REPORT_DIR/soc_lint_abstract.rpt {write_report spyglass_violations}

#
# Constraints check
#
puts "SDC checking..."
puts "---------------------------------------------------------------"
puts "current_goal constraints/sdc_audit -top ${TOP}..."
puts "---------------------------------------------------------------"
current_goal constraints/sdc_audit -top ${TOP}
foreach waive_rule ${WAIVE_constraints_sdc_audit} { waive -rule $waive_rule -comment {Add by Alchip}; puts "waive -rule $waive_rule -comment {Add by Alchip}" }
run_goal
save_goal
capture $REPORT_DIR/soc_sdc_audit.rpt {write_report spyglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal constraints/sdc_check -top ${TOP}..."
puts "---------------------------------------------------------------"
current_goal constraints/sdc_check -top ${TOP}
foreach waive_rule ${WAIVE_constraints_sdc_check} { waive -rule $waive_rule -comment {Add by Alchip}; puts "waive -rule $waive_rule -comment {Add by Alchip}"}
run_goal
save_goal
capture $REPORT_DIR/soc_sdc_check.rpt {write_report spyglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal constraints/sdc_exception_struct -top ${TOP}..."
puts "---------------------------------------------------------------"
current_goal constraints/sdc_exception_struct -top ${TOP}
foreach waive_rule ${WAIVE_constraints_sdc_exception_struct} { waive -rule $waive_rule -comment {Add by Alchip}; puts "waive -rule $waive_rule -comment {Add by Alchip}" }
run_goal
save_goal
capture $REPORT_DIR/soc_sdc_exception_struct.rpt {write_report spyglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal constraints/sdc_redundancy -top ${TOP}..."
puts "---------------------------------------------------------------"
current_goal constraints/sdc_redundancy -top ${TOP}
foreach waive_rule ${WAIVE_constraints_sdc_redundancy} {  waive -rule $waive_rule -comment {Add by Alchip}; puts "waive -rule $waive_rule -comment {Add by Alchip}"}
run_goal
save_goal
capture $REPORT_DIR/soc_sdc_redundance.rpt {write_report spyglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal constraints/sdc_abstract -top ${TOP}..."
puts "---------------------------------------------------------------"
current_goal constraints/sdc_abstract -top ${TOP}
foreach waive_rule ${WAIVE_constraints_sdc_abstract} { waive -rule $waive_rule -comment {Add by Alchip} ; puts "waive -rule $waive_rule -comment {Add by Alchip}"}
run_goal
save_goal
capture $REPORT_DIR/soc_sdc_abstract.rpt {write_report spyglass_violations}

#
# CDC check
#
puts "CDC checking..."
puts "---------------------------------------------------------------"
puts "current_goal cdc/cdc_setup_check -top ${TOP}..."
puts "---------------------------------------------------------------"
current_goal cdc/cdc_setup_check -top ${TOP}
foreach waive_rule ${WAIVE_cdc_cdc_setup_check} { waive -rule $waive_rule -comment {Add by Alchip}; puts "waive -rule $waive_rule -comment {Add by Alchip}"}
run_goal
save_goal
capture $REPORT_DIR/soc_cdc_setup.rpt {write_report spyglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal cdc/clock_reset_integrity -top ${TOP}..."
puts "---------------------------------------------------------------"
current_goal cdc/clock_reset_integrity -top ${TOP}
foreach waive_rule ${WAIVE_cdc_clock_reset_integrity} {  waive -rule $waive_rule -comment {Add by Alchip}; puts "waive -rule $waive_rule -comment {Add by Alchip}"}
run_goal
save_goal
capture $REPORT_DIR/soc_cdc_clock_reset_integrity.rpt {write_report spyglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal cdc/cdc_verify_struct -top ${TOP}..."
puts "---------------------------------------------------------------"
current_goal cdc/cdc_verify_struct -top ${TOP}
foreach waive_rule ${WAIVE_cdc_cdc_verify_struct} {  waive -rule $waive_rule -comment {Add by Alchip}; puts "waive -rule $waive_rule -comment {Add by Alchip}"}
run_goal
save_goal
capture $REPORT_DIR/soc_cdc_verify_struct.rpt {write_report spyglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal cdc/cdc_verify -top ${TOP}..."
puts "---------------------------------------------------------------"
current_goal cdc/cdc_verify -top ${TOP}
foreach waive_rule ${WAIVE_cdc_cdc_verify} {  waive -rule $waive_rule -comment {Add by Alchip}; puts "waive -rule $waive_rule -comment {Add by Alchip}"}
run_goal
save_goal
capture $REPORT_DIR/soc_cdc_verify.rpt {write_report spyglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal cdc/cdc_abstract -top ${TOP}..."
puts "---------------------------------------------------------------"
current_goal cdc/cdc_abstract -top ${TOP}
foreach waive_rule ${WAIVE_cdc_cdc_abstract} {  waive -rule $waive_rule -comment {Add by Alchip}; puts "waive -rule $waive_rule -comment {Add by Alchip}"}
run_goal
save_goal
capture $REPORT_DIR/soc_cdc_abstract.rpt {write_report spyglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal cdc/cdc_verify_jitter -top ${TOP}..."
puts "---------------------------------------------------------------"
current_goal cdc/cdc_verify_jitter -top ${TOP}
foreach waive_rule ${WAIVE_cdc_cdc_verify_jitter} {  waive -rule $waive_rule -comment {Add by Alchip}; puts "waive -rule $waive_rule -comment {Add by Alchip}"}
run_goal
save_goal
capture $REPORT_DIR/soc_cdc_verify_jitter.rpt {write_report spyglass_violations}

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
##capture $REPORT_DIR/soc_dft_scan_ready.rpt {write_report sypglass_violations}


puts "---------------------------------------------------------------"
puts "current_goal dft/dft_best_practice -top ${TOP}..."
puts "---------------------------------------------------------------"
#current_goal dft/dft_best_practice -top ${TOP}
#foreach waive_rule ${WAIVE_dft_dft_best_practice} {  waive -rule $waive_rule }
#run_goal
#save_goal
##capture $REPORT_DIR/soc_dft_best_practice.rpt {write_report sypglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal dft/dft_bist_ready -top ${TOP}..."
puts "---------------------------------------------------------------"
#current_goal dft/dft_bist_ready -top ${TOP}
#foreach waive_rule ${WAIVE_dft_dft_bist_ready} {  waive -rule $waive_rule }
#run_goal
#save_goal
##capture $REPORT_DIR/soc_dft_bist_ready.rpt {write_report sypglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal dft/dft_dsm_best_practice -top ${TOP}..."
puts "---------------------------------------------------------------"
#current_goal dft/dft_dsm_best_practice -top ${TOP}
#foreach waive_rule ${WAIVE_dft_dft_dsm_best_practice} {  waive -rule $waive_rule }
#run_goal
#save_goal
##capture $REPORT_DIR/soc_dft_dsm_best_practice.rpt {write_report sypglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal dft/dft_dsm_random_resistance -top ${TOP}..."
puts "---------------------------------------------------------------"
#current_goal dft/dft_dsm_random_resistance -top ${TOP}
#foreach waive_rule ${WAIVE_dft_dft_dam_random_resistance} {  waive -rule $waive_rule }
#run_goal
#save_goal
##capture $REPORT_DIR/soc_dft_dsm_random_resistance.rpt {write_report sypglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal dft/dft_abstract -top ${TOP}..."
puts "---------------------------------------------------------------"
#current_goal dft/dft_abstract -top ${TOP}
#foreach waive_rule ${WAIVE_dft_dft_abstract} {  waive -rule $waive_rule }
#run_goal
#save_goal
##capture $REPORT_DIR/soc_dft_bstract.rpt {write_report sypglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal dft/dft_dsm_best_practice -top ${TOP}..."
puts "---------------------------------------------------------------"
#current_goal dft/dft_dsm_best_practice -top ${TOP}
#foreach waive_rule ${WAIVE_dft_dft_dsm_best_practice} {  waive -rule $waive_rule }
#run_goal
#save_goal
##capture $REPORT_DIR/soc_dftt_practice.rpt {write_report sypglass_violations}



