use Cwd 'chdir';
use Math::Trig;

$recheck = "Yes";                                            #重新批改 #######----Yes or No!!!!!!!----########
$lock = "No";                                               #鎖定作業 #######----Yes or No!!!!!!!----########

#$datformat='-d "last Wednesday" "+%Y%m%d"';
#$getdat ="date"." $datformat ";
#$hwdir=`$getdat`;                
#chomp($hwdir);
$hwdir = "20210713";                                        #作業日期 #######------Check!!!!!!!------########

if($recheck eq "Yes"){
    $filename = "HW01.c";                                   #作業名稱 #######------Check!!!!!!!------########
    open txt, "< relist.txt" or die ("Can't find file");    #讀需重新批改的名單
    open Check, ">0B_rehw_$hwdir.txt";                        #輸出作業批改結果
    open errorout, ">0B_error_$hwdir.txt";                  #輸出作業答錯的結果
}
else{
    $filename = "HW01.c";                                   #作業名稱 #######------Check!!!!!!!------########
    open txt, "</home/list.txt" or die ("Can't find file"); #讀學生名單
    open Check, ">0A_hw_$hwdir.txt";                        #輸出作業批改結果
    open errorout, ">0A_error_$hwdir.txt";                  #輸出作業答錯的結果
    open relist, ">relist.txt";                             #輸出需重新批改的名單
}
@list = <txt>;
close txt;

#my @list = grep { $_ !~ /B093022017/ } @list;              #過濾學號
#@list = qw/node01/;                                        #測試名單

foreach $username(@list)
{
    chomp($username);
    #print"$username\n";                                    #確認學號
    chdir "/home/$username/";
    if($lock eq "Yes"){
        system("perl -p -i -e 's/$hwdir $filename.+\n//g;' ./Homework_Report.txt"); ########------Check!!!!!!!------########
        open hw, ">> ./Homework_Report.txt";                                        ########------Check!!!!!!!------########
    }

    chdir "./$hwdir/";
    print $ENV{PWD}."\n";                                   #在螢幕確認當前資料是否在作業資料夾
    if ($ENV{PWD} !~ /.+\/$username\/$hwdir/)               #作業資料夾名稱錯誤
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
            #print "yes\n";
            &check_hw($lock,$filename,$username);
            if($lock eq "Yes"){
                system("chown root $filename");            #權限鎖定 #######------Check!!!!!!!------########
                system("chmod 755  $filename");            #權限鎖定 #######------Check!!!!!!!------########
            }
        }
        else                                               #作業名稱錯誤
        {
            print "File name error!\n";
            print Check "$username $filename File name error!\n";
            print relist "$username\n";
            if($lock eq "Yes"){print hw "$hwdir $filename File name error!\n";}     ########------Check!!!!!!!------########
        }

    }
    if($lock eq "Yes"){close hw;}                                                   ########------Check!!!!!!!------########
}
close errorout;
close relist;
close Check;
print "All done!\n";

#批改作業副程式
sub check_hw
{
    ($lock,$hw_filename,$username) = @_;
    if($lock eq "Yes"){
        system("rm -rf output.txt");
    }
    $Ch = system("gcc -o check $hw_filename $sub1 $sub2 -std=c99 -lm"); #編譯指令   #######------Check!!!!!!!------########
    
    #編譯成功
    if($Ch == 0)                                                           
    {
        print Check "$username $filename Compiled successfully! ";         
        if($lock eq "Yes"){print hw "$hwdir $filename Compiled successfully! ";}    ########------Check!!!!!!!------########
        $hwout = `./check`;
        #print "$hwout";                            #輸出學生作業執行結果
        #@hwouts= split(/\n/, $hwout);
        #print "$#hwouts\n";

        $regex = "Hello! World!\n";                 #作業正確答案
        if($hwout =~ /$regex/gmi)                   #作業寫對
        {                                                                   
            print "Homework Good!\n"; 
            printf Check "Homework Good!\n";        #作業寫對
            if($lock eq "Yes"){print hw "Homework Good!\n";}                        ########------Check!!!!!!!------########
        }
        else #作業寫錯
        {
            print errorout "$username $hw_filename\n";
            print errorout "$hwout";
            print errorout "\n";
            print "Homework Bad!\n"; 
            printf Check "Homework Bad!\n";         #作業寫錯
            print relist "$username\n";
            if($lock eq "Yes"){print hw "Homework Bad!\n";}                         ########------Check!!!!!!!------########
        }  
    }
    
    #編譯失敗
    elsif($Ch != 0)
    {
        print Check "$username $filename Compiled failed!\n"; 
        print relist "$username\n";             
        if($lock eq "Yes"){print hw "$hwdir $filename Compiled failed!\n";}         ########------Check!!!!!!!------########
    }
    system("rm -rf check");
    system("rm -rf output.txt");
}