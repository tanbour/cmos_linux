#=========================== INTERFACE ==========================#
## INPUTS
#	* LIB_CORNER
# 	* OTHER_VOLTAGE
#	* SUB_BLOCKS
# 	* SUB_BLOCKS_FILE
# 	* MV_INSTANCES
# 	* MV_INSTANCES_FILE
## OUTPUTS
# 	* MV_LIBRARY_CELL_MAP
# 	* MV_LIBRARY_INST_MAP
#=========================== INTERFACE ==========================#
#source /proj/Pelican/TEMPLATES/PTSI/tcl/mv_lib_hash.tcl
#set LIB_CORNER "wcl"
#### definition from config ####
#set SUB_BLOCKS { \
#	{lib:hash_top hash_group} \
#	{verilog:cr5_top lte_top} \
#	}
#set SUB_BLOCKS_FILE "/proj/Pelican/WORK/ericl/hash_top/library/ptsi/block.mv"
#set MV_INSTANCES { \
#	tt0p75v:lib:u_hash_top/u_hash \
#	}
#set MV_INSTANCES_FILE "/proj/Pelican/WORK/ericl/hash_top/library/ptsi/instance.mv"



#========================== MAIN ===============================#
array unset MV_LIBRARY_INST_MAP *
set defaultVoltage $VOLT
set MV_LIBRARY_INST_MAP($VOLT) ""
foreach type [list verilog lib ilm bbox] {
    set SUB_BLOCKS_CELL_MAP($type) [list]
}

