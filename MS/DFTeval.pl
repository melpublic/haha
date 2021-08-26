use List::MoreUtils qw(uniq);
#read exp files

@element= ("W","Ta","Nb","Mo","V");
#@element= ( "Al","Mo");
$natom = @element;

@weight=(0,50,50,50,10,10,10);##weighting function for each ref. datum
###for here

for ( $iatom=0; $iatom <$natom; $iatom++) 
{
   $temp = "$element[$iatom]"."_exp.dat";

####################grabbing exp. data
#current concerned properties 
#(1)DFTSetting,(2)bindEnergy,(3)LengthA,(4)LengthB,(5)LengthC,(6)Configuration,(7)C11,(8)C12,(9)C13,(10)C33,(11)C44
#"none" for the above data means no corresponding exp. data for this element

   open ss,"<$temp";
   @input ="";
   @input=<ss>;  #read data from ss line by line to an array
   close ss;
   $temp =$element[$iatom];
   chomp @input;
   @$temp= split(/,/,$input[1]); #according to the exp file format
   $refdatnum =@$temp;
#print "$refdatnum\n";

#####grabbing DFT data of different DFT settings in sequence
### the perl arrays are named in sequence

   $temp = "$element[$iatom]"."_evaluation_refdata.txt";
   open ss,"<$temp";
   @input ="";
   @input=<ss>;  #read data from ss line by line to an array
   close ss;

   $temp=@input;
   $filecounter = 0; ## used to name the arrays
#####the reading format can be changed once you chnage the format of MS dmol3 perl output format
	for ( $i=1; $i <$temp; $i+=1) 
	{
		chomp($input[$i]);
		@temp1= split(/,/,$input[$i]);
		$temp1 = @temp1;## the same value as the refdatnum
		$filecounter = $filecounter+1;
		$tempname ="$element[$iatom]" . "$filecounter"; ###open array by the element name
		for ($j=0; $j <$temp1; $j++) 
		{
			$$tempname[$j]=$temp1[$j]; 
		} 	    
	}   
	$DFTsetnum=$filecounter;## the same for each
} ###the outmost loop

print "**** The number of considered DFT settings :$DFTsetnum\n"; #DFTsetnum 幾組設定

#################################################################
##begin the loop for evaluating the quality of DFT settings
######The final value of $filecounter is the number of DFT settings we consider
@setting="";
@seteval="";


