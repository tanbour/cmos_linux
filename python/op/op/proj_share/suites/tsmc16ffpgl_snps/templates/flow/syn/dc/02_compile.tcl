# From_synopsys
#set_size_only [get_flat_cells -filter "is_mapped==true && ref_name!~**logic_0** && ref_name!~**logic_1**"]

set_pin_name_synonym CP  clocked_on
set_pin_name_synonym clocked_on  CP
change_names -rules verilog -hierarchy


#===================================================================
#=================== read SDC constraints ==========================
#===================================================================

#-- read sdc ---------------------------
remove_sdc
source -e -v ${SDC_FILE} > {{cur.cur_flow_log_dir}}/02_read_sdc.log

#-- inc sdc ----------------------------
#remove_clock_uncertainty [all_clocks]
#$# --> set_clock_uncertainty -setup 0.09 [all_clocks]
#$# --> set_clock_uncertainty -hold  0.05 [all_clocks]
#$# --> set_timing_derate -data  -late  -cell_delay 1.050
#$# --> set_timing_derate -data  -late  -net_delay  1.07
#$# --> set_timing_derate -clock -early -cell_delay 0.963
#$# --> set_timing_derate -clock -early -net_delay  0.93
#$# --> set_timing_derate -clock -late  -cell_delay 1.037
#$# --> set_timing_derate -clock -late  -net_delay  1.07
#set_clock_uncertainty -setup 0.12 [all_clocks]
set dc_period {{local.dc_period}}
set_clock_uncertainty -setup [expr $dc_period*{{local.clock_uncertainty_setup_parameter}}] [all_clocks]
set_clock_uncertainty -hold  {{local.clock_uncertainty_hold}} [all_clocks]
set_timing_derate -data  -late  -cell_delay {{local.cell_data_late_timing_derate}} 
set_timing_derate -data  -late  -net_delay  {{local.net_data_late_timing_derate}}
set_timing_derate -clock -early -cell_delay {{local.cell_early_clock_timing_derate}}
set_timing_derate -clock -early -net_delay  {{local.net_early_clock_timing_derate}}
set_timing_derate -clock -late  -cell_delay {{local.cell_late_clock_timing_derate}}
set_timing_derate -clock -late  -net_delay  {{local.net_late_clock_timing_derate}}
########## my add
#set_clock_uncertainty -setup 0.260 [all_clocks]
#set_clock_uncertainty 0.400 [get_clocks hash_clock_half*]
#set_clock_uncertainty 0.500 [get_clocks hash_clock_gated]
#set_clock_uncertainty 0.800 -from [get_clocks hash_clock] -to [get_clocks hash_clock_half*]
#set_clock_uncertainty 0.500 -from [get_clocks hash_clock] -to [get_clocks hash_clock_gated]
#set_max_transition 0.18 $TOP
#group_path -to [get_clocks hash_clock_half*] -name hash_clock_half -weight 5 -critical_range 10
#group_path -to [get_clocks hash_clock_gated] -name hash_clock_gated -weight 5 -critical_range 10
#set_clock_gating_check -setup 1.0 [get_pins core/gate/tsmc16.clockgate/E]
#set_clock_gating_check -setup 0.95 [get_pins core/uut/wprep/wpipe[0].w2.gate/tsmc16.clockgate/E]
#set_clock_gating_check -setup 0.95 [get_pins core/uut/wprep/wpipe[1].w2.gate/tsmc16.clockgate/E]
#set_clock_gating_check -setup 0.95 [get_pins core/uut2/wprep/wpipe[0].w2.gate/tsmc16.clockgate/E]
#set_clock_gating_check -setup 0.95 [get_pins core/uut2/wprep/wpipe[1].w2.gate/tsmc16.clockgate/E]


#-- useful_skew ------------------------
#source -echo -verbose {{cur.config_plugins_dir}}/dc_scripts/useful_skew.tcl
#source -echo -verbose {{cur.config_plugins_dir}}/dc_scripts/path_groups.tcl


#===================================================================
#=================== read DEF ======================================
#===================================================================

{% if local.syn_mode == "dcg" %}

reset_physical_constraints
extract_physical_constraint ${DEF_FILE}
#create_bounds -name ctrl -coordinate { 200 138 230 170 } -type soft {ctrl}
set_tlu_plus_files -max_tluplus $TLUP_{{local.rc_corner}} -tech2itf_map $MAP_FILE
check_tlu_plus_files

{% endif %}
#
{% if local.isolate_buffer_libcell_name != "" %}
set_isolate_ports -driver {{local.isolate_buffer_libcell_name}} [get_ports *] -force
{% endif %}
#===================================================================
#=================== clock gate setting ============================
#===================================================================
set power_cg_iscgs_enable true
set power_cg_physically_aware_cg true
set pwr_cg_improved_cell_sorting true
## chose ULVT cells for clock network, alignd with CTS
set_clock_gating_style \
   -max_fanout {{local.set_clock_gating_style_max_fanout}} \
   -minimum_bitwidth {{local.set_clock_gating_style_minimun_bitwidth}} \
   -sequential_cell latch \
{%- if local.set_clock_gating_style_positive_edge_logic_libcell != "" %}
   -positive_edge_logic "{{ local.set_clock_gating_style_positive_edge_logic_libcell}}" \
{%- endif %}
   -control_point before \
   -control_signal scan_enable
