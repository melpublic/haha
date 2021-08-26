use strict;
use warnings;
use Time::HiRes qw( time );
use Parallel::ForkManager;
#use 5.010;
my $start = time();

#my $socketNo = `lscpu|grep "^Socket(s):" | sed 's/^Socket(s): *//g'`; 
#chomp $socketNo;
#
#my $corePsocket = `lscpu|grep "^Core(s) per socket:" | sed 's/^Core(s) per socket: *//g'`; 
#chomp $corePsocket;
#
#my $threadPcore = `lscpu|grep "^Thread(s) per core:" | sed 's/^Thread(s) per core: *//g'`;
#chomp $threadPcore;
#print "***socketNo, corePsocket, threadPcore: $socketNo, $corePsocket, $threadPcore\n";
#my $threads = $socketNo * $corePsocket * $threadPcore;
#print "Total threads can be used: $threads\n";
#if($threads == 0){die "thread Number is $threads, wrong!!!!\n";}
#my $forkNo = $threads;

my $atom = 0;
my $gbatom = 0;
my $gatom = 0;

open my $gg, ">GB.dat";
open my $cc, "<cna.cfg"; #id StructureType
while (my $cna_num = <$cc>) 
{   
    $atom += 1;

    chomp $cna_num;

	#Save GB atomic ID
    if ($cna_num =~ /(\d+) (0||1||2||4)$/) #0 1 2 3 4 > other FCC HCP BCC ICO 
    {
        #print gg "ParticleIdentifier==$1 ||\n";
        print $gg "$1\n";
        $gbatom += 1;
    }
    else
    {
        $gatom += 1;
    }
}
close $cc;
close $gg;

if($atom == $gbatom + $gatom){print "true\n";}
print "$atom $gbatom $gatom\n";
my $gbv = ($gbatom/$atom)*100;
printf("%.2f\n",$gbv);

#my $forkNo = $threads;
my $forkNo = 10; #need to check
my $pm = Parallel::ForkManager->new("$forkNo");

## put all GB atoms in an array 
open my $ss,"< ./GB.dat" or die "No GB.dat to read"; 
my @temp_array=<$ss>;
my @GBatoms= grep (($_!~m{^\s*$|^#}),@temp_array); # remove blank lines and comment lines
close $ss;
my $GBatomNo = @GBatoms; #total GB atom number
my $totalAtomNo;# assigned later
my $modifedAtomNo;# assigned later
my @eval;

for (0..$#GBatoms){
	my $temp = $GBatoms[$_];
	chomp $temp;
	$eval[$temp] = 0; #defined element, otherwise undefined
} 

# fork here
for (my $n=1 ; $n<=1; $n++) #need to check
{
$pm->start and next; 
	my $id = 1980 + $n*20; #need to check
	open $ss, "< ./HEA_$id.cfg" or die "No cfg to read"; #cfg file name
	open my $out0, "> ./00HEA_$id.cfg"; #GB atom cfg
	open my $out1, "> ./11HEA_$id.cfg"; #Grain atom cfg
	## deal with the first 9 lines
	my $i = 0;
	while (<$ss>) {
		if($i == 3){
			chomp;
			$modifedAtomNo = $_ - $GBatomNo;
			print $out0 "$modifedAtomNo\n";
			print $out1 "$GBatomNo\n";
		}
		else{
			chomp;
			print $out0 "$_\n";
			print $out1 "$_\n";
		}  
	
	  	print "$i, $_\n";
	  	$i++;
	  	if ($i == 9) {last;}
	}

	# deal with the coordinates
	#my $counter = 0;
	while ( <$ss> ){# read data line by line to save     
		$_  =~ s/^\s+|\s+$//;

		#sleep(10);
		chomp;
	    my @temp = split(/\s+/,$_);
	    #print "$_:-> $temp[0]". defined($eval[$temp[0]])."\n";
	    #sleep(10);
			if(! defined($eval[$temp[0]])){
					print $out0 "$_\n";
					#print "ID and xyz: $_\n";
					#sleep(10);
			}
			else
			{
				print $out1 "$_\n";
			}
	    #$counter++;
	}
	close $ss;
	close $out0;
	close $out1;
$pm->finish;
}
$pm->wait_all_children;

my $end = time();
printf("Execution Time: %0.02f s\n", $end - $start);
