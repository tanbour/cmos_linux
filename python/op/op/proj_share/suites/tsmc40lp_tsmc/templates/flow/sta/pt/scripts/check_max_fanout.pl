#!/usr/bin/perl

while( <> ) {
  if( /^\s*(Pin|Net):\s*(\S+)/ ) {
    ( $null, $pin_name ) =
      /^\s*(Pin|Net):\s*(\S+)/ ;
    $block_name = "TOP" ;
    $local_pin_name = $pin_name ;
    #if( $pin_name =~      /^A9C\/A9TEG\/uTOP\/uLTOP\/uCKRST\/clkrst_ck\/clkrst_ck_core\// ) {
    #  $local_pin_name =~ s/^A9C\/A9TEG\/uTOP\/uLTOP\/uCKRST\/clkrst_ck\/clkrst_ck_core\/// ;
    #  $block_name = "CLKRST_clkrst_ck_core_0" ;
   ##} elsif( $pin_name =~ /^A9C\/A9TEG\/uTOP\/uLTOP\/uK\/JIB\/uCH_ENGINE\// ) {
   ##  $local_pin_name =~ s/^A9C\/A9TEG\/uTOP\/uLTOP\/uK\/JIB\/uCH_ENGINE\/// ;
   ##  $block_name = "CHANNEL_ENGINE" ;
    #} elsif( $pin_name =~ /^A9C\/A9TEG\/uTOP\/uLTOP\/uK\/A9SYS\/u_A9CPU\/u_A9CPU_PRIMEL2\/u_A9CPU_PRIME\// ) {
    #  $local_pin_name =~ s/^A9C\/A9TEG\/uTOP\/uLTOP\/uK\/A9SYS\/u_A9CPU\/u_A9CPU_PRIMEL2\/u_A9CPU_PRIME\/// ;
    #  $block_name = "A9CPU_PRIME" ;
    #} elsif( $pin_name =~ /^A9C\/A9TEG\/uTOP\/uLTOP\/uK\/GPU\/gpu\/i_hyd2_mp4_sys_ef\/i_arx2_core[0123]_sys\/i[01]_arx2_pipeline_ef\// ) {
    #  $local_pin_name =~ s/^A9C\/A9TEG\/uTOP\/uLTOP\/uK\/GPU\/gpu\/i_hyd2_mp4_sys_ef\/i_arx2_core[0123]_sys\/i[01]_arx2_pipeline_ef\/// ;
    #  $block_name = "arx2_pipeline_ef" ;
    #} elsif( $pin_name =~ /^A9C\/A9TEG\/uTOP\/uLTOP\/uK\/GPU\/gpu\/i_hyd2_mp4_sys_ef\/i_arx2_core3_sys\/i_arx2_partition_mp_wrap_ef\// ) {
    #  $local_pin_name =~ s/^A9C\/A9TEG\/uTOP\/uLTOP\/uK\/GPU\/gpu\/i_hyd2_mp4_sys_ef\/i_arx2_core3_sys\/i_arx2_partition_mp_wrap_ef\/// ;
    #  $block_name = "arx2_partition_mp_wrap_ef" ;
    #} elsif( $pin_name =~ /^A9C\/A9TEG\/uTOP\/uLTOP\/uK\/GPU\/gpu\/i_hyd2_mp4_sys_ef\/i_hyd2_mp4_partition\// ) {
    #  $local_pin_name =~ s/^A9C\/A9TEG\/uTOP\/uLTOP\/uK\/GPU\/gpu\/i_hyd2_mp4_sys_ef\/i_hyd2_mp4_partition\/// ;
    #  $block_name = "hyd2_mp4_partition" ;
    #} elsif( $pin_name =~ /^A9C\/A9TEG\/uTOP\/uLTOP\/uK\/GPU\/gpu\// ) {
    #  $local_pin_name =~ s/^A9C\/A9TEG\/uTOP\/uLTOP\/uK\/GPU\/gpu\/// ;
    #  $block_name = "gpu" ;
    #}
    $block_name_by_pin_name{"$pin_name"} = $block_name ;
  }
  if( /^\s*max_fanout\s+(\d+\.*\d*)\s*$/ ) {
    ( $max_fanout ) =
      /^\s*max_fanout\s+(\d+\.*\d*)\s*$/ ;
    #$max_fanout = 999999 if( $pin_name =~ /^[^\/]+$/ ) ;
    #$max_fanout = 999999 if( $pin_name =~ /^A9C\/A9TEG\/uK_[^\/]+\/PAD$/ ) ;
    #$max_fanout = 999999 if( $pin_name =~ /^D4727\/[^\/]+$/ ) ;
    #$max_fanout = 999999 if( $pin_name =~ /^A9C\/A9TEG\/uK_VPGM\/AY$/ ) ;
    #$max_fanout = 999999 if( $pin_name =~ /^A9C\/A9TEG\/uTOP\/uLTOP\/uFUSE\/TREDSFWRP\/efuse_ctrl\/ss32lp_efrom_lp_128_[0-7]\/FSOURCE$/ ) ;
    #$max_fanout = 999999 if( $pin_name =~ /^A9C\/cdram\/[^\/]+$/ ) ;
    #$max_fanout = 999999 if( $pin_name =~ /^A9C\/A9TEG\/uK_CDRAM\S+\/uxioCDRAMCA\/PAD$/ ) ;
   #$max_fanout = 999999 if( $pin_name =~ /^A9C\/A9TEG\/uK_\S+_(Y|A|IE|OE|DS0|DS1)_IRYU_ISO_U0_(A|Y)_ALCHIP_U0\/Y$/ ) ;
   #$max_fanout = 999999 if( $pin_name =~ /^A9C\/A9TEG\/uK_\S+_(Y|A|IE|OE|DS0|DS1)_IRYU_ISO_U0_(A|Y)_ALCHIP_U0_PARA_BUFFER_\d+\/Y$/ ) ;
   #$max_fanout = 999999 if( $pin_name =~ /^A9C\/A9TEG\/uK_\S+_(Y|A|IE|OE|DS0|DS1)_IRYU_ISO_U0_(A|Y)_ALCHIP_U0_PARA_BUFFER_\d+_\d+\/Y$/ ) ;
   #$max_fanout = 999999 if( $pin_name =~ /^A9C\/A9TEG\/uK_\S+_(Y|A|IE|OE|DS0|DS1)_IRYU_MULTIDRIVE_\d+_U\d+\/Y$/ ) ;
   #$max_fanout = 999999 if( $pin_name =~ /^A9C\/A9TEG\/uAP_\S+_(X|A|IE)_IRYU_MULTIDRIVE_\d+_U\d+\/Y$/ ) ;
   #$max_fanout = 999999 if( $pin_name =~ /^A9C\/A9TEG\/uPA_\S+_(X|A|IE)_IRYU_MULTIDRIVE_\d+_U\d+\/Y$/ ) ;
   #$max_fanout = 999999 if( $pin_name =~ /^A9C\/A9TEG\/uCA_\S+_(X|A|IE)_IRYU_MULTIDRIVE_\d+_U\d+\/Y$/ ) ;
   #$max_fanout = 999999 if( $pin_name =~ /^A9C\/A9TEG\/uCR_\S+_(X|A|IE)_IRYU_MULTIDRIVE_\d+_U\d+\/Y$/ ) ;
  }
  if( /^\s*-\s+Fanout\s+(\d+\.*\d*)\s*$/ ) {
    ( $fanout ) =
      /^\s*-\s+Fanout\s+(\d+\.*\d*)\s*$/ ;
  }
  if( /^\s*Slack\s+(-*\d+\.*\d*)\s+\(([^\(\)]+)\)\s*$/ ) {
    ( $slack, $status ) =
      /^\s*Slack\s+(-*\d+\.*\d*)\s+\(([^\(\)]+)\)\s*$/ ;
    $slack = $max_fanout - $fanout ;
    if( $slack <= 0.000 ) {
      $fanout_by_pin{$pin_name} = $fanout ;
      $max_fanout_by_pin{$pin_name} = $max_fanout ;
      $slack_by_pin{$pin_name} = $slack ;
      $status_by_pin{$pin_name} = $status_by_pin ;
      $error_count_over_limit{$max_fanout}++ ;
      $error_count_total++ ;
      $error_count_by_block_name{$block_name}++ ;
      if( $slack_by_local_pin_name{"$local_pin_name"} eq "" ) {
        $local_error_count_total++ ;
        $local_error_count_by_block_name{$block_name}++ ;
        $slack_by_local_pin_name{"$local_pin_name"} = $slack ;
      }

      if(    ( $slack <=   0 ) && ( $slack >   -10 ) ) { $count_by_slack_range{"0-10"}++ }
      elsif( ( $slack <= -10 ) && ( $slack >   -20 ) ) { $count_by_slack_range{"10-20"}++ }
      elsif( ( $slack <= -20 ) && ( $slack >   -30 ) ) { $count_by_slack_range{"20-30"}++ }
      elsif( ( $slack <= -30 ) && ( $slack >   -40 ) ) { $count_by_slack_range{"30-40"}++ }
      elsif( ( $slack <= -40 ) && ( $slack >   -50 ) ) { $count_by_slack_range{"40-50"}++ }
      elsif( ( $slack <= -50 ) && ( $slack >   -60 ) ) { $count_by_slack_range{"50-60"}++ }
      elsif( ( $slack <= -60 ) && ( $slack >   -70 ) ) { $count_by_slack_range{"60-70"}++ }
      elsif( ( $slack <= -70 ) && ( $slack >   -80 ) ) { $count_by_slack_range{"70-80"}++ }
      elsif( ( $slack <= -80 ) && ( $slack >   -90 ) ) { $count_by_slack_range{"80-90"}++ }
      elsif( ( $slack <= -90 ) && ( $slack >  -100 ) ) { $count_by_slack_range{"90-100"}++ }
      else                                             { $count_by_slack_range{"100-"}++ }

      if(    ( $fanout >   0 ) && ( $fanout <=  10 ) ) { $count_by_fanout_range{"0-10"}++ }
      elsif( ( $fanout >  10 ) && ( $fanout <=  20 ) ) { $count_by_fanout_range{"10-20"}++ }
      elsif( ( $fanout >  20 ) && ( $fanout <=  30 ) ) { $count_by_fanout_range{"20-30"}++ }
      elsif( ( $fanout >  30 ) && ( $fanout <=  40 ) ) { $count_by_fanout_range{"30-40"}++ }
      elsif( ( $fanout >  40 ) && ( $fanout <=  50 ) ) { $count_by_fanout_range{"40-50"}++ }
      elsif( ( $fanout >  50 ) && ( $fanout <=  60 ) ) { $count_by_fanout_range{"50-60"}++ }
      elsif( ( $fanout >  60 ) && ( $fanout <=  70 ) ) { $count_by_fanout_range{"60-70"}++ }
      elsif( ( $fanout >  70 ) && ( $fanout <=  80 ) ) { $count_by_fanout_range{"70-80"}++ }
      elsif( ( $fanout >  80 ) && ( $fanout <=  90 ) ) { $count_by_fanout_range{"80-90"}++ }
      elsif( ( $fanout >  90 ) && ( $fanout <= 100 ) ) { $count_by_fanout_range{"90-100"}++ }
      else                                             { $count_by_fanout_range{"100-"}++ }
    }
  }
}

