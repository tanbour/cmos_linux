proc report_violation { file_name } {
  global synopsys_program_name

  if { $synopsys_program_name == "pt_shell" } {
    report_timing -nosplit -significant_digits 3 -input_pins -nets -max_paths 999999 -nworst 1 \
      -delay_type max -path_type full -slack_lesser_than 0 \
      > $file_name
  } else {
   #report_timing -nosplit -significant_digits 3 -input_pins -nets -max_paths 999 -nworst 1 \
   #  -delay max -path full \
   #  > $file_name
    report_constraint -nosplit -significant_digits 3 -all_violators -max_delay -verbose > $file_name
  }
  report_violation_summary $file_name
}