#set power_cg_auto_identify true
## enable physical-aware ICG restructuring


#===================================================================
#=================== Adjust Setting ================================
#===================================================================

#-- dont use ---------------------------
source {{cur.config_plugins_dir}}/dc_scripts/dont_use.tcl

# enable congestion-driven placement, to optimize local congestion and improve correlation
set placer_enable_enhanced_router true

# enable cell clumping placement, verified 60% can produce good trade-off between QoR and congestion
#20170914 0.7>0.75
set placer_max_cell_density_threshold {{local.placer_max_cell_density_threshold}}
#20170914 0.8>0.9
#set_congestion_options  -max_util     0.8

#
set_fix_multiple_port_nets -all -buffer_constants
set_auto_disable_drc_nets -constant false

# disable dynamic power optimization
set_dynamic_optimization false
set_cost_priority -delay

#-- DRC constraints --------------------
set_max_transition {{local.set_max_transition_current_design}} [current_design]
set_max_fanout {{local.set_max_fanout_current_design}}        [current_design]

#-- route layer ------------------------
#read_saif -auto_map_names -input /proj/7nm_evl/WORK/rogern/hash_engine_data/saif/hash_engine_rtl.saif -instance test_solar/FPGAs\[0\]\.uut/core_block\[0\]\.block/engine\[0\]\.hash_engine0

#===================================================================
#=================== Compile 1 =====================================
#===================================================================

#-- add bounds -------------------------
#$# --> source {{cur.config_plugins_dir}}/dc_scripts/bounds.tcl
#$# --> create_bounds -coordinate { {1027.54 1099.2} {1101.43 1254.144} } -name reg_out [get_cells -of_objects  [all_fanin -to  [get_ports -filter "direction == out"] -startpoints_only -flat]]

#-- setting ----------------------------
#set_app_var target_library  "\
   tcbn07_bwph240l8p57pd_base_ulvttt_0p75v_25c_typical_hm_ccs.db \
"

#-- compile ----------------------------
compile_ultra -no_autoungroup -gate_clock  
source -e {{cur.config_plugins_dir}}/dc_scripts/change_name.tcl
write -hier -format verilog -out {{cur.cur_flow_data_dir}}/01_{{env.BLK_NAME}}.v
write -f ddc -h -out {{cur.cur_flow_data_dir}}/01_{{env.BLK_NAME}}.ddc
set_svf -off
#-- report -----------------------------
report_timing -nets -input_pins -nosplit -significant_digits 3 -max_paths 100000 -slack_lesser_than 0 -nworst 1 -delay max > {{cur.cur_flow_rpt_dir}}/03_SYN_{{local.lib_corner}}.rpt
sh /usr/bin/perl {{cur.config_plugins_dir}}/dc_scripts/check_violation_summary.pl {{cur.cur_flow_rpt_dir}}/03_SYN_{{local.lib_corner}}.rpt > {{cur.cur_flow_rpt_dir}}/03_SYN_{{local.lib_corner}}.sum
source {{cur.config_plugins_dir}}/dc_scripts/proc_qor.tcl
proc_qor > {{cur.cur_flow_rpt_dir}}/03_proc_qor.rpt
report_qor > {{cur.cur_flow_rpt_dir}}/03_qor.rpt
report_power > {{cur.cur_flow_rpt_dir}}/03_power.rpt
#return
#===================================================================
#=================== compile 2 =====================================
#===================================================================

