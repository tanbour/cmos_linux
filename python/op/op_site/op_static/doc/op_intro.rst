.. _op_intro:

OP Platform
========================================

What is it
----------------------------------------
OP is short for OnePiece.

It's a platform to provide a simple, automatical and unified environment to improve ASIC engineer working efficiency.

Currently it has the following short time target:

1. Unified design environment, flow, working directory
2. Job automations and server management
3. Integrated signoff utilities, linked with PC’s sheet
4. Powerful database and web site for report/status tracking and data mining

Why use it
----------------------------------------
First of all, non-unified environment will cause several problems such as duplicated development, difficult project migrations and integration issues. To avoid these problems and make our engineer focus on the ASIC works, a unified environment is necessary.

Secondly, the process-oriented architecture of software integrated with project without platform is harmful for the following reason. The coupling part with projects will be changed with the modification of projects, which is not good for software development and project migrations. The missing of encapsulation will cause hard software development and maintenance. The modification of projects sometimes cause the instability of software.

Thirdly, the missing back-end database will cause the precious history data lost. The database of platform will collect all the data, then extract and display the reports and status by using a cross-platform web site. Users will check the status, read the reports and query the history of all projects and all users. Furthermore with the increasing scale of collected data, the potential data mining, machine learning and AI capabilities of platform are worth to take into consideration.

Overall, the OP platform will follow KISS principle ("keep it simple, stupid") as the general guideline, and expects to be more flexible, re-usable and scalable.

Components
----------------------------------------
The platform has the following components:

- configurable files

  + config, templates, plugins
  + This part is in project trunk and is the only interface of projects and platform
  + Details in :ref:`config`

- runner(op)

  + OP software, which provides cmds for user to run ASIC jobs
  + Details in :ref:`runner`

- web

  + OP back-end, which provides database and web services for user to check, query and analyze data/reports.
  + Details in :ref:`web`
