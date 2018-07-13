## ---------------------
## pre-CTS
## ---------------------
## Set Dont Use ##
   ;# set dont use relative STD libs.
#source -e -v "{{env.PROJ_SHARE_CMN}}/icc2_common_scripts/set_lib_cell_purpose.tcl"
Cmdlog {report_lib_cell -objects [get_lib_cells] -column {full_name:20 valid_purposes}} "$Finish_report/report_lib_cell_purpose.rpt"


## ----------------------------------------------------------------------------------
## CTS Customize Settings
## ----------------------------------------------------------------------------------
set_clock_uncertainty -setup 0.07 [all_clocks] -scenarios [all_scenarios]
set_clock_uncertainty -hold  0.01 [all_clocks] -scenarios [all_scenarios]

set_max_transition  0.06 -clock_path [get_clocks *] -corners [all_corners]
#set_max_capacitance 0.05 -clock_path [get_clocks *] -corners [all_corners]
set_clock_tree_options -target_skew 0.060

## ----------------------------------------------------------------------------------
## size all ICG as ULVT C16
## Move to pre_place.tcl
## ----------------------------------------------------------------------------------
##foreach_in_collection icg [ get_cells -hierarchical -filter "ref_name =~ CKLN*"] {
##  size_cell $icg CKLNQD16BWP16P90CPDULVT
##}

## ----------------------------------------------------------------------------------
## NDR rule
## ----------------------------------------------------------------------------------
#source -e -v "{{env.PROJ_SHARE_CMN}}/icc2_common_scripts/icc2_cts_ndr_rule.tcl"
## ----------------------------------------------------------------------------------
## CTS exception
## balance points
## ----------------------------------------------------------------------------------
#set_clock_balance_points -delay 0 -balance_points \
#  [get_pins -of_objects [get_cells -hierarchical -filter "design_type == macro"] -filter "name == CLK"]
####################################
## CTS cells and restrictions 
####################################
## derive_clock_cell_references
#  Check non-repeater cells on clock trees and suggest logically equivalent cells for CTS to use
# 	derive_clock_cell_references -output refs.tcl
#  Edit refs.tcl and source it

## The following commands have been set in common_settings_for_all.tcl. If you haven't done so, pls uncomment them here.
## CTS cells 
#	Please make sure you include always-on cells for MV-CTS, clock gate cells (for sizing),
#	and equivalent gates for other types of pre-existing clock cells such as muxes (for sizing).
#	You should also include flops (CCD can size them for timing improvement) in the list.
#	Here's an example if you want to include flops that are already available to optimization :
#	set_lib_cell_purpose -include cts [get_lib_cells */SDFF* -filter "valid_purposes=~*optimization*"]		 
## CTS-exclusive cells
#	These are the lib cells to be used by CTS exclusively, such as CTS specific buffers and inverters.
#	Please be aware that these cells will be applied with only cts purpose and nothing else.
#	If you want to use these lib cells for other purposes, such as optimization and hold,
#	specify them in CTS_LIB_CELL_PATTERN_LIST instead.

## Set CTS dont touch cells	
#if {$CTS_DONT_TOUCH_CELL_LIST != ""} {set_dont_touch $CTS_DONT_TOUCH_CELL_LIST true}
## Set CTS dont buffer nets	
#if {$CTS_DONT_BUFFER_NET_LIST != ""} {set_dont_touch [get_nets -segments $CTS_DONT_BUFFER_NET_LIST] true}
## set CTS size only cells
#if {$CTS_SIZE_ONLY_CELL_LIST != ""} {set_size_only $CTS_SIZE_ONLY_CELL_LIST true}
####################################
## CTS cell spacing 
####################################
# Apply placement based cell to cell spacing rule to avoid EM problem on P/G rails.
# This rule will be applied to the clock buffers/inverters, the clock gating cells only.
#	Example : set_clock_cell_spacing -x_spacing 0.9 -y_spacing 0.4 -lib_cells mylib/BUFFD2BWP

####################################
## CTS hierarchy preservation 
####################################
# To prevent CTS from punching new logical ports for logical hierarchies
#	Example : set_freeze_ports -clocks [get_cells {block1}]
