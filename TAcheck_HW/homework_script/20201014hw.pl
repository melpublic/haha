use Cwd 'chdir';
use Math::Trig;

open txt, "</home/list.txt" or die ("Can't find file");
@list = <txt>;
close txt;
#my @list = grep { $_ !~ /B093022017/ } @list;

$datformat='-d "last Wednesday" "+%Y%m%d"';
$getdat ="date"." $datformat ";
$hwdir=`$getdat`;                ########------Check!!!!!!!------########
chomp($hwdir);

open Check, ">0A_hw_$hwdir.txt";
open errorout, ">0A_error.txt";
open relist, ">relist.txt";
$lock = "Yes";                    ########------Yes or No!!!!!!!------########

@hwname = qw/HW01.c/;            ########------Check!!!!!!!------########

foreach $username(@list)
{
    foreach $filename(@hwname)
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
                &check_hw($lock,"./$filename",$username);
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
}
close errorout;
close relist;
close check;
print "All done!\n";

sub check_hw
{
    ($lock,$hw_filename,$username) = @_;
    if($lock eq "Yes"){
        system("rm -rf output1.txt");
        system("rm -rf output2.txt");
        system("rm -rf output3.txt");
    }
    $Ch = system("gcc -o check $hw_filename -lm"); ########------Check!!!!!!!------########

    #編譯成功
    if($Ch == 0)                                                           
    {
        print Check "$username $filename Compiled successfully! ";         
        if($lock eq "Yes"){print hw "$hwdir $filename Compiled successfully! ";} ########------Check!!!!!!!------########
        $hwout = `./check`;
        #print "$hwout";
        @hwouts= split(/\n/, $hwout);
        #print "$#hwouts\n";

        @file = qw/output1 output2 output3/;
        %num = qw/output1 1000 output2 5000 output3 10000/;

        $HG = 0;
        @teo = ();
        foreach $outputnum(@file)
        {
            if (-e "$outputnum.txt")
            {
                #print "$num{$outputnum}\n";
                open output, "<$outputnum.txt";
                @output = <output>;
                close output;  
                
                $sum = 0;
                for $o(0..$num{$outputnum})
                {
                    if($output[$o] =~ /(\d.\d+) (-?\d.\d+)/)
                    {
                        $radian = $1;
                        $sin = $2;
                        $temp1 = sprintf('%.6f',sin($radian));  #perl calculation sin
                        $temp2 = sprintf('%.6f',$sin);          #c    calculation sin
                        if(0 <= $radian && $radian <= 2.0*pi)   #$radian rang 0 ~ 2*pi
                        {  
                            if ($temp2 >= 0 && $temp1*0.95 <= $temp2 && $temp2 <= $temp1*1.05)
                            {
                                $sum = $sum + 1;
                            }
                            elsif ($temp2 <= 0 && $temp1*0.95 >= $temp2 && $temp2 >= $temp1*1.05)
                            {
                                $sum = $sum + 1;
                            }
                        }
                        else 
                        {
                            $eo = "$outputnum.txt radian rang error\n"; #error output
                            push @teo, $eo;                             #total error output
                            goto endloop;
                        }
                    }
                    else 
                    {
                        $eo = "$outputnum.txt format error\n";      #error output
                        push @teo, $eo;                             #total error output
                        goto endloop;
                    }
                }
                #print "$sum\n";
                if ($sum == $num{$outputnum} + 1)
                {
                    $HG = $HG + 1;
                    #print "$outputnum good\n";
                }
                else
                {
                    $eo = "$outputnum.txt sin error\n";      #error output
                    push @teo, $eo;                          #total error output
                    #print "$outputnum bad\n";
                }
                endloop:
            }
            else
            {
                $eo = "$outputnum.txt no such file\n";     #error output
                push @teo, $eo;                            #total error output
            }

        }
        if ($HG == 3)
        {
            print "Homework Good!\n";
            print Check "Homework Good!\n";                             #作業寫對
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
    
    #編譯失敗
    elsif($Ch != 0)
    {
        print Check "$username $filename Compiled failed!\n"; 
        print relist "$username\n";             
        if($lock eq "Yes"){print hw "$hwdir $filename Compiled failed!\n";} ########------Check!!!!!!!------########
    }
    system("rm -rf check");
    system("rm -rf output1.txt");
    system("rm -rf output2.txt");
    system("rm -rf output3.txt");
}