printf( "       slack  max_fanout  fanout  pin\n" ) ;
printf( "  ----------  ----------  ------  ----------\n" ) ;
foreach $pin_name ( sort( { $slack_by_pin{$a} <=> $slack_by_pin{$b} } keys( %slack_by_pin ) ) ) {
  printf( "  %10d  %10d  %6d  %s \(%s\)\n", $slack_by_pin{$pin_name}, $max_fanout_by_pin{$pin_name}, $fanout_by_pin{$pin_name}, $pin_name, $block_name_by_pin_name{"$pin_name"} ) ;
}
printf( "\n" ) ;

printf( "  Summary\n" ) ;
printf( "  -------\n" ) ;
foreach $max_fanout ( sort( keys( %error_count_over_limit ) ) ) {
  printf( "  Fanout error count over %2d = %10d\n", $max_fanout, $error_count_over_limit{$max_fanout} ) ;
}
printf( "  Total fanout error         = %10d\n", $error_count_total ) ;
printf( "\n" ) ;

#@block_names = qw(
#CLKRST_clkrst_ck_core_0
#CHANNEL_ENGINE
#A9CPU_PRIME
#arx2_pipeline_ef
#arx2_partition_mp_wrap_ef
#hyd2_mp4_partition
#gpu
#IRYU
#) ;
@block_names = qw(
TOP
) ;

