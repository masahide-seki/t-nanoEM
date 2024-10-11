use strict;
use warnings;

my $input = $ARGV[0];
my $judge = $ARGV[1];
my $output = $ARGV[2];

open(BAM, "samtools view -h $input |");
open(JUDGE, "$judge");
open(OUT, ">$output");

my %ref;
my %alt;

while(my $line = <JUDGE>){
    chomp $line;
    my @line = split(/\t/,$line);
    my @ref_read = split(/\,/,$line[5]);
    my @alt_read = split(/\,/,$line[6]);
    foreach my $rr (@ref_read){
        $ref{$rr} = 1;
    }
    foreach my $ar (@alt_read){
        $alt{$ar} = 1;
    }
}

while(my $line = <BAM>){
    chomp $line;
    if($line =~ /^@/){
	print OUT "$line\n";
	next;
    }
    my @line = split(/\t/,$line);
    my $rn = shift(@line);
    my $rest = join("\t", @line);
    my $rn2 = "";
    if($rn =~ /(.+)\_s\d+/){
	$rn2 = $1;
    }else{
	$rn2 = $rn;
    }
    if(defined($alt{$rn})){
        print OUT "$rn2\t$rest\tMU:i:1\n";
    }elsif(defined($ref{$rn})){
        print OUT "$rn2\t$rest\tMU:i:0\n";
    }else{
	print OUT "$rn2\t$rest\n";     
    }
}

