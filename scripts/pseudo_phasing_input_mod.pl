#!/usr/bin/perl
#$ -S /usr/bin/perl
# Revision: 1.0.0
#  Date: 2024/03/29
#  Copyright c 2024, by DYNACOM Co.,Ltd.

#############################################################################################


use strict;
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);
use FileHandle;
use Data::Dumper;
use Bio::DB::Fasta;


################################################################################
### Usage
#################################################################################
my %options=("mergen" => 0  , "skip" => 1);
my @optary = ( "help|h" , "out|o:s", "input|i:s","fasta|f:s","mergen|m:i", "skip|s:i");
GetOptions(\%options, @optary) or &usage(0);

if ( $options{help} ) { &usage(1); }
sub usage {
	my ($flag, $mes) = @_;
	chomp(my $program = `basename $0`);
	my $usage = " Usage: $program -i input_snp_mpileup.fasta -f genome.fa -m 0  \n";
	$usage   .= "        qsub -cwd $program -i input_snp_mpileup.fasta -f genome.fa -m 0 \n";
	$usage   .= "   e.g. $program \n \n";

	my $help = <<'&EOT&';
	- - - - - - - -
		[Options]
		-h --help     ... help
		-o --out      ... output file prefix            e.g sample
		-i --input    ... input mpilup on snp region.
		-f --fasta    ... refarence fasta 
		-m --mergen   ... mergen of seq edge padding(def:0 , 0 recommend)
		-s --skip     ... skip read legnth (def:1)

&EOT&
	print " !! $mes\n\n" if $mes;
	print $usage;
	print $help if $flag;
	exit 1;
}

################################################################################
## Sub
#################################################################################

sub GetIndextStats{
	my $hashref = shift;
	my %hash = %{$hashref};

	my @detcted_list;
	my $num_of_detectIndex = 0;
	foreach my $index_name (keys( %hash )){
		$num_of_detectIndex++;
		foreach my $strand ("Fw","Rv" ){
			foreach my $pos (keys( %{$hash{$index_name}{$strand}} )){
				my $dist = $hash{$index_name}{$strand}{$pos};
				push( @detcted_list ,"$index_name,$strand,$pos,$dist" );
			}
		}
	}
	return( $num_of_detectIndex , join(":",@detcted_list) );
}

################################################################################
## main funciton
#################################################################################

sub main {
	my $options = shift;
	my $in      = $$options{input};
	my $out     = $$options{out};
	my $fa      = $$options{fasta};
	my $length_filter = $$options{skip};
	my $mergen  =(exists( $$options{mergen})) ? $$options{mergen} : 0 ;

	#############################################
	#--- Get REF Fasta
	#############################################
	my $fa_flag = ( $fa ) ? 1 : 0 ;
	my $db ;
	if ($fa ){
		$db = Bio::DB::Fasta->new($fa );
	}
	#print "fasta flg  =  $fa_flag\n";

	#############################################
	#--- Get Read SNP Inf
	#############################################
	my %snp_dict ; # read_id -> chr -> st -> A/C/G/T
	my %nm_dict  ;
	
	open(my $fh , "< $in") || die "cannot open $in :$!";
	open(my $oh , "> $out") || die "cannot open $out :$!";

	while (my $line = <$fh>){
		$line =~s/\r\n|\n|\r//g;
		my ( $chr , $pos , $ref, $alt , $geno , $ref_fq_data , $alt_fq_data , $ref_tag , $alt_tag ) = split(/\t/,$line);
		my @ref_fq_list = split(/,/ ,$ref_fq_data);
		my @alt_fq_list = split(/,/ ,$alt_fq_data);
		
		# ref_fq
		foreach  my $fqid( @ref_fq_list){
			$snp_dict{$fqid}{$chr}{$pos}=$ref;
		}
		foreach  my $fqid( @alt_fq_list){
			$snp_dict{$fqid}{$chr}{$pos}=$alt;
			$nm_dict{$fqid}{$chr}++ ;
		}
	}
	close($fh);

	#############################################
	#--- Parse Psude sam
	#############################################

	foreach my $id ( keys( %snp_dict) ){
		foreach my $chr( keys( %{$snp_dict{$id}} )  ){
			my @pos_list =  sort {$a <=> $b } keys(%{$snp_dict{$id}{$chr}} );
			#print "$id\t$chr\t@pos_list\n";
			my $new_seq = "";

			my $st  = $pos_list[0] - $mergen;
			my $end = $pos_list[$#pos_list ] + $mergen;
			my $length = $end - $st +1;

			next if( $length <= $length_filter  ) ;

			my $seqd = "N" x $length;
			if ($fa ){
				$seqd = $db->seq($chr, $st , $end );
			}
			my @seq_nuc = split(//, $seqd);
			my $nm_count = ( exists( $nm_dict{$id}{$chr})) ? $nm_dict{$id}{$chr} : 0 ;
			for ( my $pos= $st ; $pos <= $end ; $pos++){
				my $nuc = ( exists( $snp_dict{$id}{$chr}{$pos})) ? $snp_dict{$id}{$chr}{$pos} : $seq_nuc[$pos - $st];
				$new_seq.= $nuc;
			}
			my $qual   = "F" x $length;
			my $flag = 0;
			if($id =~ /_s\d+/){
			    $flag = 2048;
			}
			#print $oh "$id st:$st end:$end len:$length len2:$length_2\n";
			print $oh "${id}\t$flag\t$chr\t$st\t60\t${length}M\t*\t0\t0\t$new_seq\t$qual\tNM:i:$nm_count\n";
		}
	}
	close($oh);

}


################################################################################
## Main
#################################################################################
main( \%options);


exit;

