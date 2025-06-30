use strict;
use warnings;

my $phased = $ARGV[0];
my $input = $ARGV[1];

open(LIST, "samtools view $phased |");
open(CT, "samtools view -h $input.CT.sorted.bam |");
open(GA, "samtools view -h $input.GA.sorted.bam |");

open(OUTCT1, ">$input.CT.snv.sam");
open(OUTGA1, ">$input.GA.snv.sam");
open(OUTCT2, ">$input.CT.nosnv.sam");
open(OUTGA2, ">$input.GA.nosnv.sam");

my %h1;
my %h2;

while(my $line = <LIST>){
    chomp $line;
    if($line =~ /^\#/){
        next;
    }
    my @line = split(/\t/, $line);
    my $flag = $line[1];
    if(!defined($line[13])){
        next;
    }elsif($flag == 2048 or $flag == 2064){
        next;
    }
    my $rn = $line[0];
    foreach my $hp (@line[13 .. $#line]) {      
        if($hp eq 'MU:i:1'){
            $h1{$rn} = 1;
        }elsif($hp eq 'MU:i:0'){
            $h2{$rn} = 1;
        }
    }
}


while(my $line = <CT>){
    chomp $line;
    if($line =~ /^@/){
        print OUTCT1 "$line\n";
        print OUTCT2 "$line\n";
        next;
    }
    my @line = split(/\t/,$line);
    if($line[1] == 2048 or $line[1] == 2064){
        next;
    }
    if(defined($h1{$line[0]})){
        print OUTCT1 "$line\n";
    }elsif(defined($h2{$line[0]})){
        print OUTCT2 "$line\n";
    }
}

while(my $line = <GA>){
    chomp $line;
    if($line =~ /^@/){
        print OUTGA1 "$line\n";
        print OUTGA2 "$line\n";
        next;
    }
    my @line = split(/\t/,$line);
    if($line[1] == 2048 or $line[1] == 2064){
        next;
    }
    if(defined($h1{$line[0]})){
        print OUTGA1 "$line\n";
    }elsif(defined($h2{$line[0]})){
        print OUTGA2 "$line\n";
    }
}
