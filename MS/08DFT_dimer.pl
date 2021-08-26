#This MS Perl (MS 2017) helps you to make the PES of a dimer with the 
#different bond length
#developed by Prof. Shin-Pon Ju at UCLA on Feb/23/2019

#1. you need to get the totoal energy of each element first (@DFTatomenergy)
#2. you need to get experiemntal binding energy first(@lmpatomenergy). 
#3. you must use a output reference data file name following the key word "refdata",
#   because the PSO Perl script for preprocessor will use this key word to
#   collect all reference data files. You may use different labels for these files,
#   but remember to keep "refdata" (like in 00dimer_refdata.txt).
#4. Failed structures will not be used for PSO fitting

use strict;
use MaterialsScript qw(:all);

#### PREPROCESSOR

my $inputtxt = $Documents{"00atomBE.txt"};
my $lineNo = $inputtxt->Lines->Count;
my @temp_array;
my $functional="PBESOL";
my $qual="Medium";
#my $basis="4.4";
#my $core ="DFT Semi-core Pseudopots";
#my $cutoff=5.2;
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
###################
   
my $amplitude = 0.5; # the maximal movement from the equilibrium site
my $movetimes = 10; #the times to change bond length (total= $movetimes+1)

my $totaloutput = Documents->New("00dimer_refdata.txt");# the output of PSO referend data 


#my $vdwRadius = $atom->VDWRadius;
###** YOU NEED TO USE YOUROWN SETTING (need to do the setting evaluation first)!!!!

Modules->CASTEP->ChangeSettings(Settings( KPointDerivation => "Gamma"));               
                     
######### END OF DFT SETTING

Tools->CrystalBuilder->SetSpaceGroup("P1");
Tools->CrystalBuilder->SetCellParameters(15,15,15, 90.0, 90.0, 90.0);

## consider all atom pairs by the following two loops
for (my $i =0; $i < $atomtypeNo - 1 ; $i++) {
  for (my $j = $i+1; $j < $atomtypeNo ; $j++){
    
    my $tempname = "$atomtype[$i]"."$atomtype[$j]"."_dimer";## need to use an optimized structure
	
    my $dimer_doc=Documents->new("$tempname.xsd");    
    
    $dimer_doc->BuildCrystal();##build a cell 

   my $boxlen = $dimer_doc->UnitCell->Lattice3D->LengthA;#get the box length
   # create the first atom
    $dimer_doc->CreateAtom("$atomtype[$i]",
    $dimer_doc->FromFractionalPosition(Point(X => 0.5, 
                                         Y => 0.5, 
                                         Z => 0.5)));
   # create the second atom
    $dimer_doc->CreateAtom("$atomtype[$j]",
    $dimer_doc->FromFractionalPosition(Point(X => 0.7, 
                                         Y => 0.5, 
                                         Z => 0.5)));
     my $atomNoref = $dimer_doc->UnitCell->Atoms;# the perl array reference (like pointer!)
                                    
     my $firstR = ${$atomNoref}[0]->CovalentRadius;                                   
     my $secondR = ${$atomNoref}[1]->CovalentRadius;                     
     my $initdist = $firstR + $secondR;
     
     # The first atom is located at (0.5,0.5,0.5), so only move the second atom
     # to the position with the distance of $initdist from the first atom 
     $atomNoref->[1] -> x = $boxlen/2.0 + $initdist*0.1;# y and z fractional are both 0.5 as the first atom's 
   # get the optimized distance


Modules->CASTEP->ChangeSettings(Settings( Quality => "Coarse", 
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
	
 
  eval { my $DFToutput = Modules->DMol3->GeometryOptimization->Run($dimer_doc);};
   
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
 
   
        
my @firstcoor;# the coordinates of the first reference atom
   $firstcoor[0] = $atomNoref->[0] -> x; 
   $firstcoor[1] = $atomNoref->[0] -> y;
   $firstcoor[2] = $atomNoref->[0] -> z;
my @secondcoor;# the coordinates of the second reference atom
   $secondcoor[0] = $atomNoref->[1] -> x; 
   $secondcoor[1] = $atomNoref->[1] -> y;
   $secondcoor[2] = $atomNoref->[1] -> z;
   
   # vectors from the second atom to the first atom (in real length unit)    
     my $vecx = $firstcoor[0]-$secondcoor[0];
	 my $vecy = $firstcoor[1]-$secondcoor[1];
	 my $vecz = $firstcoor[2]-$secondcoor[2];;
# only need to move the atom to the "$amplitude" time bond length
     my @incre;
     $incre[0] = $vecx*$amplitude/$movetimes;
	 $incre[1] = $vecy*$amplitude/$movetimes;
	 $incre[2] = $vecz*$amplitude/$movetimes;
	 
foreach my $imove (0..$movetimes){
	   my $fullname = "$tempname"."$imove"; 
       $dimer_doc->SaveAs("$fullname.xsd"); # built from the perfect crystal
       my $tempdoc= $Documents{"$fullname.xsd"};# car files are exported in runDFT sub
       my @moveleng = map {my $temp=$_*$imove;} @incre;
       #print "imove: $imove @moveleng\n";
#singlemove only randomly move one atom for runDFT
       moveatom($tempdoc,\@moveleng);# move the second atom
#runDFT is to run DFT (CASTEP or DMOL3) for getting the formation energy and preparing
# the templated output file to manipulate the PSO fitting (the format should follow the PSO perl).  
# hash and array should pass their references to the sub. 
       runDFT($totaloutput,$tempdoc,$fullname,\%DFTatomenergy,\%lmpatomenergy);
     }# end of moving atom        
    $dimer_doc->Delete; ## don't use this anymore!
    sleep (5);
  }
}


## build the structure with one atom random movement
#$tempdoc: the xsd file you want to manipulate 
#$ID: the atom ID you pick to randomly move the atom
#$amplitude: the maximal amplitude you can move the atom 
#           from its equilibrium site
#$coor: the reference of coordinates of the equilibrium site 
sub moveatom
{
my ($tempdoc,$moveleng) = @_;
my $atomNoref = $tempdoc->UnitCell->Atoms;# the perl array reference (like pointer!)

my $randx = $atomNoref->[1] -> x +
 $moveleng -> [0];
my $randy = $atomNoref->[1] -> y +
 $moveleng -> [1];
my $randz = $atomNoref->[1] -> z +
 $moveleng -> [2];

$atomNoref->[1] -> x = $randx;
$atomNoref->[1] -> y = $randy;
$atomNoref->[1] -> z = $randz;
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
      $element_counter{"$atomsymbol"} = $element_counter{"$atomsymbol"} + 1;
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