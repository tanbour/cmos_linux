#! /usr/local/bin/perl

my $PWR = $ARGV[0]; # ./adsRpt/power_summary.rpt
my $IR_pin = $ARGV[1]; # ./adsRpt/Dynamic/*.dvd.pin
my $IR_arc = $ARGV[2]; #./adsRpt/Dynamic/*.dvd.arc
my $timing = $ARGV[3]; # timing file
my $IP_list = $ARGV[4]; # IP list
my %clock = ();
my %IPCELL = ();
my %INST = ();
my %INSTn = ();
my @pgpins;
my %voltage = ();
my $result_file = "PIN_dynamic.info";
my %groundarc = ();
my %groundarc_power = ();
my %PG = ();

my $input_avg_ppp = 0;
my $input_min_clock_ppp = 0;
my $input_min_data_ppp = 0;
################# code ########################

if ( -e $IP_list ) {
open (IP, $IP_list) || die "$IP_list : $!";
   while (<IP>) {
      if (/^(\S+)/) {
         next if exists $IPCELL{$1};
         $IPCELL{$1} = $1;
      }
   }
   close IP;
}

open (STA, $timing) || die "$timing : $!";
my $flag = 0;
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
         next if exists $INST{$1}{clock};
      }
      if ( $is_clock eq "1" ) {
         $INST{$name}{clock} = $clock{$clock_name};
      } else {
         $INST{$name}{clock} = "signal";
      }
   }
}

