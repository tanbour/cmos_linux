#! /usr/bin/env python3
"""
pcom.py test cases
"""

import os
import unittest
import shutil
from utils import log_parser_cfg
from core import log_parser

class TestFindIter(unittest.TestCase):
    """test case for log_parser function"""
    def setUp(self):
        self.base_dir = "/tmp/test_log_parser"
        os.makedirs(self.base_dir)
    @classmethod
    def test_find_iter(cls):
        """test case"""
        key_path = {
            "dc_qor_max_key": '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180516_run/r0225_n0225/DEFAULT/rpt/syn/03_qor.rpt',
            "dc_qor_min_key": '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180516_run/r0225_n0225/DEFAULT/rpt/syn/03_qor.rpt',
            "dc_cell_count_key": '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180516_run/r0225_n0225/DEFAULT/rpt/syn/03_qor.rpt',
            "dc_area_key": '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180516_run/r0225_n0225/DEFAULT/rpt/syn/03_qor.rpt',
            "dc_design_rules_key": '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180516_run/r0225_n0225/DEFAULT/rpt/syn/03_qor.rpt',
            "dc_power_key": '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180516_run/r0225_n0225/DEFAULT/rpt/syn/03_power.rpt',
            "dc_misc_server_key": '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180516_run/r0225_n0225/DEFAULT/rpt/syn/03_qor.rpt',
            "dc_misc_key": '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180516_run/r0225_n0225/DEFAULT/sum/syn/syn.tcl.op.run.log',

            "icc2_ems_key": '/proj/OP4/SOFTWARE/WORK/minato/beta-2/Anarion/WORK/minato/huc_core_sys/V0720_S0720_F0720/rpt/icc2.0724/huc_core_sys.icc2_place.default.0724.check_design.pre_clock_tree_stage.log',
            "icc2_power_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180516_run/r0225_n0225/DEFAULT/rpt/syn/03_power.rpt",

            "icc2_const_scenario_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/rpt/icc2.120460/engine_tile.icc2_route_opt.default.120460.constraint.rep',
            "icc2_max_tran_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/rpt/icc2.120460/engine_tile.icc2_route_opt.default.120460.constraint.rep',
            "icc2_max_cap_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/rpt/icc2.120460/engine_tile.icc2_route_opt.default.120460.constraint.rep',

            "icc2_qor_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/rpt/icc2.120460/engine_tile.icc2_route_opt.default.120460.qor.rep',

            "icc2_cell_area_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/rpt/icc2.120460/engine_tile.icc2_route_opt.default.120460.threshold_voltage_group.rep',

            "icc2_utilization_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/rpt/icc2.120460/engine_tile.icc2_route_opt.default.120460.utilization.rpt',

            "icc2_routing_violation_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/rpt/icc2.120460/engine_tile.icc2_route_opt.default.120460.check_routes.log',

            "icc2_misc_server_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/log/icc2.120460/icc2_route_opt.default.120460.log',
            "icc2_misc_mem_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/log/icc2.120460/icc2_route_opt.default.120460.log',
            "icc2_misc_elapsed_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/log/icc2.120460/icc2_route_opt.default.120460.log',

            "star_open_net_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180516_run/r0225_n0225/DEFAULT/log/ext/ext.orange.star_sum',
            "star_short_net_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180516_run/r0225_n0225/DEFAULT/log/ext/ext.orange.star_sum',
            "star_misc_server_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180516_run/r0225_n0225/DEFAULT/log/ext/ext.orange.star_sum',
            "star_misc_mem_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180516_run/r0225_n0225/DEFAULT/log/ext/ext.orange.star_sum',
            "star_misc_elapsed_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180516_run/r0225_n0225/DEFAULT/log/ext/ext.orange.star_sum',

            "pt_w_io_qor_key" : '/proj/OP4/SOFTWARE/WORK/minato/beta-2/Anarion/WORK/minato/huc_core_sys/V0720_S0720_F0720/rpt/pt.0928/func.wc.rcworst_125c.max/timing.func.wc.rcworst_125c.setup.w_io.rep.summary',
            "pt_wo_io_qor_key" : '/proj/OP4/SOFTWARE/WORK/minato/beta-2/Anarion/WORK/minato/huc_core_sys/V0720_S0720_F0720/rpt/pt.0928/func.wc.rcworst_125c.max/timing.func.wc.rcworst_125c.setup.wo_io.rep.summary',
            "pt_clock_key" : '/proj/OP4/SOFTWARE/WORK/minato/beta-2/Anarion/WORK/minato/huc_core_sys/V0720_S0720_F0720/rpt/pt.0928/func.wc.rcworst_125c.max/clock_timing.func.wc.rcworst_125c.latency.rep.summary',
            "pt_max_tran_key" : '/proj/OP4/SOFTWARE/WORK/minato/beta-2/Anarion/WORK/minato/huc_core_sys/V0720_S0720_F0720/rpt/pt.0928/func.wc.rcworst_125c.max/constraint.max_transition.rep.summary',
            "pt_max_cap_key" : '/proj/OP4/SOFTWARE/WORK/minato/beta-2/Anarion/WORK/minato/huc_core_sys/V0720_S0720_F0720/rpt/pt.0928/func.wc.rcworst_125c.max/constraint.max_capacitance.rep.summary',
            "pt_misc_server_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180516_run/r0225_n0225/DEFAULT/sum/sta/func.tt0p8v.wcl.cworst_CCworst_T_125c.setup/sta.tcl.op.run.beer',
            "pt_misc_mem_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180516_run/r0225_n0225/DEFAULT/sum/sta/func.tt0p8v.wcl.cworst_CCworst_T_125c.setup/sta.tcl.op.run.log',
            "pt_misc_elapsed_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180516_run/r0225_n0225/DEFAULT/sum/sta/func.tt0p8v.wcl.cworst_CCworst_T_125c.setup/sta.tcl.op.run.log',

            "signoffcheck_GE-05-05-S_key" : "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180523_signoff/output/signoff_icc2/rpt/check_signal_wire_length.rpt",
            "signoffcheck_ST-02-10_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180523_signoff/output/signoff_icc2/rpt/check_delay_cell_chain.rpt",
            "signoffcheck_GE-05-05-C_key" : "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180523_signoff/output/signoff_icc2/rpt/check_clock_wire_length.rpt",
            "signoffcheck_GE-02-12_key" : "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180523_signoff/output/signoff_icc2/rpt/check_tie_connection.rpt",
            "signoffcheck_GE-02-02_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180523_signoff/output/signoff_icc2/rpt/check_open_input_pin.rpt",
            "signoffcheck_GE-04-20_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180523_signoff/output/signoff_icc2/rpt/check_filler_area_number.rpt",
            "signoffcheck_GE-04-02_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180523_signoff/output/signoff_icc2/rpt/check_dcap_area_number.rpt",
            "signoffcheck_GE-04-03_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180523_signoff/output/signoff_icc2/rpt/check_eco_area_number.rpt",
            "signoffcheck_GE-04-07_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180523_signoff/output/signoff_icc2/rpt/check_ip_isolation.rpt",
            "signoffcheck_GE-04-19_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180523_signoff/output/signoff_icc2/rpt/check_ip_isolation.rpt",
            "signoffcheck_GE-02-03_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180523_signoff/output/signoff_pt/rpt/func.tt0p8v.wcl.cworst_CCworst_T_125c.setup/check_multi_driver.rpt",
            "signoffcheck_CK-01-16_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180523_signoff/output/signoff_icc2/rpt/check_multi_drive_net.rpt",
            "signoffcheck_GE-04-18_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180523_signoff/output/signoff_icc2/rpt/check_port_isolation.rpt",

            "signoffcheck_GE-02-16_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180523_signoff/output/signoff_pt/rpt/func.tt0p8v.wcl.cworst_CCworst_T_125c.setup/check_dont_use_cell.rpt",
            "signoffcheck_GE-06-03_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180523_signoff/output/signoff_pt/rpt/func.tt0p8v.wcl.cworst_CCworst_T_125c.setup/check_clock_net_xtalk_delta_delay.rpt",
            "signoffcheck_GE-02-08_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180523_signoff/output/signoff_pt/rpt/func.tt0p8v.wcl.cworst_CCworst_T_125c.setup/check_dont_touch_net.rpt",
            "signoffcheck_GE-02-07_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180523_signoff/output/signoff_pt/rpt/func.tt0p8v.wcl.cworst_CCworst_T_125c.setup/check_size_only_cell.rpt",
            "signoffcheck_CK-01-03_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180523_signoff/output/signoff_pt/rpt/func.tt0p8v.wcl.cworst_CCworst_T_125c.setup/report_clock_cell_type.rpt",
            "signoffcheck_CK-01-04_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180523_signoff/output/signoff_pt/rpt/func.tt0p8v.wcl.cworst_CCworst_T_125c.setup/report_clock_cell_type.rpt",
            "signoffcheck_CK-01-05_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180523_signoff/output/signoff_pt/rpt/func.tt0p8v.wcl.cworst_CCworst_T_125c.setup/report_clock_cell_type.rpt",

            "signoffcheck_GE-02-04_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180523_signoff/output/signoff_logs/log/apple.perl.check_netlist.log",
            "signoffcheck_GE-02-05_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180523_signoff/output/signoff_logs/log/apple.perl.check_netlist.log",
            "signoffcheck_GE-02-11_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180523_signoff/output/signoff_logs/log/apple.perl.check_netlist.log",
            "signoffcheck_GE-02-09_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180523_signoff/output/signoff_logs/log/apple.perl.check_cellsize.log",
            "signoffcheck_GE-02-10_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180523_signoff/output/signoff_logs/log/apple.perl.check_cellsize.log",
            "signoffcheck_GE-08-17_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180523_signoff/output/signoff_logs/log/apple.perl.check_ip_cdl_bus_order.log",

            "signoffcheck_FP-01-01_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180516/calibre/drc/DRC.log",
            "signoffcheck_GE-04-09_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180516/calibre/drc/DRC.log",
            "signoffcheck_GE-08-01_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180516/calibre/drc/DRC.rep",
            "signoffcheck_GE-08-03_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180516/calibre/ant/ANT.rep",
            "signoffcheck_GE-08-04_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180516/calibre/lvs/LVS.log",
            "signoffcheck_GE-08-05_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180516/calibre/lvs/LVS.log",
            "signoffcheck_GE-08-06_key": "/proj/OP4/SOFTWARE/WORK/minato/dev/sample/20180516/calibre/drc/DRC.rep",

        }

        # pcd = log_parser_cfg.PARSER_CFG_DIC.get("syn").get("syn.tcl")
        # pcd = log_parser_cfg.PARSER_CFG_DIC.get("pr").get("08_finish.tcl")
        # pcd = log_parser_cfg.PARSER_CFG_DIC.get("ext").get("ext.csh")
        # pcd = log_parser_cfg.PARSER_CFG_DIC.get("sta").get("sta.tcl")

        # pcd = log_parser_cfg.PARSER_CFG_DIC.get("signoff_icc2").get("01_icc2_signoff.tcl")
        # pcd = log_parser_cfg.PARSER_CFG_DIC.get("signoff_pt").get("03_pt_signoff.tcl")
        # pcd = log_parser_cfg.PARSER_CFG_DIC.get("signoff_logs").get("04_logs_signoff.csh")

        pcd = log_parser_cfg.PARSER_CFG_DIC.get("pv").get("drc.csh")

        l_p = log_parser.LogParser()

        for p_k, p_v in pcd.items():
            if not p_k.endswith("_key") or not p_v:
                continue
            print(f"Key: {p_k}")
            l_p.add_parser(
                key_path[p_k], pcd.get(f"{p_k}_type", ""),
                pcd.get(f"{p_k}_exp_lst", []), pcd.get(f"{p_k}_tpl", ""))
        print(l_p.run_parser())

    def tearDown(self):
        shutil.rmtree(self.base_dir)
        del self.base_dir

if __name__ == "__main__":
    unittest.main()

