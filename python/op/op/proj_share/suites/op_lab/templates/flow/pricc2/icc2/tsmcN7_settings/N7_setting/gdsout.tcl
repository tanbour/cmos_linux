
## 
##   -units 2000 \
##   -design $TOP \
##   -library name \
##

set DST_DATA_DIR .
set TOP [lindex [get_attribute [get_designs] full_name] 0]

sh mkdir -p $DST_DATA_DIR/release
if {[file exist $DST_DATA_DIR/release/gds_ready]}     {sh rm $DST_DATA_DIR/release/gds_ready}
if {[file exist $DST_DATA_DIR/release/${TOP}.gds.gz]} {sh rm $DST_DATA_DIR/release/${TOP}.gds.gz}

set_host_options -max_cores 32
# process_metal_extensions_cut_metals -trim_end_off_preferred_grid_extensions true
process_metal_extensions_cut_metals

#set block_boundary [get_attribute [get_designs -filter "view_name==design"] boundary]
#set geo_mask [resize_polygons -objects $block_boundary -size {0 0.06 0 0.06}]
#create_shape -boundary [get_attribute $geo_mask poly_rects] -layer 108:250 -shape_type rect -shape_use user_route

set mapfile /proj/Pelican/WORK/gray/PV/tech/icc2/prtech/PR_tech/Synopsys/GdsOutMap/gdsout_2X_hv_1Ya_h_3Y_vhv_2Z_1.1a.map
write_gds \
          -long_names \
          -fill include \
          -hierarchy design_lib \
          -keep_data_type \
          -output_pin all \
          -layer_map $mapfile \
          -lib_cell_view frame \
          -connect_below_cut_metal \
          -write_default_layers {VIA1 VIA2} \
          -layer_map_format icc_extended \
          $DST_DATA_DIR/release/${TOP}.gds
sh gzip   $DST_DATA_DIR/release/${TOP}.gds
sh touch  $DST_DATA_DIR/release/gds_ready

#remove_shapes [get_shapes -filter "shape_type==rect && shape_use==user_route && layer_number==108"]