open(PWR,$PWR) || die "$PWR : $!";
while (<PWR>) {
   if (/^Vdd_domain/) {
      $vol_flag = 1
   }
   next if $vol_flag = 0;
   if (/^(\S+)\s+\((\S+)V\)/) {
      $voltage{$1} = $2;
   }
   if (/^For NA domain, the instance/) {
      $vol_flag = 0;
   }
}  
close PWR;
if ( -e $IR_pin ) {
   open (IR_pin, $IR_pin) || die "$IR_pin : $!";
   while (<IR_pin>) {
      if (/^(\d\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/) {
         if ( -e $IP_list ) {
            next if ! exists $IPCELL{$10};
         }
         $INSTn{$11} = 1;
         $INST{$11}{cell} = $10;
         $INST{$11}{$3}{avg_tw} = $5;
         $INST{$11}{$3}{worst_cyc} = $8;
         $INST{$11}{$3}{net} = $4;
         $vnets = $3;
         $vname = $11;
         if ( exists $voltage{$4}) {
            $INST{$vname}{$vnets}{voltage} = $voltage{$4};
         } else {
            $INST{$vname}{$vnets}{voltage} = "-";
         }
         next if exists $INST{$11}{$3}{pin};
         $INST{$11}{$3}{pin} = $3;
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
      if (/^(\d\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\d)\s+(\S+)/) {
         next if ! exists $INST{$13}{cell};
         $INST{$13}{$3}{powerARC} = $3;
         $INST{$13}{$3}{groundARC} = $4;
         $INST{$13}{$3}{eff_vdd} = $7;
         $INST{$13}{$3}{min_pg_cyc} = $10;
         my $filerpower = $3;
         if ( exists $groundarc_power{$13}{$4} and $groundarc_power{$13}{$4} ne $filerpower) {
            $groundarc_power{$13}{$4} = "multi";
         }
         next if exists $groundarc{$13}{$4};
         $groundarc{$13}{$4} = $4; 
         $groundarc_power{$13}{$4} = $3;
      }
   }
   close IR_arc;
}

open (RESULT, ">$result_file") || die "$result_file : $!";
printf RESULT "#avg_tw(pin) #worst_cyc(pin)  #voltage  #eff(arc)  #min_pg_cyc(arc)   #pin  #net  #instance  #cell  #is_clock\n";
while (($key,$value) = each %INSTn) {
   chomp $key;
   chomp $value;
   foreach $pgpin ( @pgpins ) {
      if (exists $INST{$key}{$pgpin}{pin}) {
         if ( ! exists $INST{$key}{$pgpin}{avg_tw} ) {
            $INST{$key}{$pgpin}{avg_tw} = "-";
         } elsif ($INST{$key}{$pgpin}{avg_tw} eq "n/a") {
            $INST{$key}{$pgpin}{avg_tw} = "-"
         }
         if ( ! exists $INST{$key}{$pgpin}{worst_cyc} ) {
            $INST{$key}{$pgpin}{worst_cyc} = "-";
         } elsif ($INST{$key}{$pgpin}{worst_cyc} eq "n/a") {
            $INST{$key}{$pgpin}{worst_cyc} = "-";
         }
         if ( ! exists $INST{$key}{$pgpin}{net} ) {
            $INST{$key}{$pgpin}{net} = "-";
         }
         if ($INST{$key}{$pgpin}{voltage} eq "-" and exists $groundarc{$key}{$pgpin}) {
            $INST{$key}{$pgpin}{voltage} = 0;
         }
         if ( ! exists $INST{$key}{$pgpin}{voltage} ) {
            if ( exists $voltage{$pgpin}) {
                  $INST{$key}{$pgpin}{voltage} = $voltage{$pgpin};
            } elsif ( exists $groundarc{$key}{$pgpin}) {
               $INST{$key}{$pgpin}{voltage} = 0;
            } else {
               $INST{$key}{$pgpin}{voltage} = "-";
            }
         }
         if ( ! exists $INST{$key}{$pgpin}{groundARC} ) {
            $INST{$key}{$pgpin}{groundARC} = "-";
         }
         if ( ! exists $INST{$key}{$pgpin}{powerARC} ) {
            $INST{$key}{$pgpin}{powerARC} = "-";
         }
         if ( ! exists $INST{$key}{$pgpin}{eff_vdd} ) {
            if ( exists $groundarc{$key}{$pgpin} ) {
               if ($INST{$key}{$pgpin}{avg_tw} ne "n/a") {
                  $INST{$key}{$pgpin}{eff_vdd} = $INST{$key}{$pgpin}{avg_tw};
               } else {
                  $INST{$key}{$pgpin}{eff_vdd} = "-";
               }
            } else {
               $INST{$key}{$pgpin}{eff_vdd} = "-";
            }
         } elsif ($INST{$key}{$pgpin}{eff_vdd} eq "n/a") {
            $INST{$key}{$pgpin}{eff_vdd} = "-";
         }
         if ( ! exists $INST{$key}{$pgpin}{min_pg_cyc} ) {
            if ( exists $groundarc{$key}{$pgpin} ) {
               if ($INST{$key}{$pgpin}{worst_cyc} ne "n/a") {
                  $INST{$key}{$pgpin}{min_pg_cyc} = $INST{$key}{$pgpin}{worst_cyc};
               } else {
                  $INST{$key}{$pgpin}{min_pg_cyc} = "-";
               }
            } else {
               $INST{$key}{$pgpin}{min_pg_cyc} = "-";
            }
         } elsif ($INST{$key}{$pgpin}{min_pg_cyc} eq "n/a") {
            $INST{$key}{$pgpin}{min_pg_cyc} = "-";
         }
         if ( $INST{$key}{$pgpin}{voltage} ne "-" and $INST{$key}{$pgpin}{eff_vdd} ne "-" and $INST{$key}{$pgpin}{min_pg_cyc} ne "-") {
            if ( ! exists $groundarc{$key}{$pgpin} ) {
               $p_eff  = ( $INST{$key}{$pgpin}{voltage} - $INST{$key}{$pgpin}{eff_vdd} ) / $INST{$key}{$pgpin}{voltage} * 100;
               $p_min_pg_cyc = ( $INST{$key}{$pgpin}{voltage} - $INST{$key}{$pgpin}{min_pg_cyc} ) / $INST{$key}{$pgpin}{voltage} * 100;
            } elsif ($groundarc_power{$key}{$pgpin} ne "multi" and $INST{$key}{$groundarc_power{$key}{$pgpin}}{voltage} ne "-"){
               $p_eff = $INST{$key}{$pgpin}{eff_vdd} / $INST{$key}{$groundarc_power{$key}{$pgpin}}{voltage} * 100;
               $p_min_pg_cyc = $INST{$key}{$pgpin}{min_pg_cyc} / $INST{$key}{$groundarc_power{$key}{$pgpin}}{voltage} * 100;
            } elsif ($groundarc_power{$key}{$pgpin} eq "multi") {
               $p_eff = 0;
               $p_min_pg_cyc = 0;
            } else {
               $p_eff = "-";
               $p_min_pg_cyc = "-";
            }
         } else {
            $p_eff = 0;
            $p_min_pg_cyc = 0;
         }
         if ( ! exists $INST{$key}{clock} ) {
            $INST{$key}{clock} = "notCover";
         }
         if ( $INST{$key}{clock} eq "notCover") {
            if ($p_eff > $input_min_data_ppp or $p_min_pg_cyc > $input_min_data_ppp ) {
               printf RESULT "%-6s\t%-6s\t%3s\t%-6s( %1.4f %)\t%-6s( %1.4f %)\t%3s\t%s\t%s\t%s\t%s\n",$INST{$key}{$pgpin}{avg_tw},$INST{$key}{$pgpin}{worst_cyc},$INST{$key}{$pgpin}{voltage},$INST{$key}{$pgpin}{eff_vdd},$p_eff,$INST{$key}{$pgpin}{min_pg_cyc},$p_min_pg_cyc,$INST{$key}{$pgpin}{pin},$INST{$key}{$pgpin}{net},$key,$INST{$key}{cell},$INST{$key}{clock};
            }
         } elsif ($INST{$key}{clock} eq "signal") {
            if ($p_eff > $input_avg_ppp or $p_min_pg_cyc > $input_avg_ppp ) {
               printf RESULT "%-6s\t%-6s\t%3s\t%-6s( %1.4f %)\t%-6s( %1.4f %)\t%3s\t%s\t%s\t%s\t%s\n",$INST{$key}{$pgpin}{avg_tw},$INST{$key}{$pgpin}{worst_cyc},$INST{$key}{$pgpin}{voltage},$INST{$key}{$pgpin}{eff_vdd},$p_eff,$INST{$key}{$pgpin}{min_pg_cyc},$p_min_pg_cyc,$INST{$key}{$pgpin}{pin},$INST{$key}{$pgpin}{net},$key,$INST{$key}{cell},$INST{$key}{clock};
            } 
         } else {
            if ($p_eff > $input_min_clock_ppp or $p_min_pg_cyc > $input_min_clock_ppp ) {
               printf RESULT "%-6s\t%-6s\t%3s\t%-6s( %1.4f %)\t%-6s( %1.4f %)\t%3s\t%s\t%s\t%s\t%s\n",$INST{$key}{$pgpin}{avg_tw},$INST{$key}{$pgpin}{worst_cyc},$INST{$key}{$pgpin}{voltage},$INST{$key}{$pgpin}{eff_vdd},$p_eff,$INST{$key}{$pgpin}{min_pg_cyc},$p_min_pg_cyc,$INST{$key}{$pgpin}{pin},$INST{$key}{$pgpin}{net},$key,$INST{$key}{cell},$INST{$key}{clock};
            }
         }
      }
   }
}
