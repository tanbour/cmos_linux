#!/usr/bin/perl
##################################################################################
# PROGRAM:     check_clock_timing_summary.pl
# CREATOR:     Zachary Shi <zacharys@alchip.com>
# DESCRIPTION: Check clock latency summary
# USAGE:       check_clock_timing_summary.pl clock_timing.latency.rep >
#				clock_timing.latency.rep.summary
# INFORMATION: Initial version from Alchip Design Platform Group
# DATE:        Fri Jun 30 15:21:41 CST 2017
###################################################################################

#$min_latency_limit = 1.000 ;
#$max_latency_limit = 2.000 ;
$index = 0 ;

while( <> ) {
  if( /\s+Clock:\s+(\S+)\s*$/ ) {
    ( $clock_name ) = /\s+Clock:\s+(\S+)\s*$/ ;
    printf( "\n" ) ;
    printf( " -------------------------------------------------------------------------------------- \n" ) ;
    printf( " %s (%s)\n", $clock_name, $clock_name ) ;
    printf( "\n" ) ;

    $index++ ;
    $clock_name = "$clock_name:$index" ;
    $source_name = $clock_name ;
    $source_names{$clock_name} = $source_names{$clock_name} . " " . $source_name ;
    $source_names{$clock_name} =~ s/^\s+// ;
    $key = "$clock_name:$source_name" ;
    $min_latency{$key} =  999.999 ;
    $max_latency{$key} = -999.999 ;
  }

  $flag = 0 ;
  if( /^\s+(\S+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(rp.*)/ ) {
    ( $pin_name, $dummy1, $dummy2, $dummy3, $latency ) = /^\s+(\S+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(rp.*)/ ;
    $flag = 1 ;
  }
  if( /^\s+(\S+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(fp.*)/ ) {
    ( $pin_name, $dummy1, $dummy2, $dummy3, $latency ) = /^\s+(\S+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(fp.*)/ ;
    $flag = 1 ;
  }

  if( $flag ) {
    if( $latency > $max_latency{$key} ) {
      $max_latency{$key} = $latency ;
#      $max_latency_pin_name{$key} = $pin_name ;
    }
    if( $latency < $min_latency{$key} ) {
      $min_latency{$key} = $latency ;
#      $min_latency_pin_name{$key} = $pin_name ;
    }
#    if( $lantecy > $max_latency_limit ) {
      printf( " %.3f %s\n", $latency, $pin_name ) ;
#    }
#    if( $lantecy < $min_latency_limit ) {
#      printf( " %.3f %s\n", $latency, $pin_name ) ;
#    }
#    $count_by_clock_name{$clock_name}++ ;
    $count_by_source_name{$key}++ ;
  }
}

printf( " +--------------------------------------------------------------------------+ \n" ) ;
printf( " | clock                |    # of ff |        min |        max |       skew | \n" ) ;
printf( " |----------------------+------------+------------+------------+------------| \n" ) ;
foreach $clock_name ( sort( keys( %source_names ) ) ) {
  foreach $source_name ( split( /\s+/, $source_names{$clock_name} ) ) {
    $key = "$clock_name:$source_name" ;
    $skew{$key} = $max_latency{$key} - $min_latency{$key} ;
    if( $skew{$key} >= 0 ) {
      @clock_name = split( /:/, $clock_name ) ;
      printf( " | %-20s | %10d | %10.3f | %10.3f | %10.3f | \n",
        $clock_name[0], $count_by_source_name{$key},
        $min_latency{$key}, $max_latency{$key}, $skew{$key} ) ;
    }      
  }
}
printf( " +--------------------------------------------------------------------------+ \n" ) ;

