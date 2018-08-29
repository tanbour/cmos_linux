#!/bin/csh
#===================================================================
#=================== initial setting ===============================
#===================================================================
set PT_SESSION = "sed_file_sta"
#===================================================================
#=================== OUT Timing ====================================
#===================================================================
echo "restore_session ${PT_SESSION}" >! pt.tcl
echo "source /tools_lib3/apps/redhawk/RedHawk_Linux64e5_V18.0.3p2/bin/pt2timing.tcl" >> pt.tcl
echo "set_propagated_clock [ all_clocks ]" >> pt.tcl
echo "set ADS_ALLOW_IDEAL_CLOCKS 1" >> pt.tcl
echo "set ADS_ALLOWED_PCT_OF_NON_CLOCKED_REGISTERS 50" >> pt.tcl
echo "getSTA * -noexit  -nocompact" >> pt.tcl
echo "exit" >> pt.tcl
source /apps/setenv_license.csh
#/tools_lib3/apps/synopsys/pts_vJ-2014.06/amd64/syn/bin/pt_shell -f pt.tcl | tee pt.log
#/tools_lib3/apps/synopsys/pts_vJ-2014.06-SP3/bin/pt_shell -f pt.tcl | tee pt.log
#/tools_lib3/apps/synopsys/pts_vK-2015.06-SP1/bin/pt_shell -f pt.tcl | tee pt.log
#/tools_lib3/apps/synopsys/pts_vK-2015.12-SP1/bin/pt_shell -f pt.tcl | tee pt.log
/tools_lib3/apps/synopsys/pts_vK-2015.12-SP2/bin/pt_shell -f pt.tcl | tee pt.log
#bsub -q pfn2 -P GRAPE_PFN2 -Is -n 16  -R "span[hosts=1] rusage[mem=60000]" "/tools_lib3/apps/synopsys/pts_vK-2015.12-SP2/bin/pt_shell -f pt.tcl | tee pt.log"

