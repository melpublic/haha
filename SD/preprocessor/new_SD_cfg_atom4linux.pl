use 5.010;
## This Perl script helps you to prepare the input file for MSD_cfg.f90
## Developed by Prof. Shin-Pon Ju (2018.02.19)
# input files: cfg files for MSD_cfg
# output file: finput.dat --> this is the input file for MSD_cfg.f90

#use Cwd 'abs_path';
use Cwd;
$nowDIR = getcwd;  ##直接get現在檔案的路徑
#$temp_path=abs_path($0);## use this to get the path of this Perl script
$slash="/"."/"."$0"; ##note if you want to use "\" in the variable, you should use "\\" for getting "\".
#print "$slash\n";
$temp_path =~s/$slash//g; #remove "\filename" from $temp_path
#print "***** Current path $temp_path*****\n"; ###the path from cwd don't need "\" before "\". Really strange!!

####################### Change the following for your case
$append="/00sd/"; #***#### This is the sub-path of your cfg. MS system, you may use loop to do more
$fileNo_lammps= 81; # Total cfg file number from lammps
$timeicr= 10; # counter increment of the sequential cfg file
$prefix = "HEA"; # the prefix format of all cfg files
$natoms = 4113488; # the atoms
$nskipfre = 1; # The frequency to pick cfg files from lammps dump
$fileNo_f90 = int($fileNo_lammps/$nskipfre); # the combined cfg number in MSD_cfg.f90
#$allatoms = $natoms * $fileNo_f90 ; #Total atoms
$interval = 1; # unit: ps -> the time interval between two cfg files
$interval_output = 1 * ($nskipfre - 1); # time interval between two cfg files in MSD_cfg.f90 
$naveragenum = 1; #calculate how many cfg after current cfg 
unlink "finput.dat";
open(finput,"> finput.dat");

@array= (1..5);  #type數量為5
#######################
#@pause= ();
open pot, "<pot_info.txt" or die "Could not open file pot_info.txt!";#get your potential information(mass)      
@Mass = ();
foreach(<pot>)
{
	@Split = split(" ", $_);
	$Mass[$Split[1]] = "$Split[2]";
}
close(pot);

#print "$File1 $l\n\n";
print finput "$fileNo_f90  #How many cfg files for MSD\n";
#$fileNo = $l; # the combined cfg number in MSD_cfg.f90
print finput "$natoms  #How many atoms in each cfg file\n";
$allatoms = $natoms * $fileNo_f90  ; #Total atoms
print finput "$allatoms   #Total atoms in finput_hbond.dat\n";
print finput "$interval #unit: ps -> the time interval between two cfg files\n";
print finput "$naveragenum #calculate how many cfg after current cfg\n";  

$File1 = $l=0;
for($i=1;$i<=$fileNo_lammps;$i++)
{
	@pause= ();
	if($i%$nskipfre == 0)
	{ 
		if($l==0){$File1++;}
		#$run=300+($i)*10; ###*** sometimes you need to modify the initial value!!!
		$run=1980+($i)*20; ###*** sometimes you need to modify the initial value!!!
		#if($run%20000==0 && $run!=0){$prefix+=10;}
		$cfgname="./"."$prefix"."_$run".".cfg";
		$dir= $nowDIR . $append . $cfgname;
		open(cfg,"< $dir") or die "Could not open cfg file";
		@filecontent= <cfg>;
		close(cfg);
		@coorx =(); #an empty array
		@coory =(); #an empty array
		@coorz =(); #an empty array
		@coorType =(); #an empty Type array
		@coormol =(); #an empty Type array
		for($j=9;$j<=9+$natoms-1;$j++) ###*** You need to check your cfg format first
		{
		    chomp ($filecontent[$j]);
		    $filecontent[$j]=~s/^\s+//g; # remove the beginning space 
		    @tempcoorxyz=split(/\s+/,$filecontent[$j]);
			$coorid[$tempcoorxyz[0]] = $tempcoorxyz[0]; 
			#$coormol[$tempcoorxyz[0]] = $tempcoorxyz[1]; 
			$coorType[$tempcoorxyz[0]] = $tempcoorxyz[1]; 
			$coorx[$tempcoorxyz[0]] = $tempcoorxyz[-3]; #the third element from the end element
		    $coory[$tempcoorxyz[0]] = $tempcoorxyz[-2]; #the second element from the end element
		    $coorz[$tempcoorxyz[0]] = $tempcoorxyz[-1]; #the first element from the end element
			#print "$coorx[$tempcoorxyz[0]]\n";
		}

		if($i==$nskipfre)
		{
			for($k=1;$k<=$natoms;$k++) ###*** output x, y, z coordinates in sequence
			{
				if ($coorType[$k] ~~ @array)
				{
					#$Mass[2] = 15.999;
					push @pause, " $coorx[$k] $coory[$k] $coorz[$k] $coorType[$k] $Mass[$coorType[$k]]\n";
					#print " $coorx[$k] $coory[$k] $coorz[$k] $coorType[$k]\n";
					$l++;
				}
			}
		}
		else
		{
			for($k=1;$k<=$natoms;$k++) ###*** output x, y, z coordinates in sequence
			{
				if ($coorType[$k] ~~ @array)
				{
					push @pause, " $coorx[$k] $coory[$k] $coorz[$k] $coorType[$k] $Mass[$coorType[$k]]\n";
					#print " $coorx[$k] $coory[$k] $coorz[$k] $coorType[$k]\n";
				}
			}
		}
	} ## ($i-1)%$nskipfre
	foreach(@pause)
	{
		print finput "$_";
	}
}

#print "$File1 $l\n\n";
#print finput "$fileNo_f90  #How many cfg files for MSD\n";
#$fileNo = $l; # the combined cfg number in MSD_cfg.f90
#print finput "$fileNo  #How many atoms in each cfg file\n";
#$allatoms = $l * $fileNo_f90  ; #Total atoms
#print finput "$allatoms   #Total atoms in finput_hbond.dat\n";
#print finput "$interval #unit: ps -> the time interval between two cfg files\n";
#print finput "$naveragenum #calculate how many cfg after current cfg\n";  
#foreach(@pause){
#	print finput "$_";
#}
close(finput);