#use strict;
use MaterialsScript qw(:all);

#print "@filtered\n";

my $GSFEStudyTable = Documents->New("GSFE.std");
my $calcSheet = $GSFEStudyTable->ActiveSheet;
$calcSheet->ColumnHeading(0) = "Coordination";
$calcSheet->ColumnHeading(1) = "Total Energy";

my $GSFEtrj = Documents->New("newdoc.xtd");

# Find the Atom ID you want to manipulate

my $B2filename = 'NbMo_Fine';
my $B2doc= $Documents{"$B2filename.xsd"};
cleavesurface($B2filename,$B2doc);

my $filename = "$B2filename"."_surf112.xsd";
my $docin=$Documents{"$filename"};## read original crystal file (with spacegroup)
$docin -> MakeP1;
#my $cleaved = "Al_sufr111";

#    $movetimes = 10;	 
$atomNoref = $docin->UnitCell->Atoms;# the perl array reference (like pointer!)
$atomnumber=@$atomNoref; # get the total atom number of this xsd file
my @AllZ;
    
for my $z (@{$atomNoref}){
    push @Allz,int(($z->FractionalXYZ->Z)*100);#avoid the rounding errors of coordinations
}
 
my %filter;
@filter{@Allz} = ();
#  for (keys %filter){print "$_ \n";}
my @sortedZ = sort { $a <=> $b } keys(%filter);
my $criterion = $sortedZ[5];#(the sixth layer of 12 layers) above which are moved for GSFE
for (0..$#sortedZ){print "$_ $sortedZ[$_]\n";}
my @ID2move;
my $IDcounter = 0;
for my $z (@{$atomNoref}){
    if(int(($z->FractionalXYZ->Z)*100) > $criterion){
    	push @ID2move,$IDcounter;
    }
    $IDcounter++;
}

#for my $mID (@ID2move){

#	print "$mID ".(${$atomNoref}[$mID]->FractionalXYZ->Z)*100 ."\n";
#        print "$criterion\n";
#}






#$newdoc->Trajectory->AppendFramesFrom($doc, Frames(Start => 1, End => 10));
#$calcSheet->Cell($counter-1, 1) = $allDoc->PotentialEnergy;


#my $to = $Documents{"to.xtd"};
#my $from = $Documents{"from.xtd"};
#my $trjTo = $to->Trajectory;

#$trjTo->CurrentFrame = 3;
#$trjTo->InsertFramesFrom($from, Frames(Start => 4, End => 5));


my $inputtxt = $Documents{"00atomBE.txt"};
my $lineNo = $inputtxt->Lines->Count;
my @temp_array;
my $functional="RPBE";
my $qual="Fine";
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

my $totaloutput = Documents->New("00stack_refdata.txt");

Modules->CASTEP->ChangeSettings(Settings( Quality => $qual, 
							SpinPolarized=> "Yes",
							UseFormalSpin=> "Yes",
                            TheoryLevel=> "GGA",
				            Pseudopotentials => "Ultrasoft",
                            NonLocalFunctional=> $functional,                                                                                      
            
                            DensityMixingAmplitude => 0.25,
                            SpinMixingAmplitude => 1,                                                           
                            MaxIterations => 200, 
		                    #EmptyBands => 10,
		                    #ParameterC => 1,					  
                            MaximumSCFCycles => 500,
							   
                            #UseCustomEnergyCutoff=>"Yes",
			                #EnergyCutoffQuality=>"Fine",
                            #EnergyCutoff=>330,							   
                            #OptimizeCell => "No",
			    SCFMinimizationAlgorithm => "All Bands/EDFT",
                            #CalculateElasticConstants=>"Yes",
));                    

#my @surface=("100","110","111");
#for (my $i =0; $i < $atomtypeNo - 1 ; $i++) {
#  for (my $j = $i+1; $j < $atomtypeNo ; $j++){
#    my $alloyname = "$atomtype[$i]"."$atomtype[$j]";## need to use an optimized structure
#	
#    my $docin=$Documents{"$alloyname"."_Fine.xsd"};## read original crystal file (with spacegroup)
#    $docin -> MakeP1;  
#    #my $fullname = "$atomtype[$i]"."$atomtype[$j]"."_surf"; 
#    $docin->SaveAs("$alloyname.xsd"); # built from the perfect crystal
#    my $cleavdocin=$Documents{"$alloyname.xsd"};
    
#foreach my $i (@surface)
#{
   #my $fullname = "$atomtype[$i]"."$atomtype[$j]"."_surf"; 
   #$docin->SaveAs("$alloyname"."_surf.xsd"); # built from the perfect crystal
   #my $tempdoc= $Documents{"$alloyname"."_surf.xsd"};# car files are exported in runDFT sub
   #cleavesurface only cleaves the plane for runDFT
    
    #cleavesurface($cleavdocin,$i);# filename, atom type, moving vector
    #my @ind = split(//,$i);
    #my $cleavfullname = "$alloyname"." ($ind[0] $ind[1] $ind[2])";    
    #my $tempdoc1= $Documents{"$cleavfullname.xsd"};
    #my $cleaved ="$alloyname"."_surf$i"; 
    #   $tempdoc1->SaveAs("$cleaved.xsd");
    #my $doc= $Documents{"$cleaved.xsd"};
	
   #cleavesurface  done -------------------------------------------

  
#my @array = qw(one two three two three);
#my @filtered = uniq(@array);

    
    
  #  for (0..$#Allz){
    
   # print "$_ $Allz[$_]\n";
    #}
my $movetimes = 11;    
my $incre = 1.0/($movetimes - 1.0);    
    
for my $move (0..$movetimes-1){    
	my $dis = $move*$incre;
	 #$tempname = "$cleaved"."_stacking";
	 my $fullname = "GSFE_"."$move";
	 $docin->SaveAs("$fullname.xsd");
	 my $tempdoc= $Documents{"$fullname.xsd"};

	for my $mID (@ID2move){
	   my	$X = ${$tempdoc->UnitCell->Atoms}[$mID]->FractionalXYZ->X;
	   my	$Y = ${$tempdoc->UnitCell->Atoms}[$mID]->FractionalXYZ->Y;
	   my	$Z = ${$tempdoc->UnitCell->Atoms}[$mID]->FractionalXYZ->Z;
	$Y=$Y + $dis;
	
	my $modified = int($Y); # fractional coordinates should be smaller than 1.
	$Y = $Y - $modified;
	
	#print "$move: $mID,$X,$modified\n";
	${$tempdoc->UnitCell->Atoms}[$mID]->FractionalXYZ = Point(X =>$X, Y => $Y, Z => $Z);					
       	       
	
     }
	$tempdoc->Export("$fullname.car"); 
	$GSFEtrj->Trajectory->AppendFramesFrom($tempdoc);  
	my $DFToutput = Modules->CASTEP->Energy->Run($tempdoc);
	my $totE=($DFToutput->TotalEnergy)*0.0433641;
	$calcSheet->Cell($move, 0) = $dis;
	$calcSheet->Cell($move, 1) = $totE; 
	#runDFT($totaloutput,$tempdoc,$fullname,\%DFTatomenergy,\%lmpatomenergy);	
}	
	   

 
    $docin->Delete; ## don't use this anymore!
#  }
#}


sub cleavesurface
{  
    my ($filename,$doc) = @_;
    my $cleave = Tools->SurfaceBuilder->CleaveSurface;
    $cleave->DefineCleave($doc, MillerIndex(H => 1, K => 1, L => 2), Point(X => 1, Y => -1, Z => 0), Point(X => 1, Y => 1, Z => -1));
    $cleave->MeshOrigin(Point(X => -7.45058e-009, Y => 1, Z => 0));
    $cleave->SetThickness(13);
    my $surfaceDoc = $cleave->Cleave;
    Tools->CrystalBuilder->ChangeSettings(Settings(VacuumThickness => 10));
    Tools->CrystalBuilder->VacuumSlab->Build($surfaceDoc);

    my $cleavfullname = "$filename"." (1 1 2)";    
    my $tempdoc1= $Documents{"$cleavfullname.xsd"};
    my $cleaved ="$filename"."_surf112";
    $tempdoc1->SaveAs("$cleaved.xsd");
}
		
		                                           
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
      $element_counter{"$atomsymbol"} +=  1;
}

