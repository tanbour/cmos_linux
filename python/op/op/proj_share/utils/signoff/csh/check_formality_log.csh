#!/bin/csh
unalias cp

########################################################################
# PROGRAM:     check_formality_file.csh
# CREATOR:     Daniel Wen <danielw@alchip.com>
# DATE:        Fri Mar 17 13:46:01 CST 2017
# DESCRIPTION: Extract EDA version and tech files from EDA log file
#	       Need to define the EDA run directory
# USAGE:       ./check_formality_log.csh <block_dir> <block_name> <ECO string> 
########################################################################

set FV_DIR = ($*)
set log_dir = "starrc_log"
set STAR_SUM_E = 0
set STAR_TECH_LOG_E = 0
set STAR_TECH_SET_E = 0
#rm *.${log_dir} -rf

set current_dir = `pwd`

if ( $#FV_DIR != 3) then
        echo "INFO : check_formality_log.csh <block_dir> <block_name> <ECO_string>";exit
endif

set BLOCK_NAME    = $FV_DIR[2]
set ECO_STRING    = $FV_DIR[3]
set DATE          = `echo $ECO_STRING | perl -p -i -e "s#.*\.##"`
set FV_LOG      = `find $FV_DIR[1]/log | grep fm.${ECO_STRING}.log | grep -v log.swp | grep -v log_check.rpt`
set FV_RPT_DIR  = $FV_DIR[1]/rpt/fm.$DATE

echo 2
echo $FV_LOG
if ($FV_LOG == "") then
	echo "ERROR: no log file fm.${ECO_STRING}.log found, please check" ; exit
	#echo "ERROR: Please check block name...";exit
endif
 echo 3
set LOG_CHK_RPT   = ${FV_LOG}.signoff_check.log_check.rpt
#set OUT = ${BLOCK_NAME}.starrc_log.sum

echo 1

if ( !(-d $FV_DIR[1])) then
	echo "WARNING: defined FV run dir not found, please check"
	printf "%s\n" "WARNING: defined FV run dir not found, please check" > $LOG_CHK_RPT
else
	set BLOCK_NAME = $FV_DIR[2]
	printf "%s\n" "#FV log check ..." > $LOG_CHK_RPT
	printf "%s\n" "#Block name: $FV_DIR[2]" >> $LOG_CHK_RPT
	printf "%s\n\n" "#Check dir: $FV_DIR[1]" >> $LOG_CHK_RPT
	
	set FV_ABORTED_RPT            = `find $FV_RPT_DIR | grep '.aborted.rep$' | grep -v ${log_dir}`
	set FV_BBOX_RPT               = `find $FV_RPT_DIR | grep 'black_boxes.rep$' | grep -v ${log_dir}`
	set FV_CONSTANT_RPT           = `find $FV_RPT_DIR | grep 'constants.rep$' | grep -v ${log_dir}`
	set FV_USER_MATCH_RPT         = `find $FV_RPT_DIR | grep 'user_matches.rep$' | grep -v ${log_dir}`
	set FV_DONT_MATCH_POINT_RPT   = `find $FV_RPT_DIR | grep 'dont_match_points.rep$' | grep -v ${log_dir}`
	set FV_DONT_VEFIFY_POINT_RPT  = `find $FV_RPT_DIR | grep 'shorts_all.sum$' | grep -v ${log_dir}`
	set FV_PRINT_VAR_RPT          = `find $FV_RPT_DIR | grep 'printvar.log$' | grep -v ${log_dir}`
	set FV_UNMATCH_POINT_RPT      = `find $FV_RPT_DIR | grep 'unmatched_points.rep$' | grep -v ${log_dir}`
	set FV_UNVERIFY_POINT_RPT     = `find $FV_RPT_DIR | grep 'unverified_points.rep$' | grep -v ${log_dir}`
	set FV_FAILING_RPT            = `find $FV_RPT_DIR | grep 'failing.rep$' | grep -v ${log_dir}`

	echo "Checking Formality log files......"
	if ($FV_PRINT_VAR_RPT == "") then
		echo "WARNING: no FV printvar.log found"
		printf "%s\n" "WARNING: no FV printvar.log found" >> $LOG_CHK_RPT
		#set STAR_SUM_E = 1
	endif
	if ($FV_CONSTANT_RPT == "") then
		echo "WARNING: no FV constants.rep found"
		printf "%s\n" "WARNING: no FV constants.rep found" >> $LOG_CHK_RPT
		#set STAR_TECH_LOG_E = 1
	endif
	#if ($STAR_TECH_SET == "") then
	#	echo "WARNING: no FV xtract.tech found"
	#	printf "%s\n" "WARNING: no FV xtract.tech found" >> $LOG_CHK_RPT
	#	set STAR_TECH_SET_E = 1
	#endif
	#mkdir -p ${BLOCK_NAME}.${log_dir}

	#FV version/results check
        set FV_VERSION = `grep "      Version " $FV_LOG | perl -p -i -e "s#.* Version ##" | perl -p -i -e "s# .*##g"`
        set FV_RESULT  = `grep "^Verification " $FV_LOG | perl -p -i -e "s#Verification ##"`
	#check constant
	#check verification result
	#check important setting
	set UNDRIVEN_PIN_OPTION = `grep VERIFICATION_SET_UNDRIVEN_SIGNALS $FV_PRINT_VAR_RPT | perl -p -i -e "s#VERIFICATION_SET_UNDRIVEN_SIGNALS = ##"`
	printf "%s\n" "Version: $FV_VERSION" >> $LOG_CHK_RPT
	printf "%s\n" "Result: $FV_RESULT" >> $LOG_CHK_RPT
	printf "%s\n" "UNDRIVEN_PIN_OPTION: $UNDRIVEN_PIN_OPTION" >> $LOG_CHK_RPT
endif

	echo "Formality log check report: ${LOG_CHK_RPT}"
