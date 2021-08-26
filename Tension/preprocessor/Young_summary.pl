sub Young_summary {
	
use Statistics::LineFit;

$mol_num = 6.02214085774*10**(23);
$A3_m3=10**(-30);
$kpa_Gpa=10**(-6);
$cal_J = 4.184;
$real_conversion = ($cal_J*$kpa_Gpa)/($mol_num*$A3_m3);

$eV_J = 1.602176565*10**(-19);
$pa_Gpa = 10**(-9);
$metal_conversion = ($eV_J*$pa_Gpa)/$A3_m3;


#Central Finite Difference method
#https://en.wikipedia.org/wiki/Finite_difference_coefficient


#####Getting Young's modulus for strain lower than 0.02
unlink "T_Young_modulus.dat"; 
open TY, ">T_Young_modulus.dat";

foreach  $temp_fold (@subdir){	       
  
  @ss=();  
  open ssc, "<./$temp_fold/modified_SS.dat";
  @ss=<ssc>; ###A**3
  close ssc;
  $ss_num=@ss;
  @xValues = ();
  @yValues = ();
     for($j=0;$j<$ss_num;$j++){	
       @temp= split('\s+',$ss[$j]);
       if($temp[0] <= 0.02){
       	push @xValues, $temp[0];
       	push @yValues, $temp[1];
       	};
     };
$lineFit = Statistics::LineFit->new();
$lineFit->setData (\@xValues, \@yValues) or die "Invalid data";
($intercept, $slope) = $lineFit->coefficients();
print TY "$temp_fold $slope\n";
}

close TY;
}
1;