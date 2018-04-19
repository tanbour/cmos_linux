
#!/bin/csh -f
####################################################################
# this script is used for insert dummy metal/odpo/cod,and merge the 
# design gds with dummy-only gds used calibre or opus.you can 
# choose which dummy insert and which tool used in 200_user_setup.conf
#####################################################################
set pre_stage = "{{pre.sub_stage}}"
set cur_stage = "{{cur.sub_stage}}"

set pre_stage = `echo $pre_stage | cut -d . -f 1`
set cur_stage = `echo $cur_stage | cut -d . -f 1`

set clbre_drc_CPU_NUMBER = `echo "{{local._job_cpu_number}}" | cut -d " " -f 2`

ln -sf {{pre.flow_data_dir}}/{pre.stage}/${pre_stage}.{{env.BLK_NAME}}.gds.gz {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.gds.gz
ln -sf {{pre.flow_data_dir}}/{pre.stage}/${pre_stage}.{{env.BLK_NAME}}.lvs.v.gz {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.lvs.v.gz

#===================================================================
#====  delete existing tmp file and backup the gds file ============
#===================================================================

#------------------ set the prefix name of dummys -------------------
set pre_metal = "DVIA";
set pre_odpo  = "DODPO";
set pre_cod   = "DCOD";
#------------------ delete exist rule cmd file -----------------------
rm {{cur.flow_scripts_dir}}/{{cur.stage}}/${cur_stage}.${pre_metal}_{{env.BLK_NAME}}.rule -rf
rm {{cur.flow_scripts_dir}}/{{cur.stage}}/${cur_stage}.${pre_odpo}_{{env.BLK_NAME}}.rule -rf
rm {{cur.flow_scripts_dir}}/{{cur.stage}}/${cur_stage}.${pre_cod}_{{env.BLK_NAME}}.rule  -rf
rm {{cur.flow_scripts_dir}}/{{cur.stage}}/${cur_stage}.{{env.BLK_NAME}}.*.run -rf
rm {{cur.flow_scripts_dir}}/{{cur.stage}}/${cur_stage}.{{env.BLK_NAME}}.*.il -rf

#===================================================================
#===================  set input files          =====================
#===================================================================
set top_name              = "{{env.BLK_NAME}}"
set design_gds_file       = "{{pre.flow_data_dir}}/{{pre.stage}}/${pre_stage}.{{env.BLK_NAME}}.merge.gds.gz"
set run_time              = "{{cur.cur_flow_rpt_dir}}/$cur_stage.run_time"
touch -f $run_time
#------------------ dummy create option -----------------------
set dummy_metal_creat     = "{{local.dummy_metal_creat}}"
set dummy_odpo_creat      = "{{local.dummy_odpo_creat}}"
set dummy_cod_creat       = "{{local.dummy_cod_creat}}"

#------------------ rule deck file name-----------------------
set CAL_DECKS_METAL       = "{{liblist.CAL_DECKS_METAL}}"
set CAL_DECKS_ODPO        = "{{liblist.CAL_DECKS_ODPO}}"
set CAL_DECKS_COD         = "{{liblist.CAL_DECKS_COD}}"

{%- if local.dummy_metal_creat == "true" or local.dummy_odpo_creat == "true" or local.dummy_cod_creat == "true" %}
#===================================================================
#======================= insert dummy metal ========================
#===================================================================
set dummy_names = ""
{%- if  local.dummy_metal_creat == "true" %}
set dummy_names            = "$dummy_names DVIA"
{%- endif %}
{%- if  local.dummy_odpo_creat == "true" %}
set dummy_names            = "$dummy_names DODPO"
{%- endif %}
{%- if local.dummy_cod_creat == "true" %}
set dummy_names            = "$dummy_names DCOD"
{%- endif %} 

foreach dummy_name ( $dummy_names )
echo "Alchip-Info:create the dummy of ${dummy_name}!" 
if ( $dummy_name == DVIA ) then
set rule_deck              = "$CAL_DECKS_METAL"
{%- if local.sourceme_14lpp_metal_file %}
set sourceme_file          = "{{local.sourceme_14lpp_metal_file}}"
source $source_file
{%- endif %}
else if ( $dummy_name == DODPO ) then
set rule_deck             = "$CAL_DECKS_ODPO"
{%- if local.sourceme_14lpp_dodpo_file %}
set sourceme_file         = "{{local.sourceme_14lpp_dodpo_file}}"
source $sourceme_file
{%- endif %}
else if ( $dummy_name == DCOD ) then
set rule_deck             = "$CAL_DECKS_COD"
{%- if local.sourceme_14lpp_dcod_file %}
set sourceme_file         = "{{local.sourceme_14lpp_dcod_file}}"
source $sourceme_file
{%- endif %}
endif 
set sum_file              = "{{cur.cur_flow_rpt_dir}}/${dummy_name}_{{env.BLK_NAME}}.list"
set run_file              = "{{cur.flow_scripts_dir}}/{{cur.stage}}/${cur_stage}.${dummy_name}_{{env.BLK_NAME}}.rule"
set dummy_gds_file        = "{{cur.cur_flow_data_dir}}/${cur_stage}.${dummy_name}_{{env.BLK_NAME}}.gds"
set dummy_db_file         = "{{cur.cur_flow_data_dir}}/${cur_stage}.${dummy_name}_{{env.BLK_NAME}}.db"

cat <<dummy_setting >! ${run_file}
LAYOUT ERROR ON INPUT NO

LAYOUT PRIMARY "${top_name}"
LAYOUT PATH    "${design_gds_file}"
LAYOUT SYSTEM GDSII

DRC SUMMARY REPORT "${sum_file}"
dummy_setting

#----------defined the dummy metal gds output format-------------------
set metal_results_db_key_word = `grep 'DFM DEFAULTS RDB GDS FILE' ${rule_deck}`

if ( "${metal_results_db_key_word}" != "" ) then
cat << metal_dfm_defaults_rdb >> ${run_file}
DFM DEFAULTS RDB GDS FILE "${dummy_gds_file}" PREFIX ${dummy_name}_
DRC RESULTS DATABASE "${dummy_db_file}"
DRC ICSTATION YES
metal_dfm_defaults_rdb
else 
cat << metal_drc_results_db >> ${run_file}
//DRC RESULTS DATABASE "ADD_DUMAAGTMnVn.gds" GDSII _dummy
//DRC RESULTS DATABASE "DUM.OUT" ASCII
DRC RESULTS DATABASE "${dummy_gds_file}"   GDSII  PREFIX ${dummy_name}_
DRC ICSTATION YES
metal_drc_results_db
endif

echo INCLUDE  {{cur.config_plugins_dir}}/opus_scripts/opus_dummy_${dummy_name}_plugin.rule >> ${run_file}
echo INCLUDE "${rule_deck}" >> ${run_file}

#=================== run metal insertion ===============================
echo "insert_$dummy_name " >> ${run_time}
echo " start " `date "+%F %T %a"` >> ${run_time}
{# -- if $CALIBRE_HOME contain "ixl",use the centos5 to run drc-----------
#set clbre_version = `basename $CALIBRE_HOME | awk 'BEGIN{FS="_"} {print $1}'`
#if ( $clbre_version == ixl ) then
#set host_version = centos5
#endif
#-- if $CALIBRE_HOME contain "aoi",use the centos6 to run drc------------
#if ( $clbre_version == aoi ) then
#set host_version = centos6
#endif
#}

{%- if local.calibre_insert_dummy_user_run_cmd %} 
#---------- use the user defined cmd to insert dummy metal --------------
echo "{{local.calibre_insert_dummy_user_run_cmd}} ${run_file}"
eval "{{local.calibre_insert_dummy_user_run_cmd}}  ${run_file}" 
{%- else %} 
#---------- use the default cmd to insert dummy metal --------------------
calibre  -drc -hier -hyper -turbo ${clbre_drc_CPU_NUMBER} -64  ${run_file}     
{%- endif %}

echo "  finish" `date "+%F %T %a"` >> $run_time

gzip -f $dummy_gds_file
end
{%- endif %}


{%- if  local.tool_use_to_merge_dummy_gds == "calibre" %}
#===================================================================
#=================== merge final gds by calibre ====================
#===================================================================
#************* start use calibre gds merge *****************
echo "Alchip-Info:Use calibre to merge dummy gds!"
echo "merge gds by calibre " >> ${run_time}
echo "  start " `date "+%F %T %a"` >> ${run_time}
mkdir -p clbre_dummy_merge_work
set cmd = "calibredrv -a layout filemerge -in  ${design_gds_file}"

{%- if local.dummy_metal_creat == "true" %}
#--------- input only dummy metal gds file to merge if exist --------
 if  (-e {{cur.cur_flow_data_dir}}/${cur_stage}.${pre_metal}_{{env.BLK_NAME}}.gds.gz ) then
  set cmd = "$cmd -in {{cur.cur_flow_data_dir}}/${cur_stage}.${pre_metal}_{{env.BLK_NAME}}.gds.gz"
 else
 echo "Alchip-Info:there is no {{cur.cur_flow_data_dir}}/${cur_stage}.${pre_metal}_{{env.BLK_NAME}}.gds.gz,please to check you already insert dummy metal! "
 endif
{%- endif %}

{%- if local.dummy_odpo_creat == "true" %}
#--------- input only dummy odpo gds file to merge if exist ---------
 if ( -e {{cur.cur_flow_data_dir}}/${cur_stage}.${pre_odpo}_{{env.BLK_NAME}}.gds.gz) then
  set cmd = "$cmd -in  {{cur.cur_flow_data_dir}}/${cur_stage}.${pre_odpo}_{{env.BLK_NAME}}.gds.gz"
 else
 echo "Alchip-Info:there is no {{cur.cur_flow_data_dir}}/${cur_stage}.${pre_odpo}_{{env.BLK_NAME}}.gds.gz, please to check you already insert dummy odpo! "
 endif 
{%- endif %}

{%- if local.dummy_cod_creat == "true" %}
#--------- input only dummy cod gds file to merge if exist -----------
  if (-e {{cur.cur_flow_data_dir}}/${cur_stage}.${pre_cod}_{{env.BLK_NAME}}.gds.gz) then
   set cmd = "$cmd -in {{cur.cur_flow_data_dir}}/${cur_stage}.${pre_cod}_{{env.BLK_NAME}}.gds.gz "
  else 
  echo "Alchip-Info:there is no {{cur.cur_flow_data_dir}}/${cur_stage}.${pre_cod}_{{env.BLK_NAME}}.gds.gz,please to check you already insert dummy cod! "
  endif 
{%- endif %}

#========= submit openlava job for calibre GDS merge ================
set cmd = "$cmd -out  {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.dummy_merge.gds.gz -map_cell ${top_name} ${top_name}_top -createtop ${top_name} -mode append -tmp clbre_dummy_merge_work"
echo $cmd
eval $cmd

echo "  finish" `date "+%F %T %a"` >> ${run_time}
rm -rf clbre_dummy_merge_work
#************* endof use calibre merge gds *****************
{%- endif %}

{%- if local.tool_use_to_merge_dummy_gds == "opus" %}
#===================================================================
#=================== merge final gds by opus =======================
#===================================================================
#************* start use opus merge gds *****************
echo "Alchip-Info:Use opus to merge dummy gds!"

#=================== opus input files setting   =====================
set run_dir               = "./"
set map_file              = "{{liblist.OPUS_MAPPING_FILE}}" 
set tech_file             = "{{liblist.OPUS_TECH_FILE}}"

#************* start use opus to transfer dummy gds to OA *****************
foreach dummy_name ( $dummy_names ) 
#===================  dummy metal strmin setting  ====================
set dummy_gds_file        = "{{cur.cur_flow_data_dir}}/${cur_stage}.${dummy_name}_{{env.BLK_NAME}}.gds.gz"
set dummy_topCell_name    = "${dummy_name}_${BLOCK_NAME}"
set log_strmin_file       = "{{cur.cur_flow_log_dir}}/${cur_stage}.{{env.BLK_NAME}}.${dummy_name}_strmin.log"
set sum_strmin_file       = "{{cur.cur_flow_rpt_dir}}/${cur_stage}.{{env.BLK_NAME}}.${dummy_name}_strmin.rpt"
set scr_strmin_file       = "{{cur.flow_scripts_dir}}/{{cur.stage}}/${cur_stage}.{{env.BLK_NAME}}.${dummy_name}_strmin.run"

echo "Alchip-Info:strmin the ${dummy_name} gds file to OA!"
#================== generate dummy metal stream-in script ============
cat <<strmin_setting >! ${scr_strmin_file}
#-- database setting -------------------
runDir                             "."                 # - Run Director
y
topCell                            "${dummy_topCell_name}"     # - Top Cell(s) to Translate
strmFile                           "${dummy_gds_file}" # - Stream File Name
layerMap                           "${map_file}"       # - Layer Map File Name
loadTechFile                       "${tech_file}"      # - ASCII Technology File Name
refLibList                         "XST_CDS_LIB"        # - Rerferrence Library List File
view                               "layout"            # - View Name(s) to Translate
library                            "${dummy_topCell_name}"       # - Library Name
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

#====================== run dummy  strmin =============================
echo "strmin_${dummy_topCell_name} " >> ${run_time}
echo "  start " `date "+%F %T %a"` >> ${run_time}
strmin -templateFile ${scr_strmin_file} 

#=================== dummy merge setting  ==============================
set log_merge_file        = "{{cur.cur_flow_log_dir}}/${cur_stage}.{{env.BLK_NAME}}.${dummy_name}_merge.log"
set scr_merge_file        = "{{cur.flow_scripts_dir}}/${cur_stage}.{{env.BLK_NAME}}.${dummy_name}_merge.il"
if (-e ${scr_merge_file} ) then
rm -f ${scr_merge_file}
endif

#================== generate dummy metal merge script ===================
cat <<gds_merge >! ${scr_merge_file}
cv = dbOpenCellViewByType("${top_name}" "${top_name}" "layout" "" "a")
unless(cv return())
dpo = dbOpenCellView("${dummy_topCell_name}" "${dummy_topCell_name}" "layout")
dbCreateInst(cv dpo nil list(0.0 0.0) "R0")
dbSave(cv)
dbClose(cv)
dbClose(dpo)
exit
gds_merge

#==================== run dummy metal merge =============================
echo "create_${dummy_topCell_name} " >> ${run_time}
echo "  start " `date "+%F %T %a"` >> ${run_time}
layout -64  -nograph -log ${log_merge_file} -replay ${scr_merge_file} 
end
#************* end of use opus to transfer dummy gds to OA *****************

#********************start use opus to transfer OA to dummy_merge gds **********
echo "Alchip-Info:strmout the OA to final dummy_merge gds!"

#========================= strmout setting  ==========================================
set scr_strmout_file   = "{{cur.flow_scripts_dir}}/{{cur.stage}}/${cur_stage}.{{env.BLK_NAME}}.dummy_strmout.run"
set gds_strmout_file   = "{{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.dummy_merge.gds.gz"
set log_strmout_file   = "{{cur.cur_flow_log_dir}}/${cur_stage}.{{env.BLK_NAME}}.dummy_strmout.log"
set sum_strmout_file   = "{{cur.cur_flow_log_dir}}/${cur_stage}.{{env.BLK_NAME}}.dummy_strmout.rpt"

#===================== generate  streamout script =====================================
cat <<strmout_setting > ${scr_strmout_file}
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
echo "ignoreMissingCells                 t                   #- Ignore Missing cellViews During Translation and Continue Translation" >> \${scr_strmout_file}
{%- endif %}

#================================ run strmout ==============================================
echo "strmout_final " >> ${run_time}
echo "  start " `date "+%F %T %a"` >> ${run_time}
strmout -templateFile ${scr_strmout_file}

echo "  finish" `date "+%F %T %a"` >> ${run_time}

#********************end of use opus to transfer OA to dummy_merge gds **********

#************* end of use opus merge gds *****************
{%- endif %}


