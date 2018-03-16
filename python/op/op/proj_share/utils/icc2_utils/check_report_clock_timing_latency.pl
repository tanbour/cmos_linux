#!/usr/bin/perl

$min_latency_limit = 10.000 ;
$max_latency_limit = 0.000 ;

while( <> ) {
	if( /\s+-clock\s+(\S+)\s+-from\s+(\S+)\s*$/ ) {
		( $clock_name, $source_name ) = /\s+-clock\s+(\S+)\s+-from\s+(\S+)\s*$/ ;
		$min_latency{$clock_name} =  999.999 ;
		$max_latency{$clock_name} = -999.999 ;
		$clock_names = $clock_names . " " . $clock_name ;
		$clock_source_name{$clock_name} = $source_name ;
		printf( " -------------------------------------------------------------------------------------- \n" ) ;
		printf( " %s (%s)\n", $source_name, $clock_name ) ;
		printf( "\n" ) ;
	}
	if( /^\s+(\S+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(rp-\+)|(rpi-\+)|(wrpi-\+)|(wrp-\+)/ ) {
		( $pin_name, $dummy1, $dummy2, $dummy3, $latency ) = /^\s+(\S+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+/ ;
		if( $latency > $max_latency{$clock_name} ) {
			$max_latency{$clock_name} = $latency ;
		}
		if( $latency < $min_latency{$clock_name} ) {
			$min_latency{$clock_name} = $latency ;
		} 
		if( $latency > $max_latency_limit ) {
			printf( " %.3f %s\n", $latency, $pin_name ) ;
		}elsif( $latency < $min_latency_limit ) {
			printf( " %.3f %s\n", $latency, $pin_name ) ;
		}
		$latency_list{$clock_name} = $latency_list{$clock_name} . " " . $latency;
		$count_by_clock_name{$clock_name}++ ;
		$total_latency{$clock_name} = $total_latency{$clock_name} + $latency;
	}
}

$clock_names =~ s/^\s+// ;
foreach $clock_name ( split( /\s+/, $clock_names)) {
	if ($latency_list{$clock_name} eq "") { next ; }
	$latency_list{$clock_name} =~ s/^\s+// ;
	$average_latency{$clock_name} =  $total_latency{$clock_name}/$count_by_clock_name{$clock_name};
	$skew{$clock_name} = $max_latency{$clock_name} - $min_latency{$clock_name} ;
	
	@num_l = "";
	@num_u = "";
	foreach $latency (split( /\s+/, $latency_list{$clock_name})) {
		if ($latency >= ($average_latency{$clock_name} + 0.000) && $latency < ($average_latency{$clock_name} + 0.050)) { $num_u[0] ++ ; }
		elsif ($latency >= ($average_latency{$clock_name} + 0.050) && $latency < ($average_latency{$clock_name} + 0.100)) { $num_u[1] ++ ; }
		elsif ($latency >= ($average_latency{$clock_name} + 0.100) && $latency < ($average_latency{$clock_name} + 0.150)) { $num_u[2] ++ ; }
		elsif ($latency >= ($average_latency{$clock_name} + 0.150) && $latency < ($average_latency{$clock_name} + 0.200)) { $num_u[3] ++ ; }
		elsif ($latency >= ($average_latency{$clock_name} + 0.200) && $latency <= ($max_latency{$clock_name} )) { $num_u[4] ++ ; }
		elsif ($latency < ($average_latency{$clock_name} - 0.000) && $latency >= ($average_latency{$clock_name} - 0.050)) { $num_l[0] ++ ; }
		elsif ($latency < ($average_latency{$clock_name} - 0.050) && $latency >= ($average_latency{$clock_name} - 0.100)) { $num_l[1] ++ ; }
		elsif ($latency < ($average_latency{$clock_name} - 0.100) && $latency >= ($average_latency{$clock_name} - 0.150)) { $num_l[2] ++ ; }
		elsif ($latency < ($average_latency{$clock_name} - 0.150) && $latency >= ($average_latency{$clock_name} - 0.200)) { $num_l[3] ++ ; }
		else  { $num_l[4] ++ ; }
	}
      
	printf( "\n +--------------------------------------------------------------------------------------------------------------------------------------------+ \n" ) ;
	printf( " | Clock Name                           | Source Point                                                                                        | \n" ) ;
	printf( " |--------------------------------------------------------------------------------------------------------------------------------------------| \n" ) ;
	printf( " | %-36s | %-100s|\n", $clock_name, $clock_source_name{$clock_name}) ;
	printf( " |--------------------------------------------------------------------------------------------------------------------------------------------| \n" ) ;
	printf( " |    #Endpoints |     Min |     Max |    Skew | Average | \n" ) ;
	printf( " |---------------|---------|---------|---------|---------| \n" ) ;
	printf( " |    %10d | %7.3f | %7.3f | %7.3f | %7.3f | \n", $count_by_clock_name{$clock_name},$min_latency{$clock_name}, $max_latency{$clock_name}, $skew{$clock_name},$average_latency{$clock_name} ) ;
	printf( " |-------------------------------------------------------| \n" ) ;
	printf( " | Latency Range                           # Endpoints   | \n" ) ;
	printf( " |-------------------------------------------------------| \n" ) ;
	if ( $num_l[4] ) { printf( " | Min   -> -200p ( >= %7.3f <  %7.3f ) : %-10d | \n",$min_latency{$clock_name} , ($average_latency{$clock_name} - 0.200), $num_l[4] ) }
	if ( $num_l[3] ) { printf( " | -200p -> -150p ( >= %7.3f <  %7.3f ) : %-10d | \n",($average_latency{$clock_name} - 0.200), ($average_latency{$clock_name} - 0.150), $num_l[3] ) }
	if ( $num_l[2] ) { printf( " | -150p -> -100p ( >= %7.3f <  %7.3f ) : %-10d | \n",($average_latency{$clock_name} - 0.150), ($average_latency{$clock_name} - 0.100), $num_l[2] ) }
	if ( $num_l[1] ) { printf( " | -100p -> -050p ( >= %7.3f <  %7.3f ) : %-10d | \n",($average_latency{$clock_name} - 0.100), ($average_latency{$clock_name} - 0.050), $num_l[1] ) }
	if ( $num_l[0] ) { printf( " | -050p ->  Ave  ( >= %7.3f <  %7.3f ) : %-10d | \n",($average_latency{$clock_name} - 0.050), $average_latency{$clock_name} , $num_l[0] ) }
	if ( $num_u[0] ) { printf( " |  Ave  -> +050p ( >= %7.3f <  %7.3f ) : %-10d | \n",$average_latency{$clock_name} , ($average_latency{$clock_name} + 0.050), $num_u[0] ) }
	if ( $num_u[1] ) { printf( " | +050p -> +100p ( >= %7.3f <  %7.3f ) : %-10d | \n",($average_latency{$clock_name} + 0.050), ($average_latency{$clock_name} + 0.100), $num_u[1] ) }
	if ( $num_u[2] ) { printf( " | +100p -> +150p ( >= %7.3f <  %7.3f ) : %-10d | \n",($average_latency{$clock_name} + 0.100), ($average_latency{$clock_name} + 0.150), $num_u[2] ) }
	if ( $num_u[3] ) { printf( " | +150p -> +200p ( >= %7.3f <  %7.3f ) : %-10d | \n",($average_latency{$clock_name} + 0.150), ($average_latency{$clock_name} + 0.200), $num_u[3] ) }
	if ( $num_u[4] ) { printf( " | +200p -> Max   ( >= %7.3f <= %7.3f ) : %-10d | \n",($average_latency{$clock_name} + 0.200), $max_latency{$clock_name} , $num_u[4] ) }
	printf( " +-------------------------------------------------------+ \n\n" ) ;
}

printf( " +--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+ \n" ) ;
printf( " | clock  Name                          | source  Point                                                                                        | #Endpoints |     Min |     Max |    Skew | Average |\n" ) ;
printf( " |--------------------------------------+------------------------------------------------------------------------------------------------------+------------+---------+---------+---------+---------| \n" ) ;
foreach $clock_name (split( /\s+/, $clock_names)) {
	if ($latency_list{$clock_name} eq "") { next ; }
	printf( " | %-36s | %-100s | %10d | %7.3f | %7.3f | %7.3f | %7.3f | \n",
		$clock_name,  $clock_source_name{$clock_name}, $count_by_clock_name{$clock_name},
		$min_latency{$clock_name}, $max_latency{$clock_name}, $skew{$clock_name}, $average_latency{$clock_name} ) ;
}
printf( " +--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+ \n" ) ;

