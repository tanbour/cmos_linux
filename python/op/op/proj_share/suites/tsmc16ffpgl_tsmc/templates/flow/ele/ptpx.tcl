{%- if cur.op_restore == "true" %}
{%- include 'ptpx/ptpx_restore.tcl' %}
puts "{{env.FIN_STR}}"
{%- else %}
{%- include 'ptpx/stage_ctrl.tcl' %}
{%- include 'ptpx/ptpx.tcl' %}
puts "{{env.FIN_STR}}"
exit
{%- endif %}

