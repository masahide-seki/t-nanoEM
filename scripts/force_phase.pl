use strict;
use warnings;

my $in = $ARGV[0];
my $out = $ARGV[1];

open(IN, "zcat ${in}|");
open(OUT, ">${out}");


while(my $line = <IN>){
    chomp $line;
    if($line =~ /^\#/){
	print OUT "$line\n";
	next;
    }
    my @line = split(/\t/, $line);
    my $lr = length($line[3]);
    my $lq = length($line[4]);
    my $last = pop(@line);
    my $content = join("\t", @line);
    my $rest = "";
    if($lr ==1 and $lq == 1){
	if($last =~ /^0\/1(.+)/){
	    $rest = $1;
	    print OUT "$content\t0\|1$rest\n";
	    next;
	}
    }elsif($lr == 1 and $lq == 3){
	if($last =~ /^1\/2(.+)/){
	    $rest = $1;
	    if($line[4] !~ /\*/){
		print OUT "$content\t1\|2$rest\n";
		next;
	    }
	}
    }
    print OUT "$line\n";
	
    
}
