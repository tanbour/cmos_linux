#!/bin/csh
##################################################################################
# PROGRAM:     check_pt_log.csh
# CREATOR:     Zachary Shi <zacharys@alchip.com>
# DESCRIPTION: Check Error/Warning/Information message in pt sta log
#	       ST-01-04/ST-01-07/ST-02-11
# USAGE:       check_pt_log.csh <pt.log> <block_name>
# INFORMATION: Initial version from Alchip Design Platform Group
# DATE:        Thu Jul  6 18:11:21 CST 2017
###################################################################################

if ( $# != "2" ) then
  echo "Usage: check_pt_log.csh <pt_run_dir> <block_name>"
  exit
endif

set pt_run_dir = $1
set block_name = $2
set check_sum  = $block_name.check_pt_log.sum
touch $check_sum

if ( !(-d $1) ) then
  set pt_run_dir = `pwd`
endif

#################################################
## checking for message type and number
echo "#################################################"      >> $check_sum
echo "#PT log checking for message type/number ..."           >> $check_sum
echo "#Block name: $block_name"         >> $check_sum
echo "#Log file dir: $pt_run_dir\n"     >> $check_sum

set log_count = `find $pt_run_dir -name "*pt_sta.*.log" | wc -l`
set log_files = `find $pt_run_dir -name "*pt_sta.*.log" | xargs`
#set log_count = `find $pt_run_dir -name "log" | wc -l`
#set log_files = `find $pt_run_dir -name "log" | xargs`

if ( $log_count == 0 ) then
  echo "Warning: Can't found PT log, please make sure the log name like: pt_sta.*.log" >> $check_sum
  exit
else
  echo "Info: Total found $log_count PT log file, below is the checking summary" >> $check_sum
  echo "-----------------------------------------------------------------------" >> $check_sum
endif

set n = 0
foreach log_file ( $log_files )

  @ n++
  echo "\n# $n" >> $check_sum
  echo "Info: Checking the log file: $log_file\n" >> $check_sum

  #set message_count = `cat $log_file | egrep "^Warning: |^Error: |^Information: " | wc -l`
  set message_count = `cat $log_file | egrep " \([A-Z]+-[0-9]+\)" | wc -l`
  if ( $message_count != 0 ) then
    echo " Un-suppressed Message Summary:"    >> $check_sum
    echo " Message_type   Count_of_Message"   >> $check_sum
    echo " -------------  -----------------"  >> $check_sum
    #cat $log_file | grep -P "^Warning: " | awk '{print $NF}' | awk -F '(' '{print $2}' | awk -F ')' '{print $1}' | sort | uniq -c | sort | awk '{print "\t",$1,"\t\t",$2}' >> $check_sum
    cat $log_file | egrep " \([A-Z]+-[0-9]+\)" | awk '{print $NF}' | awk -F '(' '{print $2}' | awk -F ')' '{print $1}' | sort | uniq -c | sort | awk '{print "  ",$2,"\t\t",$1}' >> $check_sum

    set uite_480_count = `cat $log_file | egrep "^Warning: .*(UITE-480)" | wc -l`
    if ( $uite_480_count != 0 ) then
      echo "Info: There found $uite_480_count warning about UITE-480, please check them." >> $check_sum
    endif
  else
    echo "Info: No any message type found in this pt log." >> $check_sum
  endif

  set message_count = `cat $log_file | egrep "^[A-Z]+-[0-9]+[[:space:]]+(Error|Warning|Information)[[:space:]]+[0-9]+[[:space:]]+[0-9]+" | wc -l`
  if ( $message_count != 0 ) then
    echo "\n Suppressed Message Summary:"      >> $check_sum
    echo " Message_type   Count_of_Message"    >> $check_sum
    echo " -------------  -----------------"   >> $check_sum
    cat $log_file | egrep "^[A-Z]+-[0-9]+[[:space:]]+(Error|Warning|Information)[[:space:]]+[0-9]+[[:space:]]+[0-9]+" | awk '{print "  ",$1,"\t\t",$3}' >> $check_sum
  endif

end

#################################################
## checking for Loading db file
echo "\n#################################################" >> $check_sum
echo "#PT log checking for loading db file ..."            >> $check_sum
echo "#Block name: $block_name"         >> $check_sum
echo "#Log file dir: $pt_run_dir\n"     >> $check_sum
echo "Info: Total found $log_count PT log file, below is the checking summary" >> $check_sum
echo "-----------------------------------------------------------------------" >> $check_sum

set n = 0
foreach log_file ( $log_files )

  @ n++
  echo "\n# $n" >> $check_sum
  echo "Info: Checking the log file: $log_file\n" >> $check_sum

  set db_count = `cat $log_file | grep "Loading db file" | wc -l`
  if ( $db_count != 0 ) then
    echo "Info: There total $db_count library were loaded" >> $check_sum
    cat $log_file | grep "Loading db file" | awk '{print $4}' | awk -F '\047' '{print $2}' >> $check_sum
  else
    echo "Error: Can't found the load library in the PT log file" >> $check_sum
  endif

end


