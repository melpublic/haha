use Cwd 'chdir';
#當天日期
#$datformat='+%Y%m%d';
#當前上禮拜日期
#$datformat='-d "-1 week" "+%Y%m%d"';
#昨天日期
#$datformat='-d "-1 day" "+%Y%m%d"';
#上禮拜三日期
$datformat='-d "last Wednesday" "+%Y%m%d"';
$getdat ="date"." $datformat ";
$hwdir=`$getdat`;
chomp($hwdir);

open Check, ">00hw_$hwdir.txt";
open txt, "<../home/list.txt" or die ("Can't find file");
@list = <txt>;
close txt;

@hwname = qw/HW01.c/;

foreach $username(@list)
{
    foreach $filename(@hwname)
    {
        #$filename = "HW1.c";                           ########------Check!!!!!!!------########
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
            printf Check "$username $filename Folder name error!\n";
            printf hw "$hwdir $filename Folder name error!\n";
        }
        else
        {
            if (-e $filename)
            {
                &check_hw("./$filename",$username,"Ans1:$username\nAns2:Hello world!");
            }
            elsif(-e "HW1.c")
            {
                &check_hw("./HW1.c",$username,"Ans1:$username\nAns2:Hello world!");
            }
            else
            {
                print "File name error!\n";
                printf Check "$username $filename File name error!\n";
                printf hw "$hwdir $filename File name error!\n";
            }
        }
        close hw;
    }
}
close check;

sub check_hw
{
    ($hw_filename,$username,$regex) = @_;
    $Ch = system("gcc $hw_filename");
    if($Ch == 0)
    {
        printf Check "$username $filename Compiled successfully! ";         #編譯成功
        printf hw "$hwdir $filename Compiled successfully! ";
        $hwout = `./a.out`;                                             ########------Check!!!!!!!------########
        if($hwout =~ /$regex/gm)
        {                                                                   
            print "Homework very Good!\n"; 
            printf Check "Homework very Good!\n";                                #作業寫對
            printf hw "Homework very Good!\n";
            break;
        }
        elsif($hwout =~ /$regex/gmi)
        {                                                                   
            print "Homework Good!\n"; 
            printf Check "Homework Good!\n";                                #作業寫對
            printf hw "Homework Good!\n";
        }
        else
        {
            print "Homework Bad!\n"; 
            printf Check "Homework Bad!\n";                                 #作業寫錯
            printf hw "Homework Bad!\n";
        } 
    }
    elsif($Ch != 0)
    {
        printf Check "$username $filename Compiled failed!\n";              #編譯失敗
        printf hw "$hwdir $filename Compiled failed!\n";
    }
    system("rm -rf a.out");
}