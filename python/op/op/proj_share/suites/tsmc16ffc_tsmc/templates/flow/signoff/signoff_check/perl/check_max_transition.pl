#!/usr/bin/perl

  ##################################################################################
  # PROGRAM:     check_max_transition.pl
  # CREATOR:     Marshal Su <marshals@alchip.com>
  # DESCRIPTION: Check PT max transition violations
  # USAGE:       check_max_transition.pl report_constraint.max_transition.rep \
  #             	 > report_constraint.max_transition.rep.summary
  # INFORMATION: Initial version from Alchip Design Platform Group
  # DATE:        March 16 2007
  ###################################################################################
$default_max_transition = 0.300 ;

while( <> ) {
  if( /^\s*(Pin|Net):\s*(\S+)/ ) {
    ( $null, $pin_name ) =
      /^\s*(Pin|Net):\s*(\S+)/ ;
    $block_name = "TOP" ;
    $local_pin_name = $pin_name ;
    $block_name_by_pin_name{"$pin_name"} = $block_name ;
  }
  if( /^\s*max_transition\s+(\d+\.*\d*)\s*$/ ) {
    ( $max_transition ) =
      /^\s*max_transition\s+(\d+\.*\d*)\s*$/ ;
    $max_transition = $default_max_transition if( $max_transition == 0.000 ) ;
    $max_transition = $default_max_transition if( $max_transition == 0.750 ) ;
    #$max_transition = 999.999 if( $pin_name =~ /^[^\/]+$/ ) ;
    #$max_transition = 999.999 if( $pin_name =~ /^[^\/]+$/ ) ;
  }
  if( /^\s*-\s+Transition Time\s+(\d+\.*\d*)\s*$/ ) {
    ( $transition ) =
      /^\s*-\s+Transition Time\s+(\d+\.*\d*)\s*$/ ;
  }
  if( /^\s*Slack\s+(-*\d+\.*\d*)\s+\(([^\(\)]+)\)\s*$/ ) {
    ( $slack, $status ) =
      /^\s*Slack\s+(-*\d+\.*\d*)\s+\(([^\(\)]+)\)\s*$/ ;
    $slack = $max_transition - $transition ;
    if( $slack <= 0.000 ) {
      $transition_by_pin{$pin_name} = $transition ;
      $max_transition_by_pin{$pin_name} = $max_transition ;
      $slack_by_pin{$pin_name} = $slack ;
      $status_by_pin{$pin_name} = $status_by_pin ;
      $error_count_over_limit{$max_transition}++ ;
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

      if(    ( $transition > 0.000 ) && ( $transition <= 0.100 ) ) { $count_by_transition_range{"0.000-0.100"}++ }
      elsif( ( $transition > 0.100 ) && ( $transition <= 0.200 ) ) { $count_by_transition_range{"0.100-0.200"}++ }
      elsif( ( $transition > 0.200 ) && ( $transition <= 0.300 ) ) { $count_by_transition_range{"0.200-0.300"}++ }
      elsif( ( $transition > 0.300 ) && ( $transition <= 0.400 ) ) { $count_by_transition_range{"0.300-0.400"}++ }
      elsif( ( $transition > 0.400 ) && ( $transition <= 0.500 ) ) { $count_by_transition_range{"0.400-0.500"}++ }
      elsif( ( $transition > 0.500 ) && ( $transition <= 0.600 ) ) { $count_by_transition_range{"0.500-0.600"}++ }
      elsif( ( $transition > 0.600 ) && ( $transition <= 0.700 ) ) { $count_by_transition_range{"0.600-0.700"}++ }
      elsif( ( $transition > 0.700 ) && ( $transition <= 0.800 ) ) { $count_by_transition_range{"0.700-0.800"}++ }
      elsif( ( $transition > 0.800 ) && ( $transition <= 0.900 ) ) { $count_by_transition_range{"0.800-0.900"}++ }
      elsif( ( $transition > 0.900 ) && ( $transition <= 1.000 ) ) { $count_by_transition_range{"0.900-1.000"}++ }
      elsif( ( $transition > 1.000 ) && ( $transition <= 1.100 ) ) { $count_by_transition_range{"1.000-1.100"}++ }
      elsif( ( $transition > 1.100 ) && ( $transition <= 1.200 ) ) { $count_by_transition_range{"1.100-1.200"}++ }
      elsif( ( $transition > 1.200 ) && ( $transition <= 1.300 ) ) { $count_by_transition_range{"1.200-1.300"}++ }
      elsif( ( $transition > 1.300 ) && ( $transition <= 1.400 ) ) { $count_by_transition_range{"1.300-1.400"}++ }
      elsif( ( $transition > 1.400 ) && ( $transition <= 1.500 ) ) { $count_by_transition_range{"1.400-1.500"}++ }
      else                                                         { $count_by_transition_range{"1.500-"}++ }
    }
  }
}

