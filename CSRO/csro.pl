use File::Copy;

$filenum = 5; #cfg number
$sd_dir = "../sd_cfg/"; #cfg folder
$type = 5; #type number

mkdir(dat);

for (1..$filenum)
{
    $temp = 300 + 10*$_; #initial temperature
    $csro_cut = 3.0; #rcut

    print "temp $temp"."K $csro_cut\n";

    @temparr = ();
    push @temparr,$csro_cut;
    for $i(1..$type){
        for $j(1..$type){
            if($i <= $j){
                push @temparr,$csro_cut;
            }
        }
    }
    
    open my $csrotemp , "<alloy_temp.dat" or die "No alloy_temp.dat";
    my $inputtemp;
    while($_=<$csrotemp>){$inputtemp.=$_;}
    close $csrotemp;
    
    open my $inputin , ">alloy_composition.dat";
    printf $inputin "$inputtemp",@temparr;
    close $inputin;
    
    $hea_file = $sd_dir."HEA_$temp.cfg"; ##cfg file name
    $input_file = "input.cfg";
    copy($hea_file,$input_file);
    
    system("gfortran.exe 00main_CN.f90");
    system("a.exe");
    sleep(1);
    
    $output_file = "CSRO.dat";
    $dir = "./dat/CSRO_$temp.dat";
    copy($output_file,$dir);
}
