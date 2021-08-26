use Cwd 'chdir';
use Math::Trig;

#open txt, "</home/list.txt" or die ("Can't find file");
open txt, "< relist_all.txt" or die ("Can't find file");
@list = <txt>;
close txt;
#my @list = grep { $_ !~ /B093022017/ } @list;
#@list = qw/node01/;

$datformat='-d "last Wednesday" "+%Y%m%d"';
$getdat ="date"." $datformat ";
$hwdir=`$getdat`;                ########------Check!!!!!!!------########
chomp($hwdir);
#$hwdir = "20201111";

open Check, ">0A_hw_$hwdir.txt";
open errorout, ">0A_error_$hwdir.txt";
open relist, ">relist.txt";
$lock = "Yes";                    ########------Yes or No!!!!!!!------########

$filename = "HW01.c";            ########------Check!!!!!!!------########
$sub1 = "distance.c";
$sub2 = "angle.c";

foreach $username(@list)
{
    chomp($username);
    #print"$username\n";
    chdir "/home/$username/";
    if($lock eq "Yes"){
        system("perl -p -i -e 's/$hwdir $filename.+\n//g;' ./Homework_Report.txt"); ########------Check!!!!!!!------########
        open hw, ">> ./Homework_Report.txt";                                        ########------Check!!!!!!!------########
    }

    chdir "./$hwdir/";
    print $ENV{PWD}."\n";
    if ($ENV{PWD} !~ /.+\/$username\/$hwdir/)                                       ########------Folder name error!------########
    {
        print "Folder name error!\n";
        print Check "$username $filename Folder name error!\n";
        print relist "$username\n";
        if($lock eq "Yes"){print hw "$hwdir $filename Folder name error!\n";}       ########------Check!!!!!!!------########
    }
    else
    {
        if (-e $filename && $sub1 && $sub2)
        {
            #print "yes\n";
            &check_hw($lock,$filename,$sub1,$sub2,$username);
            if($lock eq "Yes"){
                system("chown root $filename $sub1 $sub2"); ########------Check!!!!!!!------########
                system("chmod 755  $filename $sub1 $sub2");  ########------Check!!!!!!!------########
            }
        }
        else                                                                    ########------File name error!------########
        {
            print "File name error!\n";
            print Check "$username $filename File name error!\n";
            print relist "$username\n";
            if($lock eq "Yes"){print hw "$hwdir $filename File name error!\n";} ########------Check!!!!!!!------########
        }

    }
    if($lock eq "Yes"){close hw;}               ########------Check!!!!!!!------########
}
close errorout;
close relist;
close check;
print "All done!\n";

sub check_hw
{
    ($lock,$hw_filename,$sub1,$sub2,$username) = @_;
    if($lock eq "Yes"){
        system("rm -rf output.txt");
    }
    $Ch = system("gcc -o check $hw_filename $sub1 $sub2 -std=c99 -lm"); ########------Check!!!!!!!------########
    
    $nrv = 0;
    open ssd, "<distance.c";
    @sub_d = <ssd>;
    close ssd;
    foreach (@sub_d){
        if ($_ =~ /.+"r".+/m)
        {
            #print "no return value ";
            $nrv = $nrv + 0.5;
        }
        if ($_ =~ /.+fscanf.+/m)
        {
            #print "no return value ";
            $nrv = $nrv + 2;
        }
    }

    open ssa, "<angle.c";
    @sub_a = <ssa>;
    close ssa;
    foreach (@sub_a){
        if ($_ =~ /.+"r".+/m)
        {
            #print "no return value ";
            $nrv = $nrv + 0.5;
        }
        if ($_ =~ /.+fscanf.+/m)
        {
            #print "no return value ";
            $nrv = $nrv + 2;
        }
    }
    #print "$nrv\n";

    #編譯成功
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

        if ($nrv > 1)
        {
            print "Homework no return value!\n";
            print Check "Homework no return value!\n";                             #作業寫對
            if($lock eq "Yes"){print hw "Homework no return value!\n";}            ########------Check!!!!!!!------########
            print relist "$username\n";
        }
        elsif ($HG == 2)
        {
            print "Homework Good!\n";
            print Check "Homework Good!\n";                             #作業寫對
            if($lock eq "Yes"){print hw "Homework Good!\n";}            ########------Check!!!!!!!------########
        }
        else
        {
            print errorout "$username $hw_filename\n";
            print errorout "$output[0]";
            print errorout "$output[1]";
            print errorout "\n";
            print "Homework Bad!\n";
            print Check "Homework Bad!\n";                              #作業寫錯
            print relist "$username\n";
            if($lock eq "Yes"){print hw "Homework Bad!\n";}             ########------Check!!!!!!!------########
        } 
    }
    
    #編譯失敗
    elsif($Ch != 0)
    {
        print Check "$username $filename Compiled failed!\n"; 
        print relist "$username\n";             
        if($lock eq "Yes"){print hw "$hwdir $filename Compiled failed!\n";} ########------Check!!!!!!!------########
    }
    system("rm -rf check");
    system("rm -rf output.txt");

}