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

class ProjRepo():
    """base calss of projects from code repo"""
    def __init__(self):
        self.all_proj_dic = {}
        self.proj_normal_lst = []
        self.proj_lab_lst = []
        self.repo_dic = {}
    def gen_all_proj(self):
        """to get all projects from repo server"""
        self.all_proj_dic = all_proj_dic = {
            c_c.get("name", ""): c_c.get("url", "").replace("://", "://${USER}@") for c_c
            in requests.get(settings.PROJ_URL, auth=(settings.Q_U, settings.Q_U)).json()}
        self.proj_normal_lst = sorted([c_c for c_c in all_proj_dic if not c_c.startswith("lab_")])
        self.proj_lab_lst = sorted([c_c for c_c in all_proj_dic if c_c.startswith("lab_")])
    def list_proj(self):
        """to list all projects registered in op"""
        LOG.info(":: all available projects")
        pcom.pp_list(self.proj_normal_lst)
    def list_lab(self):
        """to list all projects registered in op"""
        LOG.info(":: all available lab projects")
        pcom.pp_list(self.proj_lab_lst)
    def git_proj(self, block_lst):
        """to check out project by using git"""
        try:
            self.repo_dic["repo"] = repo = git.Repo.init(self.repo_dic["repo_dir"])
        except PermissionError as err:
            LOG.error(err)
            raise SystemExit()
        repo.git.execute(["git", "config", "core.sparseCheckout", "true"])
        rmt = repo.remote() if repo.remotes else repo.create_remote(
            "origin", os.path.expandvars(self.repo_dic["repo_url"]))
        LOG.info(
            "git pulling project %s from repository to %s",
            self.repo_dic["init_proj_name"], self.repo_dic["repo_dir"])
        pcom.cfm()
        rmt.fetch()
        sc_file = os.sep.join([self.repo_dic["repo_dir"], ".git", "info", "sparse-checkout"])
        with open(sc_file, "w") as scf:
            if block_lst:
                scf.write(
                    f"{os.sep}share{os.sep}{os.linesep}{os.sep}"
                    f"{f'{os.sep}{os.linesep}{os.sep}'.join(block_lst)}{os.sep}")
            else:
                scf.write("*")
        try:
            # rmt.pull("master")
            repo.active_branch.checkout()
        except git.GitCommandError as err:
            if any([c_c in str(err) for c_c in settings.REPO_AUTH_ERR_STR_LST]):
                LOG.error("password (AD pwd) incorrect")
                raise SystemExit()
            elif any([c_c in str(err) for c_c in settings.REPO_BRANCH_ERR_STR_LST]):
                pass
            else:
                LOG.error(err)
                raise SystemExit()
        LOG.info("please run op cmds under the project dir %s", self.repo_dic["repo_dir"])
    def svn_proj(self):
        """to check out project by using svn"""
        pass
    def repo_proj(self, init_proj_name, init_block_name_lst=None):
        """to operate project from code repo"""
        self.repo_dic["init_proj_name"] = init_proj_name
        LOG.info(":: initializing project %s ...", init_proj_name)
        try:
            self.repo_dic["repo_url"] = self.all_proj_dic[init_proj_name]
        except KeyError:
            LOG.error("project name must be one of %s", self.proj_normal_lst)
            LOG.error("lab project name must be one of %s", self.proj_lab_lst)
            raise SystemExit()
        self.repo_dic["repo_dir"] = os.getcwd()
        if settings.PROJ_REPO == "git":
            self.git_proj(init_block_name_lst)
        elif settings.PROJ_REPO == "svn":
            self.svn_proj()
