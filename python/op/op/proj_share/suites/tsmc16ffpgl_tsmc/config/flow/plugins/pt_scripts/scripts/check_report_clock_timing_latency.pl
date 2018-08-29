#!/usr/bin/perl

$min_latency_limit = 1.000 ;
$max_latency_limit = 2.000 ;

while( <> ) {
  if( /\s+-clock\s+(\S+)\s+-from\s+(\S+)\s*$/ ) {
    ( $clock_name, $source_name ) = /\s+-clock\s+(\S+)\s+-from\s+(\S+)\s*$/ ;
    $min_latency{$source_name} =  999.999 ;
    $max_latency{$source_name} = -999.999 ;
    $source_names{$clock_name} = $source_names{$clock_name} . " " . $source_name ;
    $source_names{$clock_name} =~ s/^\s+// ;
    printf( "\n" ) ;
    printf( " -------------------------------------------------------------------------------------- \n" ) ;
    printf( " %s (%s)\n", $source_name, $clock_name ) ;
    printf( "\n" ) ;
  }
  if( /^\s+(\S+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(rp-\+)/ ) {
    ( $pin_name, $dummy1, $dummy2, $dummy3, $latency ) = /^\s+(\S+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(rp-\+)/ ;
    if( $latency > $max_latency{$source_name} ) {
      $max_latency{$source_name} = $latency ;
      $max_latency_pin_name{$source_name} = $pin_name ;
    }
    if( $latency < $min_latency{$source_name} ) {
      $min_latency{$source_name} = $latency ;
      $min_latency_pin_name{$source_name} = $pin_name ;
    }
    if( $lantecy > $max_latency_limit ) {
      printf( " %.3f %s\n", $latency, $pin_name ) ;
    }
    if( $lantecy < $min_latency_limit ) {
      printf( " %.3f %s\n", $latency, $pin_name ) ;
    }
    $count_by_clock_name{$clock_name}++ ;
    $count_by_source_name{$source_name}++ ;
  }
}

printf( " +-------------------------------------------------------------------------------------------------+ \n" ) ;
printf( " | clock                | source               |    # of ff |        min |        max |       skew | \n" ) ;
printf( " |----------------------+----------------------+------------+------------+------------+------------| \n" ) ;
foreach $clock_name ( sort( keys( %source_names ) ) ) {
  foreach $source_name ( split( /\s+/, $source_names{$clock_name} ) ) {
    $skew{$source_name} = $max_latency{$source_name} - $min_latency{$source_name} ;
    if( $skew{$source_name} > 0 ) {
      printf( " | %-20s | %-20s | %10d | %10.3f | %10.3f | %10.3f | \n",
        $clock_name, $source_name, $count_by_source_name{$source_name},
        $min_latency{$source_name}, $max_latency{$source_name}, $skew{$source_name} ) ;
    }      
  }
}
printf( " +-------------------------------------------------------------------------------------------------+ \n" ) ;

