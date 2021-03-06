#!/usr/bin/perl

while( <> ) {
  if( /^\s*(Pin|Net):\s*(\S+)/ ) {
    ( $null, $pin_name ) =
      /^\s*(Pin|Net):\s*(\S+)/ ;
    $block_name = "TOP" ;
    $local_pin_name = $pin_name ;
   # if( $pin_name =~      /^A9C\/A9TEG\/uTOP\/uLTOP\/uCKRST\/clkrst_ck\/clkrst_ck_core\// ) {
   #   $local_pin_name =~ s/^A9C\/A9TEG\/uTOP\/uLTOP\/uCKRST\/clkrst_ck\/clkrst_ck_core\/// ;
   #   $block_name = "CLKRST_clkrst_ck_core_0" ;
   ##} elsif( $pin_name =~ /^A9C\/A9TEG\/uTOP\/uLTOP\/uK\/JIB\/uCH_ENGINE\// ) {
   ##  $local_pin_name =~ s/^A9C\/A9TEG\/uTOP\/uLTOP\/uK\/JIB\/uCH_ENGINE\/// ;
   ##  $block_name = "CHANNEL_ENGINE" ;
   # } elsif( $pin_name =~ /^A9C\/A9TEG\/uTOP\/uLTOP\/uK\/A9SYS\/u_A9CPU\/u_A9CPU_PRIMEL2\/u_A9CPU_PRIME\// ) {
   #   $local_pin_name =~ s/^A9C\/A9TEG\/uTOP\/uLTOP\/uK\/A9SYS\/u_A9CPU\/u_A9CPU_PRIMEL2\/u_A9CPU_PRIME\/// ;
   #   $block_name = "A9CPU_PRIME" ;
   # } elsif( $pin_name =~ /^A9C\/A9TEG\/uTOP\/uLTOP\/uK\/GPU\/gpu\/i_hyd2_mp4_sys_ef\/i_arx2_core[0123]_sys\/i[01]_arx2_pipeline_ef\// ) {
   #   $local_pin_name =~ s/^A9C\/A9TEG\/uTOP\/uLTOP\/uK\/GPU\/gpu\/i_hyd2_mp4_sys_ef\/i_arx2_core[0123]_sys\/i[01]_arx2_pipeline_ef\/// ;
   #   $block_name = "arx2_pipeline_ef" ;
   # } elsif( $pin_name =~ /^A9C\/A9TEG\/uTOP\/uLTOP\/uK\/GPU\/gpu\/i_hyd2_mp4_sys_ef\/i_arx2_core3_sys\/i_arx2_partition_mp_wrap_ef\// ) {
   #   $local_pin_name =~ s/^A9C\/A9TEG\/uTOP\/uLTOP\/uK\/GPU\/gpu\/i_hyd2_mp4_sys_ef\/i_arx2_core3_sys\/i_arx2_partition_mp_wrap_ef\/// ;
   #   $block_name = "arx2_partition_mp_wrap_ef" ;
   # } elsif( $pin_name =~ /^A9C\/A9TEG\/uTOP\/uLTOP\/uK\/GPU\/gpu\/i_hyd2_mp4_sys_ef\/i_hyd2_mp4_partition\// ) {
   #   $local_pin_name =~ s/^A9C\/A9TEG\/uTOP\/uLTOP\/uK\/GPU\/gpu\/i_hyd2_mp4_sys_ef\/i_hyd2_mp4_partition\/// ;
   #   $block_name = "hyd2_mp4_partition" ;
   # } elsif( $pin_name =~ /^A9C\/A9TEG\/uTOP\/uLTOP\/uK\/GPU\/gpu\// ) {
   #   $local_pin_name =~ s/^A9C\/A9TEG\/uTOP\/uLTOP\/uK\/GPU\/gpu\/// ;
   #   $block_name = "gpu" ;
   # }
    $block_name_by_pin_name{"$pin_name"} = $block_name ;
  }
  if( /^\s*max_capacitance\s+(\d+\.*\d*)\s*$/ ) {
    ( $max_capacitance ) =
      /^\s*max_capacitance\s+(\d+\.*\d*)\s*$/ ;
   # $max_capacitance = 999.999 if( $pin_name =~ /^[^\/]+$/ ) ;
   # $max_capacitance = 999.999 if( $pin_name =~ /^A9C\/A9TEG\/uK_[^\/]+\/PAD$/ ) ;
   # $max_capacitance = 999.999 if( $pin_name =~ /^D4727\/[^\/]+$/ ) ;
   # $max_capacitance = 999.999 if( $pin_name =~ /^A9C\/A9TEG\/uK_VPGM\/AY$/ ) ;
   # $max_capacitance = 999.999 if( $pin_name =~ /^A9C\/A9TEG\/uTOP\/uLTOP\/uFUSE\/TREDSFWRP\/efuse_ctrl\/ss32lp_efrom_lp_128_[0-7]\/FSOURCE$/ ) ;
   # $max_capacitance = 999.999 if( $pin_name =~ /^A9C\/cdram\/[^\/]+$/ ) ;
   # $max_capacitance = 999.999 if( $pin_name =~ /^A9C\/A9TEG\/uK_CDRAM\S+\/uxioCDRAMCA\/PAD$/ ) ;
   # $max_capacitance = 999.999 if( $pin_name =~ /^A9C\/A9TEG\/inst_[^\/]+\/VB0$/ ) ;
   # $max_capacitance = 999.999 if( $pin_name =~ /^A9C\/A9TEG\/inst_[^\/]+\/VB1$/ ) ;
   # $max_capacitance = 999.999 if( $pin_name =~ /^A9C\/A9TEG\/inst_[^\/]+\/RTO$/ ) ;
   # $max_capacitance = 999.999 if( $pin_name =~ /^A9C\/A9TEG\/inst_[^\/]+\/SNS$/ ) ;
#$max_capacitance = 999.999 if( $pin_name eq "icc_place1PLCOPT/Y" ) ;
#$max_capacitance = 999.999 if( $pin_name eq "icc_place2PLCOPT/Y" ) ;
#$max_capacitance = 999.999 if( $pin_name =~ /^A9C\/A9TEG\/B*Hfix\d+\/Y$/ ) ;
#$max_capacitance = 999.999 if( $pin_name =~ /^A9C\/A9TEG\/B*Lfix\d+\/Y$/ ) ;
#$max_capacitance = 999.999 if( $pin_name =~ /ALCHIP_TIEL_\d+/ ) ;
#$max_capacitance = 999.999 if( $pin_name =~ /ALCHIP_TIEH_\d+/ ) ;
#$max_capacitance = 999.999 if( $pin_name =~ /TIEHI_/ ) ;
#$max_capacitance = 999.999 if( $pin_name =~ /TIELO_/ ) ;
#$max_capacitance = 999.999 if( ( $block_name ne "IRYU" ) && ( $block_name ne "CHANNEL_ENGINE" ) ) ;

    #$original_tiehi_count++ if( $pin_name =~ /^A9C\/A9TEG\/B*Hfix\d+\/Y$/ ) ;
    #$original_tielo_count++ if( $pin_name =~ /^A9C\/A9TEG\/B*Lfix\d+\/Y$/ ) ;
    #$alchip_tiehi_count++ if( $pin_name =~ /ALCHIP_TIEH_/ ) ;
    #$alchip_tielo_count++ if( $pin_name =~ /ALCHIP_TIEL_/ ) ;
    #$icc_tiehi_count++ if( $pin_name =~ /TIEHI_/ ) ;
    #$icc_tielo_count++ if( $pin_name =~ /TIELO_/ ) ;
  }
  if( /^\s*-\s+Capacitance\s+(\d+\.*\d*)\s*$/ ) {
    ( $capacitance ) =
      /^\s*-\s+Capacitance\s+(\d+\.*\d*)\s*$/ ;
  }
  if( /^\s*Slack\s+(-*\d+\.*\d*)\s+\(([^\(\)]+)\)\s*$/ ) {
    ( $slack, $status ) =
      /^\s*Slack\s+(-*\d+\.*\d*)\s+\(([^\(\)]+)\)\s*$/ ;
    $slack = $max_capacitance - $capacitance ;
    if( $slack <= 0.000 ) {
      $capacitance_by_pin{$pin_name} = $capacitance ;
      $max_capacitance_by_pin{$pin_name} = $max_capacitance ;
      $slack_by_pin{$pin_name} = $slack ;
      $status_by_pin{$pin_name} = $status_by_pin ;
      $error_count_over_limit{$max_capacitance}++ ;
      $error_count_total++ ;
      $error_count_by_block_name{$block_name}++ ;
      if( $slack_by_local_pin_name{"$local_pin_name"} eq "" ) {
        $local_error_count_total++ ;
        $local_error_count_by_block_name{$block_name}++ ;
        $slack_by_local_pin_name{"$local_pin_name"} = $slack ;
      }

      if(    ( $slack <=  0.000 ) && ( $slack > -0.100 ) ) { $count_by_slack_range{"0.000-0.100"}++ }
      elsif( ( $slack <= -0.100 ) && ( $slack > -0.200 ) ) { $count_by_slack_range{"0.100-0.200"}++ }
      elsif( ( $slack <= -0.200 ) && ( $slack > -0.300 ) ) { $count_by_slack_range{"0.200-0.300"}++ }
      elsif( ( $slack <= -0.300 ) && ( $slack > -0.400 ) ) { $count_by_slack_range{"0.300-0.400"}++ }
      elsif( ( $slack <= -0.400 ) && ( $slack > -0.500 ) ) { $count_by_slack_range{"0.400-0.500"}++ }
      elsif( ( $slack <= -0.500 ) && ( $slack > -0.600 ) ) { $count_by_slack_range{"0.500-0.600"}++ }
      elsif( ( $slack <= -0.600 ) && ( $slack > -0.700 ) ) { $count_by_slack_range{"0.600-0.700"}++ }
      elsif( ( $slack <= -0.700 ) && ( $slack > -0.800 ) ) { $count_by_slack_range{"0.700-0.800"}++ }
      elsif( ( $slack <= -0.800 ) && ( $slack > -0.900 ) ) { $count_by_slack_range{"0.800-0.900"}++ }
      elsif( ( $slack <= -0.900 ) && ( $slack > -1.000 ) ) { $count_by_slack_range{"0.900-1.000"}++ }
      elsif( ( $slack <= -1.000 ) && ( $slack > -1.100 ) ) { $count_by_slack_range{"1.000-1.100"}++ }
      elsif( ( $slack <= -1.100 ) && ( $slack > -1.200 ) ) { $count_by_slack_range{"1.100-1.200"}++ }
      elsif( ( $slack <= -1.200 ) && ( $slack > -1.300 ) ) { $count_by_slack_range{"1.200-1.300"}++ }
      elsif( ( $slack <= -1.300 ) && ( $slack > -1.400 ) ) { $count_by_slack_range{"1.300-1.400"}++ }
      elsif( ( $slack <= -1.400 ) && ( $slack > -1.500 ) ) { $count_by_slack_range{"1.400-1.500"}++ }
      else                                                 { $count_by_slack_range{"1.500-"}++ }

      if(    ( $capacitance > 0.000 ) && ( $capacitance <= 0.100 ) ) { $count_by_capacitance_range{"0.000-0.100"}++ }
      elsif( ( $capacitance > 0.100 ) && ( $capacitance <= 0.200 ) ) { $count_by_capacitance_range{"0.100-0.200"}++ }
      elsif( ( $capacitance > 0.200 ) && ( $capacitance <= 0.300 ) ) { $count_by_capacitance_range{"0.200-0.300"}++ }
      elsif( ( $capacitance > 0.300 ) && ( $capacitance <= 0.400 ) ) { $count_by_capacitance_range{"0.300-0.400"}++ }
      elsif( ( $capacitance > 0.400 ) && ( $capacitance <= 0.500 ) ) { $count_by_capacitance_range{"0.400-0.500"}++ }
      elsif( ( $capacitance > 0.500 ) && ( $capacitance <= 0.600 ) ) { $count_by_capacitance_range{"0.500-0.600"}++ }
      elsif( ( $capacitance > 0.600 ) && ( $capacitance <= 0.700 ) ) { $count_by_capacitance_range{"0.600-0.700"}++ }
      elsif( ( $capacitance > 0.700 ) && ( $capacitance <= 0.800 ) ) { $count_by_capacitance_range{"0.700-0.800"}++ }
      elsif( ( $capacitance > 0.800 ) && ( $capacitance <= 0.900 ) ) { $count_by_capacitance_range{"0.800-0.900"}++ }
      elsif( ( $capacitance > 0.900 ) && ( $capacitance <= 1.000 ) ) { $count_by_capacitance_range{"0.900-1.000"}++ }
      elsif( ( $capacitance > 1.000 ) && ( $capacitance <= 1.100 ) ) { $count_by_capacitance_range{"1.000-1.100"}++ }
      elsif( ( $capacitance > 1.100 ) && ( $capacitance <= 1.200 ) ) { $count_by_capacitance_range{"1.100-1.200"}++ }
      elsif( ( $capacitance > 1.200 ) && ( $capacitance <= 1.300 ) ) { $count_by_capacitance_range{"1.200-1.300"}++ }
      elsif( ( $capacitance > 1.300 ) && ( $capacitance <= 1.400 ) ) { $count_by_capacitance_range{"1.300-1.400"}++ }
      elsif( ( $capacitance > 1.400 ) && ( $capacitance <= 1.500 ) ) { $count_by_capacitance_range{"1.400-1.500"}++ }
      else                                                           { $count_by_capacitance_range{"1.500-"}++ }
    }
  }
}

