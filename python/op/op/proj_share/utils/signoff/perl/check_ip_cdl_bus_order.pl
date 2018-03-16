#!/usr/bin/perl
########################################################################
# PROGRAM:     check_ip_cdl_bus_order.pl
# CREATOR:     Zachary Shi <zacharys@alchip.com>
# DATE:        Wed Aug 16 01:23:04 CST 2017
# DESCRIPTION: checking the bus order(positive order or negative order) of specified CDL file.
#              positive bus order  : A[3] A[2] A[1] A[0]
#              negative bus order  : A[0] A[1] A[2] A[3]
# VERSION:     1.1 ; added function to solve the ".INCLUDE" CDL netlist.
# VERSION:     1.2 ; include CDL file no need the double quotation marks.
# VERSION:     1.3 ; added function to solve the disorder bus.
# USAGE:       check_ip_cdl_bus_order.pl <file_name.cdl>
# FOR:         GE-08-17
########################################################################

my $is_debug = 0 ; # "0" is for normal mode, "1" is for debug mode.

#### sub function ####
sub dprintf {
  if ( $is_debug == 1 ) {
    printf "$_[0]"
  }
}

sub check_order {
  dprintf "Info: begin to check the bus order of CDL netlist: \"$_[0]\".\n" ;
  open ( input_cdl , "$_[0]" ) ;

  $flag = 0 ;
  $subckt = 0 ;
  $top_line  = 50 ;
  $top_line2 = $top_line - 1 ;
  $both_flag = 0;
  $big_endian_flag    = 0 ;
  $little_endian_flag = 0 ;
  $line_num   = 0 ;
  $subckt_num = 0 ;
  @both_endian = () ;
  @big_endian  = () ;
  @little_endian = () ;
  undef %order;


  while ( <input_cdl> ) {
    $line_num ++ ;

    if ( /^\.(SUBCKT|subckt)\s/ ) {
      ( $subckt_tmp, $sub_name, $pins ) = $_ =~ /^\.(SUBCKT|subckt)\s(\w+)\s(.*)/;
      $flag = 1 ;
      $subckt = 1 ;
      $subckt_num = $line_num ;
      next
    }

    if ( $flag ) {
      if ( /^\+\s/ ) {
        ( $tmp_pins ) = $_ =~ /^\+\s(.*)/ ;
        $pins = $pins." ".$tmp_pins ;

      } else {
        $flag = 0 ;
        undef %bus ;
        @pins = split( ' ', $pins ) ;

        foreach $pin ( @pins ) {
          if ( $pin =~ /\[\d+\]/ ) {
            ( $bus_name, $bus_num ) = $pin =~ /(\w+)\[(\d+)\]/ ;
            $bus{$bus_name} = $bus{$bus_name}." ".$bus_num ;
          }

          if ( $pin =~ /\<\d+\>/ ) {
            ( $bus_name, $bus_num ) = $pin =~ /(\w+)\<(\d+)\>/ ;
            $bus{$bus_name} = $bus{$bus_name}." ".$bus_num ;
          }
        }

        if ( keys %bus ) {
          @bus_name = keys %bus ;
          dprintf "Info: bus name of SUBCKT line $subckt_num : @bus_name\n";
          foreach $bus_name ( @bus_name ) {
            @bus_order = split( ' ' , $bus{$bus_name} ) ;
            $bus_order = @bus_order ;
            dprintf "Info: bus number $bus_order\n";
            dprintf "Info: for hash \"bus\", $bus_name --> $bus{$bus_name}\n";

            next if ( $bus_order == 1 );

            $big_endian_flag_tmp    = 0;
            $little_endian_flag_tmp = 0;
            for ( $i = 1; $i < $bus_order; $i=$i+1 ) {

              dprintf "Info: iteration $i: $bus_order[$i-1] vs $bus_order[$i]\n";
              if ( $bus_order[$i-1] > $bus_order[$i]) {
                $big_endian_flag_tmp = 1;
              } else {
                $little_endian_flag_tmp = 1;
              }
            }

            if ( $big_endian_flag_tmp eq 1 && $little_endian_flag_tmp eq 0 ) {
              #$big_endian_flag = 1 ;
              $order{$bus_name} = "big_endian_flag $bus_name:$subckt_num";
              dprintf "Info: the bus $bus_name is \"big_endian_flag\", and the line is $subckt_num\n";
              #push(@big_endian, "$bus_name $subckt_num") ;
            } elsif ( $big_endian_flag_tmp eq 0 && $little_endian_flag_tmp eq 1) {
              #$little_endian_flag = 1 ;
              $order{$bus_name} = "little_endian_flag $bus_name:$subckt_num";
              dprintf "Info: the bus $bus_name is \"little_endian_flag\", and the line is $subckt_num\n";
              #push(@little_endian, "$bus_name $subckt_num") ;
            } else {
              $order{$bus_name} = "both_flag $bus_name:$subckt_num";
              dprintf "Error: the bus order of $bus_name is both \"big_endian_flag\" and \"little_endian_flag\", and the line is $subckt_num\n";
            }
          }
        }

      }
    }

  }

  if ( $subckt == 0 ) {
    printf "Error: can not found any SUBCKT in this CDL netlist \"$_[0]\".\n" ;

  } else {

    foreach $bus_name ( keys %order ) {
      $name_number_tmp = (split(' ', $order{$bus_name}))[1];
      if ( $order{$bus_name} =~ /big_endian_flag/ ) {
        $big_endian_flag = 1;
        push(@big_endian, $name_number_tmp);
      } elsif ( $order{$bus_name} =~ /little_endian_flag/ ) {
        $little_endian_flag = 1;
        push(@little_endian, $name_number_tmp);
      } else {
        $both_flag = 1;
        push(@both_endian, $name_number_tmp);
      }
    }

    $both_endian_num   = @both_endian;
    $big_endian_num    = @big_endian;
    $little_endian_num = @little_endian;

    printf "\n***\nInfo: checking the CDL bus order of \"$_[0]\", the positive order like: A[3] A[2] A[1] A[0], the negative order like: A[0] A[1] A[2] A[3].\n\n";

    if ( $both_flag ) {
      printf "Error: this CDL netlist \"$_[0]\" have disordered bus. ";
      printf "By default, we want the bus is positive order. ";
      if ( $both_endian_num >= $top_line ) {
        printf "The name and line number of top $top_line questionable bus: \"@both_endian[0..$top_line2]\"...\n";
      } else {
        printf "The name and line number of questionable bus: \"@both_endian\",\n";
      }

    } elsif ( $big_endian_flag && $little_endian_flag ) {
      printf "Error: this CDL netlist \"$_[0]\" have both positive order($big_endian_num) bus and negative order($little_endian_num) bus. " ;
      printf "By default, we want the bus is positive order. ";
      if ( $big_endian_num_sort >= $top_line ) {
        printf "The line number of top $top_line positive order bus: \"@big_endian[0..$top_line2]\"... " ;
      } else {
        printf "The line number of positive order bus: \"@big_endian\", " ;
      }
      if ( $little_endian_num_sort >= $top_line ) {
        printf "The line number of top $top_line negative order bus: \"@little_endian[0..$top_line2]\"...\n" ;
      } else {
        printf "The line number of negative order bus: \"@little_endian\".\n" ;
      }

    } elsif ( $little_endian_flag ) {
      printf "Warning: this CDL netlist \"$_[0]\" only have negative order($little_endian_num) bus. ";
      printf "By default, we want the bus is positive order. ";
      if ( $little_endian_num_sort >= $top_line ) {
        printf "The line number of top $top_line negative order bus: \"@little_endian[0..$top_line2]\"...\n" ;
      } else {
        printf "The line number of negative order bus: \"@little_endian\".\n" ;
      }

    } elsif ( $big_endian_flag ) {
      printf "Info: this CDL netlist \"$_[0]\" only have positive order($big_endian_num) bus. " ;
      printf "The bus order is ok. ";
      if ( $big_endian_num_sort >= $top_line ) {
        printf "The line number of top $top_line positive order bus: \"@big_endian[0..$top_line2]\"...\n" ;
      } else {
        printf "The line number of positive order bus: \"@big_endian\".\n" ;
      }

    } else {
      printf "Warning: can not found any bus in this CDL netlist \"$_[0]\", maybe it's ok, but please check the CDL netlist manually and make sure if it doesn't have bus.\n"
    }
    printf "\n" ;
  }

  dprintf "Info: end to check the bus order of CDL netlist: \"$_[0]\".\n\n"
}

