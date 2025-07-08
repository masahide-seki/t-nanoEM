use strict;
use warnings;

my $input = $ARGV[0];
my $output = $ARGV[1];

open(IN, "samtools view -h $input |");
open(OUT, "> $output");

while(my $line = <IN>){
    if($line =~ /^@/){
        print OUT "$line";
        next;
    }
    chomp $line;
    my @line = split(/\t/, $line);
    if($line[1] == 2048){
        $line[1] = 0;
    }
    my $joined = join("\t", @line);
    print OUT "$joined\n";
}
