my $box_x = 420;
my $box_y = 420;
my $box_z = 420;
my $grain_num = 3;
open ss, ">polycrystal.txt";
print ss "box $box_x $box_y $box_z\n";
print ss "random $grain_num\n";
close ss;

system("atomsk --create bcc 3.30260 Ta 00Ta.xsf -ow");
system("atomsk --polycrystal 00Ta.xsf polycrystal.txt 00grain.cfg lmp -wrap -ow");