for ( $iatom=0; $iatom <$natom; $iatom++) 
{		
	$elementtemp = $element[$iatom];
	
	for ( $iset=1; $iset<= $DFTsetnum; $iset++) 
	{
		$dmolset ="$element[$iatom]"."$iset";## data from different DFT settings
		$setting[$iset]=$$dmolset[0];## keep the DFT setting
		for ( $ie=1; $ie <$refdatnum; $ie++) ###should be modify
		{      	        
			if($$elementtemp[$ie] ne "none")
			{
				$seteval[$iset]=$seteval[$iset]+$weight[$ie]*($$dmolset[$ie]-$$elementtemp[$ie])**2/$$elementtemp[$ie]**2;
				$error = (($$dmolset[$ie]-$$elementtemp[$ie])/$$elementtemp[$ie])*100;				
				#$temp =$$dmolset[$ie]/$div;				
			}
			if ($iset == 3 && $iatom == 0){push @We,$error;@nWe = uniq(@We);}
			if ($iset == 3 && $iatom == 1){push @Tae,$error;@nTae = uniq(@Tae);}
			if ($iset == 3 && $iatom == 2){push @Nbe,$error;@nNbe = uniq(@Nbe);}
			if ($iset == 3 && $iatom == 3){push @Moe,$error;@nMoe = uniq(@Moe);}
			if ($iset == 3 && $iatom == 4){push @Ve,$error;@nVe = uniq(@Ve);}
		}
		if ($iset == 3 && $iatom == 0){
			push @Wref, "$$dmolset[1]";push @Wref, "$$dmolset[4]";push @Wref, "$$dmolset[5]";push @Wref, "$$dmolset[6]";
			push @Wexp, "$$elementtemp[1]";push @Wexp, "$$elementtemp[4]";push @Wexp, "$$elementtemp[5]";push @Wexp, "$$elementtemp[6]";
		}
		if ($iset == 3 && $iatom == 1){
			push @Taref, "$$dmolset[1]";push @Taref, "$$dmolset[4]";push @Taref, "$$dmolset[5]";push @Taref, "$$dmolset[6]";
			push @Taexp, "$$elementtemp[1]";push @Taexp, "$$elementtemp[4]";push @Taexp, "$$elementtemp[5]";push @Taexp, "$$elementtemp[6]";
		}
		if ($iset == 3 && $iatom == 2){
			push @Nbref, "$$dmolset[1]";push @Nbref, "$$dmolset[4]";push @Nbref, "$$dmolset[5]";push @Nbref, "$$dmolset[6]";
			push @Nbexp, "$$elementtemp[1]";push @Nbexp, "$$elementtemp[4]";push @Nbexp, "$$elementtemp[5]";push @Nbexp, "$$elementtemp[6]";
		}
		if ($iset == 3 && $iatom == 3){
			push @Moref, "$$dmolset[1]";push @Moref, "$$dmolset[4]";push @Moref, "$$dmolset[5]";push @Moref, "$$dmolset[6]";
			push @Moexp, "$$elementtemp[1]";push @Moexp, "$$elementtemp[4]";push @Moexp, "$$elementtemp[5]";push @Moexp, "$$elementtemp[6]";	
		}
		if ($iset == 3 && $iatom == 4){
			push @Vref, "$$dmolset[1]";push @Vref, "$$dmolset[4]";push @Vref, "$$dmolset[5]";push @Vref, "$$dmolset[6]";
			push @Vexp, "$$elementtemp[1]";push @Vexp, "$$elementtemp[4]";push @Vexp, "$$elementtemp[5]";push @Vexp, "$$elementtemp[6]";
		}
		# record the evaluation results
		#$seteval[$iset] = ;		
	}
} ###the outmost loop

print "LengthA,C11,C12,C44\n";

	print  "W:\n";
	printf "ref:%.6f %.6f %.6f %.6f\n",@Wref;
	printf "exp:%.6f %.6f %.6f %.6f\n",@Wexp;
	printf "err:%.6f %.6f %.6f %.6f\n",@nWe;
	print  "Ta:\n";
	printf "ref:%.6f %.6f %.6f %.6f\n",@Taref;
	printf "exp:%.6f %.6f %.6f %.6f\n",@Taexp;
	printf "err:%.6f %.6f %.6f %.6f\n",@nTae;
	print  "Nb:\n";
	printf "ref:%.6f %.6f %.6f %.6f\n",@Nbref;
	printf "exp:%.6f %.6f %.6f %.6f\n",@Nbexp;
	printf "err:%.6f %.6f %.6f %.6f\n",@nNbe;
	print  "Mo:\n";
	printf "ref:%.6f %.6f %.6f %.6f\n",@Moref;
	printf "exp:%.6f %.6f %.6f %.6f\n",@Moexp;
	printf "err:%.6f %.6f %.6f %.6f\n",@nMoe;
	print  "V:\n";
	printf "ref:%.6f %.6f %.6f %.6f\n",@Vref;
	printf "exp:%.6f %.6f %.6f %.6f\n",@Vexp;
	printf "err:%.6f %.6f %.6f %.6f\n",@nVe;

$temp = @seteval;
$min = $seteval[1];
$bestsetting = $setting[1];

open ss,">fitting_summary(Dmol3).dat";
	
for ( $i=1; $i <$temp; $i++) 
{ 
	print ss "$i, DFT setting: $setting[$i],evaluation: $seteval[$i]\n\n";
	if($seteval[$i] <= $min)
	{
		$min = $seteval[$i];
		$bestsetting=$setting[$i] ;
		$bestindex=$i;
	}
} 
   
print ss "\n\n*******Final Result********\n";
print ss "Best DFT setting for @element\n";
print ss "Best setting: $bestsetting\n";
print ss "Best setting index: $bestindex\n";
print ss "Evaluation: $min\n";
 
#for ( $iatom=0; $iatom <$natom; $iatom++) 
#{		
#   $elementtemp = $element[$iatom];
#   $expdata = $elementtemp   
#}  