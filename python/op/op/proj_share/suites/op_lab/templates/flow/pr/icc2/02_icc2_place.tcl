
##########################################################################################
# Tool: IC Compiler II
# Alchip Onepiece
##########################################################################################
puts "Alchip-info : Running script [info script]\n"

#set pre_stage icc2_fp
#set cur_stage icc2_place
set pre_stage "{{pre.sub_stage}}"
set cur_stage "{{cur.sub_stage}}"

set pre_stage [lindex [split $pre_stage .] 0]
set cur_stage [lindex [split $cur_stage .] 0]

##mkdir tool output dirctory
set cur_flow_data_dir "{{cur.flow_data_dir}}/{{cur.stage}}"
set pre_flow_data_dir "{{pre.flow_data_dir}}/{{pre.stage}}"
set cur_flow_rpt_dir "{{cur.flow_rpt_dir}}/{{cur.stage}}"
set cur_flow_log_dir "{{cur.flow_log_dir}}/{{cur.stage}}"
set cur_flow_sum_dir "{{cur.flow_sum_dir}}/{{cur.stage}}"

exec mkdir -p $cur_flow_data_dir
exec mkdir -p $cur_flow_rpt_dir
exec mkdir -p $cur_flow_log_dir
exec mkdir -p $cur_flow_sum_dir

set BLK_NAME          "{{env.BLK_NAME}}"

set pre_design_library  "$pre_flow_data_dir/$pre_stage.{{env.BLK_NAME}}.nlib"
set cur_design_library "$cur_flow_data_dir/$cur_stage.{{env.BLK_NAME}}.nlib"

set place_cpu_number "{{local.place_cpu_number}}"
set place_opt_active_scenario_list "{{local.place_opt_active_scenario_list}}"
set optimization_flow "{{local.optimization_flow}}"
set place_opt_spg_flow "{{local.place_opt_spg_flow}}"
set place_opt_optimize_icgs "{{local.place_opt_optimize_icgs}}"
set place_opt_optimize_icgs_critical_range "{{local.place_opt_optimize_icgs_critical_range}}"
set place_opt_multibit_banking "{{local.place_opt_multibit_banking}}"
set place_opt_multibit_debanking  "{{local.place_opt_multibit_debanking}}"
set place_opt_refine_opt "{{local.place_opt_refine_opt}}"
set pre_cts_setup_uncertainty "{{local.pre_cts_setup_uncertainty}}"
set write_def_convert_icc2_site_to_lef_site_name_list "{{local.write_def_convert_icc2_site_to_lef_site_name_list}}"

##setup host option

set_host_option -max_core $place_cpu_number

##back up database
set bak_date [exec date +%m%d]
if {[file exist ${cur_design_library}] } {
if {[file exist ${cur_design_library}_bak_${bak_date}] } {
exec rm -rf ${cur_design_library}_bak_${bak_date}
}
exec mv -f ${cur_design_library} ${cur_design_library}_bak_${bak_date}
}
## copy block and lib from previous stage
copy_lib -from_lib ${pre_design_library} -to_lib ${cur_design_library} -no_design
open_lib ${pre_design_library}
copy_block -from ${pre_design_library}:{{env.BLK_NAME}}/${pre_stage} -to ${cur_design_library}:{{env.BLK_NAME}}/${cur_stage}
close_lib ${pre_design_library}

open_lib ${cur_design_library}

current_block {{env.BLK_NAME}}/${cur_stage}

link_block
save_lib

####################################
## Timing constraints
####################################

{% if local.place_opt_active_scenario_list != "" %} 
set_scenario_status -active false [get_scenarios -filter active]
set_scenario_status -active true $place_opt_active_scenario_list
{%- else %}
set_scenario_status -active true [all_scenarios]
{% endif %}  

########################################################################
## Additional timer related setups :prects uncertainty 	
########################################################################
{% if local.pre_cts_setup_uncertainty != "" %} 
foreach scenario $place_opt_active_scenario_list {
current_scenario $scenario
remove_clock_uncertainty -setup -hold [all_clocks ]
set_clock_uncertainty -setup $pre_cts_setup_uncertainty [all_clocks ]
}
{% endif %}