printf( "       slack  max_capacitance  capacitance  pin\n" ) ;
printf( "  ----------  ---------------  -----------  ----------\n" ) ;
foreach $pin_name ( sort( { $slack_by_pin{$a} <=> $slack_by_pin{$b} } keys( %slack_by_pin ) ) ) {
  printf( "  %10.3f  %15.3f  %11.3f  %s \(%s\)\n", $slack_by_pin{$pin_name}, $max_capacitance_by_pin{$pin_name}, $capacitance_by_pin{$pin_name}, $pin_name, $block_name_by_pin_name{"$pin_name"}  ) ;
}
printf( "\n" ) ;

printf( "  Summary\n" ) ;
printf( "  -------\n" ) ;
foreach $max_capacitance ( sort( keys( %error_count_over_limit ) ) ) {
  printf( "  Capacitance error count over %5.3f = %10d\n", $max_capacitance, $error_count_over_limit{$max_capacitance} ) ;
}
printf( "  Total capacitance error            = %10d\n", $error_count_total ) ;
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
printf( "  %-25s = %10d \(%10d\)\n", "Total", $error_count_total, $error_count_total ) ;
printf( "\n" ) ;

#printf( "  A9C/A9TEG/Hfix* : %10d\n", $original_tiehi_count ) ;
#printf( "  A9C/A9TEG/Lfix* : %10d\n", $original_tielo_count ) ;
#printf( "  TIEHI_*         : %10d\n", $icc_tiehi_count ) ;
#printf( "  TIELO_*         : %10d\n", $icc_tielo_count ) ;
#printf( "  ALCHIP_TIEH_*   : %10d\n", $alchip_tiehi_count ) ;
#printf( "  ALCHIP_TIEL_*   : %10d\n", $alchip_tielo_count ) ;
#printf( "  Total           : %10d\n", $original_tiehi_count + $original_tielo_count + $icc_tiehi_count + $icc_tielo_count + $alchip_tiehi_count + $alchip_tielo_count ) ;
#printf( "\n" ) ;

