use strict;
use warnings;

#Names of input and output files
my $file1 = $ARGV[0];
my $file2 = $ARGV[1];
my $out= "$ARGV[2].tsv";
my $log= "$ARGV[2].log";

open(F1, "$file1");
open(F2, "$file2");
open(OUT, ">$out");
open(LOG, ">$log");

my $header = <F1>;
$header = <F2>;

my %hash;

my $OL = 0;
my $F1 = 0;
my $F2 = 0;

print OUT "chr\tposition\tfrequency_1\tfrequency_2\n";

while(my $line = <F1>){
    chomp $line;    
    my @line = split(/\t/,$line);
    $hash{$line[0]}{$line[2]} = $line[3];
#    print "$line[0]\n";
    $F1++;
}

while(my $line = <F2>){
    chomp $line;
    my @line = split(/\t/,$line);
    if(defined($hash{$line[0]}{$line[2]})){
        print OUT "$line[0]\t$line[2]\t$hash{$line[0]}{$line[2]}\t$line[3]\n";
        $OL++;
    }
    $F2++;
}

print LOG "f1:$file1\tf2:$file2\n";
my $F1U = $F1 - $OL;
my $F2U = $F2 - $OL;

print LOG "f1_total\tf2_total\tf1_uniq\tf2_uniq\tcommon\n";
print LOG "$F1\t$F2\t$F1U\t$F2U\t$OL\n";

