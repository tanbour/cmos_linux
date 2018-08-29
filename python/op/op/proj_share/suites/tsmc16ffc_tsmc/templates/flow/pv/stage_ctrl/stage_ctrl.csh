{%- if pre.stage and pre.sub_stage %}
while ( 1 )
# waiting previous stage "{{pre.sub_stage}}.op.run.pass" finish--------------------------------------------------
  if ( -e {{pre.flow_sum_dir}}/{{pre.stage}}/{{pre.sub_stage}}.op.run.pass ) then
    set pre_op_run_pass_time = `stat {{pre.flow_sum_dir}}/{{pre.stage}}/{{pre.sub_stage}}.op.run.pass  | grep -i Modify | awk -F. '{print $1}' | awk '{print $2$3}'| awk -F- '{print $1$2$3}' | awk -F: '{print $1$2$3}' `
    set pre_op_run_time =  ` stat {{pre.flow_scripts_dir}}/{{pre.stage}}/{{pre.sub_stage}}  | grep -i Modify | awk -F. '{print $1}' | awk '{print $2$3}'| awk -F- '{print $1$2$3}' | awk -F: '{print $1$2$3}' `
      if ( `expr $pre_op_run_pass_time - $pre_op_run_time` > 0 ) then
          echo "Alchip-info: previous stage {{pre.stage}}:{{pre.sub_stage}} is finish run, will start {{cur_stage}}:{{cur.sub_stage}} "
          break
      else 
          echo "Alchip-info: previous stage {{pre.stage}}:{{pre.sub_stage}} is not finish yet, will waiting for {{pre.stage}}:{{pre.sub_stage}} to be finish"
          sleep 60
      endif
   else 
    echo "Alchip-info: previous stage {{pre.stage}}:{{pre.sub_stage}} is not finish yet, will waiting for {{pre.stage}}:{{pre.sub_stage}} to be finish"
    sleep 60
   endif
end
{%- if local._multi_inst == "lvs" %}
while ( 1 )
# waiting previous v2lvs stage "v2lvs.op.run.pass" finish--------------------------------------------------
  if ( -e {{cur.flow_sum_dir}}/{{cur.stage}}/v2lvs/pv.csh.op.run.pass ) then
          echo "Alchip-info: previous stage v2lvs is finish, will start lvs stage"
         break
  else 
          echo "Alchip-info: previous stage v2lvs is not finish yet, will waiting for v2lvs to be finish"
          sleep 60
  endif
end
{%- endif %}
{%- endif %}
