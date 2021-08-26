#####**** THIS IS THE FIRST SCRIPT YOU HAVE TO CONDUCT
### TO GET THE BINDING ENERGIES OF ALL COMPOSITIONAL ELEMENTS
#### THE DFT SETTING SHOULD BE THE SAME FOR ALL SCRIPTS!!!!!!!

#This MS Perl (MS 2017) helps you to  get the binding energies
# of all elements you consider into a txt file, which would be used 
# as a hash for calculating the formation energies of all reference data 
# developed by Prof. Shin-Pon Ju at UCLA on Mar./1/2019

#1.00atomBE.txt is the output txt file
#2.%lmpatomenergy should be provided. Keys are element symbols and values are 
#  the binding energies by "minimize" with "box/relax" through lammps 
#  For MEAM, these values are Ec.

use strict;
use MaterialsScript qw(:all);

#### PREPROCESSOR

my $inputtxt = $Documents{"00lmpBE.txt"};
my $lineNo = $inputtxt->Lines->Count;
my @temp_array;
my $functional="PBESOL";
my $qual="Medium";
#my $basis="3.5";
#my $core ="DFT Semi-core Pseudopots";
#my $cutoff=5.8;
#my $functional= ("PW91"); ## could use more
#@functional= ("PW91");

#my $basis_file =("3.5");
#@basis_file = ("3.5");
#my $core_treatment = ("Effective Core Potentials");
#@core_treatment = ("All Electron");

for (my $i=0; $i< $lineNo; ++$i) {
   $temp_array[$i] = $inputtxt->Lines($i);   
}
my @original_array;
# you need to use chomp to remove \n and to remove the beginning empty
@original_array = map {my $temp=$_;$temp=~ s/^\s*//g;chomp($temp);$temp} @temp_array;
# filter what you want
my @filter_array = grep (($_!~m/^\s*$/ && $_!~m/\#/),@original_array);

my @atomtype = map {my $temp=$_;
          my @temparray =split(/\s+/,$temp);
          $temparray[0]=~ s/^\s*//g;chomp($temparray[0]);$temparray[0];
          } @filter_array;
foreach (@atomtype){ print "$_\n";}          

my @lmpatomenergy = map {my $temp=$_;
          my @temparray =split(/\s+/,$temp);
          $temparray[1]=~ s/^\s*//g;chomp($temparray[1]);$temparray[1];
          } @filter_array;
foreach (@lmpatomenergy){ print "$_\n";}          

#### You need to put the xx.xsd files in the same directory of this Perl script

my $atomtypeNo = @atomtype; # the atom type number 
   
# format-> "symbol" "DFT binding energy" "Lammps binding energy"
my $totaloutput = Documents->New("00atomBE.txt");
$totaloutput->Append(sprintf '#element DFT_BE LMP_BE'."\n");
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

## consider all atom pairs by the following two loops
for (my $i =0; $i < $atomtypeNo; $i++) {
    my $tempname = "$atomtype[$i]";## need to use an optimized structure
	my $docin=$Documents{"$tempname"."_PBESOL".".xsd"};## read original crystal file (with spacegroup)
       $docin -> PrimitiveCell;
	my $atomNoref = $docin->UnitCell->Atoms;# the perl array reference (like pointer!)
	my $atomnumber=@$atomNoref; # get the total atom number of this xsd file 
        
#runDFT is to run DFT (CASTEP or DMOL3) for getting the DFT total energies and preparing
# the energy output file to get the formation energies in order for following
# reference data calculation 
       runDFT($totaloutput,$docin,$atomtype[$i],$lmpatomenergy[$i]);
    $docin->Delete; ## don't use this anymore!
}


# runDFT is used to conduct DFT calculation and keep the calculated
# structure file (xsd nd car) and output the data into a txt file
sub runDFT
{
#href means the reference of a hash
my ($totaloutput,$docin,$atomtype,$lmpatomenergy) = @_;
 
my $atomNoref = $docin->UnitCell->Atoms;## the perl array reference (like pointer!)
my $atomnumber=@$atomNoref; # get the total atom number of this xsd file 

my $DFToutput;# lexical  
eval {$DFToutput = Modules->CASTEP->GeometryOptimization->Run($docin);}; 

if ($@) {
# Something bad has happened, move onto the next one
 	print "!!!!!!!!!!!!!!!!!!! $atomtype atom DFT ERROR  !!!!!!!!!!!!!!!!\n";
    print $@;
    $docin -> Export("$atomtype-FAILED.car");
    $docin->SaveAs("$atomtype-FAILED.xsd");
	$totaloutput->Append(sprintf "$atomtype DFT FAILED\n");
}    
else{ 
    #$docin -> Export("$atomtype.car");
    my $totE=($DFToutput->TotalEnergy)*0.0433641;
	 my	$DFTBE = $totE/$atomnumber;
    $totaloutput->Append(sprintf "$atomtype $DFTBE $lmpatomenergy\n");
} 

} # end of sub            