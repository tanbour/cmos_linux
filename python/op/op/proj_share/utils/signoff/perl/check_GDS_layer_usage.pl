#!/usr/bin/perl -w
##################################################################################
# PROGRAM:     check_GDS_layer_usage.pl
# CREATOR:     Zachary Shi <zacharys@alchip.com>
# DESCRIPTION: check all the GDS layer information from PIPO logs
# USAGE:       check_GDS_layer_usage.pl -top <top log dir> \
#					-sc  < sc log dir> \
#					-mem <mem log dir> \ ; optional
#					-io  < io log dir> \ ; optional
#					-ip  < ip log dir> \ ; optional
# INFORMATION: v1.1, updated the type of inputs.
# DATE:        Fri Feb 23 20:43:39 CST 2018
###################################################################################

#use strict;
use Cwd 'abs_path';

# "0" is for normal mode, "1" is for debug mode.
my $is_debug = 0 ;

#### sub function ####
sub dprintf {
  if ( $is_debug eq 1 ) {
    printf "$_[0]"
  }
}

sub script_help {
  printf "USAGE: ./check_GDS_layer_usage.pl -top <top log dir> \\\n";
  printf "                                  -sc  < sc log dir> \\\n";
  printf "                                  -io  < io log dir> \\; optional\n";
  printf "                                  -ip  < ip log dir> \\; optional\n";
  printf "                                  -mem <mem log dir> \\; optional\n";
}

#### for input ####
undef my %input;
undef my %abs_input;

if ( $#ARGV eq -1 ) {
  script_help;
  die "Error: no input!";
} elsif ( $#ARGV%2 eq 0 ) {
  script_help;
  die "Error: input is not right, please checking the inputs!";
} else {

  my $i = 0;
  while ( $i < $#ARGV ) {
    $ARGV[$i]   =~ s/^\s+|\s+$//g;
    $ARGV[$i+1] =~ s/^\s+|\s+$//g;

    if ( exists $input{$ARGV[$i]} ) {
      die "Error: encountered the same inputs: $ARGV[$i]\n";
    } else {
      $input{$ARGV[$i]} = $ARGV[$i+1] ;
      $i = $i + 2;
    }
  }

}

my $top_num = 0;
my $sc_num  = 0;
my $mem_num = 0;
my $ip_num  = 0;
my $io_num  = 0;

 # "$type" is top/sc/mem/ip/io
foreach my $type ( keys %input ) {
  my $abs_p = abs_path($input{$type});
  $abs_input{$type} = $abs_p; # maybe the abs path are the same!
  dprintf "Info: checking type: $type, path: $input{$type}, abs_path: $abs_p\n";

  if ( $type eq "-top" ) {
    $top_num = $top_num + 1;
  } elsif ( $type eq "-sc" ) {
    $sc_num  = $sc_num  + 1;
  } elsif ( $type eq "-mem" ) {
    $mem_num = $mem_num + 1;
  } elsif ( $type eq "-ip" ) {
    $ip_num  = $ip_num  + 1;
  } elsif ( $type eq "-io" ) {
    $io_num  = $io_num  + 1;
  } else {
    script_help;
    die "Error: wrong input option: $type, the option should be: -top, -sc, -mem, -ip, -io\n";
  }

}

if ( $top_num eq 0 ) {
  script_help;
  die "Error: must set the option: -top\n";
}

if ( $sc_num eq 0 && $mem_num eq 0 && $ip_num eq 0 && $io_num eq 0 ) {
  script_help;
  die "Error: at least set one of follow options: -sc, -mem, -ip, -io\n"
}

