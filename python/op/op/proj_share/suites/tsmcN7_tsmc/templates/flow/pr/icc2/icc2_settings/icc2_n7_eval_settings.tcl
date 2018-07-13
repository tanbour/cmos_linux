{#- 02_place---------------------------------------------------------------------- #}
# synopsys added in 7n_eval
set_app_options -list {extract.via_node_cap true}
# synopsys enabled from place_opt
set_app_options -list {time.delay_calc_waveform_analysis_mode full_design}
set_app_options -list {time.enable_ccs_rcv_cap false}

{#- 03_clock---------------------------------------------------------------------- #}
{%- if cur.sub_stage == "03_clock.tcl" or cur.sub_stage == "04_clock_opt.tcl" %}
# synopsys added in 7n_eval
set_app_options -list {cts.common.verbose 1}
# synopsys added in 7n_eval
set_app_options -list {cts.common.max_fanout 12 }
# synopsys added in 7n_eval
set_app_options -list {cts.common.max_net_length 100}

# synopsys added in 7n_eval
set_app_options -list {ccd.skip_path_groups {REGIN REGOUT IN_ICG}}
# synopsys added in 7n_eval
set_app_options -list {ccd.optimize_boundary_timing true}
{%- endif %}
{#- 05_route---------------------------------------------------------------------- #}
{%- if cur.sub_stage == "05_route.tcl" or cur.sub_stage == "05_route_opt.tcl" %}
# synopsys added in 7n_eval
set_app_options -list {route.detail.optimize_wire_via_effort_level high }
# synopsys added in 7n_eval
set_app_options -list {route.detail.check_pin_min_area_min_length true}
{%- endif %}
{# 06_route_opt---------------------------------------------------------------------- #}
{%- if cur.sub_stage == "06_route_opt.tcl" %}
# synopsys added in 7n_eval
set_app_option -list { route_opt.flow.xtalk_reduction true }
{%- endif %}