# identify_register_banks -input_map_file ./scr/map/input_mergerM4.tcl -register_group_file ./scr/map/group_M4.list -output_file ./scr/cmd/4_MB4_1.tcl
# source ./scr/cmd/4_MB4_1.tcl > M4_merge1.rpt
# identify_register_banks -input_map_file ./scr/map/input_mergerM4.tcl -register_group_file ./scr/map/group_M4.list -output_file ./scr/cmd/4_MB4_2.tcl
# source ./scr/cmd/4_MB4_2.tcl > M4_merge2.rpt
# identify_register_banks -input_map_file ./scr/map/input_mergerM4.tcl -register_group_file ./scr/map/group_M4.list -output_file ./scr/cmd/4_MB4_3.tcl
# source ./scr/cmd/4_MB4_3.tcl > M4_merge3.rpt
# identify_register_banks -input_map_file ./scr/map/input_mergerM2.tcl -register_group_file ./scr/map/group_M2.list -output_file ./scr/cmd/4_MB2_1.tcl
# source ./scr/cmd/4_MB2_1.tcl > M2_merge1.rpt
# identify_register_banks -input_map_file ./scr/map/input_mergerM2.tcl -register_group_file ./scr/map/group_M2.list -output_file ./scr/cmd/4_MB2_2.tcl
# source ./scr/cmd/4_MB2_2.tcl > M2_merge2.rpt
# identify_register_banks -input_map_file ./scr/map/input_mergerM2.tcl -register_group_file ./scr/map/group_M2.list -output_file ./scr/cmd/4_MB2_3.tcl
# source ./scr/cmd/4_MB2_3.tcl > M2_merge3.rpt
# identify_register_banks -input_map_file ./scr/map/input_mergerM4.tcl -register_group_file ./scr/map/group_M4.list -output_file ./scr/cmd/4_MB4_1.tcl
# source ./scr/cmd/4_MB4_1.tcl > M4_merge1.rpt
# identify_register_banks -input_map_file ./scr/map/input_mergerM4.tcl -register_group_file ./scr/map/group_M4.list -output_file ./scr/cmd/4_MB4_2.tcl
# source ./scr/cmd/4_MB4_2.tcl > M4_merge2.rpt
# identify_register_banks -input_map_file ./scr/map/input_mergerM4.tcl -register_group_file ./scr/map/group_M4.list -output_file ./scr/cmd/4_MB4_3.tcl
# source ./scr/cmd/4_MB4_3.tcl > M4_merge3.rpt
# identify_register_banks -input_map_file ./scr/map/input_mergerM2.tcl -register_group_file ./scr/map/group_M2.list -output_file ./scr/cmd/4_MB2_1.tcl
# source ./scr/cmd/4_MB2_1.tcl > M2_merge1.rpt
# identify_register_banks -input_map_file ./scr/map/input_mergerM2.tcl -register_group_file ./scr/map/group_M2.list -output_file ./scr/cmd/4_MB2_2.tcl
# source ./scr/cmd/4_MB2_2.tcl > M2_merge2.rpt
# identify_register_banks -input_map_file ./scr/map/input_mergerM2.tcl -register_group_file ./scr/map/group_M2.list -output_file ./scr/cmd/4_MB2_3.tcl
# source ./scr/cmd/4_MB2_3.tcl > M2_merge3.rpt

{%- if local.syn_mode == "dcg" %}
#-- remove bounds ----------------------
remove_bounds -all
{%- endif %}
#-- set dont touch AC regs -------------
#$# --> set_dont_touch [get_cells -of_objects  [all_fanin -to  [get_ports -filter "direction == out"] -startpoints_only -flat]] true
source {{cur.config_plugins_dir}}/dc_scripts/get_all_regs_connect_ports.tcl 
if {[echo $exclude_merger_regs] != ""} {
set exclude_merger_regs [get_object_name $exclude_merger_regs]
set_dont_touch [get_cells $exclude_merger_regs] true
}
#-- setting ----------------------------
identify_clock_gating
set placer_always_use_congestion_expansion_factors true
set spg_incr_placement_pass2_congestion_driven true
#magnet_placement -mark_fixed -logical_level 1  [get_pins -of_objects [all_macro_cells] -filter "name == CLK"]

#-- merge multi-bit --------------------

# Modified by Cindy Wang on: Fri Jul 29 02:18:43 CST 2016 END
if {[echo $exclude_merger_regs] != ""} {
set_dont_touch [get_cells $exclude_merger_regs] false
}
#-- useful_skew ------------------------
#source -echo -verbose {{cur.config_plugins_dir}}/dc_scripts/useful_skew.tcl
source {{cur.config_plugins_dir}}/dc_scripts/proc_auto_weights.tcl
proc_auto_weights -wns
group_path -name REGIN -weight 0.1
group_path -name REGOUT -weight 0.1


#-- compile ----------------------------
compile_ultra -incremental -no_autoungroup 
source -e {{cur.config_plugins_dir}}/dc_scripts/change_name.tcl
write -hier -format verilog -out {{cur.cur_flow_data_dir}}/02_{{env.BLK_NAME}}_MB.v
write -f ddc -h -out {{cur.cur_flow_data_dir}}/02_{{env.BLK_NAME}}_MB.ddc

#-- report -----------------------------
report_timing -nets -input_pins -nosplit -significant_digits 3 -max_paths 100000 -slack_lesser_than 0 -nworst 1 -delay max > {{cur.cur_flow_rpt_dir}}/04_SYN_{{local.lib_corner}}.rpt
sh /usr/bin/perl {{cur.config_plugins_dir}}/dc_scripts/check_violation_summary.pl {{cur.cur_flow_rpt_dir}}/04_SYN_{{local.lib_corner}}.rpt > {{cur.cur_flow_rpt_dir}}/04_SYN_{{local.lib_corner}}.sum
proc_qor > {{cur.cur_flow_rpt_dir}}/04_proc_qor.rpt
report_qor > {{cur.cur_flow_rpt_dir}}/04_qor.rpt
report_power > {{cur.cur_flow_rpt_dir}}/04_power.rpt

echo "lvt ratio after 1st compile:" > {{cur.cur_flow_rpt_dir}}/ratio_lvt.rpt
report_threshold_voltage_group  >> {{cur.cur_flow_rpt_dir}}/ratio_lvt.rpt
report_clock_gating -nosplit > {{cur.cur_flow_rpt_dir}}/report_clock_gating.rpt
report_qor > {{cur.cur_flow_rpt_dir}}/{{env.BLK_NAME}}.qor
# Modified by Cindy Wang on: Fri Jul 29 02:32:32 CST 2016 END
