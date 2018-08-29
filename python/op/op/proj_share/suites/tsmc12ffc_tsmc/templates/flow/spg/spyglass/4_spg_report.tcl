puts "Write report..."

save_project 
#write_report datasheet -config_file 
#write_report dashboard -config_file 

exec mkdir -p {{cur.flow_log_dir}}/spg
capture {{cur.flow_log_dir}}/spg/soc_spg_violations.rpt {write_report spyglass_violations}