#### main ####
my $is_cdl = 0 ;
my @cdl_list = () ;
my @cdl_list_tmp = () ;

push(@cdl_list, $ARGV[0]) ;
open ( input_cdl_file, "$ARGV[0]" ) or die "Error: can not open this CDL netlist \"$ARGV[0]\", $!.\n" ;

dprintf "\nInfo: begin checking \"$ARGV[0]\" for \".INCLUDE\" CDL netlist.\n" ;

while ( <input_cdl_file> ) {
  if ( /^.INCLUDE\s+/ ) {
    ( $include_cdl_name ) = $_ =~ /^.INCLUDE\s+"(\S+)"/ ;
    ( $include_cdl_name ) = $_ =~ /^.INCLUDE\s+(\S+)/ if ( $include_cdl_name eq "" );
    if ( grep /^$include_cdl_name$/, @cdl_list) {
      dprintf "Info: this CDL netlist already exists: $include_cdl_name, ignored.\n" ;
    } else {
      dprintf "Info: found new CDL netlist: $include_cdl_name\n" ;
      push(@cdl_list_tmp, $include_cdl_name);
    }
  }

  if ( /^\.(SUBCKT|subckt)\s/ ) {
    $is_cdl = 1 ;
  }
}

if ( $is_cdl == 0 ) {
  shift @cdl_list ;
}

