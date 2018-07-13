.. _openlava:

Openlava User Reference
=========================
Openlava is an open source workload job scheduling software for a cluster of computers.

Queue/Job commands
-------------------------

+-----------------------+-----------------------------------+----------------------------------------+
|Command                |Discription                        |Commment                                |
+=======================+===================================+========================================+
|bqueues <queue>        |Get queue quick information        |Very brief information, all queues will |
|                       |                                   |be reported if no queue specified.      |
+-----------------------+-----------------------------------+----------------------------------------+
|bqueues -l <queue>     |Get queue detail information       |"-l" means long                         |
+-----------------------+-----------------------------------+----------------------------------------+
|busers <user/group>    |Get user/group information         |Used to check job status for a          |
|                       |                                   |user/group                              |
+-----------------------+-----------------------------------+----------------------------------------+
|bugroup <group>        |Get users in a queue group         |All groups will be reported if no group |
|                       |                                   |specified.                              |
+-----------------------+-----------------------------------+----------------------------------------+
|report_queues <queue>  |Generate queue summary, including  |QSLOT 32/22 means total 32 cores and 22 |
|                       |hosts/slots                        |cores are being used.                   |
+-----------------------+-----------------------------------+----------------------------------------+
|bjobs -u all -q <queue>|Get all jobs in the queue          |The project lead should pay attention to|
|                       |                                   |the long running jobs.                  |
+-----------------------+-----------------------------------+----------------------------------------+
|lshostsq <queue>       |List all the host in the queue     |Static resource summary.                |
+-----------------------+-----------------------------------+----------------------------------------+
|lsloadq <queue>        |List all the host load in the queue|Dynamic resource, core, RAM, etc.       |
+-----------------------+-----------------------------------+----------------------------------------+
|otop <server>          |Get server core/memory summary     |Similar as “top”, means “openlava top”. |
+-----------------------+-----------------------------------+----------------------------------------+
|lsutq -q <queue>       |Report core/RAM/slot usage         |Default is 7 days report.               |
+-----------------------+-----------------------------------+----------------------------------------+
|bjobs -p <ID>          |Get pending reasons                |Reasons maybe user or queue limits      |
+-----------------------+-----------------------------------+----------------------------------------+
|bkill -r <ID>          |Force to kill a job in queue       |For jobs could not be killed by bkill   |
|                       |                                   |Queue admin could kill jobs in the queue|
+-----------------------+-----------------------------------+----------------------------------------+

Possible pending reasons
-------------------------

- Has the user requested unrealistic resources?

  + Use "bjobs -l" to see detail

- Has the user already run above job limit(60 slots by default)?

  + Use "busers" to check user's jobs

- More memory than any host has?

  + Use "bhosts" to check host information

- All the slots are being used in the queue?

  + Use “bqueues” or “report_queues” to check queue status

- Resource requirements may be too stringent?

- The user may have requested exclusive execution?