printf( "  Summary by block\n" ) ;
printf( "  ----------------\n" ) ;
foreach $block_name ( @block_names ) {
  printf( "  %-25s = %10d \(%10d\)\n", $block_name, $error_count_by_block_name{$block_name}, $local_error_count_by_block_name{$block_name} ) ;
}
printf( "  %-25s = %10d \(%10d\)\n", "Total", $error_count_total, $local_error_count_total ) ;
printf( "\n" ) ;

printf( "  Slack range       Count\n" ) ;
printf( "  ----------------  -----\n" ) ;
printf( "  %6d < %6d   %5d\n",  00, -10, $count_by_slack_range{"00-10"} ) ;
printf( "  %6d < %6d   %5d\n", -10, -20, $count_by_slack_range{"10-20"} ) ;
printf( "  %6d < %6d   %5d\n", -20, -30, $count_by_slack_range{"20-30"} ) ;
printf( "  %6d < %6d   %5d\n", -30, -40, $count_by_slack_range{"30-40"} ) ;
printf( "  %6d < %6d   %5d\n", -40, -50, $count_by_slack_range{"40-50"} ) ;
printf( "  %6d < %6d   %5d\n", -50, -60, $count_by_slack_range{"50-60"} ) ;
printf( "  %6d < %6d   %5d\n", -60, -70, $count_by_slack_range{"60-70"} ) ;
printf( "  %6d < %6d   %5d\n", -70, -80, $count_by_slack_range{"70-80"} ) ;
printf( "  %6d < %6d   %5d\n", -80, -90, $count_by_slack_range{"80-90"} ) ;
printf( "  %6d < %6d   %5d\n", -90, -100, $count_by_slack_range{"90-100"} ) ;
printf( "  %6d <          %5d\n", -100,         $count_by_slack_range{"100-"} ) ;
printf( "  ----------------  -----\n" ) ;
printf( "  Total             %5d\n", $error_count_total ) ;
printf( "\n" ) ;

