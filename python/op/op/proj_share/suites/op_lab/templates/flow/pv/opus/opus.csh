
#!/bin/csh -f
set pre_stage = "{{pre.sub_stage}}"
set cur_stage = "{{cur.sub_stage}}"

set pre_stage = `echo $pre_stage | cut -d . -f 1`
set cur_stage = `echo $cur_stage | cut -d . -f 1`

ln -sf {{pre.flow_data_dir}}/{pre.stage}/${pre_stage}.{{env.BLK_NAME}}.gds.gz {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.gds.gz
ln -sf {{pre.flow_data_dir}}/{pre.stage}/${pre_stage}.{{env.BLK_NAME}}.lvs.v.gz {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.lvs.v.gz

#===================================================================
#===============  set opus common input files    ===================
#===================================================================
set map_file                        = "{{liblist.OPUS_MAPPING_FILE}}" 
set tech_file                       = "{{liblist.OPUS_TECH_FILE}}"
set display_drf                     = "{{liblist.OPUS_DISPLAY_DRF}}"
set cds_lib                         = "{{local.cds_lib_path}}/cds.lib"                     
set run_time                        = "{{cur.cur_flow_rpt_dir}}/$cur_stage.run_time"
set run_dir                         = "./"

cp -rf $cds_lib  ${run_dir}
if ( $display_drf != "" ) then
cp -f $display_drf ${run_dir}
endif
touch -f ${run_time}

############ transfer subblock gds in plugin file to OA #################
set block_gds_plugin_file                  = "{{cur.config_plugins_dir}}/opus_scripts/opus_block_lib_plugin.list"
sed -i -e '/^$/d' -e '/^#.*$/d' ${block_gds_plugin_file}
if ( -s ${block_gds_plugin_file} ) then
foreach block_gds_file (`cat ${block_gds_plugin_file}`)
echo ${block_gds_file}
set block_topcell_name                     = `basename ${block_gds_file} | cut -d . -f1`
set block_log_file                         = "{{cur.cur_flow_log_dir}}/sub_block.strmin.log"
set block_sum_file                         = "{{cur.cur_flow_rpt_dir}}/sub_clock.strmin.rpt"
set block_scr_file                         = "{{cur.flow_scripts_dir}}/{{cur.stage}}/${cur_stage}.sub_block.strmin.run"

#=================== generate plugin strmin script ==================
cat <<block_strmin_setting >! ${block_scr_file}
#-- database setting -------------------
runDir                             "."        # - Run Directory
topCell                            "${block_topcell_name}"                 # - Top Cell(s) to Translate
strmFile                           "${block_gds_file}"       # - Stream File Name
layerMap                           "${map_file}"       # - Layer Map File Name
loadTechFile                       "${tech_file}"      # - ASCII Technology File Name
refLibList                         "XST_CDS_LIB "        # - Rerferrence Library List File
view                               "layout"            # - View Name(s) to Translate
library                            "${block_topcell_name}"       # - Library Name
logFile                            "${block_log_file}"                  # - Log File Name
summaryFile                        "${block_sum_file}"       # - Summary File Name

#-- common setting ---------------------
pinAttNum                           0                  # - (0-127) - Stream Attribute Number To Preserve Pin
dbuPerUU                            0                  # - DB Units Per User Units
hierDepth                           32                 # - (0-32767) - Hierarchy Depth Limit
case                               "preserve"          # - preserve | upper | lower - Case Sensitivity
labelCase                          "preserve"          # - preserve | upper | lower - Label Case Sensitivity
strmTextNS                         "cdba"              # - Text NameSpace
maxCellsInTargetLib                 20000              # - Maximum Cells in Target Library
numThreads                          1                  # - Number of threads to execute simultaneously
propSeparator                      ","                 # - Property Separator Character
block_strmin_setting

#=================== plugin strmin run  =============================
echo "strmin_${block_topcell_name}" >> $run_time
echo "  start " `date "+%F %T %a"` >> $run_time
strmin -templateFile ${block_scr_file}   
rm -rf ${block_log_file}
echo "  finish" `date "+%F %T %a"` >> $run_time
end
endif

#################### transfer the top gds to OA ####################
#===================================================================
#===================   set top gds file  ===========================
#===================================================================
set gds_file         = "{{pre.flow_data_dir}}/{pre.stage}/${pre_stage}.{{env.BLK_NAME}}.gds.gz"
echo $gds_file

#===================================================================
#=================== strmin file setting  ==========================
#===================================================================
set top_name         = "{{env.BLK_NAME}}"
set log_strmin_file  = "{{cur.cur_flow_log_dir}}/${cur_stage}.{{env.BLK_NAME}}.strmin.log"
set sum_strmin_file  = "{{cur.cur_flow_rpt_dir}}/${cur_stage}.{{env.BLK_NAME}}.strmin.rpt"
set scr_strmin_file  = "{{cur.flow_scripts_dir}}/{{cur.stage}}/${cur_stage}.{{env.BLK_NAME}}.strmin.run"

#===================================================================
#=================== strmout file setting   ========================
#===================================================================
set scr_strmout_file = "{{cur.flow_scripts_dir}}/{{cur.stage}}/${cur_stage}.{{env.BLK_NAME}}.strmout.run"
set gds_strmout_file = "{{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.merge.gds.gz"
set log_strmout_file = "{{cur.cur_flow_log_dir}}/${cur_stage}.{{env.BLK_NAME}}.strmout.log"
set sum_strmout_file = "{{cur.cur_flow_rpt_dir}}/${cur_stage}.{{env.BLK_NAME}}.strmout.rpt"

#===================================================================
#=== copy cds_lib and display_drf to current run directory==========
#===================================================================
set key_text = `basename ${cds_lib}`
if ( `grep " ${top_name} " ${run_dir}/${key_text} | wc -l ` == 1 ) then
   echo "Error : cds.lib have included ${top_name}, please delete it !"
   exit
endif

#===================================================================
#================== generate stream-in run script     ==============
#===================================================================
cat <<strmin_setting >! ${scr_strmin_file}
#-- database setting -------------------
runDir                             "."                 # - Run Directory
topCell                            "${top_name}"       # - Top Cell(s) to Translate
strmFile                           "${gds_file}"       # - Stream File Name
layerMap                           "${map_file}"       # - Layer Map File Name
loadTechFile                       "${tech_file}"      # - ASCII Technology File Name
refLibList                         "XST_CDS_LIB"        # - Rerferrence Library List File
view                               "layout"            # - View Name(s) to Translate
library                            "${top_name}"       # - Library Name
logFile                            "${log_strmin_file}"       # - Log File Name
summaryFile                        "${sum_strmin_file}"       # - Summary File Name

#-- common setting ---------------------
pinAttNum                           0                  # - (0-127) - Stream Attribute Number To Preserve Pin
dbuPerUU                            0                  # - DB Units Per User Units
hierDepth                           32                 # - (0-32767) - Hierarchy Depth Limit
case                               "preserve"          # - preserve | upper | lower - Case Sensitivity
labelCase                          "preserve"          # - preserve | upper | lower - Label Case Sensitivity
strmTextNS                         "cdba"              # - Text NameSpace
maxCellsInTargetLib                 20000              # - Maximum Cells in Target Library
numThreads                          1                  # - Number of threads to execute simultaneously
propSeparator                      ","                 # - Property Separator Character
strmin_setting

#===================================================================
#==================== generate stream-out run script  ==============
#===================================================================
cat <<strmout_setting >! ${scr_strmout_file}
#-- database setting -------------------
runDir                             "."                 #- Run Directory
topCell                            "${top_name}"       #- Top Cell(s) to Translate
strmFile                           "${gds_strmout_file}"       #- Stream File Name
layerMap                           "${map_file}"       #- Layer Map File Name
outputDir                          ""                  #- The Output Directory for Stream File
refLibList                         ""                  #- Referrence Library List File Name
view                               "layout"            #- View Name(s) to Translate
library                            "${top_name}"       #- Library Name
logFile                            "${log_strmout_file}" #- Log File Name
summaryFile                        "${sum_strmout_file}" #- Summary File Name
#-- common setting ---------------------
pinAttNum                           0                  #- (0-127) - Stream Attribute Number for Preserving Pins
dbuPerUU                            0                  #- DB Units Per User Units
hierDepth                           32                 #- (0-32767) - Hierarchy Depth Limit
case                               "preserve"          #- preserve | upper | lower - Case Sensitivity
labelCase                          "preserve"          #- preserve | upper | lower - Label Case Sensitivity
strmTextNS                         "cdba"              #- Text NameSpace
convertDot                         "ignore"            #- polygon | node | ignore - Convert Dots to
viaCutArefThreshold                 0                  #- Write a STRUCT if the number of cuts are more the specified
convertPin                         "geometry"          #- geometry | text | geometryAndText | ignore - Convert Pin to
labelDepth                          1                  #- Hierarchical depth to add labels to
strmout_setting

{%- if local.opus_ignore_missing_cells == "true" %}
echo "ignoreMissingCells                 t                   #- Ignore Missing cellViews During Translation and Continue Translation" >> ${scr_strmout_file}
{%- endif %}

#-- run strmin -------------------------
echo "strmin_${top_name}" >> ${run_time}
echo "  start " `date "+%F %T %a"` >> ${run_time}
strmin -templateFile ${scr_strmin_file}   
echo "  finish" `date "+%F %T %a"` >> ${run_time}

#-- run strmout -------------------------
echo "strmout_${top_name}" >> ${run_time}
echo "  start " `date "+%F %T %a"` >> ${run_time}
strmout -templateFile ../.${scr_strmout_file}
echo "  finish" `date "+%F %T %a"` >> ${run_time}

