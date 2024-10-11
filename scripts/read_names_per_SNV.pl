use strict;
use warnings;

my $bed = $ARGV[0];
my $mpu = $ARGV[1];

open(BED, "$bed");
open(MPU, "$mpu");

my %hash;

while(my $line = <BED>){
    chomp $line;
    my @line = split(/\t/, $line);
    my @base = split(/\,/, $line[3]);
    if(defined($base[2])){
	$hash{$line[0]}{$line[2]}{AA} = '1/2';
    }else{
	$hash{$line[0]}{$line[2]}{AA} =	'0/1';
    }
    $hash{$line[0]}{$line[2]}{r} = $base[0];
    $hash{$line[0]}{$line[2]}{a} = $base[1];
}

while(my $line = <MPU>){
    chomp $line;
    my @line = split(/\t/, $line);
    my $ref = $hash{$line[0]}{$line[1]}{r};
    my $alt = $hash{$line[0]}{$line[1]}{a};
    my $aa = $hash{$line[0]}{$line[1]}{AA};
    if($aa eq '0/1' and $ref ne uc($line[2])){
	print "Error\t$line\n";
	next;
    }
    my %judge;
    if($ref eq "C" and $alt eq "T"){ #C->T:Fw:A(x),T(x:a or r),G(x),C(x:r); Rv: a(x), t(a), g(x), c(r)
	$judge{"\,"} = "r";
	$judge{"t"} = "a";
	$judge{"\."} = "r";
    }elsif($ref eq "C" and $alt eq "A"){ #C->A:Fw: A(a), T(r),  C(r), G(x); RV: a(a), t(x), g(x), c(r)
	$judge{"T"} = "r";
	$judge{"\."} = "r";
	$judge{"\,"} = "r";
        $judge{"A"} = "a";
	$judge{"a"} = "a";
    }elsif($ref eq "C" and $alt eq "G"){#C->G:Fw: A(x), T(r),  C(r), G(a); RV: a(a), t(x), g(a), c(r)
	$judge{"T"} = "r";
	$judge{"\."} = "r";
	$judge{"\,"} = "r";
	$judge{"G"} = "a";
	$judge{"a"} = "a";
	$judge{"g"} = "a";
    }elsif($ref eq "A" and $alt eq "T"){#A->T:Fw: A(r), T(a),  C(x), G(x); RV: a(r), t(a), g(x), c(x)
        $judge{"\."} = "r";
	$judge{"\,"} = "r";
        $judge{"T"} = "a";
	$judge{"t"} = "a";
    }elsif($ref eq "A" and $alt eq "G"){#A->G:Fw: A(r), T(x),  C(x), G(a); RV: a(x:r or a), t(x), g(x:a), c(x)
        $judge{"\."} = "r";
        $judge{"G"} = "a";
	$judge{"g"} = "a";
    }elsif($ref eq "A" and $alt eq "C"){#A->C:Fw: A(r), T(a),  C(a), G(x); RV: a(r), t(x), g(x), c(a)
        $judge{"\."} = "r";
	$judge{"\,"} = "r";
        $judge{"T"} = "a";
	$judge{"C"} = "a";
	$judge{"c"} = "a";
    }elsif($ref eq "G" and $alt eq "A"){#G->A:Fw: A(a), T(x),  C(x), G(r); RV: a(x:r or a), t(x), g(x:r), c(x)
        $judge{"\."} = "r";
        $judge{"A"} = "a";
	$judge{"g"} = "r";
    }elsif($ref eq "G" and $alt eq "T"){#G->T:Fw: A(x), T(a),  C(x), G(r); RV: a(r), t(a), g(r), c(x)
        $judge{"\."} = "r";
	$judge{"a"} = "r";
	$judge{"\,"} = "r";
        $judge{"T"} = "a";
	$judge{"t"} = "a";
    }elsif($ref eq "G" and $alt eq "C"){#G->C:Fw: A(x), T(a),  C(a), G(r); RV: a(r), t(x), g(r), c(a)
	$judge{"\."} = "r";
	$judge{"\,"} = "r";
	$judge{"a"} = "r";
        $judge{"C"} = "a";
	$judge{"T"} = "a";
	$judge{"c"} = "a";
    }elsif($ref eq "T" and $alt eq "A"){#T->A:Fw: A(a), T(r),  C(x), G(x); RV: a(a), t(r), g(x), c(x)
	$judge{"\."} = "r";
	$judge{"\,"} = "r";
        $judge{"A"} = "a";
	$judge{"a"} = "a";
    }elsif($ref eq "T" and $alt eq "G"){#T->G:Fw: A(x), T(r),  C(x), G(a); RV: a(a), t(r), g(a), c(x)
	$judge{"\."} = "r";
	$judge{"\,"} = "r";
        $judge{"G"} = "a";
	$judge{"g"} = "a";
	$judge{"a"} = "a";
    }elsif($ref eq "T" and $alt eq "C"){#T->C:Fw: A(x), T(x r or a),  C(x a), G(x); RV: a(x), t(r), g(x), c(a)
	$judge{"\,"} = "r";
        $judge{"c"} = "a";
	$judge{"C"} = "a";
    }
    my $ref_rn = "";
    my $alt_rn = "";
    my $ref_c = 0;
    my $alt_c = 0;
    my @rn = split(/\,/, $line[6]);
    my @pl = split(//, $line[4]);
    foreach my $rn (@rn){
	my $base = shift(@pl);
	my $num = "";
	my $temp = "";
	if($base eq "\+" or $base eq "\-"){
	    $temp = shift(@pl);
	    while($temp =~ /\d/){
		$num = "$num$temp";
		$temp = shift(@pl);
	    }
	    for(my $i = 1; $i < $num; $i++){
		$temp = shift(@pl);
	    }
	    $base = shift(@pl);
	}elsif($base eq "\$"){
	    $base = shift(@pl);
	}elsif($base eq "\^"){
	    $temp = shift(@pl);
	    $base = shift(@pl);
	}
	
	if(defined($judge{$base})){
	    if($judge{$base} eq "r"){
		$ref_c++;
		if($ref_rn eq ""){
		    $ref_rn = $rn;
		}else{
		    $ref_rn = "$ref_rn\,$rn";
		}
	    }elsif($judge{$base} eq "a"){
		$alt_c++;
		if($alt_rn eq ""){
                    $alt_rn = $rn;
		}else{
                    $alt_rn = "$alt_rn\,$rn";
		}
		
	    }
	}
    }
    print "$line[0]\t$line[1]\t$ref\t$alt\t$aa\t$ref_rn\t$alt_rn\t$ref_c\t$alt_c\n";
}
    
