#!/usr/bin/tclsh
################################################################################################
# PROGRAM:     check_size_only_cell.pt.tcl
# CREATOR:     Zachary Shi <zacharys@alchip.com>
# DATE:        Fri Mar  9 16:37:30 2018
# DESCRIPTION: Checking size_only cell in PrimeTime
#              The specific instances (size_only cells) need to be preserved
# USAGE:       check_size_only_cell ?<check_size_only_cell.rep>
# UPDATE:      updated by Felix <felix_yuan@alchip.com>    2018-03-09 
# Item :       GE-02-06 GE-02-07
#################################################################################################
proc check_size_only_cell { {output_rpt_size_only_cell  check_size_only_cell.rep} } {

  puts "Alchip-info: Starting to signoff check size only cell in PrimeTime\n" 
  set file [ open $output_rpt_size_only_cell w ] 
  set pass_num 0
  set fail_num 0

  proc checking_size_only { args } {

    upvar pass_num loc_pass_num
    upvar fail_num loc_fail_num

    set cell_name   [ lindex $args 0 ]
    set ref_name    [ lindex $args 1 ]
    set function_id [ lindex $args 2 ]

    if { [ sizeof_collection [ get_cells $cell_name -quiet ] ] } {
      set cur_ref_name [ get_attribute [ get_cells $cell_name ] ref_name ]
      set cur_funct_id [ lindex [ get_attribute [ get_lib_cells */$cur_ref_name ] function_id ] 0 ]

      if { $cur_ref_name == $ref_name } {
        puts $file "Information: Checking the size_only cell is OK, cell: ${cell_name}"
        incr loc_pass_num

      } elseif { $cur_funct_id == $function_id } {
        puts $file "Warning: The size_only cell looks have changed the drive strength, cell: ${cell_name}, orig_ref_name: ${ref_name}, current_ref_name: ${cur_ref_name}"
        incr loc_pass_num

      } else {
        puts $file "Error: The size_only cell have been changed, please check it: ${cell_name}"
        incr loc_fail_num
      }

    } else {
      puts $file "Error: The size_only cell doesn't exist, please check it: ${cell_name}"
      incr loc_fail_num
    }
  }

  checking_size_only u_fpgaif_ddrio/u_ddriobuf_ioclk_out dti_tm40g_18dshtlrt_b_rsjl_spdppupdpk {}
  checking_size_only u_fpgaif_ddrio/gen_output_buf_3__u_ddriobuf_dout dti_tm40g_18dshtlrt_b_rsjl_spdppupdpk {}
  checking_size_only u_fpgaif_ddrio/gen_input_buf_2__u_ddriobuf_din dti_tm40g_18dshtlrt_b_rsjl_spdppupdpk {}
  checking_size_only u_fpgaif_ddrio/wangzhao_vddo_3__genblk1_u_vddo dti_tm40g_18dshtlrt_vddo_rsjl {}
  checking_size_only u_fpgaif_ddrio/gen_input_buf_0__u_ddriobuf_din dti_tm40g_18dshtlrt_b_rsjl_spdppupdpk {}
  checking_size_only u_fpgaif_ddrio/u_padlo_pvt dti_tm40g_18dshtlrt_drv_padlo_rsjl {}
  checking_size_only u_fpgaif_ddrio/gen_vss_2__u_vss dti_tm40g_18dshtlrt_vss_rsjl {}
  checking_size_only u_fpgaif_ddrio/wangzhao_vss_0__u_vss dti_tm40g_18dshtlrt_vss_rsjl {}
  checking_size_only u_fpgaif_ddrio/gen_vddo_3__genblk1_u_vddo dti_tm40g_18dshtlrt_vddo_rsjl {}
  checking_size_only u_fpgaif_ddrio/gen_output_buf_2__u_ddriobuf_dout dti_tm40g_18dshtlrt_b_rsjl_spdppupdpk {}
  checking_size_only u_fpgaif_ddrio/wangzhao_vddo_2__genblk1_u_vddo dti_tm40g_18dshtlrt_vddo_rsjl {}
  checking_size_only u_fpgaif_ddrio/gen_input_buf_5__u_ddriobuf_din dti_tm40g_18dshtlrt_b_rsjl_spdppupdpk {}
  checking_size_only u_fpgaif_ddrio/gen_vss_1__u_vss dti_tm40g_18dshtlrt_vss_rsjl {}
  checking_size_only u_fpgaif_ddrio/gen_vss_buf_fp_0__u_vss_buf_fp dti_tm40g_18dshtlrt_vss_buf_fp_rsjl {}
  checking_size_only u_fpgaif_ddrio/gen_vss_5__u_vss dti_tm40g_18dshtlrt_vss_rsjl {}
  checking_size_only u_fpgaif_ddrio/gen_vddo_2__genblk1_u_vddo dti_tm40g_18dshtlrt_vddo_rcc_rsjl {}
  checking_size_only u_fpgaif_ddrio/gen_output_buf_1__u_ddriobuf_dout dti_tm40g_18dshtlrt_b_rsjl_spdppupdpk {}
  checking_size_only u_fpgaif_ddrio/wangzhao_vddo_1__genblk1_u_vddo dti_tm40g_18dshtlrt_vddo_rsjl {}
  checking_size_only u_fpgaif_ddrio/gen_input_buf_4__u_ddriobuf_din dti_tm40g_18dshtlrt_b_rsjl_spdppupdpk {}
  checking_size_only u_fpgaif_ddrio/gen_output_buf_5__u_ddriobuf_dout dti_tm40g_18dshtlrt_b_rsjl_spdppupdpk {}
  checking_size_only u_fpgaif_ddrio/u_drv_rt_comp dti_tm40g_drv_rt_comp_rsjl {}
  checking_size_only u_fpgaif_ddrio/u_filler_pvt dti_tm40g_18dshtlrt_filler_25u_rsjl {}
  checking_size_only u_fpgaif_ddrio/gen_vdd_1__genblk1_u_vdd dti_tm40g_18dshtlrt_vdd_rcc_rsjl {}
  checking_size_only u_fpgaif_ddrio/gen_vss_0__u_vss dti_tm40g_18dshtlrt_vss_rsjl {}
  checking_size_only u_fpgaif_ddrio/gen_vss_4__u_vss dti_tm40g_18dshtlrt_vss_rsjl {}
  checking_size_only u_fpgaif_ddrio/gen_vddo_1__genblk1_u_vddo dti_tm40g_18dshtlrt_vddo_rsjl {}
  checking_size_only u_fpgaif_ddrio/wangzhao_vddo_0__genblk1_u_vddo dti_tm40g_18dshtlrt_vddo_rsjl {}
  checking_size_only u_fpgaif_ddrio/gen_output_buf_0__u_ddriobuf_dout dti_tm40g_18dshtlrt_b_rsjl_spdppupdpk {}
  checking_size_only u_fpgaif_ddrio/gen_output_buf_4__u_ddriobuf_dout dti_tm40g_18dshtlrt_b_rsjl_spdppupdpk {}
  checking_size_only u_fpgaif_ddrio/gen_input_buf_3__u_ddriobuf_din dti_tm40g_18dshtlrt_b_rsjl_spdppupdpk {}
  checking_size_only u_fpgaif_ddrio/gen_vdd_0__genblk1_u_vdd dti_tm40g_18dshtlrt_vdd_rsjl {}
  checking_size_only u_fpgaif_ddrio/u_padhi_pvt dti_tm40g_18dshtlrt_drv_padhi_rsjl {}
  checking_size_only u_fpgaif_ddrio/gen_input_buf_1__u_ddriobuf_din dti_tm40g_18dshtlrt_b_rsjl_spdppupdpk {}
  checking_size_only u_fpgaif_ddrio/gen_vss_3__u_vss dti_tm40g_18dshtlrt_vss_rsjl {}
  checking_size_only u_fpgaif_ddrio/gen_ref_0__u_ref dti_tm40g_18dshtlrt_ref_rsjl {}
  checking_size_only u_fpgaif_ddrio/gen_vddo_0__genblk1_u_vddo dti_tm40g_18dshtlrt_vddo_rsjl {}
  checking_size_only u_fpgaif_ddrio/wangzhao_vss_1__u_vss dti_tm40g_18dshtlrt_vss_rsjl {}

  puts $file "\n----------------------------------------------------------------------------"
  puts $file "Information: Total checked [ expr $pass_num + $fail_num ] size_only cells, $fail_num cell type are changed, $pass_num cells are OK.\n" 
  close $file 
  puts "Alchip-info: Completed to signoff check size only cell in PrimeTime\n"

}

