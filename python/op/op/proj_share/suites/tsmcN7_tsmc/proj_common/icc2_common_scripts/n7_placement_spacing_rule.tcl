# placement abut rule (Only needed in place stage)
if { $cur_stage == "02_place" } {
create_abut_rules -number_of_references 4 -output lib_space_rule.tcl
source ./lib_space_rule.tcl
}
#source  -e -v ./rm_user_scripts/N7_settings/N7_settings_lib_space_rule_ulvt.tcl
if {$lib_cell_height == "240"} {
    set TCL_PLACEMENT_SPACING_LABEL_RULE_FILEs  [glob ${blk_proj_cmn}/icc2_common_scripts/icc2Sprule/6T/*.tcl]
        foreach TCL_PLACEMENT_SPACING_LABEL_RULE_FILE $TCL_PLACEMENT_SPACING_LABEL_RULE_FILEs {
            if {[file exists [which $TCL_PLACEMENT_SPACING_LABEL_RULE_FILE]]} {
                source -e -v  $TCL_PLACEMENT_SPACING_LABEL_RULE_FILE
            } elseif {$TCL_PLACEMENT_SPACING_LABEL_RULE_FILE != ""} {
              puts "Error: TCL_PLACEMENT_SPACING_LABEL_RULE_FILE($TCL_PLACEMENT_SPACING_LABEL_RULE_FILE) is invalid. Pls correct it."
            }
      }
}

if {$lib_cell_height == "300"} {
    set TCL_PLACEMENT_SPACING_LABEL_RULE_FILEs  [glob ${blk_proj_cmn}/icc2_common_scripts/icc2Sprule/7d5T/*.tcl]
        foreach TCL_PLACEMENT_SPACING_LABEL_RULE_FILE $TCL_PLACEMENT_SPACING_LABEL_RULE_FILEs {
            if {[file exists [which $TCL_PLACEMENT_SPACING_LABEL_RULE_FILE]]} {
                source -e -v  $TCL_PLACEMENT_SPACING_LABEL_RULE_FILE
            } elseif {$TCL_PLACEMENT_SPACING_LABEL_RULE_FILE != ""} {
              puts "Error: TCL_PLACEMENT_SPACING_LABEL_RULE_FILE($TCL_PLACEMENT_SPACING_LABEL_RULE_FILE) is invalid. Pls correct it."
            }
      }
}
