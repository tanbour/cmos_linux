%REPL_OP4
set dst_tmp = $OP4_dst
set src_tmp = $OP4_src
set dst_eco = $OP4_dst_eco
set src_eco = $OP4_src_eco
REPL_OP4%
set dst_tool_name = `echo $dst_tmp | cut -d _ -f 1`
set src_tool_name = `echo $src_tmp | cut -d _ -f 1`
set OP4_dst_subdir = ${dst_tool_name}.${dst_eco}
set OP4_src_subdir = ${src_tool_name}.${src_eco}

%REPL_OP4
if (-e $RPT_DIR/\$OP4_dst_subdir) then
echo ""
else
mkdir $RPT_DIR/\$OP4_dst_subdir
endif

if (-e $LOG_DIR/\$OP4_dst_subdir) then
echo ""
else
mkdir $LOG_DIR/\$OP4_dst_subdir
endif

if (-e $DATA_DIR/\$OP4_dst_subdir) then
echo ""
else
mkdir $DATA_DIR/\$OP4_dst_subdir
endif

if (-e  $SUM_DIR/\$OP4_dst_subdir) then
echo ""
else
mkdir $SUM_DIR/\$OP4_dst_subdir
endif

set RPT_DIR  = $RPT_DIR/\$OP4_dst_subdir
set SRC_DATA_DIR = $DATA_DIR/\$OP4_src_subdir
set DST_DATA_DIR = $DATA_DIR/\$OP4_dst_subdir
set LOG_DIR  = $LOG_DIR/\$OP4_dst_subdir
set SUM_DIR  = $SUM_DIR/\$OP4_dst_subdir

#===================================================================
#===================  create link files   ==========================
#===================================================================

if (-e \$SRC_DATA_DIR/$BLOCK_NAME.$OP4_src.$OP4_src_branch.$OP4_src_eco.gds.gz ) then
ln -sf ../.\$SRC_DATA_DIR/$BLOCK_NAME.$OP4_src.$OP4_src_branch.$OP4_src_eco.gds.gz  \$DST_DATA_DIR/$BLOCK_NAME.$OP4_dst.$OP4_dst_branch.$OP4_dst_eco.gds.gz
endif
if (-e \$SRC_DATA_DIR/$BLOCK_NAME.$OP4_src.$OP4_src_branch.$OP4_src_eco.nlib ) then
ln -sf ../.\$SRC_DATA_DIR/$BLOCK_NAME.$OP4_src.$OP4_src_branch.$OP4_src_eco.nlib \$DST_DATA_DIR/$BLOCK_NAME.$OP4_dst.$OP4_dst_branch.$OP4_dst_eco.nlib
endif
if (-e \$SRC_DATA_DIR/$BLOCK_NAME.$OP4_src.$OP4_src_branch.$OP4_src_eco.def.gz ) then
ln -sf ../.\$SRC_DATA_DIR/$BLOCK_NAME.$OP4_src.$OP4_src_branch.$OP4_src_eco.def.gz \$DST_DATA_DIR/$BLOCK_NAME.$OP4_dst.$OP4_dst_branch.$OP4_dst_eco.def.gz
endif

if (-e \$SRC_DATA_DIR/$BLOCK_NAME.$OP4_src.$OP4_src_branch.$OP4_src_eco.pt.v) then
ln -sf ../.\$SRC_DATA_DIR/$BLOCK_NAME.$OP4_src.$OP4_src_branch.$OP4_src_eco.pt.v   \$DST_DATA_DIR/$BLOCK_NAME.$OP4_dst.$OP4_dst_branch.$OP4_dst_eco.pt.v
endif
if (-e \$SRC_DATA_DIR/$BLOCK_NAME.$OP4_src.$OP4_src_branch.$OP4_src_eco.lvs.v) then
ln -sf ../.\$SRC_DATA_DIR/$BLOCK_NAME.$OP4_src.$OP4_src_branch.$OP4_src_eco.lvs.v   \$DST_DATA_DIR/$BLOCK_NAME.$OP4_dst.$OP4_dst_branch.$OP4_dst_eco.lvs.v
endif
if (-e \$SRC_DATA_DIR/$BLOCK_NAME.$OP4_src.$OP4_src_branch.$OP4_src_eco.fm.v) then
ln -sf ../.\$SRC_DATA_DIR/$BLOCK_NAME.$OP4_src.$OP4_src_branch.$OP4_src_eco.fm.v   \$DST_DATA_DIR/$BLOCK_NAME.$OP4_dst.$OP4_dst_branch.$OP4_dst_eco.fm.v
endif
if (-e \$SRC_DATA_DIR/$BLOCK_NAME.$OP4_src.$OP4_src_branch.$OP4_src_eco.vclp.v) then
ln -sf ../.\$SRC_DATA_DIR/$BLOCK_NAME.$OP4_src.$OP4_src_branch.$OP4_src_eco.vclp.v   \$DST_DATA_DIR/$BLOCK_NAME.$OP4_dst.$OP4_dst_branch.$OP4_dst_eco.vclp.v
endif



REPL_OP4%


