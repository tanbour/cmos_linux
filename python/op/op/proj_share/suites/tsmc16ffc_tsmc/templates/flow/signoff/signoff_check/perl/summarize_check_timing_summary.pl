#!/usr/bin/perl

my $type = shift;

#report_timing.wcl_cworst_m40c.max.rep.summary

$lib_cond_list = "wc wcz wcv wczv ml bc ml1 ml2 bc1 bc2" ;
@lib_cond_list = split( /[\s\n]+/, $lib_cond_list ) ;

$rc_cond_list = "cworst_115c cworst_0c rcworst_115c rcworst_0c cbest_0c rcbest_0c cbest_115c rcbest_115c" ;
@rc_cond_list = split( /[\s\n]+/, $rc_cond_list ) ;


$op_mode_list = shift;
@op_mode_list = split( /[\s\n]+/, $op_mode_list ) ;

$sta_mode_list = "max min" ;
@sta_mode_list = split( /[\s\n]+/, $sta_mode_list ) ;

	if ($type eq "all" ) {
		@tmp =  glob "./report/*/*/*/report_timing.rep.summary";
	} elsif ( $type eq "ac" ) {
    @tmp =  glob "./report/*/*/*/report_timing_boundary.rep.summary";
  } else {
		@tmp =  glob "./report/*/*/*/report_timing_internal.rep.summary";
	}

foreach $file ( @tmp ) {
  if( $file =~ m#./report/(\d+_\S+)/(\S+)-mode/(\S+)_(\S+)_(\S+)_(max|min)/\S+(|_internal).rep.summary$#) {
    ( $stage, $op_mode, $lib_cond, $rc_cond, $tmp, $sta_mode ) = ($1, $2, $3, $4, $5, $6);
    foreach $lib_cond ( @lib_cond_list ) {
      foreach $rc_cond ( @rc_cond_list ) {
        foreach $op_mode ( @op_mode_list ) {
          foreach $sta_mode ( @sta_mode_list ) {
            $violation_count{$stage}{$lib_cond,$op_mode,$sta_mode} = "" ;
            $worst_slack{$stage}{$lib_cond,$rc_cond,$op_mode,$sta_mode} = "" ;
          }
        }
      }
    }
  }
}
	foreach $file ( @tmp ) {
	#report_timing.slow.cworst.func0to6.max.rep.summary
	#./scanshift-mode/wc_cworst_min/REPORT/report_timing.rep.summary
		if( $file =~ m#./report/(\d+_\S+)/(\S+)-mode/(\S+)_(\S+)_(\S+)_(max|min)/\S+(|_internal).rep.summary$#) {
			( $stage, $op_mode, $lib_cond, $rc_cond, $tmp, $sta_mode ) = ($1, $2, $3, $4, $5, $6);
			$rc_cond = "${rc_cond}_$tmp";
			$_ = $file ;

			$current_violation_count = "" ;
			$current_worst_slack = "" ;
			open( FILE, "< $file" ) ;
			while( <FILE> ) {
				if( /^\s+\*\s+\*\s+(\d+)\s+(-*\d*\.*\d+)\s*$/ ) {
					( $current_violation_count, $current_worst_slack ) = /^\s+\*\s+\*\s+(\d+)\s+(-*\d*\.*\d+)\s*$/ ;
				}
				if( /^\s+\*\s+\*\s+(\d+)\s*$/ ) {
					( $current_violation_count ) = /^\s+\*\s+\*\s+(\d+)\s*$/ ;
					$current_worst_slack = -0.000 ;
				}
				if( /^\s+total\s+0\s*$/ ) {
        $current_violation_count = 0 ;
        $current_worst_slack = "N/A" ;
      }
    }
    close( FILE ) ;
    if( ( $current_violation_count ne "" ) && ( $current_worst_slack ne "" ) ) {
      $violation_count{$stage}{$lib_cond,$rc_cond,$op_mode,$sta_mode} = $current_violation_count ;
      $worst_slack{$stage}{$lib_cond,$rc_cond,$op_mode,$sta_mode} = $current_worst_slack ;

      if( $worst_slack{$stage}{$lib_cond,$rc_cond,$op_mode,$sta_mode} =~ /^-*\d*\.*\d+$/ ) {
        $worst_slack{$stage}{$lib_cond,$rc_cond,$op_mode,$sta_mode} = sprintf( "%.3f", $worst_slack{$stage}{$lib_cond,$rc_cond,$op_mode,$sta_mode} ) ;
      }
      if( $violation_count{$stage}{$lib_cond,$rc_cond,$op_mode,$sta_mode} == 0 ) {
        printf( "%-131s : clean (   N/A) \n", $file, $worst_slack{$stage}{$lib_cond,$rc_cond,$op_mode,$sta_mode} ) ;
      } else {
        printf( "%-131s : %5d (%.3f) \n", $file,
        $violation_count{$stage}{$lib_cond,$rc_cond,$op_mode,$sta_mode},
        $worst_slack{$stage}{$lib_cond,$rc_cond,$op_mode,$sta_mode} ) ;
      }
    }
  }
}

