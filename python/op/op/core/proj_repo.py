"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: base class for processing projects from code repo
"""

import os
import git
import requests
from utils import pcom
from utils import settings

LOG = pcom.gen_logger(__name__)

class ProjRepo(object):
    """base calss of projects from code repo"""
    def __init__(self):
        self.all_proj_dic = all_proj_dic = {
            c_c.get("name", ""): c_c.get("url", "").replace("://", "://${USER}@") for c_c
            in requests.get(settings.PROJ_URL, auth=(settings.Q_U, settings.Q_U)).json()}
        self.proj_normal_lst = sorted([c_c for c_c in all_proj_dic if not c_c.startswith("lab_")])
        self.proj_lab_lst = sorted([c_c for c_c in all_proj_dic if c_c.startswith("lab_")])
        self.repo_dic = {}
    def list_proj(self):
        """to list all projects registered in op"""
        LOG.info(f":: all available projects")
        pcom.pp_list(self.proj_normal_lst)
    def list_lab(self):
        """to list all projects registered in op"""
        LOG.info(f":: all available lab projects")
        pcom.pp_list(self.proj_lab_lst)
    def git_proj(self):
        """to check out project by using git"""
        try:
            self.repo_dic["repo"] = repo = git.Repo.init(self.repo_dic["repo_dir"])
        except PermissionError as err:
            LOG.error(err)
            raise SystemExit()
        rmt = repo.remote() if repo.remotes else repo.create_remote(
            "origin", os.path.expandvars(self.repo_dic["repo_url"]))
        LOG.info(
            f":: git pulling project {self.repo_dic['init_proj_name']} "
            f"from repository to {self.repo_dic['repo_dir']} ..."
        )
        pcom.cfm()
        try:
            rmt.pull("master")
        except git.exc.GitCommandError as err:
            if settings.REPO_AUTH_ERR_STR in str(err):
                LOG.error(str(err))
                raise SystemExit()
            elif settings.REPO_BRANCH_ERR_STR in str(err):
                pass
        LOG.info(f" please run op cmds under the project dir {self.repo_dic['repo_dir']}")
    def svn_proj(self):
        """to check out project by using svn"""
        pass
    def repo_proj(self, init_proj_name):
        """to operate project from code repo"""
        self.repo_dic["init_proj_name"] = init_proj_name
        try:
            self.repo_dic["repo_url"] = self.all_proj_dic[init_proj_name]
        except KeyError:
            LOG.error(f"project name must be one of {self.proj_normal_lst}")
            LOG.error(f"lab project name must be one of {self.proj_lab_lst}")
            raise SystemExit()
        self.repo_dic["repo_dir"] = os.getcwd()
        if settings.PROJ_REPO == "git":
            self.git_proj()
        elif settings.PROJ_REPO == "svn":
            self.svn_proj()
