#! /usr/local/bin/perl -w
#use strict;

my $em_peak = $ARGV[0];
my $em_rms = $ARGV[1];
my $em_avg = $ARGV[2];
my $peak_ratio = 100;
my $rms_ratio = 100;
my $avg_ratio = 100;

print "\n";
print "##========= EM MODE : PEAK ===========##\n";
print "##====================================##\n";
open (PEM,$em_peak);
my $valp = 0;
$line = 0;
while (<PEM>) {
   if (/\S+\s+\(.*\)\s+(\S+)\%/) {
      $ratiop = $1;
      $line ++;
      if ($line == 1) {
          print "The worst EM ratio is $ratiop\%\n";
      }
      if ($ratiop >= $peak_ratio) {
         $valp ++;
      } else {last}
   }
}
print "The total EM violations (>= $peak_ratio\%) is $valp\n";
if ( $valp > 0 ) {
   print "Please refer ../$ARGV[0] to get more detail\n";
}
close (PEM);
print "\n";

print "##========= EM MODE : RMS ============##\n";
print "##====================================##\n";
open (REM,$em_rms);
my $valr = 0;
$line = 0;
while (<REM>) {
   if (/\S+\s+\(.*\)\s+(\S+)\%/) {
      $ratior = $1;
      $line ++;
      if ($line == 1) {
          print "The worst EM ratio is $ratior\%\n";
      }
      if ($ratior >= $rms_ratio) {
         $valr ++;
      } else {last}
   }
}
print "The total EM violations (>= $rms_ratio\%) is $valr\n";
if ( $valr > 0 ) {
   print "Please refer ../$ARGV[1] to get more detail\n";
}
close (REM);
print "\n";

print "##========= EM MODE : AVG ============##\n";
print "##====================================##\n";
open (AEM,$em_avg);
$line = 0;
my $vala = 0;
while (<AEM>) {
   if (/\S+\s+\(.*\)\s+(\S+)\%/) {
      $ratioa = $1;
      $line ++;
      if ($line == 1) {
          print "The worst EM ratio is $ratioa\%\n";
      }
      if ($ratioa >= $avg_ratio) {
         $vala ++;
      } else {last}
   }
}
print "The total EM violations (>= $avg_ratio\%) is $vala\n";
if ($vala > 0) {
   print "Please refer ../$ARGV[2] to get more detail\n";
}
close (AEM);
print "\n";