# scalar $elementtype to get the key number of %element_counter 
my $elementtype = keys %element_counter;
# array @allkeys to keep all keys of %element_counter, they should be element symbols
my @allkeys = keys %element_counter;

my $DFToutput;# lexical  
eval {$DFToutput = Modules->CASTEP->GeometryOptimization->Run($xsd);};   
   
if ($@) {
# Something bad has happened, move onto the next one
 	print "!!!!!!!!!!!!!!!!!!! $outputxsdname ERROR  !!!!!!!!!!!!!!!!\n";
    print $@ ;
    $xsd -> Export("$outputxsdname-FAILED.car");
    $xsd->SaveAs("stru$outputxsdname-FAILED.xsd");
# the foolwoing key word "FAILED" will be used to skip this reference data
#by preprocessor
	$totaloutput->Append(sprintf "refdata $outputxsdname FAILED\n");
}    
else{ 
    $xsd -> Export("$outputxsdname.car");
    my $totE=($DFToutput->TotalEnergy)*0.0433641;
	#my $bdenergy2=$bdenergy*0.0433641;ss
	
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
    my $totE_J = $totE*(1.602176634e-19);
    my $Volume = $xsd->Lattice3D->CellVolume;
    my $ZL = $xsd->Lattice3D->LengthC;
    my $A = ($Volume/$ZL)*(1e-20);
    my $SFE = $totE_J/$A;
    print "$totE_J, $Volume, $ZL, $A\n";


    $totaloutput->Append(sprintf "refdata $outputxsdname $totE $lmpE "."stacking fault: $SFE $totE_J $A \n");
} 
}