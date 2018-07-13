
#!/bin/csh -f

set pre_stage = "{{pre.sub_stage}}"
set cur_stage = "{{cur.sub_stage}}"

set pre_stage = `echo $pre_stage | cut -d . -f 1`
set cur_stage = `echo $cur_stage | cut -d . -f 1`

if ( -e {{pre.flow_data_dir}}/{{pre.stage}}/${pre_stage}.{{env.BLK_NAME}}.merge.gds.gz ) then
ln -sf {{pre.flow_data_dir}}/{{pre.stage}}/${pre_stage}.{{env.BLK_NAME}}.merge.gds.gz {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.merge.gds.gz
endif

if ( -e {{pre.flow_data_dir}}/{{pre.stage}}/${pre_stage}.{{env.BLK_NAME}}.dummy_merge.gds.gz ) then
ln -sf {{pre.flow_data_dir}}/{{pre.stage}}/${pre_stage}.{{env.BLK_NAME}}.dummy_merge.gds.gz {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.dummy_merge.gds.gz
endif

ln -sf {{pre.flow_data_dir}}/{{pre.stage}}/${pre_stage}.{{env.BLK_NAME}}.lvs.v.gz {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.lvs.v.gz

#===================================================================
#===================  delete existing tmp cdl file =================
#===================================================================
if ( -e {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.lib_to_cdl_by_v2lvs.cdl) then
rm -f {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.lib_to_cdl_by_v2lvs.cdl
endif
touch {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.lib_to_cdl_by_v2lvs.cdl

#===================================================================
#===================   set input files    ==========================
#===================================================================
set vnet_file      =  "{{pre.flow_data_dir}}/{{pre.stage}}/${pre_stage}.{{env.BLK_NAME}}.lvs.v.gz"
set cdl_std_files  = "{{liblist.CDL_STD}}"
set cdl_mem_files  = "{{liblist.CDL_MEM}}"
set cdl_ip_files   = "{{liblist.CDL_IP}}"
set cdl_io_files   = "{{liblist.CDL_IO}}"
set cdl_all_files  = "cdl_std_files cdl_mem_files cdl_ip_files cdl_io_files"
set v2lvs_cdl_tmp  = "{{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.lib_to_cdl_by_v2lvs.cdl"
set run_time       = "{{cur.cur_flow_rpt_dir}}/${cur_stage}.run_time"
set plugin_file    = "{{cur.config_plugins_dir}}/calibre_scripts/clbre_v2lvs_plugin.rule"

#===================================================================
#=================== create std/mem/IP/IO cdl files  ===============
#===================================================================
foreach cdl_files ( $cdl_all_files )
foreach cdl_file (`eval echo '$'$cdl_files`)
cat >> $v2lvs_cdl_tmp << create_cdl
.INCLUDE $cdl_file
create_cdl
end
end
sed -i -e '/^$/d' -e '/^#.*$/d' $plugin_file
if ( -s $plugin_file ) then
foreach cdl_file_from_plugin ( `cat $plugin_file` )
echo ".INCLUDE $cdl_file_from_plugin" >> $v2lvs_cdl_tmp 
end
endif

#===================================================================
#=================== generate netlist to spice =====================
#===================================================================
echo "clbre_v2lvs" >! ${run_time}
echo "start " `date "+%F %T %a"` >> ${run_time}

v2lvs -64  -v ${vnet_file}  -s ${v2lvs_cdl_tmp} -o {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.cdl

echo "finish" `date "+%F %T %a"` >> $run_time
grep "Running" ./v2lvs.log >> {{cur.cur_flow_log_dir}}/${cur_stage}.{{env.BLK_NAME}}.log

echo "{{env.FIN_STR}}"

