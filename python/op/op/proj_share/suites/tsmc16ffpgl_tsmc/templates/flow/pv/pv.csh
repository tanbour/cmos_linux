{%- include 'stage_ctrl/stage_ctrl.csh' %}
{%- include 'calibre/' + local._multi_inst + '.csh' %}
echo "{{env.FIN_STR}}"

