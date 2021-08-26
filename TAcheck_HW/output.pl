#$datformat='-d "last Wednesday" "+%Y%m%d"';
#$getdat ="date"." $datformat ";
#$hwdir=`$getdat`;
#chomp($hwdir);
$hwdir="20210713";

open A, "<0A_hw_$hwdir.txt" or die ("Can't find file");
@A = <A>;
close A;

open B, "<0B_rehw_$hwdir.txt" or die ("Can't find file");
@B = <B>;
close B;

open final, ">hw_$hwdir.txt";
$n = 0;
foreach $AA(@A)
{
    chomp($AA);
    #print "$AA\n";
    if ($AA =~ /(\w\d+) (HW01.c) (?!.*Good!)/)
    {
        #print "$n $1\n";
        push @nn, $n;
    }
    $n = $n + 1;
}

for $BB(0..$#B)
{
    chomp($B[$BB]);
    #print "$B[$BB]\n";
    #print "$A[$nn[$BB]]\n";
    $A[$nn[$BB]] = $B[$BB];
}

foreach $ff(@A)
{
    print final "$ff\n";
}
close final;