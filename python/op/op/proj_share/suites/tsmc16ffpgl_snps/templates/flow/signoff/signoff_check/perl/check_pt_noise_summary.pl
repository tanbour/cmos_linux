#!/usr/bin/perl
##################################################################################
# PROGRAM:     check_pt_noise_summary.pl
# CREATOR:     Zachary Shi <zacharys@alchip.com>
# DESCRIPTION: Check PT Noise report violations
# USAGE:       check_pt_noise_summary.pl noise.rep > noise.rep.summary
# INFORMATION: Initial version from Alchip Design Platform Group
# DATE:        Thu Jun 29 14:18:01 CST 2017
###################################################################################

#use strict;
my $flag       = 0 ;
my $slack      = "" ;
my $victim_net = "" ;

while ( <> ) {
    if ( /pin\sname\s\(net\sname\)\s+width\s+height\s+slack/ ) {
        $flag = 1 ;
    }
    if ( $flag == 1 ) {
        if ( /\S+\s+\((\S+)\)/ ) {
           ( $victim_net ) =
            /\S+\s+\((\S+)\)/ ;
            $flag = 0;
        }
    }
    if ( /Total:\s+\S+\s+\S+\s+(\S+)/ ) {
       ( $slack ) =
        /Total:\s+\S+\s+\S+\s+(\S+)/ ;
        $flag = 1;

        push ( @violations, "$slack   $victim_net" ) ;
        if   ( ( $slack <=  0.000) && ( $slack > -0.010 ) ) { $count_by_slack_range{"-0.000"}++ }
        elsif( ( $slack <= -0.010) && ( $slack > -0.020 ) ) { $count_by_slack_range{"-0.010"}++ }
        elsif( ( $slack <= -0.020) && ( $slack > -0.030 ) ) { $count_by_slack_range{"-0.020"}++ }
        elsif( ( $slack <= -0.030) && ( $slack > -0.040 ) ) { $count_by_slack_range{"-0.030"}++ }
        elsif( ( $slack <= -0.040) && ( $slack > -0.050 ) ) { $count_by_slack_range{"-0.040"}++ }
        elsif( ( $slack <= -0.050) && ( $slack > -0.060 ) ) { $count_by_slack_range{"-0.050"}++ }
        elsif( ( $slack <= -0.060) && ( $slack > -0.070 ) ) { $count_by_slack_range{"-0.060"}++ }
        elsif( ( $slack <= -0.070) && ( $slack > -0.080 ) ) { $count_by_slack_range{"-0.070"}++ }
        elsif( ( $slack <= -0.080) && ( $slack > -0.090 ) ) { $count_by_slack_range{"-0.080"}++ }
        elsif( ( $slack <= -0.090) && ( $slack > -0.100 ) ) { $count_by_slack_range{"-0.090"}++ }
        else                                                { $count_by_slack_range{"-0.100"}++ }
    }
}

my $violation_count = @violations ;
printf ( " Noise Report Summary\n" ) ;
printf ( " ---------------------------------------\n") ;
printf ( " Total noise violation count\t= $violation_count\n\n") ;

printf ( " Slack range        Count\n") ;
printf ( " ----------------  ------\n") ;
printf ( " %6.3f < %6.3f    %5d\n",  0.000, -0.010, $count_by_slack_range{"-0.000"} ) ;
printf ( " %6.3f < %6.3f    %5d\n", -0.010, -0.020, $count_by_slack_range{"-0.010"} ) ;
printf ( " %6.3f < %6.3f    %5d\n", -0.020, -0.030, $count_by_slack_range{"-0.020"} ) ;
printf ( " %6.3f < %6.3f    %5d\n", -0.030, -0.040, $count_by_slack_range{"-0.030"} ) ;
printf ( " %6.3f < %6.3f    %5d\n", -0.040, -0.050, $count_by_slack_range{"-0.040"} ) ;
printf ( " %6.3f < %6.3f    %5d\n", -0.050, -0.060, $count_by_slack_range{"-0.050"} ) ;
printf ( " %6.3f < %6.3f    %5d\n", -0.060, -0.070, $count_by_slack_range{"-0.060"} ) ;
printf ( " %6.3f < %6.3f    %5d\n", -0.070, -0.080, $count_by_slack_range{"-0.070"} ) ;
printf ( " %6.3f < %6.3f    %5d\n", -0.080, -0.090, $count_by_slack_range{"-0.080"} ) ;
printf ( " %6.3f < %6.3f    %5d\n", -0.090, -0.100, $count_by_slack_range{"-0.090"} ) ;
printf ( " %6.3f <           %5d\n", -0.100,        $count_by_slack_range{"-0.100"} ) ;
printf ( " ----------------  ------\n" ) ;
printf ( " Total              %5d\n\n", $violation_count ) ;

printf ( " Slack    Victim net\n" ) ;
printf ( " ------   ------------------------------------\n") ;
foreach $slack_vio ( @violations ) {
  print " $slack_vio\n" ;
}

