set active_scenarios_note [get_scenarios -filter active]
set_scenario_status -active true [all_scenarios]
update_timing
sh mkdir -p {{cur.cur_flow_data_dir}}/${cur_stage}_SPEF
write_parasitics -compress -output {{cur.cur_flow_data_dir}}/${cur_stage}_SPEF/{{env.BLK_NAME}}
set spefs [glob {{cur.cur_flow_data_dir}}/${cur_stage}_SPEF/{{env.BLK_NAME}}*.spef.gz]
foreach s $spefs {
  if {[regexp {(.*).spef.gz} $s "" nspef]} {sh mv $s ${nspef}c.spef.gz} 
}
set_scenario_status -active false [all_scenarios]
set_scenario_status -active true  $active_scenarios_note
