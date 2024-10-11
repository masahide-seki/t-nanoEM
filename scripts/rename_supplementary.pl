use strict;
use warnings;

my $input = $ARGV[0];

open(IN, "samtools view -h $input |");

my %hash;

while(my $line = <IN>){
    chomp $line;
    if($line =~ /^@/){
	print "$line\n";
	next;
    }
    my @line = split(/\t/,$line);
    my $rn = shift(@line);
    my $data = join("\t", @line); 
    if($line[0] == 0 or $line[0] == 16){
	print "$line\n";
    }elsif($line[0] == 2048 or $line[0] == 2064){
	$hash{$rn}++;
	$rn = "${rn}\_s$hash{$rn}";
	
	print "$rn\t$data\n";
	
    }

}

