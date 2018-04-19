#! /usr/bin/perl 
while( <> ) {
  if(/^\s+Pin:\s+(\S+)$/) { $pin = $1; }
  if(/^\s+slack\s+\S+\s+(\S+)$/) { 
    $slack = $1;
    print ("$slack\t$pin\n");
  }
}
