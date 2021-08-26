#Getting stress_strain profile by using lammps stress output.
# Developed by Prof. Shin-Pon Ju at NSYSU on 2017/1/12
#This script is not allowed to use outside MEL group or without Prof. Ju's permission.
#
#1. make the correct @subdir
#2. the units you used in lammps script


require './Vol_maker.pl';
require './Young_summary.pl';

####The following things you sould do for your own case
$units = "metal"; # the units used in your lammps script

#for($i=0;$i<13;$i++){
#$subdir[$i] = 300+$i*25 # making the folder names for using data within them
#}

#@subdir = ("66304","663031"); #array to store the name of your subdir. You may also make it by typing.
@subdir = ("HEA_compress");
unlink "Finputdata.dat"; # make Fortran exe input file for Vol_maker.pl*******
$cutoff = 'cutoff:  2.975'; # You need to find this by ovito (RDF profile)(不能低於第一個peak的峰值)
$pbcx= 'pbcx: .False.';
$pbcy= 'pbcy: .True.';
$pbcz= 'pbcz: .True.';

open fortran, "> Finputdata.dat";
print fortran "$cutoff\n";
print fortran "$pbcx\n";
print fortran "$pbcy\n";
print fortran "$pbcz\n";
close(fortran);

##### end of required parameter setting



###We need to get the path we are conducting this perl script first
use Cwd 'abs_path';
$temp_path=abs_path($0);## use this to get the path
$slash="\\"."\\"."$0"; ##note if you want to use "\" in the variable, you should use "\\" for gettting "\".

$temp_path =~s/$slash//g;
print "***** Current path $temp_path*****\n";
## end of set path


&Vol_maker();
print "QQQQQQQQQQQQQ\n";
&Young_summary();

print "**** All done*";
