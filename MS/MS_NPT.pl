use strict;
use MaterialsScript qw(:all);

my $inputtxt = $Documents{"00atomBE.txt"};
my $lineNo = $inputtxt->Lines->Count;
my @temp_array;
my $functional="RPBE";
my $qual="Coarse";

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
my @Temperature=("300","600","900");
my $totaloutput = Documents->New("00MD_refdata.txt");# the output of PSO referend data 

for (my $i =0; $i < $atomtypeNo - 1 ; $i++){
	for (my $j = $i+1; $j < $atomtypeNo ; $j++){
	my $alloyname = "$atomtype[$i]"."$atomtype[$j]";## need to use an optimized structure
	my $docin=$Documents{"$alloyname"."_Fine.xsd"};## read original crystal file (with spacegroup)
	$docin -> MakeP1;   
	$docin->BuildSuperCell(2, 2, 2);
		for my $n(0..2){
	    	$docin->SaveAs("$alloyname"."_Fine_"."$Temperature[$n]".".xsd"); # built from the perfect crystal
			my $xsd=$Documents{"$alloyname"."_Fine_"."$Temperature[$n]".".xsd"};

			Modules->CASTEP->ChangeSettings(Settings( 
			Quality => $qual, 
			SpinPolarized => "Yes", 
			NonLocalFunctional => $functional, 
			UseCustomEnergyCutoff => "Yes", 
			EnergyCutoff => 330, 
			SCFConvergence => 1e-005,
			DensityMixingAmplitude => 0.5,
	    	SpinMixingAmplitude => 2,                                                            
			MaximumSCFCycles => 600, 
			#KPointOverallQuality => "Coarse", 
			Pseudopotentials => "Ultrasoft", 
			MDTemperature => $Temperature[$n], 
			TimeStep => 2.5, 
			NumSteps => 100, 
			Ensemble => "NPT", 
			#Thermostat => "NHL",
			Barostat => "Parrinello", 
			#PropertiesKPointQuality => "Coarse",
			RuntimeOptimization=>"Memory",
			));
			my $DFToutput;
			eval {$DFToutput = Modules->CASTEP->Dynamics->Run($xsd);};
		}
	}
}

sub runDFT
{
	#$totaloutput: output txt reference
	#$docin: doc reference
	#$tempname: alloy name (for example, TiZr ...)
	#href means the reference of a hash
	my ($totaloutput,$xsd,$tempname,$href_DFTatomenergy,$href_lmpatomenergy) = @_;
	my $atomNoref = $xsd->UnitCell->Atoms;## the perl array reference (like pointer!)
	my $atomnumber=@$atomNoref; # get the total atom number of this xsd file 

	## get atom numbers of different elements
	my %element_counter; # element counter
	foreach  my $atom (@{$atomNoref})
	{
		my $atomsymbol = $atom->Elementsymbol;
		$element_counter{"$atomsymbol"} += 1;
	}

	# scalar $elementtype to get the key number of %element_counter 
	my $elementtype = keys %element_counter;
	# array @allkeys to keep all keys of %element_counter, they should be element symbols
	my @allkeys = keys %element_counter;
	my $DFToutput;# lexical  
	eval {$DFToutput = Modules->CASTEP->Dynamics->Run($xsd);};   
	if ($@) 
	{
		# Something bad has happened, move onto the next one
		print "!!!!!!!!!!!!!!!!!!! $tempname ERROR  !!!!!!!!!!!!!!!!\n";
		print $@;
		#$xsd -> Export("$tempname-FAILED.car");
		$xsd->SaveAs("stru$tempname-FAILED.xsd");
		# the foolwoing key word "FAILED" will be used to skip this reference data
		#by preprocessor
		$totaloutput->Append(sprintf "$tempname"."FAILED\n");
	}    
	else
	{
	    my $totE=($DFToutput->TotalEnergy)*0.0433641;
		#my $bdenergy2=$bdenergy*0.0433641;

		my $sumDFTatomE = 0;
		my $sumLMPatomE = 0;
		# $key is the scalar for each element symbol obtained from the above xsd file 	

		foreach my $key (@allkeys)
		{
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
	    $totaloutput->Append(sprintf "$tempname:"."$lmpE\n");
	} 

} # end of sub 