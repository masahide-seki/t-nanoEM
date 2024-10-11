use strict;
use warnings;

my $input = $ARGV[0];
my $pseudo = $ARGV[1];
my $output = $ARGV[2];

open(BAM, "samtools view -h $input |");
open(PBAM, "samtools view $pseudo |");
open(OUT, ">$output");

my %hash;

while(my $line = <PBAM>){
    chomp $line;
    my @line = split(/\t/,$line);
    if(defined($line[12])){
	$hash{$line[0]} = "$line[12]\t$line[13]\t$line[14]";
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
    if(defined($hash{$rn})){
	print OUT "$rn2\t$rest\t$hash{$rn}\n";
	
    }else{
        print OUT "$rn2\t$rest\n";
    }
}

