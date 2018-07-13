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
capture ./reports/soc_sdc_audit.rpt {write_report spyglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal constraints/sdc_check -top ${TOP}..."
puts "---------------------------------------------------------------"
current_goal constraints/sdc_check -top ${TOP}
foreach waive_rule ${WAIVE_constraints_sdc_check} { waive -rule $waive_rule -comment {Add by Alchip}; puts "waive -rule $waive_rule -comment {Add by Alchip}"}
run_goal
save_goal
capture ./reports/soc_sdc_check.rpt {write_report spyglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal constraints/sdc_exception_struct -top ${TOP}..."
puts "---------------------------------------------------------------"
current_goal constraints/sdc_exception_struct -top ${TOP}
foreach waive_rule ${WAIVE_constraints_sdc_exception_struct} { waive -rule $waive_rule -comment {Add by Alchip}; puts "waive -rule $waive_rule -comment {Add by Alchip}" }
run_goal
save_goal
capture ./reports/soc_sdc_exception_struct.rpt {write_report spyglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal constraints/sdc_redundancy -top ${TOP}..."
puts "---------------------------------------------------------------"
current_goal constraints/sdc_redundancy -top ${TOP}
foreach waive_rule ${WAIVE_constraints_sdc_redundancy} {  waive -rule $waive_rule -comment {Add by Alchip}; puts "waive -rule $waive_rule -comment {Add by Alchip}"}
run_goal
save_goal
capture ./reports/soc_sdc_redundance.rpt {write_report spyglass_violations}

puts "---------------------------------------------------------------"
puts "current_goal constraints/sdc_abstract -top ${TOP}..."
puts "---------------------------------------------------------------"
current_goal constraints/sdc_abstract -top ${TOP}
foreach waive_rule ${WAIVE_constraints_sdc_abstract} { waive -rule $waive_rule -comment {Add by Alchip} ; puts "waive -rule $waive_rule -comment {Add by Alchip}"}
run_goal
save_goal
capture ./reports/soc_sdc_abstract.rpt {write_report spyglass_violations}

