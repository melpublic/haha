#This MS Perl (MS 2017) helps you to randomly remove the atom to
# form the defected structure with the void
# developed by Prof. Shin-Pon Ju at UCLA on Feb/26/2019

#1. you need to get the totoal energy of each element first (@DFTatomenergy)
#2. you need to get experiemntal binding energy first(@lmpatomenergy). 
#3. you must use a output reference data file name following the key word "refdata",
#   because the PSO Perl script for preprocessor will use this key word to
#   collect all reference data files. You may use different labels for these files,
#   but remember to keep "refdata" (like in 00void_refdata.txt).
#4. Failed structures will not be used for PSO fitting

use strict;
use MaterialsScript qw(:all);
#### PREPROCESSOR

my $inputtxt = $Documents{"00atomBE.txt"};
my $lineNo = $inputtxt->Lines->Count;
my @temp_array;
my $functional="PBESOL";
my $qual="Medium";
#my $basis="3.5";
#my $core ="DFT Semi-core Pseudopots";
#my $cutoff =5.8;
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

my @surface=("100","110","111");
my $totaloutput = Documents->New("00surface_refdata.txt");# the output of PSO referend data 

###** YOU NEED TO USE YOUROWN SETTING (need to do the setting evaluation first)!!!!
#ForceConvergence, EnergyConvergence,StressConvergence,
#DisplacementConvergence use the setting of ultra-fine for CASTEP


Modules->CASTEP->ChangeSettings(Settings( Quality => $qual, 
							   SpinPolarized=> "Yes",
							   UseFormalSpin=> "Yes",
                               TheoryLevel=> "GGA",
							   Pseudopotentials => "Ultrasoft",
                               NonLocalFunctional=> $functional,                                                                                      
            
							   DensityMixingAmplitude => 0.05,
                               SpinMixingAmplitude => 0.125,   
                               MaxIterations => 200,                               
                               MaximumSCFCycles=> 500,                                                        
                               UseCustomEnergyCutoff=>"Yes",
							   EnergyCutoffQuality=>"Fine",
                               EnergyCutoff=>330,						   
                               OptimizeCell => "yes",
							   SCFMinimizationAlgorithm => "All Bands/EDFT",
                               CalculateElasticConstants=>"Yes",
                              ));                  
######### END OF DFT SETTING
 
### the following rough setting is for testing purpose.                              
#Modules->CASTEP->ChangeSettings(Settings( Quality => "Coarse", 
#				SpinPolarized => "Yes", 
#				UseFormalSpin=> "Yes",
#				NonLocalFunctional => "PBE",
#				#SCFMinimizationAlgorithm=> "All Bands/EDFT",
#				#UseCustomEnergyCutoff=>"Yes",
#				#EnergyCutoff=>320,					 
#				MaximumSCFCycles => 1000, 
				#OptimizeCell => "Yes",				 
			#	MaxIterations => 2,
#				SCFConvergence=>5.0,
#				Pseudopotentials=>"Ultrasoft"			
#                              ));
                      
######### END OF DFT SETTING

