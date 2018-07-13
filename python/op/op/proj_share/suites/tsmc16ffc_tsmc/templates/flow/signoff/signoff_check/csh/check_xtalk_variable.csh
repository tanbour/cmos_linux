#!/bin/csh
##################################################################################
# PROGRAM:     check_xtalk_variable.csh
# CREATOR:     Zachary Shi <zacharys@alchip.com>
# DESCRIPTION: Check xtalk variables setting in printvar.log
#	       GE-06-01/GE-06-06
# USAGE:       check_xtalk_variable.csh <printvar.log> <block_name>
# INFORMATION: Initial version from Alchip Design Platform Group
# DATE:        Thu Jul  6 18:11:21 CST 2017
###################################################################################

if ( $# != "2" ) then
  echo "Usage: check_xtalk_variable.csh <pt_run_dir> <block_name>"
  exit
endif

set pt_run_dir = $1
set block_name = $2
set check_sum  = $block_name.check_xtalk_variable.sum
touch $check_sum

if ( !(-d $1) ) then
  set pt_run_dir = `pwd`
endif

#################################################
## checking for xtalk variables
echo "#################################################"      >> $check_sum
echo "#Xtalk variable checking ..."     >> $check_sum
echo "#Block name: $block_name"         >> $check_sum
echo "#Log file dir: $pt_run_dir\n"     >> $check_sum

set log_count = `find $pt_run_dir -name "printvar.log" | wc -l`
set log_files = `find $pt_run_dir -name "printvar.log" | xargs`

if ( $log_count == 0 ) then
  echo "Warning: Can't found printvar.log , please make sure the log name: printvar.log" >> $check_sum
  exit
else
  echo "Info: Total found $log_count log file, below is the checking summary"    >> $check_sum
  echo "-----------------------------------------------------------------------" >> $check_sum
endif

set n = 0
foreach log_file ( $log_files )

  @ n++
  echo "\n# $n" >> $check_sum
  echo "Info: Checking the log file: $log_file\n" >> $check_sum
  set xtalk_var_count = `cat $log_file | egrep "si_|xtalk_delay" | wc -l`
  if ( $xtalk_var_count != 0 ) then
    cat $log_file | egrep "si_|xtalk_delay" >> $check_sum
  else
    echo "Warning: Can't not found any variable about the xtalk, please check the log file." >> $check_sum
  endif
 
end

