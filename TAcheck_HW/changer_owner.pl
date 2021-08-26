use Cwd 'chdir';

#$datformat='-d "last Wednesday" "+%Y%m%d"';
#$getdat ="date"." $datformat ";
#$hwdir=`$getdat`;
#chomp($hwdir);
$hwdir = "20210713";                                        #作業日期 #######------Check!!!!!!!------########

open txt, "</home/list.txt" or die ("Can't find file");
@list = <txt>;
close txt;

@hwname = qw/HW01.c/;

foreach $username(@list)
{
    foreach $filename(@hwname)
    {
        chomp($username);
        #print"$username\n";
        chdir "/home/$username/";

        chdir "./$hwdir/";
        print $ENV{PWD}."\n";
        if ($ENV{PWD} !~ /.+\/$username\/$hwdir/)
        {
            print "Folder name error!\n";
        }
        else
        {
            if (-e $filename)
            {
                system("chown root $filename");
                system("chmod 755 $filename");
            }
            elsif(-e "HW1.c")
            {
                system("chown root HW1.c");
                system("chmod 755 HW1.c");
            }
            else
            {
                print "File name error!\n";
            }
        }
    }
}