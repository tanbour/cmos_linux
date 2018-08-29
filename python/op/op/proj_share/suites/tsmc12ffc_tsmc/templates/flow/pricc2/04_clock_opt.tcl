{%- if cur.op_restore == "true" %}
{%- include 'icc2/icc2_restore.tcl' %}
puts "{{env.FIN_STR}}"
{%- else %}
{%- include 'stage_ctrl/stage_ctrl.tcl' %}
{% include 'icc2/04_icc2_clock_opt.tcl' %}
puts "Alchip_info: op stage finished."
exit
{%- endif %}
