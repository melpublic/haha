use Cwd 'chdir';
use Math::Trig;

open txt, "</home/list.txt" or die ("Can't find file");
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
$lock = "No";                    ########------Yes or No!!!!!!!------########

$filename = "HW01.c";            ########------Check!!!!!!!------########

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
        if (-e $filename)
        {
            &check_hw($lock,$filename,$username);
            if($lock eq "Yes"){
                system("chown root $filename"); ########------Check!!!!!!!------########
                system("chmod 755 $filename");  ########------Check!!!!!!!------########
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
    ($lock,$hw_filename,$username) = @_;
    if($lock eq "Yes"){
        system("rm -rf output.txt");
    }
    $Ch = system("gcc -o check $hw_filename -std=c99 -lm"); ########------Check!!!!!!!------########

    #編譯?��?
    if($Ch == 0)                                                           
    {
        print Check "$username $filename Compiled successfully! ";         
        if($lock eq "Yes"){print hw "$hwdir $filename Compiled successfully! ";} ########------Check!!!!!!!------########
        $hwout = `./check`;
        #print "$hwout";
        @hwouts= split(/\n/, $hwout);
        #print "$#hwouts\n";

        open input, "<input.txt";
        @input = <input>;
        close input;

        open output, "<output.txt";
        @output = <output>;
        close output;    

        $HG = 0;
        @apartofAns1 = split (' ',$output[0]);
        @apartofAns2 = split (' ',$output[1]);
       # print qq(@apartofAns[0]);
       #print qq($apartofAns[0]    $apartofAns[1]\n);
        if ($apartofAns1[1] =~ m/7/x && $apartofAns1[2] =~ m/21/x && $apartofAns1[3] =~ m/17\.18/x || $apartofAns1[1] =~ m/21/x && $apartofAns1[2] =~ m/7/x && $apartofAns1[3] =~ m/17\.18/x)
            {
                $HG = $HG+1;
               # print qq($HG\n);
            }
        if ($apartofAns2[1] =~ m/15/x && $apartofAns2[2] =~ m/5/x && $apartofAns2[3] =~ m/22/x && $apartofAns2[4] =~ m/174\.62/x ||
            $apartofAns2[1] =~ m/5/x && $apartofAns2[2] =~ m/15/x && $apartofAns2[3] =~ m/22/x && $apartofAns2[4] =~ m/174\.62/x ||
            $apartofAns2[1] =~ m/15/x && $apartofAns2[2] =~ m/5/x && $apartofAns2[3] =~ m/22/x && $apartofAns2[4] =~ m/174\.6199/x ||
            $apartofAns2[1] =~ m/5/x && $apartofAns2[2] =~ m/15/x && $apartofAns2[3] =~ m/22/x && $apartofAns2[4] =~ m/174\.6199/x ||
            $apartofAns2[1] =~ m/15/x && $apartofAns2[2] =~ m/5/x && $apartofAns2[3] =~ m/22/x && $apartofAns2[4] =~ m/1\.74/x   ||
            $apartofAns2[1] =~ m/15/x && $apartofAns2[2] =~ m/5/x && $apartofAns2[3] =~ m/22/x && $apartofAns2[4] =~ m/1\.74/x   ||
            $apartofAns2[1] =~ m/ID15/x && $apartofAns2[2] =~ m/ID5/x && $apartofAns2[3] =~ m/ID22/x && $apartofAns2[4] =~ m/1\.74/x   ||
            $apartofAns2[1] =~ m/ID15/x && $apartofAns2[2] =~ m/ID5/x && $apartofAns2[3] =~ m/ID22/x && $apartofAns2[4] =~ m/174\.62/x ||
            $apartofAns2[1] =~ m/ID5/x && $apartofAns2[2] =~ m/ID15/x && $apartofAns2[3] =~ m/ID22/x && $apartofAns2[4] =~ m/174\.62/x ||
            $apartofAns2[1] =~ m/ID15/x && $apartofAns2[2] =~ m/ID5/x && $apartofAns2[3] =~ m/ID22/x && $apartofAns2[4] =~ m/174\.6199/x ||
            $apartofAns2[1] =~ m/ID5/x && $apartofAns2[2] =~ m/ID15/x && $apartofAns2[3] =~ m/ID22/x && $apartofAns2[4] =~ m/174\.6199/x             
           )
           
            {
                $HG = $HG+2;
                #print qq(GOOD!! $HG\n);
            }
        if ($HG == 1)
            {   
                print Check qq(Ans1 is good Ans2 is bad);
            }
        if ($HG == 2)
            {
                print Check qq(Ans2 is good Ans1 is bad);
            }
        if ($HG == 3)
        {
            print "Homework Good!\n";
            print Check "Homework Good!\n";                             #作業寫�?
            if($lock eq "Yes"){print hw "Homework Good!\n";}            ########------Check!!!!!!!------########
        }
        else
        {
            print errorout "$username $hw_filename\n";
            foreach $errortemp(@teo){print errorout "$errortemp";}
            print errorout "\n";
            print "Homework Bad!\n";
            print Check "Homework Bad!\n";                              #作業寫錯
            print relist "$username\n";
            if($lock eq "Yes"){print hw "Homework Bad!\n";}             ########------Check!!!!!!!------########
        } 
    }
    
    #編譯失�?
    elsif($Ch != 0)
    {
        print Check "$username $filename Compiled failed!\n"; 
        print relist "$username\n";             
        if($lock eq "Yes"){print hw "$hwdir $filename Compiled failed!\n";} ########------Check!!!!!!!------########
    }
    system("rm -rf check");
    #system("rm -rf output.txt");
}