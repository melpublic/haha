use Cwd 'chdir';
use Math::Trig;

open txt, "</home/list.txt" or die ("Can't find file");
@list = <txt>;
close txt;
#my @list = grep { $_ !~ /B093022017/ } @list;
#@list = qw/B093022007/;

$datformat='-d "last Wednesday" "+%Y%m%d"';
$getdat ="date"." $datformat ";
$hwdir=`$getdat`;                ########------Check!!!!!!!------########
chomp($hwdir);
$hwdir = "20201111";

open Check, ">0A_hw_$hwdir.txt";
open errorout, ">0A_error_$hwdir.txt";
open relist, ">relist_$hwdir.txt";
$lock = "Yes";                    ########------Yes or No!!!!!!!------########

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

    #編譯成功
    if($Ch == 0)                                                           
    {
        print Check "$username $filename Compiled successfully! ";         
        if($lock eq "Yes"){print hw "$hwdir $filename Compiled successfully! ";} ########------Check!!!!!!!------########
        $hwout = `./check`;
        #print "$hwout";
        @hwouts= split(/\n/, $hwout);
        #print "$#hwouts\n";

        open input, "</root/check_HW/input_20201111.txt";
        @input = <input>;
        close input;

        open output, "<output.txt";
        @output = <output>;
        close output;    
        
        $HG = 0;
        @err = ();
        if ($output[0] =~ /ID   English Adjusted Difference/){
            $HG = $HG + 1;
        }
        else
        {
            push @err, "first row format error";
        }

        for $num(1..$#input) {
            @s_in_num=split(' ', $input[$num]);
            #print "$s_in_num[0]\n";
            $adjusted = sqrt($s_in_num[1])*10;
            $adjusted = sprintf('%.1f', $adjusted);
            $difference = $adjusted - $s_in_num[1];
            $difference = sprintf('%.1f', $difference);
            #print "$s_in_num[0] $s_in_num[1] $adjusted $difference\n";

            #print "$output[$num]\n";
            if ($output[$num] =~ /($s_in_num[0])\s+($s_in_num[1])\s+($adjusted)\s+($difference)/m){
                $HG = $HG + 1;
                push @err, "$output[$num]\n";
                #print "$HG\n";
            }
        }

        if ($HG == 101)
        {
            print "Homework Good!\n";
            print Check "Homework Good!\n";                             #作業寫對
            if($lock eq "Yes"){print hw "Homework Good!\n";}            ########------Check!!!!!!!------########
        }
        else
        {
            print errorout "$username $hw_filename\n";
            print errorout "ID   English Adjusted Difference\n";
            print errorout "$err[0]\n";
            print errorout "$output[0]";
            print errorout "$output[-1]";
            print errorout "correct num:$HG\n";
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
        print errorout "$username $hw_filename\n";
        print errorout "Compiled failed!\n";
        print errorout "\n";
        print Check "$username $filename Compiled failed!\n"; 
        print relist "$username\n";             
        if($lock eq "Yes"){print hw "$hwdir $filename Compiled failed!\n";} ########------Check!!!!!!!------########
    }
    system("rm -rf check");
    system("rm -rf output.txt");
}