foreach my $stage (keys %worst_slack ) {
  print "INFO: $stage\n";
  my @tmp_mode_list;
  my $list_ready = 0 ;
  my $ll_per_mode = 18;
  my $ll_pre = 29;
  my $space  = $ll_per_mode - 1;
  my $value_space = $space - 10;
  my $num_space   = 5;
  
  for ( my $k = 0 ; $k < ( $#op_mode_list + 1 ) ; ) {
    push @tmp_mode_list, $op_mode_list[$k];
    $k ++ ;
    if ( $k < ( $#op_mode_list + 1 ) ) {
      if ( $k % 6 == 0 ) {
        $list_ready = 1;
      }
    } else {
        $list_ready = 1;
    }
  
    if ( $list_ready ) {
      my $num_of_mode = ( $#tmp_mode_list + 1 );
      my $ll = $ll_per_mode * $num_of_mode;
      print "+" . "-" x $ll_pre ;
      print "-" x $ll . "+\n";
      printf( "|  STA  |  lib  |       rc      |" ) ;
      foreach $op_mode ( @tmp_mode_list ) {
        my $length = length $op_mode;
        my $front  = int ( ( $space - $length ) / 2 );
        my $new_name = " " x $front . $op_mode;
        printf( "%-${space}s|", $new_name);
      }
      print"\n";
      
      foreach $sta_mode ( sort @sta_mode_list ) {
        foreach $lib_cond ( sort @lib_cond_list ) {
          foreach $rc_cond ( sort @rc_cond_list ) {
  
            next if ( $lib_cond eq "tc" );
            next if( ( $sta_mode eq "max" ) && ( $lib_cond eq "lt" or $lib_cond =~ /ml/ or $lib_cond =~ /bc/ ) ) ;
            next if ( $lib_cond eq "lt" and ( $rc_cond =~ /_115c/ ) );
            next if ( $lib_cond =~ /bc/ and ( $rc_cond =~ /_115c/ ) );
            next if ( $lib_cond =~ /ml/ and ( $rc_cond =~ /_m40c/ or $rc_cond =~ /_0c/) );
            next if( ( $sta_mode eq "min" ) && ( $lib_cond eq "wcl" and $rc_cond eq "cbest_m40c" ) ) ;
            next if( ( $sta_mode eq "min" ) && ( $lib_cond eq "wcz" and $rc_cond =~ /cbest/ ) ) ;
            next if( ( $sta_mode eq "min" ) && ( $lib_cond eq "wc" and $rc_cond eq "cbest_115c" ) ) ;
            next if( ( $sta_mode eq "min" ) && ( $lib_cond eq "wc" and $rc_cond eq "rcbest_115c" ) ) ;
            next if( ( $sta_mode eq "max" ) && ( $rc_cond =~ /cbest_/  ) ) ;
            next if( ( $lib_cond eq "wc" and ( $rc_cond =~ /_m40c/ or $rc_cond =~ /_0c/ ) ) ) ;
            next if( ( $lib_cond eq "wcl" and $rc_cond =~ /_115c/ ) ) ;
            next if( ( $lib_cond eq "wcz" and $rc_cond =~ /_115c/ ) ) ;
            next if( $lib_cond =~ /bc2/ && ( $rc_cond eq "cbest_0c" || $rc_cond eq "cworst_0c"  ) ) ;
            next if( $lib_cond =~ /ml2/ && ( $rc_cond eq "cbest_115c" || $rc_cond eq "cworst_115c" ) ) ;
            next if( $lib_cond =~ /bc1/ && ( $rc_cond eq "cbest_0c" || $rc_cond eq "cworst_0c" || $rc_cond eq "rcworst_0c" ) ) ;
            next if( $lib_cond =~ /ml1/ && ( $rc_cond eq "rcbest_115c" || $rc_cond eq "cworst_115c" || $rc_cond eq "cbest_115c" ) ) ;

            next if( ( $sta_mode eq "min" ) && ( $lib_cond eq "wczv" and $rc_cond =~ /cbest/ ) ) ;
            next if( ( $sta_mode eq "min" ) && ( $lib_cond eq "wcv" and $rc_cond eq "cbest_115c" ) ) ;
            next if( ( $sta_mode eq "min" ) && ( $lib_cond eq "wcv" and $rc_cond eq "rcbest_115c" ) ) ;
            next if( ( $lib_cond eq "wcv" and ( $rc_cond =~ /_m40c/ or $rc_cond =~ /_0c/ ) ) ) ;
            next if( ( $lib_cond eq "wczv" and $rc_cond =~ /_115c/ ) ) ;


  
  
            printf( "|-------+-------+---------------+");
            for ( my $i = 0; $i < $num_of_mode ; $i ++ ) {
                print "-" x $space ;
                if ($i == $#tmp_mode_list ) {
      	      print "|\n";
      	  } else {
      	      print "+";
      	  }
            }
            printf( "| %-5s | %-5s | %-13s |", $sta_mode, $lib_cond,$rc_cond ) ;
            foreach $op_mode ( @tmp_mode_list ) {
              $priority = 0 ;
              #$priority = 2 if( ( $sta_mode eq "max" ) && ( $lib_cond eq "worst_1.10v_tj85" ) && ( $op_mode eq "scan" ) ) ;
              if( $priority == 1 ) {
                $violation_count{$stage}{$lib_cond,$rc_cond,$op_mode,$sta_mode} = "----" ;
                $worst_slack{$stage}{$lib_cond,$rc_cond,$op_mode,$sta_mode} = "------" ;
              }
              if( $priority == 2 ) {
                $violation_count{$stage}{$lib_cond,$rc_cond,$op_mode,$sta_mode} = "XXXX" ;
                $worst_slack{$stage}{$lib_cond,$rc_cond,$op_mode,$sta_mode} = "XXXXXX" ;
              }
              printf( " %${num_space}s : %${value_space}s |", $violation_count{$stage}{$lib_cond,$rc_cond,$op_mode,$sta_mode}, $worst_slack{$stage}{$lib_cond,$rc_cond,$op_mode,$sta_mode} ) ;
            }
            printf( "\n" ) ;
          }
        }
      }
      print "+" . "-" x $ll_pre ;
      print "-" x $ll . "+\n";
      $list_ready = 0 ;
      @tmp_mode_list = qw();
    }
  }
}
#print "$ENV{LINES}\n";