## consider all atom pairs by the following two loops
for (my $i =0; $i < $atomtypeNo - 1 ; $i++) {
  for (my $j = $i+1; $j < $atomtypeNo ; $j++){
    my $alloyname = "$atomtype[$i]"."$atomtype[$j]";## need to use an optimized structure
	
    my $docin=$Documents{"$alloyname"."_Fine.xsd"};## read original crystal file (with spacegroup)
    $docin -> MakeP1;  
    #my $fullname = "$atomtype[$i]"."$atomtype[$j]"."_surf"; 
    $docin->SaveAs("$alloyname.xsd"); # built from the perfect crystal
    my $cleavdocin=$Documents{"$alloyname.xsd"};
    
foreach my $i (@surface){
    #my $fullname = "$atomtype[$i]"."$atomtype[$j]"."_surf"; 
    #$docin->SaveAs("$alloyname"."_surf.xsd"); # built from the perfect crystal
    #my $tempdoc= $Documents{"$alloyname"."_surf.xsd"};# car files are exported in runDFT sub
#cleavesurface only cleaves the plane for runDFT
    
    cleavesurface($cleavdocin,$i);# filename, atom type, moving vector
    my @ind = split(//,$i);
    my $cleavfullname = "$alloyname"." ($ind[0] $ind[1] $ind[2])";    
    my $tempdoc1= $Documents{"$cleavfullname.xsd"};
    my $cleaved ="$alloyname"."_surf$i"; 
       $tempdoc1->SaveAs("$cleaved.xsd");
    my $DFTdoc= $Documents{"$cleaved.xsd"};
    
#runDFT is to run DFT (CASTEP or DMOL3) for getting the formation energy and preparing
# the templated output file to manipulate the PSO fitting (the format should follow the PSO perl).  
# hash and array should pass their references to the sub. 
       runDFT($totaloutput,$DFTdoc,$cleaved,\%DFTatomenergy,\%lmpatomenergy);
      }
 
    $docin->Delete; ## don't use this anymore!
  }
}

## build the structure with one void
#$tempdoc: the xsd file you want to manipulate 
#$plane: the plane direction you want to cleave
sub cleavesurface
{
my ($tempdoc,$plane) = @_;
my @index = split(//,$plane);
my $cleaver;
$cleaver = Tools->SurfaceBuilder->CleaveSurface;
$cleaver->DefineCleave($tempdoc, MillerIndex(H => $index[0], K => $index[1], L =>$index[2]));
$cleaver->SetTopPosition(1.0);
$cleaver->SetThickness(4.0);
my $surfaceDoc = $cleaver->Cleave;
Tools->CrystalBuilder->ChangeSettings(Settings(VacuumThickness => 15));# not replicate in lammps in the z direction
Tools->CrystalBuilder->VacuumSlab->Build($surfaceDoc);

#	return ($xsd);# the same reference for the xsd file
}

# runDFT is used to conduct DFT calculation and keep the calculated
# structure file (xsd nd car) and output the data into a txt file
sub runDFT
{
#href means the reference of a hash
my ($totaloutput,$xsd,$outputxsdname,$href_DFTatomenergy,$href_lmpatomenergy) = @_;
 
my $atomNoref = $xsd->UnitCell->Atoms;## the perl array reference (like pointer!)
my $atomnumber=@$atomNoref; # get the total atom number of this xsd file 

## get atom numbers of different elements
my %element_counter; # element counter

foreach  my $atom (@{$atomNoref}){
   my $atomsymbol = $atom->Elementsymbol;
      $element_counter{"$atomsymbol"} += 1;
}

# scalar $elementtype to get the key number of %element_counter 
my $elementtype = keys %element_counter;
# array @allkeys to keep all keys of %element_counter, they should be element symbols
my @allkeys = keys %element_counter;

my $DFToutput;# lexical  
eval {$DFToutput = Modules->CASTEP->Energy->Run($xsd);};   
   
if ($@) {
# Something bad has happened, move onto the next one
 	print "!!!!!!!!!!!!!!!!!!! $outputxsdname ERROR  !!!!!!!!!!!!!!!!\n";
    print $@;
    $xsd -> Export("$outputxsdname-FAILED.car");
    $xsd->SaveAs("stru$outputxsdname-FAILED.xsd");
# the foolwoing key word "FAILED" will be used to skip this reference data
#by preprocessor
	$totaloutput->Append(sprintf "refdata $outputxsdname FAILED\n");
}    
else{ 
    $xsd -> Export("$outputxsdname.car");
    my $totE=($DFToutput->TotalEnergy)*0.0433641;
	#my $bdenergy2=$bdenergy*0.0433641;
	
	my $sumDFTatomE = 0;
	my $sumLMPatomE = 0;
# $key is the scalar for each element symbol obtained from the above xsd file 	

	foreach my $key (@allkeys) {
	my $DFTtemp = $href_DFTatomenergy->{"$key"};
	my $lmptemp = $href_lmpatomenergy->{"$key"};
	
	print "key1: $key,$element_counter{\"$key\"},DFTatomenergy: $DFTtemp\n";
	print "key2: $key,$element_counter{\"$key\"},lmpatomenergy: $lmptemp\n";
	
	  $sumDFTatomE = $sumDFTatomE + 
	      $element_counter{"$key"}*$DFTtemp;   
	  $sumLMPatomE = $sumLMPatomE +
	      $element_counter{"$key"}*$lmptemp;   
	}
   
#$formE is the formation energy by lammps, and used for the reference data
    print "$totE,$sumDFTatomE, $sumLMPatomE, $atomnumber\n";
    my	$lmpE = (($totE - $sumDFTatomE) + $sumLMPatomE) / $atomnumber;
    $totaloutput->Append(sprintf "refdata $outputxsdname $lmpE\n");
} 

}            