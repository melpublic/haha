use Cwd 'chdir';

open txt, "</home/list.txt" or die ("Can't find file");
@list = <txt>;
close txt;

$datformat='-d "last Wednesday" "+%Y%m%d"';
$getdat ="date"." $datformat ";
$hwdir=`$getdat`;
chomp($hwdir);

open Check, ">0A_hw_$hwdir.txt"; ########------Check!!!!!!!------########
open errorout, ">0A_error.txt";
open relist, ">relist.txt";
$lock = "Yes";                    ########------Check!!!!!!!------########

@hwname = qw/HW01.c/;            ########------Check!!!!!!!------########

foreach $username(@list)
{
    foreach $filename(@hwname)
    {
        chomp($username);
        #print"$username\n";
        chdir "/home/$username/";
        system("perl -p -i -e 's/$hwdir $filename.+\n//g;' ./Homework_Report.txt");
        open hw, ">> ./Homework_Report.txt";

        chdir "./$hwdir/";
        print $ENV{PWD}."\n";
        if ($ENV{PWD} !~ /.+\/$username\/$hwdir/)
        {
            print "Folder name error!\n";
            print Check "$username $filename Folder name error!\n";
            print relist "$username\n";
            if($lock eq "Yes"){print hw "$hwdir $filename Folder name error!\n";}
        }
        else
        {
            if (-e $filename)
            {
                &check_hw("./$filename",$username);
                if($lock eq "Yes"){
                system("chown root $filename");
                system("chmod 755 $filename");
            }
            }
            else
            {
                print "File name error!\n";
                print Check "$username $filename File name error!\n";
                print relist "$username\n";
                if($lock eq "Yes"){print hw "$hwdir $filename File name error!\n";}
            }
        }
        close hw;
    }
}
close errorout;
close relist;
close check;

sub check_hw
{
    ($hw_filename,$username) = @_;
    $Ch = system("gcc -o check $hw_filename");

    #編譯成功
    if($Ch == 0)                                                           
    {
        print Check "$username $filename Compiled successfully! ";         
        if($lock eq "Yes"){print hw "$hwdir $filename Compiled successfully! ";}
        $hwout = `./check`;                                                 ########------Check!!!!!!!------########
        #print "$hwout";
        @s= split(/\n/, $hwout);
        #print "$#s\n";

        #if($s[0] =~ /Ans\d+: \d+ dollars? on Day \d+/)
        #{                                                                   
        $HG = 0;
        @en = ();
        $s = 0;
        for $n(0..$#s)
        {
            if ($s[$n] =~ /Ans\d+: (\d+).?(\d+)? dollars? on Day \d+/)
            {
                $HG = $HG + 1;
                $s = $s + $1;
            }
            elsif ($s[$n] =~ /Ans\d+: SUM: (\d+).?(\d+)? dollars/)
            {
                if ($s == $1){ $HG = $HG + 1;}
                else {push @en, $n; }               
            }
            else
            {
                push @en, $n;                                           #error output
            }
        }
        if ($HG == $#s+1)
        {
            print "Homework Good!\n";
            print Check "Homework Good!\n";                             #作業寫對
            if($lock eq "Yes"){print hw "Homework Good!\n";}
        }
        else
        {
            print errorout "$username $hw_filename\n";
            print errorout "$hwout\n";
            print errorout "First error $s[$en[0]]\n\n";
            print "Homework Bad!\n";
            print Check "Homework Bad!\n";                              #作業寫錯
            print relist "$username\n";
            if($lock eq "Yes"){print hw "Homework Bad!\n";}
        } 
        #}
        #else
        #{
        #    print errorout "$username $hw_filename\n";
        #    print errorout "$hwout\n";
        #    print errorout "First error $s[0]\n\n";
        #    print "Homework Bad!\n"; 
        #    print Check "Homework Bad!\n";                                  #作業寫錯
        #    print relist "$username\n";
        #    if($lock eq "Yes"){print hw "Homework Bad!\n";}
        #} 
    }
    
    #編譯失敗
    elsif($Ch != 0)
    {
        print Check "$username $filename Compiled failed!\n"; 
        print relist "$username\n";             
        if($lock eq "Yes"){print hw "$hwdir $filename Compiled failed!\n";}
    }
    system("rm -rf check");
}