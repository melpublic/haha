use Cwd 'chdir';
use Math::Trig;
open txt, "<relist.txt" or die ("Can't find file");
@list = <txt>;
close txt;

$datformat='-d "last Wednesday" "+%Y%m%d"';
$getdat ="date"." $datformat ";
$hwdir=`$getdat`;
chomp($hwdir);
#$hwdir="20201209";

open Check, ">0B_rehw_$hwdir.txt"; ########------Check!!!!!!!------########
open errorout, ">0B_reerror.txt";
$lock = "Yes";                     ########------Check!!!!!!!------########

#@hwname = qw/HW01_1.c/;
$filename = "HW01_1.c";            ########------Check!!!!!!!------########
$sub1 = "distance_1.c";
$sub2 = "angle_1.c";

foreach $username(@list)
{   
    chomp($username);
    #print"$username\n";
    chdir "/home/$username/";
    system("perl -p -i -e 's/$hwdir HW01(_1)?.c.+\n//g;' ./Homework_Report.txt");
    open hw, ">> ./Homework_Report.txt";

    chdir "./$hwdir/";
    print $ENV{PWD}."\n";
    if ($ENV{PWD} !~ /.+\/$username\/$hwdir/)
    {
        print "Folder name error!\n";
        printf Check "$username $filename Folder name error!\n";
        if($lock eq "Yes"){print hw "$hwdir $filename Folder name error!\n";}
    }
    else
    {
        if (-e $filename && $sub1 && $sub2)
        {
            &check_hw($lock,$filename,$sub1,$sub2,$username);
            if($lock eq "Yes"){
                system("chown root $filename $sub1 $sub2"); #!$#######------Check!!!!!!!------########
                system("chmod 755 $filename $sub1 $sub2");  #!$#######------Check!!!!!!!------########
            }
        }
        else
        {
            print "File name error!\n";
            printf Check "$username $filename File name error!\n";
            if($lock eq "Yes"){print hw "$hwdir $filename File name error!\n";}
        }
    }
    close hw;
    
}
close errorout;
close check;

sub check_hw
{
    ($lock,$hw_filename,$sub1,$sub2,$username) = @_;
    if($lock eq "Yes"){
        system("rm -rf output.txt");
    }
    $Ch = system("gcc -o check $hw_filename $sub1 $sub2 -std=c99 -lm"); ########------Check!!!!!!!------########
    
    $nrv = 0;
    open ssd, "<distance_1.c";
    @sub_d = <ssd>;
    close ssd;
    foreach (@sub_d){
        if ($_ =~ /fopen/m)
        {
            #print "no return value ";
            $nrv = $nrv + 1;
        }
        if ($_ =~ /.+fscanf.+/m)
        {
            #print "no return value ";
            $nrv = $nrv + 1;
        }
    }

    open ssa, "<angle_1.c";
    @sub_a = <ssa>;
    close ssa;
    foreach (@sub_a){
        if ($_ =~ /fopen/m)
        {
            #print "no return value ";
            $nrv = $nrv + 1;
        }
        if ($_ =~ /.+fscanf.+/m)
        {
            #print "no return value ";
            $nrv = $nrv + 1;
        }
    }
    #print "$nrv\n";

    #????
    if($Ch == 0)                                                           
    {
        print Check "$username $filename Compiled successfully! ";         
        if($lock eq "Yes"){print hw "$hwdir $filename Compiled successfully! ";} ########------Check!!!!!!!------########
        $hwout = `./check`;
        #print "$hwout";
        @hwouts= split(/\n/, $hwout);
        #print "$#hwouts\n";

        open output, "<output.txt";
        @output = <output>;
        close output;    

        $distance = 17.182354;
        $angle = 174.619949;
        $HG = 0;
        if ($output[0] =~ /Ans1: (7|21) (7|21) (.+)/m || $output[0] =~ /Ans1: ID(7|21) ID(7|21) (.+)/m)
        {
            if ($distance*0.95 <= $3 && $3 <= $distance*1.05)
            {
                $HG = $HG + 1;
            }
        }
        if ($output[1] =~ /Ans2: (5|15|22) (5|15|22) (5|15|22) (.+)/m || $output[1] =~ /Ans2: ID(5|15|22) ID(5|15|22) ID(5|15|22) (.+)/m)
        {
            if ($angle*0.95 <= $4 && $4 <= $angle*1.05)
            {
                $HG = $HG + 1;
            }
        }

        if ($nrv > 0)
        {
            print "Subroutine don't need to open files!\n";
            print Check "Subroutine don't need to open files!\n";
            if($lock eq "Yes"){print hw "Subroutine don't need to open files!\n";}
            print relist "$username\n";
        }
        elsif ($HG == 2)
        {
            print "Homework Good!\n";
            print Check "Homework Good!\n";                             #????
            if($lock eq "Yes"){print hw "Homework Good!\n";}            ########------Check!!!!!!!------########
        }
        else
        {
            print errorout "$username $hw_filename\n";
            print errorout "$output[0]";
            print errorout "$output[1]";
            print errorout "\n";
            print "Homework Bad!\n";
            print Check "Homework Bad!\n";                              #????
            print relist "$username\n";
            if($lock eq "Yes"){print hw "Homework Bad!\n";}             ########------Check!!!!!!!------########
        } 
    }
    
    #????
    elsif($Ch != 0)
    {
        print Check "$username $filename Compiled failed!\n"; 
        print relist "$username\n";             
        if($lock eq "Yes"){print hw "$hwdir $filename Compiled failed!\n";} ########------Check!!!!!!!------########
    }
    system("rm -rf check");
    system("rm -rf output.txt");

}