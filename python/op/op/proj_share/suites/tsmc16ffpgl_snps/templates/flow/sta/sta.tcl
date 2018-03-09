###===================================================================###
###   pt setup                                                        ###
###===================================================================###
set pre_stage "{{pre.sub_stage}}"
set cur_stage "{{cur.sub_stage}}"

set pre_stage [lindex [split $pre_stage .] 0]
set cur_stage [lindex [split $cur_stage .] 0]

set ANNOTATED_FILE_FORMAT	    	"{{local.ANNOTATED_FILE_FORMAT}}"

set SESSION                         "{{local._multi_inst}}" 
set MODE                            [lindex [split $SESSION .] 0]
set VOLT                            [lindex [split $SESSION .] 1]
set LIB_CORNER                      [lindex [split $SESSION .] 2]
set RC_CORNER                       [lindex [split $SESSION .] 3]
set CHECK_TYPE                      [lindex [split $SESSION .] 4]

set TOP                             "{{env.BLK_NAME}}"
set SUB_BLOCKS                      "{{local.SUB_BLOCKS}}"
set SUB_BLOCKS_FILE                 "{{local.SUB_BLOCKS_FILE}}"
set MV_INSTANCES                    "{{local.MV_INSTANCES}}"
set MV_INSTANCES_FILE               "{{local.MV_INSTANCES_FILE}}"
set SUB_BLOCKS_LOCATIONS_FILE       "{{local.SUB_BLOCKS_LOCATIONS_FILE}}"

if {[file exist {{pre.flow_data_dir}}/{{pre.stage}}/$pre_stage.{{env.BLK_NAME}}.v.gz]} {
set VNET                           " {{pre.flow_data_dir}}/{{pre.stage}}/$pre_stage.{{env.BLK_NAME}}.v.gz "
} else {
set VNET                            "{{env.BLK_NETLIST}}/{{ver.netlist}}/{{env.BLK_NAME}}.v"
}
set SDC_LIST                        "{{env.BLK_SDC}}/{{ver.sdc}}/{{env.BLK_NAME}}.${MODE}.sdc"
set SPEF                            "{{pre.flow_data_dir}}/{{pre.stage}}/{{env.BLK_NAME}}.${RC_CORNER}.spef.gz"
set CLK_MODE                        "{{local.CLK_MODE}}"
set XTK                             "{{local.XTK}}"
set PBA_MODE                        "{{local.PBA_MODE}}"
set PATH_TYPE                       "{{local.PATH_TYPE}}"
set NWORST_NUM                      "{{local.NWORST_NUM}}"
set PBA_PATH_NUM                    "{{local.PBA_PATH_NUM}}"
set MAX_PATH_NUM                    "{{local.MAX_PATH_NUM}}"
set SAVE_SESSION                    "{{local.SAVE_SESSION}}"
set GEN_SDF                         "{{local.GEN_SDF}}"
set GEN_ETM                         "{{local.GEN_ETM}}"
set GEN_ILM                         "{{local.GEN_ILM}}"
set GEN_HSC                         "{{local.GEN_HSC}}"
set GEN_ICE                         "{{local.GEN_ICE}}"
set GEN_RH                          "{{local.GEN_RH}}"
set ENABLE_OCV                      "{{local.ENABLE_OCV}}"
set ENABLE_AOCV                     "{{local.ENABLE_AOCV}}"
set ENABLE_POCV                     "{{local.ENABLE_POCV}}"
###===================================================================###
###  source liblist                                                   ###
###===================================================================###
source {{cur.flow_liblist_dir}}/liblist/liblist.tcl

###===================================================================###
###  run PT flow                                                      ###
###===================================================================###
{% include 'pt/PTSI_signoff_template.tcl' %}

puts "Alchip_info: op stage finished."
exit
