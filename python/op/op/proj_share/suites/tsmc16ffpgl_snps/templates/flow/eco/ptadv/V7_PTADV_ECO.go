#!/bin/csh -v
set DIRNAME = "final_1115_run3_ECO1228TestDummy"
set ECO_dir = "Physical_ECO"
set TOP = "pcie_wrapper"
set MODULES = (\
pcie_wrapper \
)
set DMSA_MODES = (\
normal \
shift \
)
set MODULES_DEFS = (\
/proj/IPU-A_new/RELEASE/FORECO/glai/pcie_wrapper/release/201712281/pcie_wrapper_wo_AP.def.gz \
) 
set DONT_TOUCH_MODULE = ()
set DMSA_CORNERS = (\
bc_cworst_ccworst_0c_min \
ml_rcworst_ccworst_125c_min \
ml_cworst_ccworst_125c_min \
wcz_cworst_ccworst_t_0c_max \
)
set SCENARIO_SESSIONS = (\
/space/cindyw/ipu/pt/ECO1228TestDummy/normal/bc_cworst_ccworst_0c_min/PT_pcie_wrapper_normal_bc_cworst_ccworst_0c_min.w_io_session \
/space/cindyw/ipu/pt/ECO1228TestDummy/normal/ml_rcworst_ccworst_125c_min/PT_pcie_wrapper_normal_ml_rcworst_ccworst_125c_min.w_io_session \
/space/cindyw/ipu/pt/ECO1228TestDummy/normal/ml_cworst_ccworst_125c_min/PT_pcie_wrapper_normal_ml_cworst_ccworst_125c_min.w_io_session \
/space/cindyw/ipu/pt/ECO1228TestDummy/normal/wcz_cworst_ccworst_t_0c_max/PT_pcie_wrapper_normal_wcz_cworst_ccworst_t_0c_max.w_io_session \
/space/cindyw/ipu/pt/ECO1228TestDummy/shift/bc_cworst_ccworst_0c_min/PT_pcie_wrapper_shift_bc_cworst_ccworst_0c_min.w_io_session \
/space/cindyw/ipu/pt/ECO1228TestDummy/shift/ml_rcworst_ccworst_125c_min/PT_pcie_wrapper_shift_ml_rcworst_ccworst_125c_min.w_io_session \
/space/cindyw/ipu/pt/ECO1228TestDummy/shift/ml_cworst_ccworst_125c_min/PT_pcie_wrapper_shift_ml_cworst_ccworst_125c_min.w_io_session \
/space/cindyw/ipu/pt/ECO1228TestDummy/shift/wcz_cworst_ccworst_t_0c_max/PT_pcie_wrapper_shift_wcz_cworst_ccworst_t_0c_max.w_io_session \
) 

set ADD_LEFS = "/proj/IPU-A/techfile/EDATechfile/designrule/N16_ICOVL_library_kit_FF+_20150528/lef/topMxMxaMxc_M7/N16_ICOVL_v1d0a.lef /proj/IPU-A/techfile/EDATechfile/designrule/N16_DTCD_library_kit_20160111/lef/topMxyMxe_M7/N16_DTCD_v1d0a.lef"

set FIX_POWER = 				"0"
set VTH_SWAPPING = 				"0"
set DOWNSIZING =				"0"
set REMOVE_BUFFER =				"0"
set SAVE_SESSION_FIX_POWER =	"0"

set FIX_DRC =					"0"
set FIX_SLEW = 			   		"0"
set FIX_CAP =	 		   		"0"
set FIX_FANOUT =		   		"0"
set FIX_NOISE =			   		"0"
set SAVE_SESSION_FIX_DRC = 		"0"

set FIX_TIMING = 				"1"
set FIX_HOLD = 					"1"
set FIX_SETUP = 				"1"
set SAVE_SESSION_FIX_TIMING = 	"0"

set PROCESS_NUM = "8"
set MAX_CORE = "4"

set TOUCH_READY = "1"
###################################################################################################
if ( -e $DIRNAME ) then
   echo "dir name exist,please change dir name !"
   exit
