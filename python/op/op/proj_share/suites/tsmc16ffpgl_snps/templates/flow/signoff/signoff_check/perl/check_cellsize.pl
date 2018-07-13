#!/usr/bin/perl

$size_max = 24 ;
$size_min = 1  ;
@exc_inst   = ("") ;

while (<>) {
  if( /^\s*module\s+([^\s\(\)]+)[\s\(\)]/ ) {
    ( $module_name ) = /^\s*module\s+([^\s\(\)]+)[\s\(\)]/ ;
  }
  split ;
  if ($_[0] =~ /^\S.*D([0-9]+)BWP.*$/ ) {
    if ($1 > $size_max) {
      $err = 1 ;
      foreach $exc_inst (@exc_inst) {
        if ($_[1] =~ /$exc_inst/) {
          $err = 0 ;
          last ;
        }
      }
      if ($err) {
        printf( "Error: high driving cell ( > D$size_max ) found in module \"%s\". (L%d)\n", $module_name, $. ) ;
        print ;
        $count{"max-size-error"}++ ;
      }
    } elsif ($1< $size_min) {
      $err = 1 ;
      foreach $exc_inst (@exc_inst) {
        if ($_[1] =~ /$exc_inst/) {
          $err = 0 ;
          last ;
        }
      }
      if ($err) {
        printf( "Error: weak driving cell ( < D$size_min ) found in module \"%s\". (L%d)\n", $module_name, $. ) ;
        print ;
        $count{"min-size-error"}++ ;
      }
    } elsif ( ($1 eq "V") && ($2 eq "L") && ($3 == 0) ) {
      $err = 1 ;
      foreach $exc_inst (@exc_inst) {
        if ($_[1] =~ /$exc_inst/) {
          $err = 0 ;
          last ;
        }
      }
      if ($err) {
        printf( "Error: small area cell ( < SVL_D1 ) found in module \"%s\". (L%d)\n", $module_name, $. ) ;
        print ;
        $count{"min-area-error"}++ ;
      }
    }
  }
}

print "\n" ;
@items = ("max-size-error", "min-size-error", "min-area-error") ;
foreach $item ( @items ) {
  printf( " Number of %-8s = %6d\n", $item, $count{$item} ) ;
}