$cdl_list_tmp = @cdl_list_tmp ;
dprintf "Info: end checking \"$ARGV[0]\", total found $cdl_list_tmp CDL netlist(s).\n\n" ;

while ( $cdl_list_tmp > 0 ) {

  dprintf "\nIterB: @cdl_list\n";
  dprintf "IterB: @cdl_list_tmp\n\n";

  $file_name = shift @cdl_list_tmp ;
  #push(@cdl_list, $file_name) ;
  if ( -e $file_name ) {
    push(@cdl_list, $file_name) ;
    open ( input_cdl_file , "$file_name" ) ;
    while ( <input_cdl_file> ) {
      if ( /.INCLUDE\s+/ ) {
        ( $include_cdl_name ) = $_ =~ /.INCLUDE\s+"(\S+)"/ ;
        ( $include_cdl_name ) = $_ =~ /.INCLUDE\s+(\S+)/ if ( $include_cdl_name eq "" );
        if ( grep /^$include_cdl_name$/, @cdl_list ) {
          dprintf "Info: this CDL netlist already exists: $include_cdl_name, ignored.\n" ;
        } else {
          dprintf "Info: found new CDL netlist: $include_cdl_name\n" ;
          push(@cdl_list_tmp, $include_cdl_name);
        }
      }
    }

  } else {
    printf "Error: can not open this CDL netlist \"$file_name\", $!.\n" ;
  }

  $cdl_list_tmp = @cdl_list_tmp ;
  dprintf "\nIterE: @cdl_list\n";
  dprintf "IterE: @cdl_list_tmp\n\n";
}

$cdl_list = @cdl_list ;
dprintf "Info: total found $cdl_list CDL netlist(s) which need to check bus order: \"@cdl_list\"\n\n" ;

foreach $cdl_netlist ( @cdl_list ) {
  check_order $cdl_netlist ;
}


