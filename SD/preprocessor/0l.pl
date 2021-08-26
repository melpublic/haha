#@files = <*.data>;
#
#foreach my $i (@files){
#unlink "$i";
#print "Kill $i file\n";
#}
unlink "./msd.exe";
system("gfortran -O3 -o msd.exe msd_omp.f90");
#sleep(1);
system('./msd.exe');