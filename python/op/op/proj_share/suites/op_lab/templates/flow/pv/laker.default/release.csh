#!/bin/csh -f
if (-d laker_gen_lib) then
#cd laker_gen_lib
#\rm -rf blitzGds*  *info* 
#cd ..
%REPL_OP4
if (-d $PROJ_DIR/LIB/Techfile/LAKER_LIB) then
\rm  -rf $PROJ_DIR/LIB/Techfile/LAKER_LIB
endif
mkdir $PROJ_DIR/LIB/Techfile/LAKER_LIB
cp -rf  ./laker_gen_lib/*  $PROJ_DIR/LIB/Techfile/LAKER_LIB
#cd $PROJ_DIR/LIB/Techfile/LAKER_LIB
\rm -rf $PROJ_DIR/LIB/Techfile/LAKER_LIB/blitzGds* 
\rm -rf $PROJ_DIR/LIB/Techfile/LAKER_LIB/*info*
set new_path = $PROJ_DIR/LIB/Techfile/LAKER_LIB
set laker_resource_file = $PROJ_DIR/LIB/Techfile/LAKER_LIB/laker.rc
REPL_OP4%
set lib_dir = `grep "=" $laker_resource_file | sed 's/.*=//g'`
foreach lib_path ($lib_dir)
set old_path = `dirname ${lib_path}`
sed -i 's#'${old_path}'#'${new_path}'#g' ${laker_resource_file}
end
else
echo "Alchip-info:the folder laker_gen_lib noexist,you should run the laker_gen_lib step first!"
endif
