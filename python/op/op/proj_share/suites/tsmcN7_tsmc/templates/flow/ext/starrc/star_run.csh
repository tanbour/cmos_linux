#!/bin/csh -f
#################################
##link database to dst database##
#################################

set pre_stage = "{{pre.sub_stage}}"
set cur_stage = "{{cur.sub_stage}}"

set pre_stage = `echo $pre_stage | cut -d . -f 1`
set cur_stage = `echo $cur_stage | cut -d . -f 1`

##mkdir tool output dirctory
set pre_flow_data_dir = "{{pre.flow_data_dir}}/{{pre.stage}}"

# source liblsit by strategy
{%- if local.lib_cell_height == "240" %}
source {{env.PROJ_SHARE_CMN}}/process_strategy/liblist/liblist_6T.csh
{%- elif local.lib_cell_height == "300" %}
source {{env.PROJ_SHARE_CMN}}/process_strategy/liblist/liblist_7d5T.csh
{%- endif %}

##link previous stage data
ln -sf $pre_flow_data_dir/$pre_stage.{{env.BLK_NAME}}.pt.v.gz {{cur.cur_flow_data_dir}}/$cur_stage.{{env.BLK_NAME}}.pt.v.gz
ln -sf $pre_flow_data_dir/$pre_stage.{{env.BLK_NAME}}.def.gz {{cur.cur_flow_data_dir}}/$cur_stage.{{env.BLK_NAME}}.def.gz

