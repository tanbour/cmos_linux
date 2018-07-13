#!/usr/bin/env python3

# User Guide----------------------------------------------------------------------
# cd <block_name>/run/<version>  ex: orange/run/v0225
# op_import.py <flow::stage:sub_stage> data_file

# Note1: 
# data file format: <sub_stage>.<block_name>.<ext>
# EX: 06_route_opt.orange.ndm

# Note2:
# create a new flow name in flow.cfg ( remember to init "op flow -init <new_flow_name>")
# This flow can have no dependency to other flow.
# Then run this new flow by "op flow -run <new_flow> -begin <new_flow>::<stage>:<sub_stage> 
# Example:
#           [test1_flow]
#
#                   pre_flow  =  
#                   pre_stage = 
#                   stages    = pr:06_route_opt.tcl, ext:ext.csh

##==================================================================##
##                  op_import.py                                    ##
##==================================================================##

import os
import sys
import time

cur_path  = os.getcwd()
sub_stage = sys.argv[1]
data_file = os.path.abspath(sys.argv[2])

# check data file exist before import data----------------------------------------
if os.path.exists(data_file):
    print ("INFO: Current location is \"%s\"" % (cur_path))
    print ("INFO: Put file \"%s\" as sub_stage \"%s\"" % (data_file, sub_stage))
else:
    print ("INFO: file \"%s\" cannot been find, please make sure source file exist" % (data_file))
    quit()

flow_name     = sub_stage.split('::')[0]
stage_name    = sub_stage.split('::')[1].split(':')[0]
substage_name = sub_stage.split('::')[1].split(':')[1]

if os.path.exists(os.path.join(cur_path, flow_name)):
    print("INFO: %s/%s already exist" % (cur_path, flow_name))
else:
    os.mkdir(os.path.join(cur_path, flow_name))

if os.path.exists(os.path.join(cur_path, flow_name, 'data')):
    print("INFO: %s/%s/data already exist" % (cur_path, flow_name))
else: 
    os.mkdir(os.path.join(cur_path, flow_name, 'data'))

if os.path.exists(os.path.join(cur_path, flow_name, 'data', stage_name)):
    print("INFO: %s/%s/data/%s already exist" % (cur_path, flow_name, stage_name))
else:
    os.mkdir(os.path.join(cur_path, flow_name, 'data', stage_name))

if os.path.exists(os.path.join(cur_path, flow_name, 'sum')):
    print("INFO: %s/%s/sum already exist" % (cur_path, flow_name))
else:
    os.mkdir(os.path.join(cur_path, flow_name, 'sum'))

if os.path.exists(os.path.join(cur_path, flow_name, 'sum', stage_name)):
    print("INFO: %s/%s/sum/%s already exist" % (cur_path, flow_name, stage_name))
else:
    os.mkdir(os.path.join(cur_path, flow_name, 'sum', stage_name))

if os.path.exists(os.path.join(cur_path, flow_name, 'scripts')):
    print("INFO: %s/%s/scripts already exist" % (cur_path, flow_name))
else:
    os.mkdir(os.path.join(cur_path, flow_name, 'scripts'))

if os.path.exists(os.path.join(cur_path, flow_name, 'scripts', stage_name)):
    print("INFO: %s/%s/scripts/%s already exist" % (cur_path, flow_name, stage_name))
else:
    os.mkdir(os.path.join(cur_path, flow_name, 'scripts', stage_name))


# link file to dst location---------------------------------------------------------
file_dir,file_name = os.path.split(data_file)
dst_file = os.path.join(cur_path, flow_name, 'data', stage_name, file_name)
if os.path.exists(dst_file):
    print ("%s already exist, will remove it" % (dst_file))
    os.remove(dst_file)

os.symlink(data_file, dst_file)

# touch run file --------------------------------------------------------------------
scripts_path = os.path.join(cur_path, flow_name, 'scripts', stage_name)
s_scripts_file = substage_name
scripts_file = os.path.join(scripts_path, s_scripts_file)

if os.path.exists(scripts_file):
    print ("%s already exist, will keep it, if you do not want it, please delete it manually" % (scripts_file))
#    os.remove(scripts_file)
else:
    open(scripts_file, 'w').close()

# wait 2s to avoid conflit------------------------------------------------------------
time.sleep( 5 )

# touch pass file---------------------------------------------------------------------
pass_path = os.path.join(cur_path, flow_name, 'sum', stage_name)
s_pass_file = (substage_name, 'op', 'run', 'pass')
n_pass_file = '.'.join(s_pass_file)
pass_file = os.path.join(pass_path, n_pass_file)

if os.path.exists(pass_file):
    print ("%s already exist, will remove it" % (pass_file))
    os.remove(pass_file)

open(pass_file, 'w').close()

print("INFO: op_import complete!")

