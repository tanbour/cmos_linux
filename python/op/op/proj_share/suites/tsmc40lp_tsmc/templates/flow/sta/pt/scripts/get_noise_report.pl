#! /usr/local/bin/perl
open (IN, $ARGV[0]);
while (<IN>) {
  if (/^\s+(\S+)\s+\((\S+)\)$/) {
    $violated_net = $2;
    $violated_pin = $1;
  }
  if (/Total:\s+\S+\s+\S+\s+(\S+)$/) {
    if (exists $violation{$violated_pin} == 0 || $violation{$violated_pin}->{slack} > $1) {
      $violation{$violated_pin}->{slack} = $1;
      $violation{$violated_pin}->{net} = $violated_net;
    }
  }
}
close IN;
print ("slack\tpin\(net\)\n");
foreach $pin (sort { $violation{$a}->{slack} <=> $violation{$b}->{slack} } keys %violation ) {
  print ("$violation{$pin}->{slack}\t$pin\($violation{$pin}->{net}\)\n");
}
