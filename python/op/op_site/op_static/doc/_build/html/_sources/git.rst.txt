.. _git:

Git User Reference
=========================
Git is an open source version controlling software for users cooperation on code management.

Common Issues
-------------------------

- make sure your git version is correct.
  source /proj/onepiece4/op_env.csh

::

   [guanyu_yi@utah: /proj/OP4/SOFTWARE/WORK/guanyu_yi/ws]$ which git
   /proj/onepiece4/Tools/git_2.16.2/bin/git

- git pull origin master
  
  + fatal: Authentication failed:

    .. figure:: images/git_issue_1.png

    1. ** Please confirm that you have entered the correct Windows AD password ! **

  + error: Automatic merge failed

    .. figure:: images/git_issue_2.png

    * normal solution:

      1. Fix conflicts manually

      2. Commit the fixed file

      3. Re-pull

      * The content of the conflict is located between “<<<<<<” and “>>>>>>>”, separated by “=======”. Keep the correct parts and remove the delimiters and unwanted content.

      .. figure:: images/git_issue_3.png
      .. figure:: images/git_issue_4.png

    * optional solution: git stash

      1. Before pull, stash all change: ``git stash``
      2. Git pull origin master: ``git pull origin master``
      3. Fix conflicts manually: ``git stash pop``

    * Force overwrite modified content !!! (carefully used)

      1. ``git fetch --all``
      2. ``git reset --hard origin/master``
      3. ``git pull``
