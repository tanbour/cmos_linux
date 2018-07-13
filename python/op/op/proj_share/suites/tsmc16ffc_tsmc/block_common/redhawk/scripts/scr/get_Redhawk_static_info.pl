#! /usr/local/bin/perl

my $PWR = $ARGV[0]; # # ./adsRpt/*.power.rpt
my $IR_pin = $ARGV[1]; # ./adsRpt/Static/*.inst.pin
my $IR_arc = $ARGV[2]; #./adsRpt/Static/*.inst.arc
my $IP_list = $ARGV[3]; # IP list
my $percent = $ARGV[4]; # percent default 1%
my $RES = $ARGV[5];  # ./adsRpt/*.res_calc
my $result_file = "PIN_static.info";
my %IPCELL = ();
my %INST = ();
my %INSTn = ();
my %PG = ();
my @pgpins = ();
my %groundarc = ();
my %groundarc_power = ();
my $p;

################# code ########################
if ( $#ARGV < 3 ) {
   die "please input 4 ARGV at least!";
}
if ( $#ARGV = 4) {
   if (-e $ARGV[4]) {
      $RES = $ARGV[4];
      $percent = 1;
   } 
}

if ( $#ARGV < 4) {
   $percent = 1;
}
open (IP, $IP_list) || die "$IP_list : $!";
while (<IP>) {
   if (/^(\S+)/) {
      next if exists $IPCELL{$1};
      $IPCELL{$1} = $1;
   }
}
close IP;
open (PWR, $PWR) || die "$PWR : $!";
while (<PWR>) {
   if (/^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/) {
      next if ! exists $IPCELL{$2};
      next if exists  $INSTn{$1};
      $INSTn{$1} = $2;
   }
}
close PWR;
if ( -e $IR_pin ) {
   open (IR_pin, $IR_pin) || die "$IR_pin : $!";
   while (<IR_pin>) {
      if (/^(\d\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/) {
         next if ! exists $INSTn{$8};
         $INST{$8}{$3}{ir} = $5;
         $INST{$8}{$3}{net} = $4;
         $INST{$8}{$3}{voltage} = $6;
         next if exists $INST{$8}{$3}{pin};
         $INST{$8}{$3}{pin} = $3;
         next if exists $PG{$3};
         $PG{$3} = $3;
         push (@pgpins,$3);
      }
   }
   close IR_pin;
}
if ( -e $IR_arc ) {
   open (IR_arc, $IR_arc) || die "$IR_arc : $!";
   while (<IR_arc>) {
      if (/^(\d\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/) {
         next if ! exists $INSTn{$10};
         $INST{$10}{$3}{powerARC} = $3;
         $INST{$10}{$3}{groundARC} = $4;
         $INST{$10}{$3}{ARCnum} = $9;
         $INST{$10}{$3}{ARCIR} = $7;
         my $filerpower = $3;
         if ( exists $groundarc_power{$10}{$4} and $groundarc_power{$10}{$4} ne $filerpower) {
            $groundarc_power{$10}{$4} = "multi";
         }
         next if exists $groundarc{$10}{$4};
         $groundarc{$10}{$4} = $4;
         $groundarc_power{$10}{$4} = $3;
      }
   }
   close IR_arc;
}
if ( -e $RES ) {
   open (RES, $RES) || die "$RES : $!";
   while (<RES>) {
      if (/^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/) {
         next if ! exists $INSTn{$7};
         $INST{$7}{$6}{layer} = $4;
         $INST{$7}{$6}{R} = $1;
         next if exists $INST{$7}{$6}{pin};
         $INST{$7}{$6}{pin} = $6;
         next if exists $PG{$6};
         $PG{$6} = $6;
         push (@pgpins,$6);
      }
   }
   close RES;
}
open (RESULT, ">$result_file") || die "$result_file : $!";
printf RESULT "#R(Ohm)  #ir-drop(pin)  #voltage  #vdd-vss(arc)  #layer  #pin  #net  #instance \n";
while (($key,$value) = each %INSTn) {
   chomp $key;
   chomp $value;
   foreach $pgpin ( @pgpins ) {
      if (exists $INST{$key}{$pgpin}{pin}) {
         if ( ! exists $INST{$key}{$pgpin}{R} ) {
            $INST{$key}{$pgpin}{R} = "-";
         }
         if ( ! exists $INST{$key}{$pgpin}{layer} ) {
            $INST{$key}{$pgpin}{layer} = "-";
         }
         if ( ! exists $INST{$key}{$pgpin}{ir} ) {
            $INST{$key}{$pgpin}{ir} = "-";
         }
         if ( ! exists $INST{$key}{$pgpin}{net} ) {
            $INST{$key}{$pgpin}{net} = "-";
         }
         if ( ! exists $INST{$key}{$pgpin}{voltage} ) {
            $INST{$key}{$pgpin}{voltage} = "-";
         }
         if ( ! exists $INST{$key}{$pgpin}{groundARC} ) {
            $INST{$key}{$pgpin}{groundARC} = "-";
         }
         if ( ! exists $INST{$key}{$pgpin}{powerARC} ) {
            $INST{$key}{$pgpin}{powerARC} = "-";
         }
         if ( ! exists $INST{$key}{$pgpin}{ARCIR} ) {
            if ( exists $groundarc{$key}{$pgpin} ) {
               $INST{$key}{$pgpin}{ARCIR} = $INST{$key}{$pgpin}{ir};
            } else {
               $INST{$key}{$pgpin}{ARCIR} = "-";
            }
         }
         if ( $INST{$key}{$pgpin}{voltage} ne "-" and $INST{$key}{$pgpin}{ARCIR} ne "-" ) {
            if ( ! exists $groundarc{$key}{$pgpin} ) {
               $p = ( $INST{$key}{$pgpin}{voltage} - $INST{$key}{$pgpin}{ARCIR} ) / $INST{$key}{$pgpin}{voltage} * 100;
            } elsif ($groundarc_power{$key}{$pgpin} ne "multi"){
               $p = $INST{$key}{$pgpin}{ARCIR} / $INST{$key}{$groundarc_power{$key}{$pgpin}}{voltage} * 100;
            } else {
               $p = 0;
            }
         } else {
            $p = 0;
         }
         if ( $p >= $percent) {
            printf RESULT "N %-10s\t%-10s\t%3s\t%-10s( %1.3f% )\t%3s\t%6s\t%6s\t%s\n",$INST{$key}{$pgpin}{R},$INST{$key}{$pgpin}{ir},$INST{$key}{$pgpin}{voltage},$INST{$key}{$pgpin}{ARCIR},$p,$INST{$key}{$pgpin}{layer},$pgpin,$INST{$key}{$pgpin}{net},$key;
         } else {
            printf RESULT "%-10s\t%-10s\t%3s\t%-10s( %1.3f% )\t%3s\t%6s\t%6s\t%s\n",$INST{$key}{$pgpin}{R},$INST{$key}{$pgpin}{ir},$INST{$key}{$pgpin}{voltage},$INST{$key}{$pgpin}{ARCIR},$p,$INST{$key}{$pgpin}{layer},$pgpin,$INST{$key}{$pgpin}{net},$key;
         }
      }
   }
}
