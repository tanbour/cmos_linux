#!/usr/bin/perl
$flag = 0;
while (<>) {
	#chomp;
	$line = $_;
	if (/^\d+\s+(\S+)\s+(-?\d+\.\d+)/) {
		$startpoint = $line; 
		$worst_slack = $2;
		$key = "$worst_slack,$startpoint";
		$startpoints{$key} = "";
		$flag = 1;
		next;
	}
	if ($flag == 1 && $line =~ m/^\s+\S+\s+(-?\d+\.\d+)/) {
		$endpoints{$line} = $1;
		next;
	}
	if ($flag == 1 && $line =~ m/^\s*\n$/) {
		$flag = 0;
		@endpoints = (sort {$endpoints{$a} <=> $endpoints{$b}} keys %endpoints);
		foreach $endpoint (@endpoints) {
			$startpoints{$key} = "$startpoints{$key}$endpoint";
		}
		foreach $endpoint (keys %endpoints) {
			delete $endpoints{$endpoint};
		}
		$worst_slack = "";
		$slartpoint = "";
		$key = "";
		next;
	}
	if ($flag == 0 && $line =~ m/^[^\d]/) {
		print "$line";
	}
}
foreach $start_point (sort {$a <=> $b} keys %startpoints) {
	@stkey = split(/,/, $start_point);
	print "$stkey[1]";
	print "$startpoints{$start_point}\n";
}
