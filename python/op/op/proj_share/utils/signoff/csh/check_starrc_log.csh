#!/bin/csh
#################################################################################################
# PROGRAM     : check_starrc_log.csh
# CREATOR     : Norton Zhang <nortonz@alchip.com>
# DATE        : Fri Mar 17 13:46:01 CST 2017
# DESCRIPTION : Extract EDA version and tech files from EDA log file
#	        Need to define the EDA run directory
# USAGE       : ./check_starrc_log.csh <starrc_log_dir> <block_name>
# UPDATER     : Felix Yuan <felix_yuan@alchip.com>  2018-03-21 
# ITEM        :  
#################################################################################################

set STARRC_LOG_CHECK_OPTION = ($*)
set STAR_SUM_E = 0
set STAR_TECH_LOG_E = 0
set STAR_TECH_SET_E = 0
set CURRENT_DIR = `pwd`

if ( $#STARRC_LOG_CHECK_OPTION != 2) then
        echo "INFO : check_starrc_log.csh <starrc_log_dir> <block_name> ";exit
endif

set BLOCK_NAME      = $STARRC_LOG_CHECK_OPTION[2]
set LOG_CHECK_RPT   = ${BLOCK_NAME}.ext.check_starrc_log.rpt

if ( !(-d $STARRC_LOG_CHECK_OPTION[1])) then
	echo "Warning:Can't find starrc log run dir, please check it !"
	printf "%s\n" "Warning: defined STARRC run dir not found, please check" > $LOG_CHECK_RPT
else
	set BLOCK_NAME = $STARRC_LOG_CHECK_OPTION[2]
	printf "%s\n" "#STARRC log check ..." > $LOG_CHECK_RPT
	printf "%s\n" "#Block name: $STARRC_LOG_CHECK_OPTION[2]" >> $LOG_CHECK_RPT
	printf "%s\n\n" "#Check dir: $STARRC_LOG_CHECK_OPTION[1]" >> $LOG_CHECK_RPT
	
	set STAR_SUM       = `find $STARRC_LOG_CHECK_OPTION[1] | grep '.star_sum$' `
	set STAR_TECH_LOG  = `find $STARRC_LOG_CHECK_OPTION[1] | grep 'tech_file.asc$' `
	set STAR_TECH_SET  = `find $STARRC_LOG_CHECK_OPTION[1] | grep 'xtract.tech$' `
	set STAR_SHORT_LOG = `find $STARRC_LOG_CHECK_OPTION[1] | grep 'shorts_all.sum$' `
	set STAR_OPEN_LOG  = `find $STARRC_LOG_CHECK_OPTION[1] | grep 'opens.sum$' `

	set BLOCK_NAME_LOG = `grep ^BLOCK: $STAR_TECH_LOG | awk '{print $2}'`

	if ($BLOCK_NAME !~ $BLOCK_NAME_LOG) then
		printf "%s\n" "Warning: Please check block name..." >> $LOG_CHECK_RPT
		printf "%s\n" "	Defined by user: $BLOCK_NAME" >> $LOG_CHECK_RPT
		printf "%s\n" "	Defined in log : $BLOCK_NAME_LOG in ${STAR_TECH_LOG}" >> $LOG_CHECK_RPT
		#echo "ERROR: Please check block name...";exit
	endif
	#echo "$STAR_SUM\n$STAR_TECH_LOG\n$STAR_TECH_SET\n"
	
	echo "Checking StarRC log files......"
	if ($STAR_SUM == "") then
		echo "Warning: no STARRC .star_sum found"
		printf "%s\n" "Warning: no STARRC .star_sum found" >> $LOG_CHECK_RPT
		set STAR_SUM_E = 1
	endif
	if ($STAR_TECH_LOG == "") then
		echo "Warning: no STARRC tech_file.asc found"
		printf "%s\n" "Warning: no STARRC tech_file.asc found" >> $LOG_CHECK_RPT
		set STAR_TECH_LOG_E = 1
	endif
	if ($STAR_TECH_SET == "") then
		echo "Warning: no STARRC xtract.tech found"
		printf "%s\n" "Warning: no STARRC xtract.tech found" >> $LOG_CHECK_RPT
		set STAR_TECH_SET_E = 1
	endif
endif

if ($STAR_SUM_E == 0) then
	set STAR_VERSION    = `grep 'Version ' ${STAR_SUM} | awk '{print $2}' | sort -u`
	printf "%s %s\n\n" "STARRC version:" "$STAR_VERSION" >> $LOG_CHECK_RPT
endif

if ($STAR_TECH_LOG_E == 0) then
	set STAR_MAP_FILES = `grep MAPPING_FILE $STAR_TECH_LOG | awk '{print $2}' | sort -u`
        printf "%s %s\n" "MAPFILE:" "$STAR_MAP_FILES" >> $LOG_CHECK_RPT
	set CORNERS_FILE = `grep CORNERS_FILE $STAR_TECH_LOG | awk '{print $2}' | sort -u`
	printf "%s %s\n" "CORNERS_FILE:" "$CORNERS_FILE" >> $LOG_CHECK_RPT
	set SELECTED_CORNERS = `grep SELECTED_CORNERS $STAR_TECH_LOG | cut -d: -f 2`
	printf "%s %s\n" "SELECTED_CORNERS:" "$SELECTED_CORNERS" >> $LOG_CHECK_RPT
endif

if ($STAR_TECH_SET_E == 0) then
	set STAR_TECH_FILES = `grep tcad_file $STAR_TECH_SET | perl -p -i -e "s#.*tcad_file##g"`
	set NUM = 0
        foreach grd ( $STAR_TECH_FILES )
		printf "%s %s\n" "NXGRD_${NUM}:" "$grd" >> $LOG_CHECK_RPT
		@ NUM++
        end
endif

if ($STAR_SHORT_LOG == "") then
	printf "\n%s" "SHORT_NETS: 0" >> $LOG_CHECK_RPT
else
	set SHORT_NETS = `cat $STAR_SHORT_LOG | awk '{print $1 $2 $3 $4 $5 $6 $7}' | sort -u | wc -l`
	printf "\n%s %s\n" "SHORT_NETS:" "$SHORT_NETS" >> $LOG_CHECK_RPT
	printf "%s %s\n" "SHORT_NETS_FILE:" "$CURRENT_DIR/${BLOCK_NAME}/shorts_all.sum" >> $LOG_CHECK_RPT
endif

if ($STAR_OPEN_LOG == "") then
        printf "\n%s" "OPEN_NETS: 0" >> $LOG_CHECK_RPT
else
	set OPEN_NETS = `cat $STAR_OPEN_LOG | grep "^OPEN" | wc -l`
        printf "\n%s %s\n" "OPEN_NETS:" "$OPEN_NETS" >> $LOG_CHECK_RPT
        printf "%s %s\n" "OPEN_NETS_FILE:" "$CURRENT_DIR/${BLOCK_NAME}/opens.sum" >> $LOG_CHECK_RPT
endif

	echo "StarRC log check report: ${LOG_CHECK_RPT}"

