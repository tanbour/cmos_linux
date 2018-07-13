#!/bin/csh -f

set HOSTS_UNIQ = `echo $LSB_HOSTS|sed 's/ /\n/g'|uniq -c|awk '{print $2}'`

#--------------------- set input files -----------------------------

%REPL_OP4
if ( $OP4_src == opus ) then
set input_file     = "$BLOCK_NAME.$OP4_src.$OP4_src_branch.$OP4_src_eco.merge"
set output_file    = "$BLOCK_NAME.$OP4_dst.$OP4_dst_branch.$OP4_dst_eco"
set run_dir        = "$BLOCK_NAME.$OP4_dst.$OP4_dst_eco"
set plugin_file    = "../../.$FLOW_BRANCH_DIR/plugin/clbre_drc_plugin.rule"
else if ( $OP4_src == opus_dummy ) then
set input_file     = "$BLOCK_NAME.$OP4_src.$OP4_src_branch.$OP4_src_eco.dummy_merge"
set output_file    = "$BLOCK_NAME.$OP4_dst.$OP4_dst_branch.$OP4_dst_eco.dummy_merge"
set run_dir        = "$BLOCK_NAME.$OP4_dst.$OP4_dst_eco.dummy_merge"
set plugin_file    = "../../.$FLOW_BRANCH_DIR/plugin/clbre_drc_plugin_dummy_merge.rule"
endif
set drc_run      = "../../.$FLOW_BRANCH_DIR/\${output_file}.rule"
REPL_OP4%
#--------------------- create remote.conf file ---------------------
foreach HOST ($HOSTS_UNIQ)
  set HOST_NUM = `echo $LSB_HOSTS|sed 's/ /\n/g'|grep $HOST|uniq -c|awk '{print $1}'`
  echo "REMOTE HOST  $HOST $HOST_NUM  RSH /usr/bin/ssh" >>! remote.$LSB_JOBID.conf
  end
echo "LAUNCH AUTOMATIC" >> remote.$LSB_JOBID.conf

#============ run clbre drc check ============

%REPL_OP4
set calibre_drc_user_run_cmd = "$CALIBRE_DRC_USER_RUN_CMD"
REPL_OP4%
if ( "$calibre_drc_user_run_cmd" != "" ) then
#-- if "$calibre_drc_user_run_cmd" is not empty run user defined command-
echo "$calibre_drc_user_run_cmd ${drc_run} "
eval "$calibre_drc_user_run_cmd ${drc_run} "
else 
#-- user command is not fill, will run initialized command -------------
calibre -drc -hier -turbo -hyper -64 -remotefile remote.$LSB_JOBID.conf  ${drc_run}  
endif

