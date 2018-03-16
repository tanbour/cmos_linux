#!/usr/bin/perl

$root_dir = shift ;
$root_dir = $ENV{PWD} if( $root_dir eq "" ) ;

@mode_list = qw(
normal
maxdelay
mbist
scan_shift
scan_capture
) ;

@files = sort( split( /\s+/, `find $root_dir/ -name "tm_*.rpt.summary"` ) ) ;

foreach $file ( @files ) {
 #( $mode, $corner, $min_max ) = $file =~ /\/(\w+)-mode\/(\w+)\/AOCVM_FINAL\/rpt_final\/tm_(min|max)\.rpt\.summary/ ;
  ( $mode, $corner) = $file =~ /\/(\w+)-mode\/(\w+)\// ;
  ( $min_max ) = $file =~ /tm_(min|max)\.rpt\.summary/ ;

  $cross_voltage_corner = 1 if( $corner =~ /LH/ ) ;
  $cross_voltage_corner = 1 if( $corner =~ /HL/ ) ;

          $is_available{"$mode:$corner:$min_max"} = 1 ;
  $number_of_violations{"$mode:$corner:$min_max"} = 0 ;
           $worst_slack{"$mode:$corner:$min_max"} = "" ;
  $total_negative_slack{"$mode:$corner:$min_max"} = 0 ;

  open( FILE, "< $file" ) ;
  while( <FILE> ) {
    if( /^\s+(\S+)\s+(-*\d+\.*\d*)\s+\((\d+)\)\s+/ ) {
      ( $endpoint, $slack, $stage_count ) =
        /^\s+(\S+)\s+(-*\d+\.*\d*)\s+\((\d+)\)\s+/ ;
      $number_of_violations{"$mode:$corner:$min_max"}++ ;
               $worst_slack{"$mode:$corner:$min_max"} = $slack if( $worst_slack{"$mode:$corner:$min_max"} eq "" ) ;
               $worst_slack{"$mode:$corner:$min_max"} = $slack if( $worst_slack{"$mode:$corner:$min_max"} > $slack ) ;
      $total_negative_slack{"$mode:$corner:$min_max"} =   $total_negative_slack{"$mode:$corner:$min_max"} - $slack ;
    }
  }
  close( FILE ) ;

  next if( ( $mode eq "maxdelay" ) && ( $min_max eq "min" ) ) ;

  printf( "%s : %d / %.3f / %.3f\n", $file, $number_of_violations{"$mode:$corner:$min_max"}, $worst_slack{"$mode:$corner:$min_max"}, $total_negative_slack{"$mode:$corner:$min_max"} ) ;
}

if( $cross_voltage_corner == 1 ) {
@corner_list = qw(
wcl_cworst_m25c_max
wcl_rcbest_m25c_max
wc_cworst_125c_max
ml_cbest_125c_min
ml_rcworst_125c_min
lt_cbest_m25c_min
wclLH_cworst_m25c_max
wclHL_cworst_m25c_max
wclLH_rcbest_m25c_max
wclHL_rcbest_m25c_max
wcLH_cworst_125c_max
wcHL_cworst_125c_max
mlLH_cbest_125c_min
mlHL_cbest_125c_min
mlLH_rcworst_125c_min
mlHL_rcworst_125c_min
ltLH_cbest_m25c_min
ltHL_cbest_m25c_min
) ;
} else {
@corner_list = qw(
wcl_cworst_m25c_max
wcl_rcbest_m25c_max
wc_cworst_125c_max
ml_cbest_125c_min
ml_rcworst_125c_min
lt_cbest_m25c_min
) ;
}

printf( "%s/report/176_pt_sta_ss28lpp/*-mode/*/AOCVM_FINAL/rpt_final/tm_m*.rpt.summary\n", $root_dir ) ;

print << "EOL" ;
+------------------------------------------------------------------------------------------------------------------------+
| mode         | corner                | setup                                  |  hold                                  |
|              |                       |----------------------------------------+----------------------------------------|
|              |                       | #           | WNS        | TNS         |#            | WNS        | TNS         |
EOL

foreach $mode ( @mode_list ) {
  if( $mode ne $last_mode ) {
print << "EOL" ;
|--------------+-----------------------+-------------+------------+-------------+-------------+------------+-------------|
EOL
  }
  foreach $corner ( @corner_list ) {
   #$is_available{"$mode:$corner:$min_max"} = 0 if( ( $mode eq "maxdelay" ) && ( $min_max eq "min" ) ) ;
    $is_available{"maxdelay:$corner:min"} = 0 ;

    next if( ( $mode ne "normal" ) && ( ( $corner =~ /HL/ ) || ( $corner =~ /LH/ ) ) ) ;

    if( $corner eq "wclLH_cworst_m25c_max" ) {
print << "EOL" ;
|--------------+-----------------------+-------------+------------+-------------+-------------+------------+-------------|
EOL
    }

    printf( "| %-12s | %-21s |", $mode, $corner ) ;
    if( $is_available{"$mode:$corner:max"} == 0 ) {
      printf( "  %10s | %10s | %11s |", "", "", "" ) ;
    } else {
      printf( "  %10d | %10.3f | %11.3f |", $number_of_violations{"$mode:$corner:max"}, $worst_slack{"$mode:$corner:max"}, $total_negative_slack{"$mode:$corner:max"} ) ;
    }
    if( $is_available{"$mode:$corner:min"} == 0 ) {
      printf( "  %10s | %10s | %11s |", "", "", "" ) ;
    } else {
      printf( "  %10d | %10.3f | %11.3f |", $number_of_violations{"$mode:$corner:min"}, $worst_slack{"$mode:$corner:min"}, $total_negative_slack{"$mode:$corner:min"} ) ;
    }
    printf( "\n" ) ;
  }
  $last_mode = $mode ;
}

print << "EOL" ;
+------------------------------------------------------------------------------------------------------------------------+
EOL

