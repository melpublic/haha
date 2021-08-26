#!perl
use strict;
use MaterialsScript qw(:all);

my $inputtxt = $Documents{"00atomBE.txt"};
my $lineNo = $inputtxt->Lines->Count;
my @temp_array;
for (my $i=0; $i< $lineNo; ++$i) {
   $temp_array[$i] = $inputtxt->Lines($i);   
}
my @original_array = ( );
# you need to use chomp to remove \n and to remove the beginning empty
@original_array = map {my $temp=$_;$temp=~ s/^\s*//g;chomp($temp);$temp} @temp_array;
# filter what you want
my @filter_array = grep (($_!~m/^\s*$/ && $_!~m/\#/),@original_array);

my @atomtype = map {my $temp=$_;
          my @temparray =split(/\s+/,$temp);
          $temparray[0]=~ s/^\s*//g;chomp($temparray[0]);$temparray[0];
          } @filter_array;
my $atomtypeNo = @atomtype; # the atom type number
          
foreach (@atomtype){ print "element: $_\n";}          

my @DFTenergy = map {my $temp=$_;
          my @temparray =split(/\s+/,$temp);
          $temparray[1]=~ s/^\s*//g;chomp($temparray[1]);$temparray[1];
          } @filter_array;
foreach (@DFTenergy){ print "DFTenergy: $_\n";}
          
my @lmpenergy = map {my $temp=$_;
          my @temparray =split(/\s+/,$temp);
          $temparray[2]=~ s/^\s*//g;chomp($temparray[2]);$temparray[2];
          } @filter_array;
foreach (@lmpenergy){ print "lmpenergy: $_\n";}

my %DFTatomenergy;## from unit cell calculation
my %lmpatomenergy;#binding energy from energy parameters, 
#or binding energy from molecular statics after minimization with box/relax (0K)
foreach my $i (0..$#atomtype){
	$lmpatomenergy{"$atomtype[$i]"} = $lmpenergy[$i];
	$DFTatomenergy{"$atomtype[$i]"} = $DFTenergy[$i];
}

my $totaloutput = Documents->New("00NPT_refdata.txt");
my $filename = "NbTa_Fine";
my $temp = "300";
my $trj = $Documents{"$filename".".xtd"};
my $trajectory = $trj ->Trajectory;

for (my $i=1; $i<=$trajectory->NumFrames; $i++)
{    
    $trajectory->CurrentFrame = $i;
    my $name=$i-1;   #newfilename
    $trj-> Export("$filename"."_$temp"."MD"."$name.car");
    my $MDname =  "$filename"."_$temp"."MD"."$name";

    my $atoms = $trj->AsymmetricUnit->Atoms;
    my $totE=($trj->TotalEnergy)*0.0433641;

    lmp($totE,$totaloutput,$atoms,$MDname,\%DFTatomenergy,\%lmpatomenergy);
}

sub lmp
{
#href means the reference of a hash
my ($totE,$totaloutput,$atoms,$outputxsdname,$href_DFTatomenergy,$href_lmpatomenergy) = @_;

## get atom numbers of different elements
my %element_counter; # element counter

my $atomnumber=@$atoms;
foreach  my $atom (@$atoms){
   my $atomsymbol = $atom->Elementsymbol;
      $element_counter{"$atomsymbol"} += 1;
}

# scalar $elementtype to get the key number of %element_counter 
my $elementtype = keys %element_counter;
# array @allkeys to keep all keys of %element_counter, they should be element symbols
my @allkeys = keys %element_counter;
	
my $sumDFTatomE = 0;
my $sumLMPatomE = 0;
# $key is the scalar for each element symbol obtained from the above xsd file 	

	foreach my $key (@allkeys) {
	my $DFTtemp = $href_DFTatomenergy->{"$key"};
	my $lmptemp = $href_lmpatomenergy->{"$key"};
	
	print "key1: $key,$element_counter{\"$key\"},DFTatomenergy: $DFTtemp\n";
	print "key2: $key,$element_counter{\"$key\"},lmpatomenergy: $lmptemp\n";
	
    $sumDFTatomE = $sumDFTatomE + $element_counter{"$key"}*$DFTtemp;   
    $sumLMPatomE = $sumLMPatomE + $element_counter{"$key"}*$lmptemp;   
	}
  
#$formE is the formation energy by lammps, and used for the reference data
    print "$totE,$sumDFTatomE, $sumLMPatomE, $atomnumber\n";
    my	$lmpE = (($totE - $sumDFTatomE) + $sumLMPatomE) / $atomnumber;
    $totaloutput->Append(sprintf "refdata $outputxsdname $lmpE\n");
} 