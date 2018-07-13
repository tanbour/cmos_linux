
#!/bin/csh -f
source /proj/onepiece4/op_env.csh

set pre_stage = "{{pre.sub_stage}}"
set cur_stage = "{{cur.sub_stage}}"

set pre_stage = `echo $pre_stage | cut -d . -f 1`
set cur_stage = `echo $cur_stage | cut -d . -f 1`

ln -sf {{pre.flow_data_dir}}/{{pre.stage}}/${pre_stage}.{{env.BLK_NAME}}.gds.gz {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.gds.gz
ln -sf {{pre.flow_data_dir}}/{{pre.stage}}/${pre_stage}.{{env.BLK_NAME}}.lvs.v.gz {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.lvs.v.gz

#===================================================================
#===================  delete existing run file and folder ==========
#===================================================================
if (-e {{cur.cur_flow_rpt_dir}}/$cur_stage.run_time) then
rm -rf {{cur.cur_flow_rpt_dir}}/$cur_stage.run_time
endif
touch {{cur.cur_flow_rpt_dir}}/$cur_stage.run_time
#===================================================================
#=================== set opus input files ==========================
#===================================================================
set gds_files                        = "{{liblist.GDS_STD}} {{liblist.GDS_MEM}} {{liblist.GDS_IP}} {{liblist.GDS_IO}}"
set map_file                         = "{{liblist.OPUS_MAPPING_FILE}}" 
set tech_file                        = "{{liblist.OPUS_TECH_FILE}}"
set run_time                         = "{{cur.cur_flow_rpt_dir}}/$cur_stage.run_time"
set gds_plugin_file                  = "{{cur.config_plugins_dir}}/opus_scripts/opus_oa_lib_plugin.list"
set opus_skip_gen_standard_lib       = "{{local.opus_skip_gen_standard_lib}}"
set opus_oa_output_path              = "{{local.opus_oa_output_path}}"
set cds_lib                          = ""

#===================================================================
#=================== opus strmin setting    ========================
#===================================================================
set display_drf                      = "{{liblist.OPUS_DISPLAY_DRF}}"
set log_file                         = "{{cur.cur_flow_log_dir}}/${cur_stage}.{{env.BLK_NAME}}.log"
set sum_file                         = "{{cur.cur_flow_rpt_dir}}/${cur_stage}.{{env.BLK_NAME}}.rpt"
set scr_file                         = "{{cur.flow_scripts_dir}}/{{cur.stage}}/${cur_stage}.lib_stream_in.run"
{%- if local.opus_oa_output_path %}
set run_dir                          = "{{local.opus_oa_output_path}}"
{%- else %}
set run_dir                          = "{{cur.cur_flow_data_dir}}/opus_oa_lib"
{%- endif %}

#===================================================================
#==================  transfer STD/MEM/IO/IP gds to OA ==============
#===================================================================
{%- if  local.opus_skip_gen_standard_lib == true %} 
echo "Alchip-info:the lib of STD/MEM/IP/IO is already exist,and this step will be skipped!"
{%- else %}
mkdir -p ${run_dir} 
{%- if liblist.OPUS_DISPLAY_DRF %}
cp $display_drf  ${run_dir} -f
{%- endif %}
cd ${run_dir}
foreach gds_file  ( $gds_files )
echo $gds_file
set lib_name         = `basename ${gds_file} | sed "s#.gds.*##"`

#=================== generate STD/MEM/IO/IP strmin script ===========

cat <<strmin_setting >! ${scr_file}
#-- database setting -------------------
runDir                             "."                 # - Run Directory
topCell                            ""                  # - Top Cell(s) to Translate
strmFile                           "${gds_file}"       # - Stream File Name
layerMap                           "${map_file}"       # - Layer Map File Name
loadTechFile                       "${tech_file}"      # - ASCII Technology File Name
refLibList                         " "                 # - Rerferrence Library List File
view                               "layout"            # - View Name(s) to Translate
library                            "${lib_name}"       # - Library Name
logFile                            "${log_file}"                  # - Log File Name
summaryFile                        "${sum_file}"       # - Summary File Name

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

#=================== run STD/MEM/IO/IP strmin ========================

echo "opus_oa" >> ${run_time}
echo "start " `date "+%F %T %a"` >> ${run_time}
strmin -templateFile ${scr_file}   
end
echo "finish" `date "+%F %T %a"` >> ${run_time}
cd ..
{%- endif %}

#===================================================================
#===================   generate plugin lib =========================
#===================================================================
sed -i -e '/^$/d' -e '/#.*$/d' ${gds_plugin_file}
if ( ${gds_plugin_file} == "" ) then
echo "Alchip-info:no plugin gds!"
else
 if (!(-d ${run_dir} )) then
 mkdir -p ${run_dir}
 cp -rf $cds_lib ${run_dir}
 endif
cd ${run_dir}
foreach gds_file (`cat .${gds_plugin_file}`)
echo $gds_file
set lib_name         = `basename ${gds_file} | cut -d . -f1`
#=================== generate plugin strmin script ==================
cat <<strmin_setting >! ${scr_file}
#-- database setting -------------------
runDir                             "."                 # - Run Directory
topCell                            " "                 # - Top Cell(s) to Translate
strmFile                           "${gds_file}"       # - Stream File Name
layerMap                           "${map_file}"       # - Layer Map File Name
loadTechFile                       "${tech_file}"      # - ASCII Technology File Name
refLibList                         " "                 # - Rerferrence Library List File
view                               "layout"            # - View Name(s) to Translate
library                            "${lib_name}"       # - Library Name
logFile                            "${log_file}"                  # - Log File Name
summaryFile                        "${sum_file}"       # - Summary File Name

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

#=================== plugin strmin run  =============================
echo "opus_oa" >> ${run_time}
echo "start " `date "+%F %T %a"` >> ${run_time}
strmin -templateFile ${scr_file}   
end
echo "finish" `date "+%F %T %a"` >> ${run_time}
cd ..
endif
echo "{{env.FIN_STR}}"