########################################################################
## place_opt settings	
########################################################################
## Reset all app options in current block
reset_app_options -block [current_block] *
{% include 'icc2/tsmc_settings/tsmc16ffc_common.tcl' %}
{% include 'icc2/tsmc_settings/tsmc16ffc_place.tcl' %}

set_app_option -list {place.coarse.continue_on_missing_scandef true}
########################################################################
## source dont_use/hold_fix/cts cell 
########################################################################
#source -e -v "{{cur.config_plugins_dir}}/icc2_scripts/set_lib_cell_purpose.tcl"

####################################
## Enable AOCV 	
####################################
{% if local.ocv_mode == "aocv" %} 
## Enable the AOCV analysis
set_app_options -name time.aocvm_enable_analysis -value true ;# default false
{% elif local.ocv_mode == "pocv" %} 
set_app_options -name  time.pocvm_enable_analysis true ; ;# default false
{% endif %}

####################################
## read_saif 
####################################
## read_saif is recommended for features such as PREROUTE_LOW_POWER_PLACEMENT, and PREROUTE_TOTAL_POWER_OPTIMIZATION

####################################
## Pre-place_opt customizations
####################################

{# OPTIMIZATION_FLOW: ttr  : runs two pass place_opt #}
{%- if  local.optimization_flow == "ttr"  %}
#######################################################################
#OPTIMIZATION_FLOW: ttr: runs single place_opt	
#######################################################################
{%- if local.place_opt_spg_flow == "true" %}
set_app_options -name place_opt.flow.do_spg -value true
{%- endif %}
place_opt
{%- endif %}
{# OPTIMIZATION_FLOW: qor  : runs two pass place_opt #}
{%- if  local.optimization_flow == "qor"  %}
#######################################################################
#OPTIMIZATION_FLOW: qor  : runs two pass place_opt	
#######################################################################

puts "Alchip-info: Running place_opt -to initial_drc"
place_opt -to initial_drc
puts "Alchip-info: Running update_timing -full"
update_timing -full

puts "Alchip-info: save block for place_opt -to initial_drc"
save_block 

{%- if local.place_opt_optimize_icgs == "true" %} 
set_app_option -name place_opt.flow.optimize_icgs -value true ;# default false
{% if local.place_opt_optimize_icgs_critical_range != "" %} 
set_app_options -name place_opt.flow.optimize_icgs_critical_range -value $place_opt_optimize_icgs_critical_range ;# default 0.75
{%- endif %}
{%- endif %}

puts "Alchip-info: Running create_placement -use_seed_locs -timing_driven -congestion"
create_placement -use_seed_locs -timing_driven -congestion

puts "Alchip-info: save block for create_placement -use_seed_locs -timing_driven -congestion"
save_block 

puts "Alchip-info: Running place_opt -from initial_drc -to initial_opto"
place_opt -from initial_drc -to initial_opto

puts "Alchip-info: save block for place_opt -from initial_drc -to initial_opto"
save_block

puts "Alchip-info: save block for place_opt -from initial_drc -to initial_opto"

{%- if local.place_opt_multibit_banking == "true" %} 
	puts "Alchip-info: Running identify_multibit -register -no_dft_opt -apply"
	identify_multibit -register -no_dft_opt -apply
{%- endif %}

puts "Alchip-info: Running place_opt -from final_place"
place_opt -from final_place

puts "Alchip-info: save block for place_opt -from final_place"
save_block

{%- if local.place_opt_multibit_debanking == "true" %} 
puts "Alchip-info: Running split_multibit -slack_threshold 0"
split_multibit -slack_threshold 0
{%- endif %}
{%- endif %}
{# OPTIMIZATION_FLOW: hplp  : runs two pass place_opt #}
{%- if local.optimization_flow == "hplp" %} 
#######################################################################
#OPTIMIZATION_FLOW:  hplp  : runs two pass place_opt	
#######################################################################

puts "Alchip-info: Running place_opt -to initial_drc"
place_opt -to initial_drc
puts "Alchip-info: Running update_timing -full"
update_timing -full

puts "Alchip-info: save block for place_opt -to initial_drc"
save_block 

{%- if local.place_opt_optimize_icgs == "true" %} 
set_app_option -name place_opt.flow.optimize_icgs -value true ;# default false
{%- if local.place_opt_optimize_icgs_critical_range != "" %} 
set_app_options -name place_opt.flow.optimize_icgs_critical_range -value $place_opt_optimize_icgs_critical_range ;# default 0.75
{%- endif %}
{%- endif %}

puts "Alchip-info: Running create_placement -use_seed_locs -timing_driven -effort high"
create_placement -use_seed_locs -timing_driven -effort high

puts "Alchip-info: save block for create_placement -use_seed_locs -timing_driven -effort high"
save_block

puts "Alchip-info: Running place_opt -from initial_drc -to initial_opto"
place_opt -from initial_drc -to initial_opto

puts "Alchip-info: save block for place_opt -from initial_drc -to initial_opto"
save_block

{% if local.place_opt_multibit_banking == "true" %} 
	puts "Alchip-info: Running identify_multibit -register -no_dft_opt -apply"
	identify_multibit -register -no_dft_opt -apply
{% endif %}

puts "Alchip-info: Running place_opt -from final_place"
place_opt -from final_place

puts "Alchip-info: save block for place_opt -from final_place"
save_block

{% if local.place_opt_multibit_debanking == "true" %} 
	puts "Alchip-info: Running split_multibit -slack_threshold 0"
	split_multibit -slack_threshold 0
{%- endif %}
{%- endif %}
{# OPTIMIZATION_FLOW: arlp  : runs two pass place_opt #}
{%- if local.optimization_flow == "arlp" %} 
#######################################################################
##OPTIMIZATION_FLOW: arlp  : runs two pass place_opt	
#######################################################################
puts "Alchip-info: Running place_opt -to initial_drc"
place_opt -to initial_drc
puts "Alchip-info: Running update_timing -full"
update_timing -full

puts "Alchip-info: save block for place_opt -to initial_drc"
save_block 

{%- if local.place_opt_optimize_icgs == "true" %} 
set_app_option -name place_opt.flow.optimize_icgs -value true ;# default false
{%- if local.place_opt_optimize_icgs_critical_range != "" %} 
set_app_options -name place_opt.flow.optimize_icgs_critical_range -value $place_opt_optimize_icgs_critical_range ;# default 0.75
{%- endif %}
{%- endif %}
puts "Alchip-info: Running create_placement -use_seed_locs -timing_driven -congestion"
create_placement -use_seed_locs -timing_driven -congestion

puts "Alchip-info: save block for create_placement -use_seed_locs -timing_driven -congestion"
save_block 

puts "Alchip-info: Running place_opt -from initial_drc -to initial_opto"
place_opt -from initial_drc -to initial_opto

puts "Alchip-info: save block for place_opt -from initial_drc -to initial_opto"
save_block

{%- if local.place_opt_multibit_banking == "true" %} 
	puts "Alchip-info: Running identify_multibit -register -no_dft_opt -apply"
	identify_multibit -register -no_dft_opt -apply
{%- endif %}

puts "Alchip-info: Running place_opt -from final_place"
place_opt -from final_place

puts "Alchip-info: save block for place_opt -from final_place"
save_block 

{%- if local.place_opt_multibit_debanking == "true" %} 
	puts "Alchip-info: Running split_multibit -slack_threshold 0"
	split_multibit -slack_threshold 0
{%- endif %}
{%- endif %}
{# OPTIMIZATION_FLOW: hc  : runs two pass place_opt #}
{%- if local.optimization_flow == "hc" %} 
########################################################################## 
#OPTIMIZATION_FLOW: hc : runs two pass place_opt
########################################################################## 

		#  CDR: The following is WITH congestion-driven restructuring (CDR) enabled.
		#  SPG: For designs starting with SPG input, since seed placement comes from SPG,
		#       initial placement of CDR is skipped by enabling place_opt.flow.do_spg during CDR.

{%- if local.place_opt_spg_flow == "false" %} 
puts "RM-info: Running place_opt -to initial_drc"
place_opt -to initial_drc
puts "RM-info: Running update_timing -full"
update_timing -full

puts "Alchip-info: save block for place_opt -to initial_drc"
save_block

{%- else %}
puts "RM-info: For designs starting with SPG input, since seed placement comes from SPG, initial placement of CDR is skipped by setting place_opt.flow.do_spg to true for CDR."
puts "RM-info: set_app_options -name place_opt.flow.do_spg -value true" 
set_app_options -name place_opt.flow.do_spg -value true
puts "RM-info: Running create_placement -congestion_driven_restructuring" 
create_placement -congestion_driven_restructuring
puts "RM-info: set_app_options -name place_opt.flow.do_spg -value false" 
set_app_options -name place_opt.flow.do_spg -value false
puts "RM-info: Running place_opt -from initial_drc -to initial_drc"
place_opt -from initial_drc -to initial_drc	
puts "RM-info: Running update_timing -full"
update_timing -full
puts "Alchip-info: save block for place_opt -to initial_drc"
save_block

{%- endif %}

{%- if local.place_opt_optimize_icgs == "true" %} 
set_app_option -name place_opt.flow.optimize_icgs -value true ;# default false
{%- if local.place_opt_optimize_icgs_critical_range != "" %} 
set_app_options -name place_opt.flow.optimize_icgs_critical_range -value $place_opt_optimize_icgs_critical_range ;# default 0.75
{%- endif %}        
{%- endif %}
puts "Alchip-info: Running create_placement -use_seed_locs -timing_driven -congestion -congestion_effort high -effort high"
create_placement -use_seed_locs -timing_driven -congestion -congestion_effort high -effort high
puts "Alchip-info: Running place_opt -from initial_drc -to initial_opto"
place_opt -from initial_drc -to initial_opto

{%- if local.place_opt_multibit_banking ==  "true" %} 
puts "Alchip-info: Running identify_multibit -register -no_dft_opt -apply"
identify_multibit -register -no_dft_opt -apply
{%- endif %}

puts "Alchip-info: Running place_opt -from final_place"
place_opt -from final_place

{%- if local.place_opt_multibit_debanking == "true" %} 
puts "Alchip-info: Running split_multibit -slack_threshold 0"
split_multibit -slack_threshold 0
{%- endif %}
{%- endif %}
####################################
## Post-place_opt customizations
####################################

#touch -f  {{cur.config_plugins_dir}}/02_place_plug/post_place.tcl

####################################
## refine_opt	
####################################
{%- if local.place_opt_refine_opt == "true" %} 
puts "Alchip-info: Running refine_opt command"
refine_opt
puts "Alchip-info: save block for refine_opt"
save_block 
{%- endif %}

####################################
## output netlist/def
####################################

####################################
## save design
####################################
save_block
save_block -as {{env.BLK_NAME}}
save_lib

####################################
## Report and output
####################################			 
{%- if local.write_place_data == "true" %} 

write_verilog -exclude {leaf_module_declarations pg_objects} -hierarchy all $cur_flow_data_dir/$cur_stage.{{env.BLK_NAME}}.v

write_verilog  -exclude {scalar_wire_declarations leaf_module_declarations empty_modules} -hierarchy all $cur_flow_data_dir/${cur_stage}.{{env.BLK_NAME}}.pg.v

{% if local.write_def_convert_icc2_site_to_lef_site_name_list != "" %} 
write_def -include_tech_via_definitions -convert_sites { $write_def_convert_icc2_site_to_lef_site_name_list } -compress gzip $cur_flow_data_dir/.${cur_stage}{{env.BLK_NAME}}.def
{%- else %}
write_def -include_tech_via_definitions -compress gzip $cur_flow_data_dir/${cur_stage}.{{env.BLK_NAME}}.def
{%- endif %}
{%- endif %}
####################################
## exit icc2
####################################	
exit
