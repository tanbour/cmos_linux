set wait_file = ( /space/cindyw/ipu/pt/final_1115_run3_ECO12110/normal/ml_rcworst_ccworst_125c_min/session_done /space/cindyw/ipu/pt/final_1115_run3_ECO12110/normal/tt_cworst_ccworst_t_85c_max/session_done /space/cindyw/ipu/pt/final_1115_run3_ECO12110/normal/wc_cworst_ccworst_t_125c_max/session_done /space/cindyw/ipu/pt/final_1115_run3_ECO12110/normal/wcz_cworst_ccworst_t_0c_max/session_done /space/cindyw/ipu/pt/final_1115_run3_ECO12110/shift/ml_rcworst_ccworst_125c_min/session_done   /space/cindyw/ipu/pt/final_1115_run3_ECO12110/shift/wcz_cworst_ccworst_t_0c_max/session_done )
foreach WAIT ( ${wait_file} ) 
	while ( ! ( -e ${WAIT} ) ) 
		echo "Waiting ${WAIT} get ready." 
		sleep 100 
	end
	echo "${WAIT} get ready." 
end 
#source /proj/Mars2/WORK/donid/SETUP/synopsys.lic.doni
#/tools_lib3/apps/synopsys/pts_vK-2015.12-SP1/bin/pt_shell -multi_scenario -f PT_PA_ECO_run.tcl | tee pt.log
  source /proj/IPU-A/template/PTADV/synopsys.lic
#/tools_lib3/apps/synopsys/pts_vK-2015.12-SP2/bin/pt_shell -multi_scenario -f PT_PA_ECO_run.tcl | tee pt.log
#/apps/synopsys/pts_vM-2016.12-SP3-2/amd64/syn/bin/pt_shell -multi_scenario -f PT_PA_ECO_run.tcl | tee pt.log
/apps/synopsys/pts_vM-2017.06-SP3/amd64/syn/bin/pt_shell -multi_scenario -f PT_PA_ECO_run.tcl | tee pt.log
