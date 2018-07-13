#! /usr/local/bin/perl

my $func = $ARGV[0];
my $dir = $ARGV[1];
my $IP_list = $ARGV[2];
my $PWR = $ARGV[3];
my $IR = $ARGV[4];
my $RES = $ARGV[5];
my %IPCELL = ();
my %INST = ();
my $net;
if ($func eq "-h") {
   print "please input : IP_list PWR IR RES\n";
   exit;
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
      $INST{$1} = $1;
   }
}
close PWR;
open (IR, $IR) || die "$IR : $!";
if ($func eq "ir") {
   print "#vdd-vss\t#vdd_drop\t#gnd_bounce\t#pwr_net\t#inst_name\n";
}
while (<IR>) {
   if (/^  (\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+\(.*\)\s+(\S+)/) {
      next if ! exists $INST{$6};
      $INST{$6}{$5}{ir} = $1;
      $INST{$6}{$5}{VDD} = $2;
      $INST{$6}{$5}{GND} = $3;
      $net = $5;
      if ($func eq "ir") {
         print "$INST{$6}{$5}{ir} $INST{$6}{$5}{VDD} $INST{$6}{$5}{GND} $net $INST{$6}\n";
      }
   }
}
close IR;
if ($func eq "all") {
   my $VDD_IR;
   my $VSS_IR;
   my $ALL_IR;
   my $result_file = $dir;
   open (RES, $RES) || die "$RES : $!";
   open (RESULT, ">$result_file") || die "$result_file : $!";
   printf RESULT "#vdd-vss (%) #vdd_drop  #gnd_bounce  #pwr_net  #inst_name  #R(Ohm)  #layer  #pin\n";
   while (<RES>) {
      if (/^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/) {
         next if ! exists $INST{$7};
         $INST{$7}{$5}{pin} = $6;
         $INST{$7}{$5}{layer} = $4;
         $INST{$7}{$5}{R} = $1;
         $net = $5;
         if ( ! exists $INST{$7}{$5}{ir} ) {
            if ( $net eq "VSS" ) {
               if ( exists $INST{$7}{VDD}{ir}) {
                  $ALL_IR = $INST{$7}{VDD}{ir};
                  $VDD_IR = "*";
                  $VSS_IR = $INST{$7}{VDD}{GND};
               } elsif ( exists $INST{$7}{VDDR}{ir} ) {
                  $ALL_IR = $INST{$7}{VDDR}{ir};
                  $VDD_IR = "*";
                  $VSS_IR = $INST{$7}{VDDR}{GND};
               } else {
                  $ALL_IR = "MISS";
                  $VDD_IR = "MISS";
                  $VSS_IR = "MISS";
               }
            } else {
               $ALL_IR = "MISS";
               $VDD_IR = "MISS";
               $VSS_IR = "MISS";
            }
         } else {
            $ALL_IR = $INST{$7}{$5}{ir};
            $VDD_IR = $INST{$7}{$5}{VDD};
            $VSS_IR = "*";
         }
         if ($ALL_IR ne "MISS") {
            my $dd;
            my $pppp;
            if ( $net eq "VDDQ" ) {
               $dd = 1.2 - $ALL_IR;
               $pppp = $dd / 1.2 * 100;
            } else {
               $dd = 0.8 - $ALL_IR;
               $pppp = $dd / 0.8 * 100;
            }
            if ($dd >= 0.008) {
               if ( $net ne "VDDQ" ) {
                  printf RESULT "- %8s (%1.2f%)\t%8s\t%8s\t%5s\t%85s\t%3.5f\t%3s\t%5s\n",$ALL_IR,$pppp,$VDD_IR,$VSS_IR,$net,$INST{$7},$INST{$7}{$5}{R},$INST{$7}{$5}{layer},$INST{$7}{$5}{pin};
               } elsif ( $dd >= 0.012) {
                  printf RESULT "- %8s (%1.2f%)\t%8s\t%8s\t%5s\t%85s\t%3.5f\t%3s\t%5s\n",$ALL_IR,$pppp,$VDD_IR,$VSS_IR,$net,$INST{$7},$INST{$7}{$5}{R},$INST{$7}{$5}{layer},$INST{$7}{$5}{pin};
               } else {
                  printf RESULT "%8s (%1.2f%)\t%8s\t%8s\t%5s\t%85s\t%3.5f\t%3s\t%5s\n",$ALL_IR,$pppp,$VDD_IR,$VSS_IR,$net,$INST{$7},$INST{$7}{$5}{R},$INST{$7}{$5}{layer},$INST{$7}{$5}{pin};
               }
            } else {
               printf RESULT "%8s (%1.2f%)\t%8s\t%8s\t%5s\t%85s\t%3.5f\t%3s\t%5s\n",$ALL_IR,$pppp,$VDD_IR,$VSS_IR,$net,$INST{$7},$INST{$7}{$5}{R},$INST{$7}{$5}{layer},$INST{$7}{$5}{pin};
            }
         }
      }
   }
   close RES;
}
