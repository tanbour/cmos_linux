{%- if pre.stage and pre.sub_stage %}
# waiting previous stage "{{pre.sub_stage}}.op.run.pass" finish--------------------------------------------------
while { true } {
if { [file exist {{pre.flow_sum_dir}}/{{pre.stage}}/{{local.scenario}}/{{pre.sub_stage}}.op.run.pass] } {
    set pre_op_run_pass_time [ clock format [file mtime {{pre.flow_sum_dir}}/{{pre.stage}}/{{local.scenario}}/{{pre.sub_stage}}.op.run.pass ] -format %y%m%d%H%M%S ]
    set pre_op_run_time [ clock format [file mtime {{pre.flow_scripts_dir}}/{{pre.stage}}/{{local.scenario}}/{{pre.sub_stage}} ] -format %y%m%d%H%M%S ]
        if { [expr $pre_op_run_pass_time - $pre_op_run_time] > 0 } {
            puts "Alchip-info: previous stage {{local.scenario}}/{{pre.stage}}:{{pre.sub_stage}} is finish run, will start {{local.scenario}}/{{cur_stage}}:{{cur.sub_stage}} "
            break
        } else {
            puts "Alchip-info: previous stage {{local.scenario}}/{{pre.stage}}:{{pre.sub_stage}} is not finish yet, will waiting for {{local.scenario}}/{{pre.stage}}:{{pre.sub_stage}} to be finish"
            exec sleep 60
        }
} else {
    puts "Alchip-info: previous stage {{local.scenario}}/{{pre.stage}}:{{pre.sub_stage}} is not finish yet, will waiting for {{local.scenario}}/{{pre.stage}}:{{pre.sub_stage}} to be finish"
    exec sleep 60
    }
}
{%- endif %}
