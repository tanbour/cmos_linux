
new_project -force {{local.sg_project_name}}

#
# options
#
set_option enableSV {{local.set_option_enableSV}}
set_option allow_module_override {{local.set_option_allow_module_override}}
set_option report_incr_messages {{local.set_report_incr_messages}}
set_option define {{local.set_option_define}}
#
#
set TOP  {{env.BLK_NAME}} 
set SDC  {{env.BLK_SDC}}/{{ver.sdc}}/{{env.BLK_NAME}}.rtl.sdc
set RST  {{local.RST}}
set SGDC {{cur.flow_scripts_dir}}/spg/soc_rtl.sgdc
set RTL [glob {{env.BLK_RTL}}/{{ver.rtl}}/*]
set REPORT_DIR {{cur.flow_rpt_dir}}/spg

# ignore modules in read design
set IGNORE_MODUELS { empty}
set IGNORE_MODUELS1 { \
{%- for ignore_module in local.ignore_modules %}
    {{ignore_module}} \
{%- endfor %}
}

#
# blackbox modules in read design
set BBOX_MODULES { empty}
set BBOX_MODULES1 { \
{%- for bbox_module in local.bbox_modules %}
    {{bbox_module}} \
{%- endfor %}
}

#
# waive modules in check design
set WAIVE_MODULES { empty}
set WAIVE_MODULES1 { \
{%- for waive_module in local.waive_modules %}
    {{waive_module}} \
{%- endfor %}
 }

#
# wavie rules
set WAIVE_RULES { \
{%- for waive_rule in local.waive_rules %}
    {{waive_rule}} \
{%- endfor %}
 }




