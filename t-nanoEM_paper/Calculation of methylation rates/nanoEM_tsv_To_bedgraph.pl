use strict;
use warnings;

my $in = $ARGV[0];
my $out = $ARGV[1];
my $threshold = $ARGV[2];

open(IN, "$in");
open(OUT, ">$out");

print OUT 'track type=bedGraph';
print OUT "\n";

while(my $line = <IN>){
    chomp $line;
    if($line =~ /^chromosome/){
        next;
    }
    my @line = split(/\t/, $line);
    my $cov = $line[2] + $line[3];
    if($cov >= $threshold){
        my $start = $line[1] -1;
        my $meth = $line[4] * 100;
        print OUT "$line[0]\t$start\t$line[1]\t$meth\n";
    }
}
