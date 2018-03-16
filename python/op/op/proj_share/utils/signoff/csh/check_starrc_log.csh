#!/bin/csh
unalias cp

########################################################################
# PROGRAM:     check_starrc_log.csh
# CREATOR:     Norton Zhang <nortonz@alchip.com>
# DATE:        Fri Mar 17 13:46:01 CST 2017
# DESCRIPTION: Extract EDA version and tech files from EDA log file
#	       Need to define the EDA run directory
# USAGE:       ./check_starrc_log.csh <starrc_run_dir> <block_name> <ECO string> 
########################################################################

set STARRC_DIR = ($*)
set log_dir = "starrc_log"
set STAR_SUM_E = 0
set STAR_TECH_LOG_E = 0
set STAR_TECH_SET_E = 0
#rm *.${log_dir} -rf

set current_dir = `pwd`

if ( $#STARRC_DIR != 3) then
        echo "INFO : check_starrc_log.csh <starrc_run_dir> <block_name> <ECO_string>";exit
endif

set BLOCK_NAME    = $STARRC_DIR[2]
set ECO_STRING    = $STARRC_DIR[3]
set STAR_LOG      = `find $STARRC_DIR[1] | grep star.${ECO_STRING}.log | grep -v log_check`
if ($STAR_LOG == "") then
	echo "ERROR: no log file star.${ECO_STRING}.log found, please check" ; exit
	#echo "ERROR: Please check block name...";exit
endif
set LOG_CHK_RPT   = ${STAR_LOG}.signoff_check.log_check.rpt
#set OUT = ${BLOCK_NAME}.starrc_log.sum
if ( !(-d $STARRC_DIR[1])) then
	echo "WARNING: defined STARRC run dir not found, please check"
	printf "%s\n" "WARNING: defined STARRC run dir not found, please check" > $LOG_CHK_RPT
else
	set BLOCK_NAME = $STARRC_DIR[2]
	printf "%s\n" "#STARRC log check ..." > $LOG_CHK_RPT
	printf "%s\n" "#Block name: $STARRC_DIR[2]" >> $LOG_CHK_RPT
	printf "%s\n\n" "#Check dir: $STARRC_DIR[1]" >> $LOG_CHK_RPT
	
	set STAR_SUM      = `find $STARRC_DIR[1] | grep '.star_sum$' | grep -v ${log_dir}`
	set STAR_TECH_LOG = `find $STARRC_DIR[1] | grep 'tech_file.asc$' | grep -v ${log_dir}`
	set STAR_TECH_SET = `find $STARRC_DIR[1] | grep 'xtract.tech$' | grep -v ${log_dir}`
	set STAR_SHORT_LOG = `find $STARRC_DIR[1] | grep 'shorts_all.sum$' | grep -v ${log_dir}`
	set STAR_OPEN_LOG = `find $STARRC_DIR[1] | grep 'opens.sum$' | grep -v ${log_dir}`

	set BLOCK_NAME_LOG = `grep ^BLOCK: $STAR_TECH_LOG | awk '{print $2}'`

	if ($BLOCK_NAME !~ $BLOCK_NAME_LOG) then
		printf "%s\n" "WARNING: Please check block name..." >> $LOG_CHK_RPT
		printf "%s\n" "	Defined by user: $BLOCK_NAME" >> $LOG_CHK_RPT
		printf "%s\n" "	Defined in log : $BLOCK_NAME_LOG in ${STAR_TECH_LOG}" >> $LOG_CHK_RPT
		#echo "ERROR: Please check block name...";exit
	endif
	#echo "$STAR_SUM\n$STAR_TECH_LOG\n$STAR_TECH_SET\n"
	
	echo "Checking StarRC log files......"
	if ($STAR_SUM == "") then
		echo "WARNING: no STARRC .star_sum found"
		printf "%s\n" "WARNING: no STARRC .star_sum found" >> $LOG_CHK_RPT
		set STAR_SUM_E = 1
	endif
	if ($STAR_TECH_LOG == "") then
		echo "WARNING: no STARRC tech_file.asc found"
		printf "%s\n" "WARNING: no STARRC tech_file.asc found" >> $LOG_CHK_RPT
		set STAR_TECH_LOG_E = 1
	endif
	if ($STAR_TECH_SET == "") then
		echo "WARNING: no STARRC xtract.tech found"
		printf "%s\n" "WARNING: no STARRC xtract.tech found" >> $LOG_CHK_RPT
		set STAR_TECH_SET_E = 1
	endif
	mkdir -p ${BLOCK_NAME}.${log_dir}
endif

if ($STAR_SUM_E == 0) then
	cp -rf $STAR_SUM ${BLOCK_NAME}.${log_dir}
	set STAR_VERSION    = `grep 'Version ' ${STAR_SUM} | awk '{print $2}' | sort -u`
	printf "%s %s\n\n" "STARRC version:" "$STAR_VERSION" >> $LOG_CHK_RPT
endif

if ($STAR_TECH_LOG_E == 0) then
        cp -rf $STAR_TECH_LOG ${BLOCK_NAME}.${log_dir}
	set STAR_MAP_FILES = `grep MAPPING_FILE $STAR_TECH_LOG | awk '{print $2}' | sort -u`
        printf "%s %s\n" "MAPFILE:" "$STAR_MAP_FILES" >> $LOG_CHK_RPT
	set CORNERS_FILE = `grep CORNERS_FILE $STAR_TECH_LOG | awk '{print $2}' | sort -u`
	printf "%s %s\n" "CORNERS_FILE:" "$CORNERS_FILE" >> $LOG_CHK_RPT
	set SELECTED_CORNERS = `grep SELECTED_CORNERS $STAR_TECH_LOG | cut -d: -f 2`
	printf "%s %s\n" "SELECTED_CORNERS:" "$SELECTED_CORNERS" >> $LOG_CHK_RPT
endif

if ($STAR_TECH_SET_E == 0) then
        cp -rf $STAR_TECH_SET ${BLOCK_NAME}.${log_dir}
	set STAR_TECH_FILES = `grep tcad_file $STAR_TECH_SET | perl -p -i -e "s#.*tcad_file##g"`
	set NUM = 0
        foreach grd ( $STAR_TECH_FILES )
		printf "%s %s\n" "NXGRD_${NUM}:" "$grd" >> $LOG_CHK_RPT
		@ NUM++
        end
endif

if ($STAR_SHORT_LOG == "") then
	printf "\n%s" "SHORT_NETS: 0" >> $LOG_CHK_RPT
else
	cp -rf $STAR_SHORT_LOG ${BLOCK_NAME}.${log_dir}
	set SHORT_NETS = `cat $STAR_SHORT_LOG | awk '{print $1 $2 $3 $4 $5 $6 $7}' | sort -u | wc -l`
	printf "\n%s %s\n" "SHORT_NETS:" "$SHORT_NETS" >> $LOG_CHK_RPT
	printf "%s %s\n" "SHORT_NETS_FILE:" "$current_dir/${BLOCK_NAME}.${log_dir}/shorts_all.sum" >> $LOG_CHK_RPT
endif

if ($STAR_OPEN_LOG == "") then
        printf "\n%s" "OPEN_NETS: 0" >> $LOG_CHK_RPT
else
        cp -rf $STAR_OPEN_LOG ${BLOCK_NAME}.${log_dir}
	set OPEN_NETS = `cat $STAR_OPEN_LOG | grep "^OPEN" | wc -l`
        printf "\n%s %s\n" "OPEN_NETS:" "$OPEN_NETS" >> $LOG_CHK_RPT
        printf "%s %s\n" "OPEN_NETS_FILE:" "$current_dir/${BLOCK_NAME}.${log_dir}/opens.sum" >> $LOG_CHK_RPT
endif

	echo "StarRC log check report: ${LOG_CHK_RPT}"