endif
mkdir -p $DIRNAME
cd $DIRNAME
mkdir -p $ECO_dir
cp -r /proj/IPU-A/template/PTADV/V7_temp/* .

sed -i "s?set ADD_LEFS \[list .*\]?set ADD_LEFS [list ${ADD_LEFS}]?g" ./PROJECT_eco_setup.tcl

touch DESIGN_eco_setup.tcl
echo "set TOP ${TOP}" >> ./DESIGN_eco_setup.tcl
echo "set MODULES {${MODULES}}" >> ./DESIGN_eco_setup.tcl

set i = 1
foreach MODULE ($MODULES)
        echo "set DEF_OF(${MODULE}) {$MODULES_DEFS[$i]}" >> ./DESIGN_eco_setup.tcl
        @ i++
end

echo "set DONT_TOUCH_MODULE {${DONT_TOUCH_MODULE}}" >> ./DESIGN_eco_setup.tcl


echo "set DMSA_MODES {${DMSA_MODES}}" >> ./DESIGN_eco_setup.tcl
echo "set DMSA_CORNERS {${DMSA_CORNERS}}" >> ./DESIGN_eco_setup.tcl

set i = 1
foreach DMSA_MODE ($DMSA_MODES)
        foreach DMSA_CORNER ($DMSA_CORNERS)
                set SCENARIO = ${DMSA_MODE}_${DMSA_CORNER}
		if ($SCENARIO_SESSIONS[$i] == "") then
			echo "#set SESSION($SCENARIO) {$SCENARIO_SESSIONS[$i]}" >> ./DESIGN_eco_setup.tcl
		else
                	echo "set SESSION($SCENARIO) {$SCENARIO_SESSIONS[$i]}" >> ./DESIGN_eco_setup.tcl
		endif
		@ i++		
        end
end
             
echo "set ECO_dir ${ECO_dir}" >> ./DESIGN_eco_setup.tcl
echo "set PROCESS_NUM ${PROCESS_NUM}" >> ./DESIGN_eco_setup.tcl
echo "set MAX_CORE ${MAX_CORE}" >> ./DESIGN_eco_setup.tcl

sed -i "s?set FIX_POWER.*;?set FIX_POWER ${FIX_POWER};?g" ./ECO_flow_setup.tcl 
sed -i "s?set VTH_SWAPPING.*;?set VTH_SWAPPING ${VTH_SWAPPING};?g" ./ECO_flow_setup.tcl
sed -i "s?set DOWNSIZING.*;?set DOWNSIZING ${DOWNSIZING};?g" ./ECO_flow_setup.tcl
sed -i "s?set REMOVE_BUFFER.*;?set REMOVE_BUFFER ${REMOVE_BUFFER};?g" ./ECO_flow_setup.tcl
sed -i "s?set SAVE_SESSION_FIX_POWER.*;?set SAVE_SESSION_FIX_POWER ${SAVE_SESSION_FIX_POWER};?g" ./ECO_flow_setup.tcl

sed -i "s?set FIX_DRC.*;?set FIX_DRC ${FIX_DRC};?g" ./ECO_flow_setup.tcl 
sed -i "s?set FIX_SLEW.*;?set FIX_SLEW ${FIX_SLEW};?g" ./ECO_flow_setup.tcl
sed -i "s?set FIX_CAP.*;?set FIX_CAP ${FIX_CAP};?g" ./ECO_flow_setup.tcl
sed -i "s?set FIX_FANOUT.*;?set FIX_FANOUT ${FIX_FANOUT};?g" ./ECO_flow_setup.tcl
sed -i "s?set FIX_NOISE.*;?set FIX_NOISE ${FIX_NOISE};?g" ./ECO_flow_setup.tcl
sed -i "s?set SAVE_SESSION_FIX_DRC.*;?set SAVE_SESSION_FIX_DRC ${SAVE_SESSION_FIX_DRC};?g" ./ECO_flow_setup.tcl


sed -i "s?set FIX_TIMING.*;?set FIX_TIMING ${FIX_TIMING};?g" ./ECO_flow_setup.tcl 
sed -i "s?set FIX_HOLD.*;?set FIX_HOLD ${FIX_HOLD};?g" ./ECO_flow_setup.tcl 
sed -i "s?set FIX_SETUP.*;?set FIX_SETUP ${FIX_SETUP};?g" ./ECO_flow_setup.tcl 
sed -i "s?set SAVE_SESSION_FIX_TIMING.*;?set SAVE_SESSION_FIX_TIMING ${SAVE_SESSION_FIX_TIMING};?g" ./ECO_flow_setup.tcl


if ($TOUCH_READY) then
cat > ready_file << EOF
set wait_file = ( $SCENARIO_SESSIONS )
foreach WAIT ( \${wait_file} ) 
	while ( ! ( -e \${WAIT} ) ) 
		echo "Waiting \${WAIT} get ready." 
		sleep 100 
	end
	echo "\${WAIT} get ready." 
end 
EOF
sed -i "s#PT\w\+\.w_io_session\S*#session_done#g" ready_file
mv run_PTADV.go bk_run_PTADV.go
cat ready_file bk_run_PTADV.go > run_PTADV.go
rm ready_file bk_run_PTADV.go
endif



