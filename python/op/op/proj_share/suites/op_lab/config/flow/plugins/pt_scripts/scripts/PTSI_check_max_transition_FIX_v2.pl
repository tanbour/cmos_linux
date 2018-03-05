#! /usr/bin/perl
# SS corner needs to set_max_transition "value of $default_clock_max_transition" in PTSI
# FF corner remove set_max_transition setting in PTSI
$default_data_max_transition =  $ARGV[3] ;
$default_clock_max_transition = $ARGV[2] ;#(0.100 for DDRPHY)
##################################################################
open F2, "<$ARGV[1]" or die "can not open file $ARGV[1]\n";
while ( <F2> ) {
     next if (/^\s*$/ | /^#/);
     chomp ;
     $CLOCK_NET{$_} = 1 ;
}
close F2;
##################################################################
my $CLK = "SLEW_CLK" ;
my $DATA = "SLEW_DATA" ;

open F1, "<$ARGV[0]" or die "can not open file $ARGV[0]\n";
open OUT_CLK, ">$CLK" or die "can not open $SLEW_CLK";
open OUT_DATA, ">$DATA" or die "can not open $SLEW_DATA";

while (<F1>) {
  chomp;

 if ( /^\s+Pin:\s+(\S*)$/ ) {
       $pin_name =$1;
  } 

 if ( /^\s+max_transition\s+(\d+\.\d+)$/ ) {
       $check_transition =$1;
  } 

 if ( /^\s+-\s+Transition\s+Time\s+(\d+\.\d+)$/ ) {
       $slack = $1 ; 
       MakeC ( $pin_name, $slack , $check_transition ) ;
    #  last ;
  }

}
close F1;
##################################################################
sub MakeC {
  my ($PinName, $SlewValue , $PTCHECKtransition) = @_;
    if ( exists $CLOCK_NET{$PinName} ) {
        if ( $default_clock_max_transition <= $PTCHECKtransition ) {
           $checkV = $default_clock_max_transition ;
        } else {
           $checkV = $PTCHECKtransition ;
        }
        if ( $SlewValue >= $checkV ) {
           $CLOCK_ERROR{$PinName} = $SlewValue ;
        }
    } else {
        if ( $default_data_max_transition <= $PTCHECKtransition || $PTCHECKtransition == $default_clock_max_transition ) {
           $checkV = $default_data_max_transition ;
        } else {
           $checkV = $PTCHECKtransition ;
        }
        if ( $SlewValue >= $checkV ) {
           $SLEW_ERROR{$PinName} = $SlewValue ;
        }
    }
    $CHECKV{$PinName} = $checkV ;
}
##################################################################
print "# DATA SLEW ERROR ! \n" ;
foreach $NetN (sort {$SLEW_ERROR{$b} <=> $SLEW_ERROR{$a}} keys %SLEW_ERROR ) {
print OUT_DATA "$SLEW_ERROR{$NetN} $NetN ($CHECKV{$NetN})\n";
}
# 
print "# CLOCK SLEW ERROR !\n" ;
#
foreach $NetN (sort {$CLOCK_ERROR{$b} <=> $CLOCK_ERROR{$a}} keys %CLOCK_ERROR ) {
print OUT_CLK "$CLOCK_ERROR{$NetN} $NetN ($CHECKV{$NetN})\n";
}
close OUT_CLK ;
close OUT_DATA ;