printf( "  Transition range  Count\n" ) ;
printf( "  ----------------  -----\n" ) ;
printf( "  %6d < %6d   %5d\n", 00, 10, $count_by_fanout_range{"00-10"} ) ;
printf( "  %6d < %6d   %5d\n", 10, 20, $count_by_fanout_range{"10-20"} ) ;
printf( "  %6d < %6d   %5d\n", 20, 30, $count_by_fanout_range{"20-30"} ) ;
printf( "  %6d < %6d   %5d\n", 30, 40, $count_by_fanout_range{"30-40"} ) ;
printf( "  %6d < %6d   %5d\n", 40, 50, $count_by_fanout_range{"40-50"} ) ;
printf( "  %6d < %6d   %5d\n", 50, 60, $count_by_fanout_range{"50-60"} ) ;
printf( "  %6d < %6d   %5d\n", 60, 70, $count_by_fanout_range{"60-70"} ) ;
printf( "  %6d < %6d   %5d\n", 70, 80, $count_by_fanout_range{"70-80"} ) ;
printf( "  %6d < %6d   %5d\n", 80, 90, $count_by_fanout_range{"80-90"} ) ;
printf( "  %6d < %6d   %5d\n", 90, 100, $count_by_fanout_range{"90-100"} ) ;
printf( "  %6d <          %5d\n", 100,        $count_by_fanout_range{"100-"} ) ;
printf( "  ----------------  -----\n" ) ;
printf( "  Total             %5d\n", $error_count_total ) ;
printf( "\n" ) ;

