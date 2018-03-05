#! /proj/onepiece4/Tools/python_3.6.3/bin/python3



import os,re

scenarios = (
"func.tt0p4v.tt85.cworst_ccworst_t_85c.setup",
"func.tt0p4v.tt85.rcworst_ccworst_t_85c.setup",
"func.tt0p4v.wcz.cworst_ccworst_0c.hold",
"func.tt0p4v.wcz.rcworst_ccworst_0c.hold",
"func.tt0p4v.wc.cworst_ccworst_125c.hold",
"func.tt0p4v.wc.rcworst_ccworst_125c.hold",
"func.tt0p4v.ltz.cworst_ccworst_0c.hold",
"func.tt0p4v.ltz.rcworst_ccworst_0c.hold",
"func.tt0p4v.ml.cworst_ccworst_125c.hold",
"func.tt0p4v.ml.rcworst_ccworst_125c.hold",
"func.tt0p4v.ltz.cbest_ccbest_0c.hold",
"func.tt0p4v.ltz.rcbest_ccbest_0c.hold",
"func.tt0p4v.ml.cbest_ccbest_125c.hold",
"func.tt0p4v.ml.rcbest_ccbest_125c.hold",
"func.tt0p75v.tt85.cworst_ccworst_t_85c.setup",
"func.tt0p75v.tt85.rcworst_ccworst_t_85c.setup",
"func.tt0p75v.wcz.cworst_ccworst_0c.hold",
"func.tt0p75v.wcz.rcworst_ccworst_0c.hold",
"func.tt0p75v.wc.cworst_ccworst_125c.hold",
"func.tt0p75v.wc.rcworst_ccworst_125c.hold",
"func.tt0p75v.ltz.cworst_ccworst_0c.hold",
"func.tt0p75v.ltz.rcworst_ccworst_0c.hold",
"func.tt0p75v.ml.cworst_ccworst_125c.hold",
"func.tt0p75v.ml.rcworst_ccworst_125c.hold",
"func.tt0p75v.ltz.cbest_ccbest_0c.hold",
"func.tt0p75v.ltz.rcbest_ccbest_0c.hold",
"func.tt0p75v.ml.cbest_ccbest_125c.hold",
"func.tt0p75v.ml.rcbest_ccbest_125c.hold"
)

for scenario in scenarios:
    kList = scenario.split('.')
    mode = kList[0]
    volt = kList[1]
    libC = kList[2]
    rcC  = kList[3]
    ckTp = kList[4]
    rptFile = scenario+"/rpts/"+"hash_top."+mode+"."+volt+"."+libC+"."+rcC+"."+ckTp+".wo_io.rpt"
    #rptFile = scenario+"/rpts/"+"hash_top."+mode+"."+volt+"."+libC+"."+rcC+".xtk."+ckTp+".wo_io.rpt"
    #rptFile = scenario+"/rpts/"+"hash_top."+mode+"."+rcC+".xtk."+ckTp+".wo_io.rpt"
    if os.path.exists(rptFile):
        result = os.popen("grep 'slack (VIOLATED)' "+rptFile+" | gawk '{ sum += $3 }; END { print sum }'")
        tns = result.read().replace('\n',"")
        if tns == "":
            tns = 0
        result = os.popen("grep 'slack (VIOLATED)' "+rptFile+" | gawk 'BEGIN {min=65536} {if($i+0<min+0) min=$3} END {print min}'")
        wns = result.read().replace('\n',"")
        if wns == "65536":
            wns = 0
        result = os.popen("grep 'slack (VIOLATED)' "+rptFile+" | wc -l")
        num = result.read().replace('\n',"")
        tns = float(tns)
        wns = float(wns)
    rptFile = scenario+"/rpts/report_constraint.max_transition.rpt"
    trans_wns = "-"
    trans_num = "-"
    if os.path.exists(rptFile):
        result = os.popen("grep '(VIOLATED)' "+rptFile+" | gawk 'BEGIN {min=65536} {if($i+0<min+0) min=$2} END {print min}'")
        trans_wns = result.read().replace('\n',"")
        if trans_wns == "65536":
            trans_wns = 0
        result = os.popen("grep '(VIOLATED)' "+rptFile+" | wc -l")
        trans_num = result.read().replace('\n',"")
    fanout_wns = "-"
    fanout_num = "-"
    rptFile = scenario+"/rpts/report_constraint.max_fanout.rpt"
    if os.path.exists(rptFile):
        result = os.popen("grep '(VIOLATED)' "+rptFile+" | gawk 'BEGIN {min=65536} {if($i+0<min+0) min=$2} END {print min}'")
        fanout_wns = result.read().replace('\n',"")
        if fanout_wns == "65536":
            fanout_wns = 0
        result = os.popen("grep '(VIOLATED)' "+rptFile+" | wc -l")
        fanout_num = result.read().replace('\n',"")
    cap_wns = "-"
    cap_num = "-"
    rptFile = scenario+"/rpts/report_constraint.max_capacitance.rpt"
    if os.path.exists(rptFile):
        result = os.popen("grep '(VIOLATED)' "+rptFile+" | gawk 'BEGIN {min=65536} {if($i+0<min+0) min=$2} END {print min}'")
        cap_wns = result.read().replace('\n',"")
        if cap_wns == "65536":
            cap_wns = 0
        result = os.popen("grep '(VIOLATED)' "+rptFile+" | wc -l")
        cap_num = result.read().replace('\n',"")
    #print("%-60s\033[1;35m%15s\033[0m%15s%15s" %(scenario,num,wns,tns))
    print("%-60s\033[1;35m%15s\033[0m%15.3f%15.3f\t%10s:%-10s%10s:%-10s%10s:%-10s" %(scenario,num,wns,tns,trans_wns,trans_num,fanout_wns,fanout_num,cap_wns,cap_num))
    #print(rptFile)
