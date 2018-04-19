#!/bin/csh -f
if (-d opus_oa_lib) then
%REPL_OP4
if (-d $PROJ_DIR/LIB/Techfile/OPUS_LIB) then
\rm  -rf $PROJ_DIR/LIB/Techfile/OPUS_LIB
endif
mkdir $PROJ_DIR/LIB/Techfile/OPUS_LIB
cp -rf  ./opus_oa_lib/*  $PROJ_DIR/LIB/Techfile/OPUS_LIB
set new_path = $PROJ_DIR/LIB/Techfile/OPUS_LIB
set opus_cds_file = $PROJ_DIR/LIB/Techfile/OPUS_LIB/cds.lib
REPL_OP4%
set lib_dir = `grep "DEFINE" ${opus_cds_file} | awk '{print $3}'`
foreach lib_path ($lib_dir)
set old_path = `dirname ${lib_path}`
sed -i 's#'${old_path}'#'${new_path}'#g' ${opus_cds_file}
end
else
echo "Alchip-info:the folder laker_gen_lib noexist,you should run the laker_gen_lib step first!"
endif
