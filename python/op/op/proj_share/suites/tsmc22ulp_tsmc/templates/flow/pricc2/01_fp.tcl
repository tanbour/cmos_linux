{%- if cur.op_restore == "true" %}
{%- include 'icc2/icc2_restore.tcl' %}
puts "{{env.FIN_STR}}"
{%- else %}
{%- include 'stage_ctrl/stage_ctrl.tcl' %}
{% include 'icc2/01_icc2_fp.tcl' %}
puts "{{env.FIN_STR}}"
exit
{%- endif %}

