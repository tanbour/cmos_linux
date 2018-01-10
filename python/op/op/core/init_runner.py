"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: projects initialization and related features
"""

import os
import getpass
import git
import requests
from utils import pcom
from utils import env_boot
from utils import settings

LOG = pcom.gen_logger(__name__)

def check_out_dir(repo_base, dir_name, u_n, p_w):
    """to check out particular dir"""
    repo_dir = f"{repo_base}{os.sep}{dir_name}"
    cur_dir = f"{os.getcwd()}{os.sep}{dir_name}"
    LOG.info("checking out dir %s", repo_dir)
    repo = svn.remote.RemoteClient(
        repo_dir, username=u_n, password=p_w) if u_n and p_w else svn.remote.RemoteClient(repo_dir)
    if dir_name.endswith(pcom.flag_file):
        repo.export(cur_dir)
    else:
        repo.checkout(cur_dir)

def np_check_out(sub_dir_lst, repo_base, u_n, p_w):
    """to process normal project checking out dir actions"""
    if sub_dir_lst:
        check_out_dir(repo_base, "share", u_n, p_w)
        for s_d in sub_dir_lst:
            check_out_dir(repo_base, s_d, u_n, p_w)
        if not repo_base.endswith("tools"):
            open(f"{os.getcwd()}{os.sep}{pcom.flag_file}", "w").close()
    else:
        check_out_dir(repo_base, "", u_n, p_w)

def sp_check_out(proj_name, sub_dir_lst, repo_base, u_n, p_w):
    """to process svn project checking out dir actions"""
    dir_query_url = (
        f"{pcom.BE_URL}/user_info/svn/query_dir_lst/?user={u_n}&proj={proj_name}")
    avail_dir_lst = requests.get(dir_query_url).json() if pcom.BACKEND else []
    if sub_dir_lst:
        check_out_dir(repo_base, "share", u_n, p_w)
        for s_d in sub_dir_lst:
            for avail_dir in avail_dir_lst:
                if s_d not in avail_dir:
                    continue
                check_out_dir(repo_base, avail_dir, u_n, p_w)
        if not repo_base.endswith("tools"):
            open(f"{os.getcwd()}{os.sep}{pcom.flag_file}", "w").close()
    else:
        for avail_dir in avail_dir_lst:
            check_out_dir(repo_base, avail_dir, u_n, p_w)

class InitProc(object):
    """initial processor for projects and blocks"""
    def __init__(self, args):
        self.args = args
        self.ced, self.cfg_dic = env_boot.boot_env()
        self.git_proj_dic = git_proj_dic = settings.git_proj_dic
        self.proj_lst = sorted(list(git_proj_dic))
    def list_proj(self):
        str_lst = [f"{os.linesep}all available projects"]
        str_lst.append("*"*30)
        str_lst.extend(self.proj_lst)
        str_lst.append("*"*30)
        LOG.info(os.linesep.join(str_lst))
        LOG.info("list all available projects done")
    def init_proj(self):
        if self.args.init_proj_name not in self.git_proj_dic:
            LOG.error(f"proj name must be one of {self.proj_lst}")
            os.sys.exit()
        repo_base = git_proj_dic[args.proj_name]
        try:
            repo = git.Git()
            repo.info()
            u_n = ""
            p_w = ""
        except svn.exception.SvnException:
            u_n = getpass.getuser()
            p_w = getpass.getpass("svn password: ")
        if args.proj_name in normal_proj_dic:
            np_check_out(args.sub_dir, repo_base, u_n, p_w)
        else:
            sp_check_out(args.proj_name, args.sub_dir, repo_base, u_n, p_w)
    def proc_init(self):
        if self.args.init_proj_list:
            self.list_proj()
        elif self.args.init_proj_name:
            self.init_proj()
        else:
            LOG.critical("op init sub cmd missing main arguments")
            os.sys.exit()

def run_init(args):
    """to run init sub cmd"""
    InitProc(args).proc_init()