if {[info exists SUB_BLOCKS_FILE]  && [file exist $SUB_BLOCKS_FILE]} {
    set f [open $SUB_BLOCKS_FILE r]
    while {![eof $f]} {
       gets $f line
       if { ![regexp {^ *#} $line] && ![regexp {^ *$} $line] } {
            if {![info exists SUB_BLOCKS]} {
                 set SUB_BLOCKS [list]
            }
            lappend SUB_BLOCKS $line
       }
    }
    close $f
}

if {[info exists SUB_BLOCKS]  && [llength $SUB_BLOCKS] > 0} {
    foreach blk $SUB_BLOCKS {
        set blkList [split $blk {:}]
        set numElement [llength $blkList]
        set blkNames [lindex $blkList end]
        if {$numElement == 1} {
            set subType verilog
        } else {
             set subType [lindex $blkList 0]
        }
        set SUB_BLOCKS_CELL_MAP($subType) [concat $SUB_BLOCKS_CELL_MAP($subType) $blkNames]
    }
}
if {[info exists MV_INSTANCES_FILE]  && [file exist $MV_INSTANCES_FILE]} {
    set f [open $MV_INSTANCES_FILE r]
    while {![eof $f]} {
       gets $f line
       if { ![regexp {^ *#} $line] && ![regexp {^ *$} $line]} {
            if {![info exists MV_INSTANCES]} {
                 set MV_INSTANCES [list]
            }
            lappend MV_INSTANCES $line
       }
    }
    close $f
}

if {[info exists MV_INSTANCES]  && [llength $MV_INSTANCES] > 0} {
    foreach inst $MV_INSTANCES {
        set instList [split $inst {:}]
        set numElement [llength $instList]
        set instNames [lindex $instList end]
        if {$numElement == 1} {
            set libVolt default
        } else {
            set libVolt [lindex $instList 0]
        }
       set MV_LIBRARY_INST_MAP($libVolt) [concat $MV_LIBRARY_INST_MAP($libVolt) $instNames]
    }
}

set OTHER_VOLTAGE [array names MV_LIBRARY_INST_MAP]
set VOLTAGE [concat $defaultVoltage $OTHER_VOLTAGE]
array unset lnLibrary *
set lLimit [string toupper $LIB_CORNER]
set dbPrefix CCS
if {[info exists ENABLE_POCV] && $ENABLE_POCV == "true"} {
    set dbPrefix LVF
}
set dbPrefix ""
foreach volt $VOLTAGE {
    set lnLibrary($volt) [list]
    set vLimit [string toupper $volt]
    foreach tt [list STD MEM IP IO] {
    if { [llength  [info globals ${dbPrefix}DB_${tt}_${vLimit}_${lLimit}]] >= 1 } {
        foreach vr [info globals ${dbPrefix}DB_${tt}_${vLimit}_${lLimit}] {
             set cmd " \
             set lnLibrary($volt) \[concat $lnLibrary($volt) \$$vr\] \
             "; eval $cmd
        }
    }
    }
             puts "\$lnLibrary($volt) $lnLibrary($volt)"
}

array unset aocvLibrary *
set lLimit [string toupper $LIB_CORNER]
set cLimit [string toupper $CHECK_TYPE]
foreach volt $VOLTAGE {
    set aocvLibrary($volt) [list]
    set vLimit [string toupper $volt]
#    if { [llength [info globals AOCV_*_${vLimit}_${lLimit}_${cLimit}]] >= 1 } {
    if { [llength [info globals AOCV_*_${vLimit}_${lLimit}]] >= 1 } {
#        foreach vr [info globals AOCV_*_${vLimit}_${lLimit}_${cLimit}] {
        foreach vr [info globals AOCV_*_${vLimit}_${lLimit}] {
             set cmd " \
             set aocvLibrary($volt) \[concat $aocvLibrary($volt) \$$vr\] \
             "; eval $cmd
        }
    }
}

array unset pocvLibrary *
set lLimit [string toupper $LIB_CORNER]
set cLimit [string toupper $CHECK_TYPE]
foreach volt $VOLTAGE {
    set pocvLibrary($volt) [list]
    set vLimit [string toupper $volt]
    if { [llength [info globals SPM_*_${vLimit}_${lLimit}]] >= 1 } {
        foreach vr [info globals SPM_*_${vLimit}_${lLimit}] {
             set cmd " \
             set pocvLibrary($volt) \[concat $pocvLibrary($volt) \$$vr\] \
             "; eval $cmd
        }
    }
}
set pocvWireFile [list]
if {[info exists ENABLE_POCV] && $ENABLE_POCV == "true"} {
    if {[info exists POCV_WIRE] && [file isfile $POCV_WIRE]} {
        set pocvWireFile $POCV_WIRE
    } else {
        puts "WARNING: cannot find POCV WIRE file. Please define POCV wire using POCV_WIRE variable if you want."
    }
}

#========================== END  ===============================#

#========================== Check ===============================#
set defaultVoltageLibrary $lnLibrary($defaultVoltage)
set   otherVoltageLibrary [list] 
foreach volt [array names MV_LIBRARY_INST_MAP] {
    if {$volt eq $defaultVoltage} {
    } else {
       lappend otherVoltageLibrary [list "$MV_LIBRARY_INST_MAP($volt)" " * $lnLibrary($volt)"]
    }
}
puts "Votage Number = [llength $VOLTAGE]"
puts "Default Voltage Library:"
foreach lib $defaultVoltageLibrary {
    puts "\t- $lib"
}

puts "Other Voltage Library:"
foreach lbs $otherVoltageLibrary {
    puts "\t- [lindex $lbs 0]"
    foreach lib [lindex $lbs 1] {
        puts "\t\t + $lib"
    }
}
#========================== END  ===============================#
#
#
#

set link_path [concat * $defaultVoltageLibrary]
if {[info exists otherVoltageLibrary] && $otherVoltageLibrary != ""} {
    set link_path_per_instance $otherVoltageLibrary
}

if {[info exists SUB_BLOCKS_CELL_MAP(lib)] &&[llength $SUB_BLOCKS_CELL_MAP(lib)] > 0} {
    foreach blk $SUB_BLOCKS_CELL_MAP(lib) {
        set blkLib [glob $BLOCK_RELEASE_DIR/$blk/lib/${blk}.${SESSION}*.db]
        set link_path [concat $link_path $blkLib]
    }
}
