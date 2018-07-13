#!/bin/csh
##################################################################################
# PROGRAM:     check_annotated_parasitics_rep.csh
# CREATOR:     Zachary Shi <zacharys@alchip.com>
# DESCRIPTION: Check RC annotated information in log file 
#	       ST-02-16
# USAGE:       check_annotated_parasitics_rep.csh <annotate_parasitics.log> <block_name>
# INFORMATION: Initial version from Alchip Design Platform Group
# DATE:        Thu Jul  6 18:11:21 CST 2017
###################################################################################

if ( $# != "2" ) then
  echo "Usage: check_annotated_parasitics_rep.csh <pt_run_dir> <block_name>"
  exit
endif

set pt_run_dir = $1
set block_name = $2
set check_sum  = $block_name.check_annotated_parasitics_rep.sum
touch $check_sum

if ( !(-d $1) ) then
  set pt_run_dir `pwd`
endif

#################################################
## checking for annotated information
echo "#################################################" >> $check_sum
echo "#Annotated parasitics log checking ..."            >> $check_sum
echo "#Block name: $block_name"                          >> $check_sum
echo "#Log file dir: $pt_run_dir\n"                      >> $check_sum

set log_count = `find $pt_run_dir -name "*annotated_parasitics.internal_nets.pin_to_pin.nets.rep" | wc -l`
set log_files = `find $pt_run_dir -name "*annotated_parasitics.internal_nets.pin_to_pin.nets.rep" | xargs`

if ( $log_count == 0 ) then
  echo "Warning: Can't found annotated parasitics log, please make sure the log name like: annotated_parasitics.internal_nets.pin_to_pin.nets.rep" >> $check_sum
  exit
else
  echo "Info: Total found $log_count annotated parasitics log file, below is the checking summary" >> $check_sum
  echo "-----------------------------------------------------------------------------------------" >> $check_sum
endif

set n = 0
foreach log_file ( $log_files )

  @ n++
  echo "\n# $n" >> $check_sum
  echo "Info: Checking the log file: $log_file\n" >> $check_sum

  if ( `cat $log_file | grep "Pin to pin nets" | awk '{print $17}'` ) then
    echo "Error: Found some internal pin to pin nets did not annotated RC information." >> $check_sum
  else
    if ( `cat $log_file | grep "incomplete RC" | wc -l` ) then
      echo "Warning: All the nets had annotated the RC, but some nets annotated incomplete." >> $check_sum
    else
      echo "Info: All the nets had annotated the RC information." >> $check_sum
    endif
  endif

end
