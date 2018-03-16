{{local.var1}} + {{local.var2}} + {{local.var3}} + {{global.lib.std}} + {{env.BLK_CFG}}
{{local.var4}}
{%- for i in local.var4 %}
this is {{i}}
{%- endfor %}
{{liblist.o}}

This is place

****************************************
 Report : check_design 
 Options: { pre_clock_tree_stage }
 Design : huc_core_sys
 Version: M-2016.12-SP2
 Date   : Mon Jul 24 13:26:36 2017
****************************************

Running mega-check 'pre_clock_tree_stage': 
    Running atomic-check 'design_mismatch'
    Running atomic-check 'scan_chain'
    Running atomic-check 'mv_design'
    Running atomic-check 'legality'
    Running atomic-check 'design_extraction'
    Running atomic-check 'timing'
    Running atomic-check 'clock_trees'
    Running atomic-check 'hier_pre_clock_tree'

  *** EMS Message summary ***
  ----------------------------------------------------------------------------------------------------
  Rule         Type   Count      Message
  ----------------------------------------------------------------------------------------------------
  CTS-013      Warn   1606       Cell %inst in the clock network have a dont_touch constraint as ...
  CTS-015      Warn   6          %delay constraint is defined in the %type %object.
  CTS-902      Warn   1          No AON (always-on) buffers or inverters available for CTS.
  CTS-903      Warn   1641       Cell %cell instantiated in the clock network with lib cell %libc...
  CTS-904      Warn   67         Clock reference cell %libcell(cell %cell) have no LEQ cell speci...
  DFT-011      Info   1          The design has no scan chain defined in the scandef.
  DMM-104      Info   127        Mismatch type %mmtype is detected on object type %objtype at obj...
  TCK-001      Warn   278212     The reported endpoint '%endpoint' is unconstrained. Reason: '%re...
  TCK-002      Warn   34773      The register clock pin '%pin' has no fanin clocks. Mode:'%mode'.
  TCK-012      Warn   492        The input port '%port' has no clock_relative delay specified. Mo...
  ----------------------------------------------------------------------------------------------------
  Total 316926 EMS messages : 0 errors, 316798 warnings, 128 info.
  ----------------------------------------------------------------------------------------------------

  *** Non-EMS message summary ***
  ----------------------------------------------------------------------------------------------------
  Rule         Type   Count      Message
  ----------------------------------------------------------------------------------------------------
  CTS-101      Info   1          %s will work on the following scenarios.
  CTS-107      Info   1          %s will work on all clocks in active scenarios, including %d mas...
  PDC-003      Warn   2          Routing direction of metal layer %s is neither "horizontal" nor ...
  ----------------------------------------------------------------------------------------------------
  Total 4 non-EMS messages : 0 errors, 2 warnings, 2 info.
  ----------------------------------------------------------------------------------------------------

Information: EMS database is saved to file './rpt/icc2.0724/huc_core_sys.icc2_place.default.0724.check_design.pre_clock_tree_stage.ems'.
Information: Non-EMS messages are saved into file 'check_design2017Jul24132636.log'.
1
