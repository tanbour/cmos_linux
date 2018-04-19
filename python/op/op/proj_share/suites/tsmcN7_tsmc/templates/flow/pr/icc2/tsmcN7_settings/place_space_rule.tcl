# placement abut rule (Only needed in place stage)
create_abut_rules -number_of_references 4 -output lib_space_rule.tcl
source ./lib_space_rule.tcl
source  -e -v ./rm_user_scripts/N7_settings/N7_settings_lib_space_rule_ulvt.tcl
set TCL_PLACEMENT_SPACING_LABEL_RULE_FILEs  [glob /proj/7nm_evl/WORK/juliaz/hash_engine/data/icc2Sprule/*.tcl]
foreach TCL_PLACEMENT_SPACING_LABEL_RULE_FILE $TCL_PLACEMENT_SPACING_LABEL_RULE_FILEs {
   if {[file exists [which $TCL_PLACEMENT_SPACING_LABEL_RULE_FILE]]} {
      source -e -v  $TCL_PLACEMENT_SPACING_LABEL_RULE_FILE
   } elseif {$TCL_PLACEMENT_SPACING_LABEL_RULE_FILE != ""} {
      puts "Error: TCL_PLACEMENT_SPACING_LABEL_RULE_FILE($TCL_PLACEMENT_SPACING_LABEL_RULE_FILE) is invalid. Pls correct it."
   }
}

## add by saber:
set_app_options -name place.legalize.enable_vertical_abutment_rules -value true
source -e -v /proj/7nm_evl/WORK/saberh/scr/space_rule_tap.tcl

Cmdlog {report_placement_spacing_rules} 

