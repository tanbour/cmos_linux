#! /usr/local/bin/perl
#use strict;

my $power_file = $ARGV[0];  #./adsPower/power_summary.rpt
my $static_inst_worst = $ARGV[1];  #./adsRpt/Static/*inst.worst
my $static_inst_total = $ARGV[2];  #./adsRpt/Static/*inst
my $static_em = $ARGV[3];  #./adsRpt/Static/*em.worst
my $IR_violation_cell = "static_ir_violation_cell.rpt"; ##IR-drop violation cells in static
my $violation_ir_ratio = 0.023;
my $violation_en_ratio = 99;

print "\n";
print "######################## redhawk summary report ##################\n";
print "#################################################################\n";

if (-e $power_file) {
open (POWER,$power_file);
while (<POWER>) {
   if (/^Total\s+(\d\S+)\s+(\d\S+)\s+(\d\S+)\s+(\S+)/) {
      print "The total power is $1 watt \n\tleakage power   : $2 watt \n\tinternal power  : $3 watt \n\tswitching power : $4 watt.\n";
      last;
   }
}
close (POWER);
}

if ( -e $static_inst_worst ) {
   open (SINSTW,$static_inst_worst);
   while (<SINSTW>) {
      if ( /^\s+(\S+)\s+\S+\s+\S+\s+(\S+)/ ) {
      $ir_drop_worst = 1 - $1/$2;
       print sprintf "The worst IR-Drop in static analysis is %.3f%% .\n",$ir_drop_worst*100;
      last;
      }
   }
   close (SINSTW);
}

if ($ir_drop_worst >= $violation_ir_ratio) {
   open (SINST,$static_inst_total);
   $val = 0;
   while (<SINST>) {
      if (/^\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+\(\s+(\S+)\,\s+(\S+)\)\s+(\S+)/) {
         $ir_drop = 1 - $1/$4;
         if ( $ir_drop > $violation_ir_ratio ) {
            $val ++;
            $cell{$val} = $8;
            $location_x{$val} = $6;
            $location_y{$val} = $7;
            $vdd_vss{$val} = $1;
            $ideal_vdd{$val} = $4;
            $IR_drop{$val} = $ir_drop*100;
            $vdd_drop{$val} = $2;
            $vss_bounce{$val} = $3;
            $pwr_net{$val} = $5;
         }
      }
   }
   print sprintf "The total IR-Drop violations (ir-drop >= %.3f%%)in static analysis is $val\n",$violation_ir_ratio*100;
   close (SINST);
}

if (-e $static_em) {
   open (SEM,$static_em);
   $val = 0;
   $vio = 0;
   while (<SEM>) {
      if (/\S+\s+\(.*\)\s+(\S+)\%\s+\S+/) {
         $val ++;
         if ($val == 1) {
            print "The worst EM ratio in static analysis is $1\%\n";
         }
         if ($1 > $violation_en_ratio) {
            $vio ++;
         } else {
            last
         }
      }
   }
      print "The total EM violations (> $violation_en_ratio\%) in static analysis is $vio\n\n";
   if ($vio > 0) {
      print "Warning : Have EM violation !! Please get more detail reference ../$static_em\n";
   }
   close (SEM);
}

if($ir_drop_worst > $violation_ir_ratio) {
   print sprintf "Warning : Have violations that ir-drop > %.3f%% !! Please get more detail reference $IR_violation_cell\n",$violation_ir_ratio*100;
   open (VINST, ">$IR_violation_cell");
   print VINST "#IR_Drop    #vdd-vss    #vdd_drop    #vss_bounce    #ideal_vdd    #pwr_net    #instance                       #location\n";
   foreach $num (sort {$IR_drop{$b} <=> $IR_drop{$a}} keys %IR_drop) {
      printf VINST "%.3f%%     $vdd_vss{$num}     $vdd_drop{$num}    $vss_bounce{$num}    $ideal_vdd{$num}    $pwr_net{$num}    $cell{$num}     ($location_x{$num} $location_y{$num})\n",$IR_drop{$num};
   }
}

printf "###################################################################\n";
printf "###################################################################\n";
print "\n";
