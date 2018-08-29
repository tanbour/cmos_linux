#! /usr/local/bin/perl
my $timing = $ARGV[0];
my $rpt = $ARGV[1];
my $flag = 0;
my %clock = ();
my %inst = ();
my $sum = 0;
my %clockIRavg = ();
my %clockIRmin = ();
my %dataIRavg = ();
my %dataIRmin = ();
my %nofuncIRavg = ();
my %nofuncIRmin = ();
my $VDDPower = "0.8";
my $min_clockIRavg_p =  "8";
my $min_clockIRmin_p =  "12.5";
my $min_dataIRavg_p =  "8";
my $min_dataIRmin_p =  "15";
my $min_nofuncIRavg_p = "8";
my $min_nofuncIRmin_p = "15";

open (STA, $timing) || die "$timing : $!";
open (RPT, $rpt) || die "$rpt : $!";
print "############## CLOCK DOMAIN ####################\n";
print "#CLOCK <rise> <fall> <period> <root>\n";
while (<STA>) {
   if ( /^CLOCK\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)+\s+(\S+)/ ) {
      next if exists $clock{$5};
      $clock{$5} = $4;
#      print "CLOCK $1 $2 $3 $4\n";
   }
   if ( /^# 3\) TIMING WINDOWS OF LEAF PINS/ ) {
      $flag = 1; 
   }
   next if /^#/;
   next if $flag eq 0;
   if ( /^(\S+)\/\S+\s+\S+\s+(\S+)\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)/ ) {
      my $is_clock = $2;
      my $name = $1;
      my $clock_name = $3;
      if ( $is_clock eq 0 ) {
         next if exists $inst{$1};
      }
      if ( $is_clock eq "1" ) {
         $inst{$name} = $clock_name;
#         print "IS_CLOCK $name $clock{$inst{$name}}\n";
      } else {
         $inst{$name} = "none";
#         print "IS_DATA $name\n";
      }
   }
}


