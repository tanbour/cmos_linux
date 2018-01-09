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

LOG = pcom.gen_logger(__name__)

def check_out_dir(repo_base, dir_name, u_n, p_w):
    """to check out particular dir"""
    repo_dir = f"{repo_base}{os.sep}{dir_name}"
    cur_dir = f"{os.getcwd()}{os.sep}{dir_name}"
    LOG.info("checking out dir %s", repo_dir)
    repo = svn.remote.RemoteClient(
        repo_dir, username=u_n, password=p_w) if u_n and p_w else svn.remote.RemoteClient(repo_dir)
    if dir_name.endswith(pcom.FLAG_FILE):
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
            open(f"{os.getcwd()}{os.sep}{pcom.FLAG_FILE}", "w").close()
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
            open(f"{os.getcwd()}{os.sep}{pcom.FLAG_FILE}", "w").close()
    else:
        for avail_dir in avail_dir_lst:
            check_out_dir(repo_base, avail_dir, u_n, p_w)

def run_init(args):
    """to run init sub cmd"""
    git_proj_dic = {
        "ff": "git@xsfuture.com:/srv/ff_git.git",
        "hosts": "https://github.com/googlehosts/hosts.git"
    }
    all_proj_dic = {}
    all_proj_dic.update(git_proj_dic)
    proj_lst = sorted(list(all_proj_dic))
    if args.init_proj_list:
        str_lst = [f"{os.linesep}all available projects"]
        str_lst.append("*"*30)
        str_lst.extend(proj_lst)
        str_lst.append("*"*30)
        LOG.info(os.linesep.join(str_lst))
        return
    elif args.init_proj_name:
        if args.init_proj_name not in all_proj_dic:
            LOG.error(f"proj name must be one of {proj_lst}")
            os.sys.exit()
        repo_base = all_proj_dic[args.proj_name]
        try:
            repo = svn.remote.RemoteClient(repo_base)
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
    else:
        raise Exception("missing main arguments")
