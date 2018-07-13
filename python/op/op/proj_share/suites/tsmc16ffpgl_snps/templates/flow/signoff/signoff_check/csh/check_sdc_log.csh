#!/bin/csh
##################################################################################
# PROGRAM:     check_sdc_log.csh
# CREATOR:     Zachary Shi <zacharys@alchip.com>
# DESCRIPTION: Check UITE-137/UITE-136 in read sdc log
#	       CK-01-13
# USAGE:       check_sdc_log.csh <reading_sdc.log> <block_name>
# INFORMATION: Initial version from Alchip Design Platform Group
# UPDATED:     Updated for UITE-136 warning
# DATE:        Mon Sep 11 22:11:19 CST 2017
###################################################################################

if ( $# != "2" ) then
  echo "Usage: check_sdc_log.csh <pt_run_dir> <block_name>"
  exit
endif
 
set pt_run_dir = $1
set block_name = $2
set check_sum  = $block_name.check_sdc_log.sum
touch $check_sum

if ( !(-d $1) ) then
  set pt_run_dir `pwd`
endif

echo "#Reading sdc log checking ..."	>> $check_sum
echo "#Block name: $block_name"		>> $check_sum
echo "#Log file dir: $pt_run_dir\n"	>> $check_sum

#set log_files = `find $pt_run_dir -name "*read_sdc*.log" | xargs echo`
#set log_files = `find $pt_run_dir -name "*read_sdc*.log" -exec printf "%s " {} \;`
set log_count = `find $pt_run_dir -name "read_sdc*.log" | wc -l`
set log_files = `find $pt_run_dir -name "read_sdc*.log" | xargs`
if ( $log_count == 0 ) then
  echo "Warning: Can't found reading sdc log, please make sure the log name like: read_sdc*.log" >> $check_sum
  exit
else
  echo "Info: Total found $log_count reading sdc log files, below are the checking summary."  >> $check_sum
  echo "------------------------------------------------------------------------------------" >> $check_sum
endif

set n = 0
foreach log_file ( $log_files )

  @ n++
  echo "\n# $n" >> $check_sum
  echo "Info: Checking the log file: $log_file\n" >> $check_sum

  ## for UITE-137
  if ( `cat $log_file | grep "UITE-137" | wc -l` ) then
    echo "Info: Found the warning about UITE-137" >> $check_sum
    cat $log_file | grep "UITE-137" >> $check_sum
  else
    echo "Info: No UITE-137 warning in this reading sdc log file." >> $check_sum
  endif

  ## for UITE-136
  if ( `cat $log_file | grep "UITE-136" | wc -l` ) then
    echo "Info: Found the warning about UITE-136" >> $check_sum
    cat $log_file | grep "UITE-136" >> $check_sum
  else
    echo "Info: No UITE-136 warning in this reading sdc log file." >> $check_sum
  endif

  ## for others
  if ( `cat $log_file | grep "Warning" | grep -v "UITE-137" | grep -v "UITE-136" | wc -l`) then
    echo "\nInfo: Some other warning found in this reading sdc log file, please check the log file." >> $check_sum
    #cat $log_file | grep "Warning" | grep -v "UITE-137" | grep -v "UITE-136" >> $check_sum
  endif

end

