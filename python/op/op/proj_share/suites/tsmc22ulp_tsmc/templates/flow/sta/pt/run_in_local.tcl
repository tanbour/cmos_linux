set hostname_n [exec hostname]
set local_run_date_tab [exec  date +%y%m%d_%H%M%S]
echo "Alchip-info : run at $hostname_n"
set cur_run_dir [pwd]
regexp {(.*)/} $cur_run_dir "" cur_flow_data_dir
set sub_cur_flow_data_dir [lindex [split $cur_flow_data_dir "/"] end]
source /alchip/home/juliaz/scr/Usage/OP4_flow/get_local_space.tcl
{%- if local.run_at_local_min_volume_G %}
set volume_vth {{local.run_at_local_min_volume_G}}
set local_dir [check_local_space $volume_vth]
{%- else %}
set local_dir [check_local_space 100000000]
{%- endif %}
puts "INFO: local_dir = \"$local_dir\""
if {$local_dir !=""} {
  regexp {(([^/]+/run/\w+/\w+)\S+)} $cur_flow_data_dir "" a a_b 
  set local_run_dir ${local_dir}/Beige/${a}
  set local_root ${local_dir}/Beige/${a}
  exec mkdir -p $local_root
  cd $local_root
  puts "INFO: now use local to run: [pwd]"
  exec rm -f $cur_run_dir/${cur_stage}_runInLocal_$hostname_n
  redirect  $cur_run_dir/${cur_stage}_runInLocal_$hostname_n {puts "$local_run_dir (@ $hostname_n [date])"}
  exec mkdir -p  {{cur.blk_release_dir}}/RM_space_run
  exec touch {{cur.blk_release_dir}}/RM_space_run/rm_space_op4run.{{cur.flow}}.csh
  set rm_space_op4run_info [exec cat {{cur.blk_release_dir}}/RM_space_run/rm_space_op4run.{{cur.flow}}.csh]
  redirect -app {{cur.blk_release_dir}}/RM_space_run/rm_space_op4run.{{cur.flow}}.csh {
    if {[regexp "remove by enter $hostname_n" $rm_space_op4run_info]} {
      puts "## Have remove by enter $hostname_n; # ${a_b}/*/{{cur.stage}} ($local_run_date_tab)\n"
    } else {
#    cat /proj/Beige/WORK/juliaz/orange/run/r20180319_n20180324_10d5T/try8/sum/pr/04_clock_opt.tcl.op.run
      puts "set cmd = \"rm -rf ${local_dir}/Beige/${a_b}; touch {{cur.blk_release_dir}}/RM_space_run/rm_finish\""
       puts "xterm -e ssh -X $hostname_n \$cmd; # ${a_b}/*/{{cur.stage}} ($local_run_date_tab)"
       puts "if (-e {{cur.blk_release_dir}}/RM_space_run/rm_finish) then"
       puts "\techo \"remove by enter $hostname_n: ${local_dir}/Beige/${a_b}\""
       puts "\trm {{cur.blk_release_dir}}/RM_space_run/rm_finish"
       puts "else"
       puts "echo \"can not enter server by :ssh -X $hostname_n, so need to use bsub\""
       set rm_spacerun_cmd [exec  cat {{cur.cur_flow_sum_dir}}/$sub_cur_flow_data_dir/{{cur.sub_stage}}.op.run | sed "s#-m\\s\\+\\S\\+##g" | sed "s#-n\\s\\+\\S\\+#-n 1 -m $hostname_n#g" | sed "s#-title\\s\\+\\S\\+#-title 'rm space: ${a_b}'#g" | sed "s#-e\\s\\+.*#-e 'rm -rf ${local_dir}/Beige/${a_b}'#g"]
       puts "\t$rm_spacerun_cmd"
       puts "endif\n"
    }
  } 
}
