"""
Author: Tsukasa Minato @ OnePiece Platform Group
Email: minato@alchip.com
Description: clean features
"""

import os
import glob
import fnmatch
from core import runner_flow
from utils import pcom
from utils import settings

LOG = pcom.gen_logger(__name__)


class CleanProc(runner_flow.FlowProc):
    """clean for blocks"""
    def __init__(self):
        super().__init__()
        self.data_types = ('data', 'log', 'rpt', 'scripts', 'sum')
        self.excludes_lst = ['*.pass', '*.sum']

    def list_clean_flow(self):
        """to list all current block available flows"""
        lf_dic = {}
        for sec_k in self.cfg_dic.get("flow", {}):
            lf_dic[sec_k] = runner_flow.exp_stages([], self.cfg_dic["flow"], sec_k)
        return lf_dic

    def get_multi_inst_lst(self, flow_dic):
        """getting multi_inst_lst by reading config file"""
        flow_name = flow_dic.get('flow', '*')
        stage_name = flow_dic.get('stage', '*')
        sub_stage_name = flow_dic.get('sub_stage', '*')
        # read config for multi-instance names and retrun them
        return(pcom.rd_cfg(
            self.dir_cfg_dic.get("flow", {}).get(flow_name, {}).get(stage_name, {}),
            sub_stage_name, "_multi_inst"))

    def get_clean_candidate(self, flow_dic, data_type):
        """getting flow names to be clean candidate"""
        flow_name = flow_dic.get('flow', '*')
        stage_name = flow_dic.get('stage', '*')
        sub_stage_name = flow_dic.get('sub_stage', '*')
        inst_name = flow_dic.get('inst', {})
        flow_ver = self.ver_dic.get(flow_name, {}).get('rtl_netlist', {})
        # search candidate files
        base_dir = os.path.join(self.ced['BLK_RUN'], flow_ver, flow_name, data_type, stage_name)
        if inst_name:
            file_pattern = os.path.join(base_dir, inst_name)
        else:
            name = os.path.splitext(sub_stage_name)[0]
            file_pattern = os.path.join(base_dir, f'{name}.*')
        files = glob.glob(file_pattern)
        return files

    def remove_path_aux(self, file, dry_run=False):
        """removing file (aux method of remove_path)"""
        # check exclude
        for exclude in self.excludes_lst:
            if fnmatch.fnmatch(file, exclude):
                return 0
        if os.path.islink(file):
            size = 0
        else:
            size = os.path.getsize(file)
        if not dry_run:
            if not settings.DEBUG:
                os.remove(file)
        return size

    def remove_path(self, path, dry_run=False):
        """removing path (file and directory support)"""
        accum_size = 0
        if os.path.islink(path):
            if not dry_run:
                LOG.info(f':: removing symlink {path}')
            self.remove_path_aux(path, dry_run)
        elif os.path.isfile(path):
            if not dry_run:
                LOG.info(f':: removing file {path}')
            accum_size += self.remove_path_aux(path, dry_run)
        elif os.path.isdir(path):
            if not dry_run:
                LOG.info(f':: removing dir {path}')
            for root, dirs, files in os.walk(path, topdown=False):
                for name in files:
                    accum_size += self.remove_path_aux(os.path.join(root, name), dry_run)
                if not dry_run and not settings.DEBUG:
                    for name in dirs:
                        try:
                            os.rmdir(os.path.join(root, name))
                        except OSError:
                            pass
            if not dry_run and not settings.DEBUG:
                try:
                    os.rmdir(path)
                except OSError:
                    pass
        return accum_size

    def clean_files(self, files_lst, dry_run=False):
        """remove files in files_lst"""
        accum_size = 0
        for file in files_lst:
            accum_size += self.remove_path(file, dry_run)
        return round(accum_size/1048576, 1)

    def proc_clean(self, clean_flow_lst):
        """to process clean"""
        if clean_flow_lst:
            LOG.info("removing specified flows of block")
            dry_run = False
            lf_dic = {}
            for clean_flow in clean_flow_lst:
                flow_tmp = clean_flow.split(':')
                if len(flow_tmp) == 1 or len(flow_tmp) == 2:
                    flow_dic = {'flow':flow_tmp[0]}
                elif len(flow_tmp) == 3:
                    flow_dic = {'flow':flow_tmp[0], 'stage':flow_tmp[2]}
                elif len(flow_tmp) == 4:
                    flow_dic = {'flow':flow_tmp[0], 'stage':flow_tmp[2], 'sub_stage':flow_tmp[3]}
                elif len(flow_tmp) == 5:
                    flow_dic = {'flow':flow_tmp[0], 'stage':flow_tmp[2], 'sub_stage':flow_tmp[3],
                                'inst':[flow_tmp[4],]}
                else:
                    LOG.error(f'invalid clean_flow name: {clean_flow}')
                    raise SystemExit()
                lf_lst = lf_dic.get(flow_tmp[0], [])
                lf_lst.append(flow_dic)
                lf_dic[flow_tmp[0]] = lf_lst
        else:
            LOG.info("current available flows of block")
            dry_run = True
            lf_dic = self.list_clean_flow()
        for _, lf_lst in lf_dic.items():
            for flow_dic in lf_lst:
                flow_name = flow_dic.get('flow', '*')
                stage_name = flow_dic.get('stage', '*')
                sub_stage_name = flow_dic.get('sub_stage', '*')
                if dry_run:
                    multi_inst_lst = self.get_multi_inst_lst(flow_dic)
                else:
                    multi_inst_lst = flow_dic.get('inst', [])
                if multi_inst_lst:
                    for inst in multi_inst_lst:
                        flow_dic['inst'] = inst
                        files_lst = []
                        for data_type in self.data_types:
                            files_lst.extend(self.get_clean_candidate(flow_dic, data_type))
                        if files_lst:
                            clean_size = self.clean_files(files_lst, dry_run)
                            LOG.info(f'- %s\t(Size: %.1f MiB)',
                                     f'{flow_name}::{stage_name}:{sub_stage_name}:{inst}',
                                     clean_size)
                        else:
                            LOG.info(f'- %s\t(No data)',
                                     f'{flow_name}::{stage_name}:{sub_stage_name}:{inst}')
                else:
                    files_lst = []
                    for data_type in self.data_types:
                        files_lst.extend(self.get_clean_candidate(flow_dic, data_type))
                    if files_lst:
                        clean_size = self.clean_files(files_lst, dry_run)
                        LOG.info(f'- %s\t(Size: %.1f MiB)',
                                 f'{flow_name}::{stage_name}:{sub_stage_name}', clean_size)
                    else:
                        LOG.info(f'- %s\t(No data)',
                                 f'{flow_name}::{stage_name}:{sub_stage_name}')


def run_clean(args):
    """to run clean sub cmd"""

    c_p = CleanProc()
    c_p.lib_flg = False
    c_p.proc_ver()

    if args.excludes_lst:
        c_p.excludes_lst.extend(args.excludes_lst)

    c_p.proc_clean(args.clean_flow)