echo "delete exsting smc files and starrc command file"
rm -f {{cur.flow_scripts_dir}}/{{cur.stage}}/*.smc
rm -f {{cur.flow_scripts_dir}}/{{cur.stage}}/*.cmd
 
#################################
## STAR flow                   ##
#################################
set star_flow_type              = "{{local.star_flow_type}}"
set ndm_block_name              = "{{local.ndm_block_name}}"
set BLK_NAME                    = "{{env.BLK_NAME}}"
set STAR_MAPPING_FILE           = "${STAR_MAPPING_FILE}"
set star_cpu_number             = "{{local.star_cpu_number}}"
{%- if local.conds is string %} 
set CONDS                       = "{{local.conds}}" 
{%- elif local.conds is sequence %}
set CONDS                       = "{{local.conds|join(' ') }}" 
{%- endif %}
set simultaneous_multi_corner   = "{{local.simultaneous_multi_corner}}"
{%- if local.selected_corners is string %}
set selected_corners            = "{{local.selected_corners}}"
{%- elif local.selected_corners is sequence %} 
set selected_corners            = "{{local.selected_corners|join(' ')}}"
{%- endif %}
set metal_fill_polygon_handling = "{{local.metal_fill_polygon_handling}}"
set GDS_LAYER_MAP_FILE          = "${STAR_METAL_FILL_MAPPING_FILE}"
set COUPLING_ABS_THRESHOLD      = "{{local.coupling_abs_threshold}}"
set COUPLING_REL_THRESHOLD      = "{{local.coupling_rel_threshold}}"

set NDM_TECH                    = `echo $NDM_TECH`
set NDM_STD                     = `echo $NDM_STD`
if ( $?NDM_MEM ) then
set NDM_MEM                     = `echo $NDM_MEM`
endif 
if ( $?NDM_IP ) then
set NDM_IP                     = `echo $NDM_IP`
endif 
if ( $?NDM_IO ) then
set NDM_IO                     = `echo $NDM_IO`
endif

{%- if local.star_flow_type == "ndm" %} 
{%- if local.ndm_block_name ==  "" %}
set BLK_NAME           =  {{env.BLK_NAME}}/$pre_stage 
{%- else %}
set BLK_NAME           = $ndm_block_name
{%- endif %}
{%- elif local.star_flow_type == "deflef" %} 
set BLK_NAME                    =	 $BLK_NAME
{%- elif star_flow_type == "milkyway" %} 
set BLK_NAME                    =	 $BLK_NAME
{%- endif %}

set DEF                          = "$pre_flow_data_dir/${pre_stage}.{{env.BLK_NAME}}.def.gz"
set MILKYWAY_DATABASE            =	"$pre_flow_data_dir/${pre_stage}.{{env.BLK_NAME}}.mw" 
set NDM_DATABASE                 = "$pre_flow_data_dir/${pre_stage}.{{env.BLK_NAME}}.nlib"

{%- if local.star_flow_type == "ndm" %}
# define ndm search path
if ( $?NDM_MEM ) then
    set NDM_SEARCH_PATH              = "$NDM_TECH $NDM_STD $NDM_MEM"
    else if ( $?NDM_IP ) then
        set NDM_SEARCH_PATH              = "$NDM_TECH $NDM_STD $NDM_IP"
    else if ( $?NDM_IP && $?NDM_MEM) then
        set NDM_SEARCH_PATH              = "$NDM_TECH $NDM_STD $NDM_MEM $NDM_IP"
    else
        set NDM_SEARCH_PATH              = "$NDM_TECH $NDM_STD"
endif
{%- endif %}

{%- if local.star_flow_type == "deflef" %}
# define LEF FILE path
if ( $?LEF_MEM ) then
    set LEF_FILE              = "$LEF_TECH $LEF_STD $LEF_MEM"
    else if ( $?LEF_IP ) then
        set LEF_FILE              = "$LEF_TECH $LEF_STD $LEF_IP"
    else if ( $?LEF_IP && $?LEF_MEM ) then
        set LEF_FILE              = "$LEF_TECH $LEF_STD $LEF_MEM $LEF_IP"
    else
        set LEF_FILE              = "$LEF_TECH $LEF_STD"
endif
{%- endif %}

if ( -e `find $pre_flow_data_dir/* -wholename DVIA_${pre_stage}.${BLK_NAME}.gds.gz` ) then
set METAL_FILL_GDS_FILE          = `find {{pre.flow_data_dir}}/* -name DVIA_${pre_stage}.${BLK_NAME}.gds.gz` 
else
set METAL_FILL_GDS_FILE          = ""
endif

######################
# if CONDS or SELECTED_CORNERS are emptpy in config file, Warning... 
######################

{%- if local.conds == "" %} 
echo "Alchip-Warning: No CONDS is set"
{%- endif %}

{%- if local.selected_corners == "" %} 
echo "Alchip-Warning: No SELECTED_CORNERS are selected"
{%- endif %}

foreach COND ( $CONDS )
	 if (${COND} == "cworst") then
		set GRD =  "${CWORST_NXTGRD_FILE}"
	    else if (${COND} == "cbest") then
		    set GRD =  "${CBEST_NXTGRD_FILE}"
	    else if (${COND} == "rcworst") then
		    set GRD =  "${RCWORST_NXTGRD_FILE}"
	    else if (${COND} == "rcbest") then
		    set GRD =  "${RCBEST_NXTGRD_FILE}"
	    else if (${COND} == "typical") then
		    set GRD =  "${TYPICAL_NXTGRD_FILE}}
	    else if (${COND} == "typical_CCbest") then
		    set GRD =  "${TYPICAL_CCBEST_NXTGRD_FILE}"
	    else if (${COND} == "typical_CCworst") then
		    set GRD =  "${TYPICAL_CCWORST_NXTGRD_FILE}"
        else if (${COND} == "cworst_CCworst") then
		    set GRD =  "${CWORST_CCWORST_NXTGRD_FILE}"
	    else if (${COND} == "cworst_CCworst_T") then
		    set GRD =  "${CWORST_CCWORST_T_NXTGRD_FILE}"
	    else if (${COND} == "cbest_CCbest") then
		    set GRD =  "${CBEST_CCBEST_NXTGRD_FILE}"
        else if (${COND} == "cbest_CCbest_T") then
		    set GRD =  "${CBEST_CCBEST_T_NXTGRD_FILE}" 
        else if (${COND} == "rcworst_CCworst") then
		    set GRD =  "${RCWORST_CCWORST_NXTGRD_FILE}"
	    else if (${COND} == "rcworst_CCworst_T") then
		    set GRD =  "${RCWORST_CCWORST_T_NXTGRD_FILE}" 
	    else if (${COND} == "rcbest_CCbest") then
		    set GRD =  "${RCBEST_CCBEST_NXTGRD_FILE}" 
	    else if (${COND} == "rcbest_CCbest_T") then
		    set GRD =  "${RCBEST_CCBEST_T_NXTGRD_FILE}" 
        else if (${COND} == "cbest_T") then
		    set GRD =  "${CBEST_T_NXTGRD_FILE}" 
        else if (${COND} == "cworst_T") then
		    set GRD =  "${CWORST_T_NXTGRD_FILE}" 
        else if (${COND} == "rcbest_T") then
	    	set GRD =  "${RCBEST_T_NXTGRD_FILE}" 
        else if (${COND} == "rcworst_T") then
	    	set GRD =  "${RCWORST_T_NXTGRD_FILE}"  
    endif

############generate smc file for each condition########
echo "generating smc file for $COND"

if ( ${COND} == "typical" ) then
   set tempratures = " 25c 85c"
else
   set tempratures = "125c m40c 0c"

endif

foreach tempr ( $tempratures )
 
 if ( $tempr == m40c ) then
 set atempr = "-40"
 else if ( $tempr == 125c ) then
 set atempr = 125
 else if ( $tempr == 0c ) then
 set atempr = 0
 else if ( $tempr == 25c ) then
 set atempr = 25
 else if ( $tempr == 85c ) then
 set atempr = 85
 endif

cat <<FP > {{cur.flow_scripts_dir}}/{{cur.stage}}/{{env.BLK_NAME}}.${COND}_${tempr}.smc

CORNER_NAME: ${COND}_$tempr
TCAD_GRD_FILE: $GRD
OPERATING_TEMPERATURE: $atempr

FP

end
end

cat {{cur.flow_scripts_dir}}/{{cur.stage}}/{{env.BLK_NAME}}.*.smc > {{cur.flow_scripts_dir}}/{{cur.stage}}/{{env.BLK_NAME}}.smc
rm -f {{cur.flow_scripts_dir}}/{{cur.stage}}/{{env.BLK_NAME}}*_*.smc

############generate cmd file for each condition########

echo "********** Starting ${CONDS} ..."
set SESSION	   = ${cur_stage}.{{env.BLK_NAME}}
set SPEF	   = {{cur.cur_flow_data_dir}}/${SESSION}.spef
echo "generating ${SESSION}.cmd file for ${CONDS}"
########################################
#              flow                    #
########################################
cat << FP >! {{cur.flow_scripts_dir}}/{{cur.stage}}/${SESSION}.cmd
{% if local.star_flow_type == "deflef" %}
{% include 'starrc/star_deflef.cmd' %}
{% elif local.star_flow_type == "ndm" %}
{% include 'starrc/star_ndm.cmd' %}
{% elif local.star_flow_type == "milkyway" %}
{% include 'starrc/star_milkyway.cmd' %}
{% endif %}
FP
	
	############Print all the variables########
	echo "****************************************************"
	echo "Design Name                : ${BLK_NAME}"
    echo STAR_MAPPING_FILE           : ${STAR_MAPPING_FILE}
    echo star_cpu_number             : {{local.star_cpu_number}}
    echo conds                       : ${CONDS}
    echo simultaneous_multi_corner   : {{local.simultaneous_multi_corner}}
    echo selected_corners            : ${selected_corners}
    echo metal_fill_polygon_handling : {{local.metal_fill_polygon_handling}}
    echo GDS_LAYER_MAP_FILE          : ${STAR_METAL_FILL_MAPPING_FILE}
    echo COUPLING_ABS_THRESHOLD      : {{local.coupling_abs_threshold}}
    echo COUPLING_REL_THRESHOLD      : {{local.coupling_rel_threshold}}
	echo "****************************************************"
	############################################
    # Run STARRC                               #	
    ############################################ 

set star_mem_requirement = `expr {{local.star_mem_requirement}} / 10000`
echo $star_mem_requirement
touch {{cur.cur_flow_rpt_dir}}/run_timing.rpt
echo "\n\n# $cur_stage : Start Time: `date` \t Host: `hostname` (contain waitting assign server times)" >> {{cur.cur_flow_rpt_dir}}/run_timing.rpt
cat << RUN_start >! {{cur.flow_scripts_dir}}/{{cur.stage}}/${SESSION}.runt_start.csh
echo "\t\t\t## start time   (1): $cur_stage   Time: \`date\` \t Host: \`hostname\`" >> {{cur.cur_flow_rpt_dir}}/run_timing.rpt
RUN_start
cat << RUN_end >! {{cur.flow_scripts_dir}}/{{cur.stage}}/${SESSION}.runt_end.csh
echo "\t\t\t## end time     (0): $cur_stage   Time: \`date\` \t Host: \`hostname\`" >> {{cur.cur_flow_rpt_dir}}/run_timing.rpt
RUN_end

cat << RUN_all  >! {{cur.flow_scripts_dir}}/{{cur.stage}}/${SESSION}.cmd.run_all.csh
/bin/csh -v {{cur.flow_scripts_dir}}/{{cur.stage}}/${SESSION}.runt_start.csh
StarXtract {{cur.flow_scripts_dir}}/{{cur.stage}}/${SESSION}.cmd
/bin/csh -v {{cur.flow_scripts_dir}}/{{cur.stage}}/${SESSION}.runt_end.csh
RUN_all
absub -r "q:{{local.openlava_batch_queue}} os:6 M:$star_mem_requirement star:true n:$star_cpu_number" -c "/bin/csh -v {{cur.flow_scripts_dir}}/{{cur.stage}}/${SESSION}.cmd.run_all.csh"
echo "\t\t# End time: $cur_stage   Time: `date` \t Host: `hostname`\n" >> {{cur.cur_flow_rpt_dir}}/run_timing.rpt

    ############################################
    # change out put spef file naming          #	
    ############################################ 

    foreach selected_corner ($selected_corners)
    set i = 1
    set tmp =  `echo $selected_corner | awk '{print $i}'`
    if (-e {{cur.cur_flow_data_dir}}/${SESSION}.spef) then
    mv -f {{cur.cur_flow_data_dir}}/${SESSION}.spef {{cur.cur_flow_data_dir}}/${SESSION}.spef.$tmp
    endif

    if ( -e {{cur.cur_flow_data_dir}}/${SESSION}.spef.$tmp ) then
    gzip {{cur.cur_flow_data_dir}}/${SESSION}.spef.$tmp
    mv -f {{cur.cur_flow_data_dir}}/${SESSION}.spef.$tmp.gz {{cur.cur_flow_data_dir}}/{{env.BLK_NAME}}.$tmp.spef.gz
    endif
    end

############################################
# move report                              #	
############################################ 

if ( $star_flow_type == "deflef" || $star_flow_type == "mw") then
mv -f {{env.BLK_NAME}}.star_sum {{cur.cur_flow_rpt_dir}}/${cur_stage}.star_sum
endif

if ( $star_flow_type == "ndm") then

set block_name = `echo $ndm_block_name | cut -d / -f 1`
set label_name = `echo $ndm_block_name | cut -d / -f 2`

mv -f ${block_name}.star_sum {{cur.cur_flow_rpt_dir}}/${cur_stage}.star_sum
endif

mv -f ./star/xtract.tech {{cur.cur_flow_rpt_dir}}/${cur_stage}.xtract.tech
mv -f ./star/tech_file.asc {{cur.cur_flow_rpt_dir}}/${cur_stage}.tech_file.asc

if (-e ./star/shorts_all.sum) then
mv -f ./star/shorts_all.sum {{cur.cur_flow_rpt_dir}}/${cur_stage}.shorts_all.sum
endif
if (-e ./star/opens.sum) then
mv -f ./star/opens.sum {{cur.cur_flow_rpt_dir}}/${cur_stage}.opens.sum
endif

#./scr/signoff_check/csh/check_starrc_log.csh $RUN_DIR $BLOCK_NAME $OP4_dst_eco

rm -rf ./star