print "################################################\n";
print "\n";
print "############### VIOLATION SUMMARY ##############\n";
while (<RPT>) {
   next if /^#/;
   if ( /^\S+\s+\S+\s+(\S+)\s+\S+\s+\S+\s+(\S+)\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)/ ) {
      my $instname = $3;
      my $avg = $1;
      my $min = $2;
      print "$instname $avg $min" > a;
      if ( exists $inst{$instname} ) {
         if ( $inst{$instname} ne "none" ) {
            $clockIRavg{$instname} = $avg;
            $clockIRmin{$instname} = $min;
         } else {
            $dataIRavg{$instname} = $avg;
            $dataIRmin{$instname} = $min;
         }
      } else {
         $nofuncIRavg{$instname} = $avg;
         $nofuncIRmin{$instname} = $min;
      }
   }
}
my $firstline = 1;
my $firstdone = 0;
my $maxIR = 0;
$sum = 0;
print "#clock PATH TYPE  #INST NAME  #AVG > $min_clockIRavg_p%  #clock_root\n";
foreach $key (sort { $clockIRavg{$a} <=> $clockIRavg{$b} } keys %clockIRavg) {
   if ( $firstline eq 1 && $firstdone eq 0 ) {
      print "is_clock $key $clockIRavg{$key} $clock{$inst{$key}}\n";
      $maxIR = ( $VDDPower - $clockIRavg{$key} ) / $VDDPower * 100;
      $firstdone = 1;
   }
   $min_clockIRavg = $VDDPower * (1 - $min_clockIRavg_p/100.0);
   next if $clockIRavg{$key} > $min_clockIRavg;
   if ( $firstline ne 1) {
      print "is_clock $key $clockIRavg{$key} $clock{$inst{$key}}\n";
   }
   $sum = $sum + 1;
   $firstline = 0;
}
print "##AVG clock SUM > $min_clockIRavg_p%: $sum (MAX : $maxIR%)\n";
$firstline = 1;
$firstdone = 0;
$maxIR = 0;
$sum = 0;
print "\n";
print "#data PATH TYPE  #INST NAME  #AVG > $min_dataIRavg_p%\n";
foreach $key (sort { $dataIRavg{$a} <=> $dataIRavg{$b} } keys %dataIRavg) {
   if ( $firstline eq 1 && $firstdone eq 0 ) {
      print "is_data $key $dataIRavg{$key}\n";
      $maxIR = ( $VDDPower - $dataIRavg{$key} ) / $VDDPower * 100;
      $firstdone = 1;
   }
   $min_dataIRavg = $VDDPower * (1 - $min_dataIRavg_p/100.0);
   next if $dataIRavg{$key} > $min_dataIRavg;
   if ( $firstline ne 1) {
      print "is_data $key $dataIRavg{$key}\n";
   }
   $sum = $sum + 1;
   $firstline = 0;
}
print "##AVG data SUM > $min_dataIRavg_p%: $sum (MAX : $maxIR%)\n";
$firstline = 1;
$firstdone = 0;
$maxIR = 0;
$sum = 0;
print "\n";
print "#clock PATH TYPE  #INST NAME  #MIN > $min_clockIRmin_p%  #clock_root\n";
foreach $key (sort { $clockIRmin{$a} <=> $clockIRmin{$b} } keys %clockIRmin) {
   if ( $firstline eq 1 && $firstdone eq 0 ) {
      print "is_clock $key $clockIRmin{$key} $clock{$inst{$key}}\n";
      $maxIR = ( $VDDPower - $clockIRmin{$key} ) / $VDDPower * 100;
      $firstdone = 1;
   }
   $min_clockIRmin = $VDDPower * (1 - $min_clockIRmin_p/100.0);
   next if $clockIRmin{$key} > $min_clockIRmin;
   if ( $firstline ne 1) {
      print "is_clock $key $clockIRmin{$key} $clock{$inst{$key}}\n";
   }
   $sum = $sum + 1;
   $firstline = 0;
}
print "##MIN clock SUM > $min_clockIRmin_p%: $sum (MAX : $maxIR%)\n";
$firstline = 1;
$firstdone = 0;
$maxIR = 0;
$sum = 0;
print "\n";
print "#data PATH TYPE  #INST NAME  #MIN > $min_dataIRmin_p%\n";
foreach $key (sort { $dataIRmin{$a} <=> $dataIRmin{$b} } keys %dataIRmin) {
   if ( $firstline eq 1 && $firstdone eq 0 ) {
      print "is_data $key $dataIRmin{$key}\n";
      $maxIR = ( $VDDPower - $dataIRmin{$key} ) / $VDDPower * 100;
      $firstdone = 1;
   }
   $min_dataIRmin = $VDDPower * (1 - $min_dataIRmin_p/100.0);
   next if $dataIRmin{$key} > $min_dataIRmin;
   if ( $firstline ne 1) {
      print "is_data $key $dataIRmin{$key}\n";
   }
   $sum = $sum + 1;
   $firstline = 0;
}
print "##MIN data SUM > $min_dataIRmin_p%: $sum (MAX : $maxIR%)\n";
$firstline = 1;
$firstdone = 0;
$maxIR = 0;
$sum = 0;
print "\n";
print "#notiming PATH TYPE  #INST NAME  #AVG > $min_nofuncIRavg_p%\n";
foreach $key (sort { $nofuncIRavg{$a} <=> $nofuncIRavg{$b} } keys %nofuncIRavg) {
   next if $nofuncIRavg{$key} eq "n/a";
   if ( $firstline eq 1 && $firstdone eq 0 ) {
      print "is_no_timing $key $nofuncIRavg{$key}\n";
      $maxIR = ( $VDDPower - $nofuncIRavg{$key} ) / $VDDPower * 100;
      $firstdone = 1;
   }
   $min_nofuncIRavg = $VDDPower * (1 - $min_nofuncIRavg_p/100.0);
   next if $nofuncIRavg{$key} > $min_nofuncIRavg;
   if ( $firstline ne 1) {
      print "is_no_timing $key $nofuncIRavg{$key}\n";
   }
   $sum = $sum + 1;
   $firstline = 0;
}
print "##AVG notiming SUM > $min_nofuncIRavg_p%: $sum (MAX : $maxIR%)\n";
$firstline = 1;
$firstdone = 0;
$maxIR = 0;
$sum = 0;
print "\n";
print "#notiming PATH TYPE  #INST NAME  #MIN > $min_nofuncIRmin_p%\n";
foreach $key (sort { $nofuncIRmin{$a} <=> $nofuncIRmin{$b} } keys %nofuncIRmin) {
   if ( $firstline eq 1 && $firstdone eq 0 ) {
      print "is_no_timing $key $nofuncIRmin{$key}\n";
      $maxIR = ( $VDDPower - $nofuncIRmin{$key} ) / $VDDPower * 100;
      $firstdone = 1;
   }
   $min_nofuncIRmin = $VDDPower * (1 - $min_nofuncIRmin_p/100.0);
   next if $nofuncIRmin{$key} > $min_nofuncIRmin;
   if ( $firstline ne 1) {
      print "is_no_timing $key $nofuncIRmin{$key}\n";
   }
   $sum = $sum + 1;
   $firstline = 0;
}
print "##MIN notiming SUM > $min_nofuncIRmin_p%: $sum (MAX : $maxIR%)\n";
