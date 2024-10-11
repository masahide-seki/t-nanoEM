use strict;
use warnings;

my $vcf = $ARGV[0];
my $bed = $ARGV[1];

open(IN ,"$ARGV[0].vcf");
open(OUT, ">$ARGV[0].SNV.bed");

while(my $line = <IN>){
    chomp $line;
    if($line =~ /^\#/){
	    next;
    }
    my @line = split(/\s/, $line);
    my $lr = length($line[3]);
    my $lq = length($line[4]);
    my $start = $line[1] - 1;
    if($lr ==1 and $lq == 1){
	    print OUT "$line[0]\t$start\t$line[1]\t$line[3]\,$line[4]\n";
    }

}
