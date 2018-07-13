#!/usr/bin/perl
##################################################################################
# PROGRAM:     check_sta_result_summary.pl
# CREATOR:     Zachary Shi <zacharys@alchip.com>
# DESCRIPTION: Check STA result summary
# USAGE:       check_sta_result_summary.pl .
# USAGE:       check_sta_result_summary.pl <PT STA directory>
# INFORMATION: Initial version from Alchip Design Platform Group
# DATE:        Tue Jun 27 12:54:19 CST 2017
###################################################################################

$root_dir = shift ;
$root_dir = $ENV{PWD} if( $root_dir eq "" ) ;

@mode_list = qw(
  func
  mbist
  shift 
  ac_capture
  dc_capture
  ip
) ;

@corner_list = qw(
   wcl.cworst_t_m40c
   wcl.rcworst_t_m40c
   wc.cworst_t_125c
   wc.rcworst_t_125c
   wcl.cworst_m40c
   wcl.rcworst_m40c
   wc.cworst_125c
   wc.rcworst_125c
   ml.cworst_125c
   ml.rcworst_125c
   ml.cbest_125c
   ml.rcbest_125c
   lt.cworst_m40c
   lt.rcworst_m40c
   lt.cbest_m40c
   lt.rcbest_m40c
   ltz.cworst_0c
   ltz.rcworst_0c
   ltz.cbest_0c
   ltz.rcbest_0c
) ;

@files = sort( split( /\s+/, `find $root_dir/ -name "*w_io.rep.summary"` ) ) ;

foreach $file ( @files ) {
  ( $mode , $corner, $min_max ) = $file =~ /\/(\w+)\.(\w+\.\w+)\.(\w+)\/timing\.\w+\.\w+\.\w+\.\w+\.w_io.rep.summary/ ;

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

  printf( "%s : %d / %.3f / %.3f\n", $file, $number_of_violations{"$mode:$corner:$min_max"}, $worst_slack{"$mode:$corner:$min_max"}, $total_negative_slack{"$mode:$corner:$min_max"} ) ;
}


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

