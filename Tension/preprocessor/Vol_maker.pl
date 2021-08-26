##This perl help you to get the averaged system volume for modifying the stress calculated by lammps
##***** Don't try to change the output format of your lammps script.
# ******* It only works in Windows system. *********
# Developed by Prof. Shin-Pon Ju at NSYSU on 2016/10/26
 
#$temp_path: the current path for perl script (from 00mail.pl)
#solid.dat : sum of the volume of each atom (by our fortran exe file)


sub Vol_maker {

foreach $temp_fold (@subdir){  

  @index_counter = ();
  opendir(DIR, $temp_fold) ;

    while (my $file = readdir(DIR)) {    	
        if ($file =~ m/00stress_[0-9]+.cfg/){
           $file =~s/00stress_//g;#remove "stress"
           $file =~s/.cfg//g;#remove ".cfg"           
           push(@index_counter, $file);
        }
    }

  closedir(DIR);

### be used after we find the reference index for the negative stress from the last stress element  
  @sorted_counter = sort { $a <=> $b } @index_counter;#ascending order

## create all required files into the subdirectory  
  unlink "Getvol.bat";
  open bat, "> Getvol.bat";##******batch file for conducting fortran exe
  print bat "cd $temp_fold\n";
  print bat "Getvol.exe \n";
  print bat "cd ..\n";  
  close bat;
   
  #unlink "./$temp_fold/Getvol.exe";  
  unlink "./$temp_fold/Finputdata.dat";  
  $cp_pathexe ="$temp_fold"; #. "\\$temp_fold\\Getvol.exe"; ###############****set path (DOS form)
  $cp_pathFinputdata ="$temp_path"."\\$temp_fold"."\\Finputdata.dat"; #. "\\$temp_fold\\Finputdata.dat";##required data for Getvol
  system ("echo %cd%");
  system ("copy Getvol.exe $cp_pathexe");#copy Getvol.exe (Fortran executable file) to each subfolder
  print "QQQQQQQQQQQQQQ $cp_pathexe";
  system ("copy Finputdata.dat $cp_pathexe");# fortran input file

### get the proper row number for length and stress

  open FILE, "< ./$temp_fold/Strain_Stress.dat";### find the number of strain increment. The same for other cases. (lammps output file)
   @strain_temp = ();
   @strain_temp=<FILE> ; 
   close FILE;   
   $strain_number = @strain_temp;#get the strain number
   
####################***********   get the reference length here
### using interpolation 
  $refindex = 0; ## from which all stresses are positive 
   for($j1=$strain_number;$j1>0;$j1--){
   	$j11=$j1-1;   	
   	@temp= split('\s+',$strain_temp[$j11]);
   	#$tempnum=;   	
      if($temp[$#temp] < 0.0){
       $refindex= $j11;## the  perl index for the first negaive stress from the last stress 
       goto done;
      }
   }
   done:
   print "Refindex : $refindex\n";
    $posindex = $refindex+1;
    @temp= split('\s+',$strain_temp[$refindex]);
    $negstress = $temp[$#temp];
    $negleng = $temp[1];
    @temp= split('\s+',$strain_temp[$posindex]);
    $posstress = $temp[$#temp];
    $posleng = $temp[1];
    $reflength= $negleng+($posleng-$negleng)*abs($negstress)/(abs($negstress)+$posstress);
    print "$negstress $negleng\n";
    print "$posstress $posleng\n";
    print "$reflength \n";   
   
##### The following is to do the vol calculation one by one from $posindex. 

  unlink "./$temp_fold/modified_SS.dat";
  open ss, "> $temp_fold/modified_SS.dat"; # file to write vol of all cfg files
     for($j=$posindex;$j<$strain_number;$j++){            
       unlink "./$temp_fold/input.cfg";# input file of Getvol            
       unlink "./$temp_fold/cfg_vol.dat"; # output file from Getvol (Fortran)           
       $tempfile = "00stress_"."$sorted_counter[$j]".".cfg";      
       $cp_path1 ="$temp_fold"."\\input.cfg";#  "\\$temp_fold\\input.cfg"; # the input cfg name for Getvol. Don't change this name
       $cp_path2 ="$temp_fold"."\\$tempfile";          
#*****************************     	
     	 system ("copy $cp_path2 $cp_path1");
     	 system ('Getvol.bat');
     	 open vol, "< ./$temp_fold/cfg_vol.dat";
     	 @vol_temp=<vol> ;
     	 close vol;
     	 chomp $vol_temp[0];
       @temp= split('\s+',$strain_temp[$j]);
       $strain = ($temp[1]/$reflength)-1;
       $stress = $temp[$#temp]*$temp[3]/$vol_temp[0];
       print  "$vol_temp[0]\n";
       #$stress = $temp[$#temp]*$temp[3];
       print ss "$strain $stress\n";       
     }
     close ss;   
}

}
1;


