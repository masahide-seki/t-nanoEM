use strict;
use warnings;


open(IN, "$ARGV[0]");
open(OUT, ">$ARGV[1]");

my @count = {};

my $header = <IN>;

while(my $line = <IN>){
    chomp $line;
    my @line = split(/\t/, $line);
    my $um = $line[2];
    my $me = $line[3];
    my $sum = $um + $me;
    $count[$sum]++;
}

my $length = $#count;

my $sum = 0;

my @sort = {};

print OUT "Coverage_threshold\tCount\n";

for(my $i = $length; $i >=1; $i--){
    if(defined($count[$i])){
        $sum += $count[$i];
        $sort[$i] = "$i\t$sum\n";
    }else{
        $sort[$i] = "$i\t$sum\n";
    }
}

for(my $i = 1; $i < $length + 1; $i++){
    print OUT $sort[$i];
}
