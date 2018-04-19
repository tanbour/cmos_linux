
#!/usr/bin/csh  -f
source $APACHEROOT/setup.csh

set pre_stage = "{{pre.sub_stage}}"
set cur_stage = "{{cur.sub_stage}}"

set pre_stage = `echo $pre_stage | cut -d . -f 1`
set cur_stage = `echo $cur_stage | cut -d . -f 1`

if ( -e {{pre.flow_data_dir}}/{{pre.stage}}/${pre_stage}.{{env.BLK_NAME}}.def.gz ) then
ln -sf {{pre.flow_data_dir}}/{{pre.stage}}/${pre_stage}.{{env.BLK_NAME}}.def.gz {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.def.gz
endif

if ( -e {{pre.flow_data_dir}}/{{pre.stage}}/${pre_stage}.{{env.BLK_NAME}}.timing ) then
ln -sf {{pre.flow_data_dir}}/{{pre.stage}}/${pre_stage}.{{env.BLK_NAME}}.timing {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.timing
endif

ln -sf {{pre.flow_data_dir}}/{pre.stage}/${pre_stage}.{{env.BLK_NAME}}.{{local.rc_corner}}.spef.gz {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.{{local.rc_corner}}.spef.gz

#==========================================================================
#=================== delete exist directory ===============================
#==========================================================================
set ircx_layer_mapping  = "{{local.ircx_layer_mapping}}"
set ircx_file           = "{{local.redhawk_ircx_file}}"
set via_res             = "{{local.via_res}}"
set tech_name           = `basename ${ircx_file} | sed 's/.ircx//g'`
set tech_file           =  {{cur.cur_flow_data_dir}}/${tech_name}.tech

#===========================================================================
#=================== generate Redhawk techfile =============================
#===========================================================================
#--------------------- run ircx2tech to achieve the tech file ------------------
$APACHEROOT/bin/ircx2tech  -i  $ircx_file -m  $ircx_layer_mapping -v $via_res -o ${tech_file}
mv -f ./ircx2tech.log {{cur.cur_flow_log_dir}}/${cur_stage}.log