#### main ####
undef my %layers ;
foreach my $type ( keys %abs_input ) {
  ( my $abs_type ) = $type =~ /-(\S+)/;
  my @files = sort( split( '\s+', `find $abs_input{$type} -name "*\.*"` ) );
  my $file_num = @files;
  if( $file_num eq 0 ) {
    die "Error: can not find the logs in the directory \"$abs_input{$type}\"\n";
  }

  ## check each file ##
  foreach my $file ( @files ) {
    ( my $file_name ) = $file =~ /\/([^\/]+)$/;
    dprintf "\nInfo: checking the file: $file\n";

    my $is_layer = 0;
    open( FILE, "< $file" ) ;
    while (<FILE>) {
      if ( /^\s+Statistics\s+of\s+Layers/ ) {
        $is_layer = 1 ;
        dprintf "Info: find the statistics of layers in the file: $file\n" ;
      }

      if ( $is_layer ) {
        if ( /^\S+\s+\S+\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+/ ) {
          ( my $layer_name , my $stream_layer , my $stream_data_type ) = /^(\S+)\s+\S+\s+(\d+)\s+(\d+)\s+/ ;
          dprintf "Info: layer and it related info: $layer_name => $stream_layer:$stream_data_type\n" ;

          ## for block and top hash
          if ( exists( ${$abs_type}{$layer_name} ) ) {
            my $layer_value = ${$abs_type}{$layer_name} ;
            my @layer_value = split( ' ', $layer_value ) ;
            if ( grep {$_ eq "$stream_layer:$stream_data_type:$file"} @layer_value ) {
              dprintf "Info: hash \"$abs_type\" already have the same value: @layer_value => $stream_layer:$stream_data_type\n" ;
            } else {
              push( @layer_value , "$stream_layer:$stream_data_type:$file" ) ;
              $layer_value = join( ' ', @layer_value ) ;
              ${$abs_type}{$layer_name} = $layer_value ;
              dprintf "Info: hash \"$abs_type\" add new value: $abs_type\{$layer_name\} => ${$abs_type}{$layer_name}\n" ;
            }

          } else {
            ${$abs_type}{$layer_name} = "$stream_layer:$stream_data_type:$file" ;
            dprintf "Info: hash \"$abs_type\" have new value: $abs_type\{$layer_name\} => ${$abs_type}{$layer_name}\n";
          }

          ## for hash %layers
          if ( exists( $layers{$layer_name} ) ) {
            my $layer_data = $layers{$layer_name} ;
            my @layer_data = split(' ', $layer_data) ;
            if ( grep {$_ eq "$stream_layer:$stream_data_type:$file"} @layer_data ) {
              dprintf "Info: hash \"layers\" already have the same value: @layer_data => $stream_layer:$stream_data_type\n" ;
            } else {
              push( @layer_data, "$stream_layer:$stream_data_type:$file" ) ;
              $layer_data = join(' ', @layer_data) ;
              $layers{$layer_name} = $layer_data ;
              dprintf "Info: hash \"layers\" add new value: \$layers\{$layer_name\} => $layers{$layer_name}\n" ;
            }
          } else {
            $layers{$layer_name} = "$stream_layer:$stream_data_type:$file" ;
            dprintf "Info: hash \"layers\" have new value: $stream_layer:$stream_data_type\n" ;
          }
        }

      }
    }
  }

  dprintf "\n###########################################################################################################################\n";
  dprintf "Info: summary of layer, stream_layer, and stream_data_type of \"$abs_type\":\n" ;
  foreach ( keys %{$abs_type} ) {
    #dprintf "key: $_,\tvalue: ${$abs_type}{$_}\n" ;
    dprintf "key: $_,\tvalue:";

    my $value_tmp = ${$abs_type}{$_};
    my @value_tmp = split(' ', $value_tmp);
    foreach my $vt ( @value_tmp ) {
      ( my $sl, my $sdt ) = $vt =~ /(\S+):(\S+):\S+/;
      dprintf " $sl:$sdt";
    }
    dprintf "\n";
  }
  dprintf "###########################################################################################################################\n";

}

dprintf "Info: summary of layer, layer number and layer date type of all layers\n";
foreach ( keys %layers ) {
  #dprintf "key: $_,\tvalue: $layers{$_}\n";
  dprintf "key: $_,\tvalue:";

  my $value_tmp = $layers{$_};
  my @value_tmp = split(' ', $value_tmp);
  foreach my $vt ( @value_tmp ) {
    ( my $sl, my $sdt ) = $vt =~ /(\S+):(\S+):\S+/;
    dprintf " $sl:$sdt";
  }
  dprintf "\n";
}

#### checking and printing the result ####
my @sub_module = ();
printf "####################################################################################\n";
printf "Info: Below is the GDS layer check summary:\n";
printf " Layer_name (Stream_layer:Stream_data_type) ";
foreach $type ( keys %abs_input ) {
  ( my $abs_type ) = $type =~ /-(\S+)/;
  if ( $abs_type ne "top" ) {
    printf ("%9s", $abs_type);
    push(@sub_module, "$abs_type");
  }
}
printf ("%8s %10s\n", "top", "Result");
printf ("%8s","-------------------------------------------");
foreach $type ( keys %abs_input ) {
  printf ("%9s", "------");
  if ( $type eq "-top" ) {
    printf ("%9s", "------");
  }
}
printf "\n";

