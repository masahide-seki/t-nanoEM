use strict;
use warnings;

my $vcf = $ARGV[0];
my $out = $ARGV[1];

if($vcf =~ /.gz$/) {
	open(IN, "gunzip $vcf |");
}else{
	open(IN ,"$vcf");
}
open(OUT, ">$out");

while(my $line = <IN>){
    chomp $line;
    if($line =~ /^\#/){
	    next;
    }
    my @line = split(/\s/, $line);
    my $lr = length($line[3]);
    my $lq = length($line[4]);
    my $start = $line[1] - 1;
#    print "$line[2]\n";
    if($lr ==1 and $lq == 1){
	if($line[9] =~ /^0\/1/){
	    print OUT "$line[0]\t$start\t$line[1]\t$line[3]\,$line[4]\n";
	}
    }
    if($lr == 1 and $lq == 3){
	if($line[9] =~ /^1\/2/){
	    if($lq == 3 and $line[4] !~ /\*/){
		print OUT "$line[0]\t$start\t$line[1]\t$line[4]\,aa\n";
		next;
	    }
	}
    }
}