printf( "  Slack range        Count\n" ) ;
printf( "  -----------------  -----\n" ) ;
printf( "  %6.3f < %6.3f    %5d\n",  0.000, -0.100, $count_by_slack_range{"0.000-0.100"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", -0.100, -0.200, $count_by_slack_range{"0.100-0.200"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", -0.200, -0.300, $count_by_slack_range{"0.200-0.300"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", -0.300, -0.400, $count_by_slack_range{"0.300-0.400"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", -0.400, -0.500, $count_by_slack_range{"0.400-0.500"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", -0.500, -0.600, $count_by_slack_range{"0.500-0.600"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", -0.600, -0.700, $count_by_slack_range{"0.600-0.700"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", -0.700, -0.800, $count_by_slack_range{"0.700-0.800"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", -0.800, -0.900, $count_by_slack_range{"0.800-0.900"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", -0.900, -1.000, $count_by_slack_range{"0.900-1.000"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", -1.000, -1.100, $count_by_slack_range{"1.000-1.100"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", -1.100, -1.200, $count_by_slack_range{"1.100-1.200"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", -1.200, -1.300, $count_by_slack_range{"1.200-1.300"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", -1.300, -1.400, $count_by_slack_range{"1.300-1.400"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", -1.400, -1.500, $count_by_slack_range{"1.400-1.500"} ) ;
printf( "  %6.3f <           %5d\n", -1.500,         $count_by_slack_range{"1.500-"} ) ;
printf( "  -----------------  -----\n" ) ;
printf( "  Total              %5d\n", $error_count_total ) ;
printf( "\n" ) ;

printf( "  Capacitance range  Count\n" ) ;
printf( "  -----------------  -----\n" ) ;
printf( "  %6.3f < %6.3f    %5d\n", 0.000, 0.100, $count_by_capacitance_range{"0.000-0.100"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", 0.100, 0.200, $count_by_capacitance_range{"0.100-0.200"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", 0.200, 0.300, $count_by_capacitance_range{"0.200-0.300"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", 0.300, 0.400, $count_by_capacitance_range{"0.300-0.400"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", 0.400, 0.500, $count_by_capacitance_range{"0.400-0.500"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", 0.500, 0.600, $count_by_capacitance_range{"0.500-0.600"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", 0.600, 0.700, $count_by_capacitance_range{"0.600-0.700"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", 0.700, 0.800, $count_by_capacitance_range{"0.700-0.800"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", 0.800, 0.900, $count_by_capacitance_range{"0.800-0.900"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", 0.900, 1.000, $count_by_capacitance_range{"0.900-1.000"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", 1.000, 1.100, $count_by_capacitance_range{"1.000-1.100"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", 1.100, 1.200, $count_by_capacitance_range{"1.100-1.200"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", 1.200, 1.300, $count_by_capacitance_range{"1.200-1.300"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", 1.300, 1.400, $count_by_capacitance_range{"1.300-1.400"} ) ;
printf( "  %6.3f < %6.3f    %5d\n", 1.400, 1.500, $count_by_capacitance_range{"1.400-1.500"} ) ;
printf( "  %6.3f <           %5d\n", 1.500,        $count_by_capacitance_range{"1.500-"} ) ;
printf( "  -----------------  -----\n" ) ;
printf( "  Total              %5d\n", $error_count_total ) ;
printf( "\n" ) ;

