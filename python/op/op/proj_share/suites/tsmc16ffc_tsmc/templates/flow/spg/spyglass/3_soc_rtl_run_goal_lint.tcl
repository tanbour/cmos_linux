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
foreach waive_rule ${WAIVE_lint_lint_rtl} {  waive -rule $waive_rule -comment {Add by Alchip}; puts "waive -rule $waive_rule -comment {Add by Alchip}"}
run_goal
save_goal
capture ./reports/soc_lint_rtl.rpt {write_report spyglass_violations}
#current_goal lint/lint_turbo_rtl -top ${TOP}
#run_goal
#save_goal
#capture ./reports/soc_lint_turbol_rtl.rpt {write_report spyglass_violations}

#current_goal lint/lint_functional_rtl -top ${TOP}
#run_goal
#save_goal
#capture ./reports/soc_lint_functional_rtl.rpt {write_report spyglass_violations}

#current_goal lint/lint_abstract -top ${TOP}
#run_goal
#save_goal
#capture ./reports/soc_lint_abstract.rpt {write_report spyglass_violations}

