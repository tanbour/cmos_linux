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
capture ./reports/soc_cdc_setup.rpt {write_report spyglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal cdc/clock_reset_integrity -top ${TOP}..."
puts "---------------------------------------------------------------"
current_goal cdc/clock_reset_integrity -top ${TOP}
foreach waive_rule ${WAIVE_cdc_clock_reset_integrity} {  waive -rule $waive_rule -comment {Add by Alchip}; puts "waive -rule $waive_rule -comment {Add by Alchip}"}
run_goal
save_goal
capture ./reports/soc_cdc_clock_reset_integrity.rpt {write_report spyglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal cdc/cdc_verify_struct -top ${TOP}..."
puts "---------------------------------------------------------------"
current_goal cdc/cdc_verify_struct -top ${TOP}
foreach waive_rule ${WAIVE_cdc_cdc_verify_struct} {  waive -rule $waive_rule -comment {Add by Alchip}; puts "waive -rule $waive_rule -comment {Add by Alchip}"}
run_goal
save_goal
capture ./reports/soc_cdc_verify_struct.rpt {write_report spyglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal cdc/cdc_verify -top ${TOP}..."
puts "---------------------------------------------------------------"
current_goal cdc/cdc_verify -top ${TOP}
foreach waive_rule ${WAIVE_cdc_cdc_verify} {  waive -rule $waive_rule -comment {Add by Alchip}; puts "waive -rule $waive_rule -comment {Add by Alchip}"}
run_goal
save_goal
capture ./reports/soc_cdc_verify.rpt {write_report spyglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal cdc/cdc_abstract -top ${TOP}..."
puts "---------------------------------------------------------------"
current_goal cdc/cdc_abstract -top ${TOP}
foreach waive_rule ${WAIVE_cdc_cdc_abstract} {  waive -rule $waive_rule -comment {Add by Alchip}; puts "waive -rule $waive_rule -comment {Add by Alchip}"}
run_goal
save_goal
capture ./reports/soc_cdc_abstract.rpt {write_report spyglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal cdc/cdc_verify_jitter -top ${TOP}..."
puts "---------------------------------------------------------------"
current_goal cdc/cdc_verify_jitter -top ${TOP}
foreach waive_rule ${WAIVE_cdc_cdc_verify_jitter} {  waive -rule $waive_rule -comment {Add by Alchip}; puts "waive -rule $waive_rule -comment {Add by Alchip}"}
run_goal
save_goal
capture ./reports/soc_cdc_verify_jitter.rpt {write_report spyglass_violations}