#print summary
printf( "  Max transition Summary\n" ) ;
printf( "  ----------------------\n" ) ;
foreach $max_transition ( sort( keys( %error_count_over_limit ) ) ) {
  printf( "  Transition error count over %5.3f = %10d\n", $max_transition, $error_count_over_limit{$max_transition} ) ;
}
printf( "  Total transition error            = %10d\n", $error_count_total ) ;
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
#@block_names = qw(
#CLKRST_clkrst_ck_core_0
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
printf( "  %6.3f < %6.3f   %5d\n",  0.000, -0.100, $count_by_slack_range{"0.000-0.100"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", -0.100, -0.200, $count_by_slack_range{"0.100-0.200"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", -0.200, -0.300, $count_by_slack_range{"0.200-0.300"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", -0.300, -0.400, $count_by_slack_range{"0.300-0.400"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", -0.400, -0.500, $count_by_slack_range{"0.400-0.500"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", -0.500, -0.600, $count_by_slack_range{"0.500-0.600"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", -0.600, -0.700, $count_by_slack_range{"0.600-0.700"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", -0.700, -0.800, $count_by_slack_range{"0.700-0.800"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", -0.800, -0.900, $count_by_slack_range{"0.800-0.900"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", -0.900, -1.000, $count_by_slack_range{"0.900-1.000"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", -1.000, -1.100, $count_by_slack_range{"1.000-1.100"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", -1.100, -1.200, $count_by_slack_range{"1.100-1.200"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", -1.200, -1.300, $count_by_slack_range{"1.200-1.300"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", -1.300, -1.400, $count_by_slack_range{"1.300-1.400"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", -1.400, -1.500, $count_by_slack_range{"1.400-1.500"} ) ;
printf( "  %6.3f <          %5d\n", -1.500,         $count_by_slack_range{"1.500-"} ) ;
printf( "  ----------------  -----\n" ) ;
printf( "  Total             %5d\n", $error_count_total ) ;
printf( "\n" ) ;

printf( "  Transition range  Count\n" ) ;
printf( "  ----------------  -----\n" ) ;
printf( "  %6.3f < %6.3f   %5d\n", 0.000, 0.100, $count_by_transition_range{"0.000-0.100"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", 0.100, 0.200, $count_by_transition_range{"0.100-0.200"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", 0.200, 0.300, $count_by_transition_range{"0.200-0.300"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", 0.300, 0.400, $count_by_transition_range{"0.300-0.400"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", 0.400, 0.500, $count_by_transition_range{"0.400-0.500"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", 0.500, 0.600, $count_by_transition_range{"0.500-0.600"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", 0.600, 0.700, $count_by_transition_range{"0.600-0.700"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", 0.700, 0.800, $count_by_transition_range{"0.700-0.800"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", 0.800, 0.900, $count_by_transition_range{"0.800-0.900"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", 0.900, 1.000, $count_by_transition_range{"0.900-1.000"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", 1.000, 1.100, $count_by_transition_range{"1.000-1.100"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", 1.100, 1.200, $count_by_transition_range{"1.100-1.200"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", 1.200, 1.300, $count_by_transition_range{"1.200-1.300"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", 1.300, 1.400, $count_by_transition_range{"1.300-1.400"} ) ;
printf( "  %6.3f < %6.3f   %5d\n", 1.400, 1.500, $count_by_transition_range{"1.400-1.500"} ) ;
printf( "  %6.3f <          %5d\n", 1.500,        $count_by_transition_range{"1.500-"} ) ;
printf( "  ----------------  -----\n" ) ;
printf( "  Total             %5d\n", $error_count_total ) ;
printf( "\n" ) ;

#print detail report
printf( "       slack  max_transition  transition  pin\n" ) ;
printf( "  ----------  --------------  ----------  ----------\n" ) ;
foreach $pin_name ( sort( { $slack_by_pin{$a} <=> $slack_by_pin{$b} } keys( %slack_by_pin ) ) ) {
  printf( "  %10.3f  %14.3f  %10.3f  %s \(%s\)\n", $slack_by_pin{$pin_name}, $max_transition_by_pin{$pin_name}, $transition_by_pin{$pin_name}, $pin_name, $block_name_by_pin_name{"$pin_name"} ) ;
}
printf( "\n" ) ;