foreach $layer ( keys %layers ) {
  $layer_data = $layers{$layer} ;
  @layer_data = split(' ', $layer_data) ;

  my @layer_data_tmp  = ();
  my @layer_data_sort = ();
  undef my %count;
  foreach $layer_data ( @layer_data ) {
    ( my $sl, my $sdt ) = $layer_data =~ /(\S+):(\S+):\S+/;
    push(@layer_data_tmp, "$sl:$sdt");
  }
  @layer_data_sort = grep {++$count{$_} < 2;} @layer_data_tmp;

  foreach $layer_data ( @layer_data_sort ) {
    printf ("   %-15s\t%-17s", "$layer","$layer_data");

    ## for sub_module
    my $flag = 0;
    my $ssp = 0; # sub_module stream paths
    my @ssp = ();
    foreach $abs_type ( @sub_module ) {
      my $abs_type_value = 0;
      my @abs_type_value = ();
      my $abs_type_value_num = 0;
      if ( exists(${$abs_type}{$layer}) ) {
        $abs_type_value = ${$abs_type}{$layer};
        @abs_type_value = split(' ', $abs_type_value);
        $abs_type_value_num = @abs_type_value ;
        if ($abs_type_value_num ne 0) {

#          if ( grep {$_ eq $layer_data} @abs_type_value ) {
#            printf ("%9s", "YES");
#            $flag = 1;
#          } else {
#            printf ("%9s", "NO");
#          }
          foreach my $atv ( @abs_type_value ) {
            ( my $sl, my $sdt, my $ssp ) = $atv =~ /(\S+):(\S+):(\S+)/;
            if ( $layer_data eq "$sl:$sdt") {
              push(@ssp, $ssp);
              $flag = 1;
            } 
          }
          if ( $flag ) {
            printf ("%9s", "YES");
          } else {
            printf ("%9s", "NO");
          }

        } else {
          printf ("%9s", "NO");
        }
      } else {
        printf ("%9s", "NO");
      }
    }

    ## for top
    my $tsp = 0; # top stream paths
    my @tsp = ();
    if ( exists($top{$layer}) ) {
      my $abs_type_value = 0;
      my @abs_type_value = ();
      my $abs_type_value_num = 0;
      $abs_type_value = $top{$layer};
      @abs_type_value = split(' ', $abs_type_value);
      $abs_type_value_num = @abs_type_value ;
      if ($abs_type_value_num ne 0) {

#        if ( grep { $_ eq $layer_data } @abs_type_value ) {
#          printf ("%9s", "YES");
#          if ($flag eq 0 ) {
#            printf ("%48s\n", "Warning, sub module can't find this layer info");
#          } else {
#            printf ("%9s\n", "OK");
#          }
#        } else {
#          printf ("%9s %43s\n", "NO", "Fail, top can't find this layer info");
#        }
        my $tflag = 0;
        foreach my $atv ( @abs_type_value ) {
          ( my $sl, my $sdt, my $tsp ) = $atv =~ /(\S+):(\S+):(\S+)/;
          if ( $layer_data eq "$sl:$sdt") {
            push(@tsp, $tsp);
            $tflag = 1;
          }
        }
        if ( $tflag ) {
          printf ("%9s", "YES");
          if ($flag eq 0 ) {
            #printf ("%48s\n", "Warning, sub module can't find this layer info");
            printf "     Warning, sub module can't find this layer info, follow file can found this layer: @tsp\n";
          } else {
            printf ("%9s\n", "OK");
          }
        } else {
          printf "       NO     Fail, top can't find this layer info, follow file can found this layer: @ssp\n";
        }

      } else {
        printf "       NO     Fail, top can't find this layer info, follow file can found this layer: @ssp\n"; # not execute
      }
    } else {
      printf "       NO     Fail, top can't find this layer info, follow file can found this layer: @ssp\n";
    }

  }

}

printf "####################################################################################\n";
printf "Info: GDS layer checking end.\n";
