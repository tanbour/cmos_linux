{%- if pre.stage and pre.sub_stage %}
while ( 1 )
# waiting previous stage "{{pre.sub_stage}}.op.run.pass" finish--------------------------------------------------
  if ( -e {{pre.flow_sum_dir}}/{{pre.stage}}/{{local.scenario}}/{{pre.sub_stage}}.op.run.pass ) then
    set pre_op_run_pass_time = `stat {{pre.flow_sum_dir}}/{{pre.stage}}/{{local.scenario}}/{{pre.sub_stage}}.op.run.pass  | grep -i Modify | awk -F. '{print $1}' | awk '{print $2$3}'| awk -F- '{print $1$2$3}' | awk -F: '{print $1$2$3}' `
    set pre_op_run_time =  ` stat {{pre.flow_scripts_dir}}/{{pre.stage}}/{{local.scenario}}/{{pre.sub_stage}}  | grep -i Modify | awk -F. '{print $1}' | awk '{print $2$3}'| awk -F- '{print $1$2$3}' | awk -F: '{print $1$2$3}' `
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
{% endif %}

if ( -e {{local._multi_inst}} ) then
set bak_time = `date +%m_%d_%H_%M`
echo " workspace {{local._multi_inst}} is alreay exist, will move to backup workspace {{local._multi_inst}}_${bak_time} "
mv -f {{local._multi_inst}} {{local._multi_inst}}_${bak_time}
endif
