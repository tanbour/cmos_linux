#!/usr/bin/perl

$DIR_NAME = $ARGV[0];
$REPORT = $ARGV[1];

if ($REPORT =~ /(\S+)\.gz/) {
open(REP,"gzip -dc $REPORT |") || die ("cant open file : $REPORT");
} else {
open(REP,"<$REPORT") || die ("cant open file : $REPORT");
}
$REPORT_NAME = `basename $REPORT`;
chomp $REPORT_NAME;
$REPORT_NAME =~ s/\.rpt\b//g ;


 while (<REP>) {
      if (/^\s+-delay_type\s+(\S+)/) {
       $TIMING_TYPE = $1;
       $TIMING_GROUP_DIR = join "_" , $DIR_NAME , $TIMING_TYPE;
       system ("mkdir -p $TIMING_GROUP_DIR");
      } elsif (/^\s+Startpoint:\s.*/) {
       $NEEDPRINT = "";
       $NEEDPRINT = join "",$NEEDPRINT,$_; 
       next;
      } elsif (/^\s+Path Group: (\S+)/) {
          $NEEDPRINT = join "",$NEEDPRINT,$_;
          $group_name = $1;
          $group_name =~ s/\*/_/g;
          $have_group_name = (grep /\b$group_name\b/, @group_name);
    #      print "$group_name $have_group_name;\t";
          if ($have_group_name) {
              if ("$last_group" eq "$group_name") {
              #  print "$last_group eq $group_name;\n";
              } else {
               # print "$last_group nq $group_name;\n";
                close NEW_RTP;
                $GROUP_TIMING = "$REPORT_NAME.$group_name.rpt";
                $GROUP_TIMING_REPORT = "$TIMING_GROUP_DIR/$GROUP_TIMING";
                open NEW_RTP,">> $GROUP_TIMING_REPORT" or die "Cant write file : $GROUP_TIMING_REPORT";
              }
          } else {
         #   print "AFirstG: $group_name\n";
            if (defined $have_open) {close NEW_RTP;} else {$have_open = 1;}
            push (@group_name, $group_name);
            $GROUP_TIMING = "$REPORT_NAME.$group_name.rpt";
            $GROUP_TIMING_REPORT = "$TIMING_GROUP_DIR/$GROUP_TIMING";
            open NEW_RTP,"> $GROUP_TIMING_REPORT" or die "Cant write file : $GROUP_TIMING_REPORT";
          }
          $last_group = $group_name;
           next;
       } elsif (/^\s+slack \(.*\)\s+(\S+)/) {
            $NEEDPRINT = join "",$NEEDPRINT,$_;
            print NEW_RTP "$NEEDPRINT\n\n\n";
#            close NEW_RTP;
            next;
       } else {
        $NEEDPRINT = join "",$NEEDPRINT,$_;
       }
}
foreach $group_name (@group_name) {
   $f = "$TIMING_GROUP_DIR/$REPORT_NAME.$group_name.rpt";
#   `perl ${blk_utils_dir}/check_violation_summary.pl $f > $f.sum`;
   `perl /proj/FJR1300/UTILS/icc2_utils/check_violation_summary.pl $f > $f.sum`;
   `perl /proj/FJR1300/UTILS/icc2_utils/sort_sta_violation_summary.pl $f.sum > $f.sum.sort`;
   `rm $f.sum`;
#   print "perl /proj/Beige/UTILS/icc2_utils/check_violation_summary.pl $f > $f.sum\n";
#   print "perl /proj/Beige/UTILS/icc2_utils/sort_sta_violation_summary.pl $f.sum > $f.sum.sort\n";
#   print "rm $f.sum\n";

}
close REP;


