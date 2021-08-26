=b
https://blog.csdn.net/oPrinceme/article/details/51001849
https://docs.mellanox.com/display/OFEDv502180/InfiniBand+Fabric+Utilities
https://wiki.archlinux.org/title/InfiniBand
=cut

system("/etc/init.d/openibd restart");
system("service openibd start");
system("chkconfig openibd on");
system("service opensmd start");
system("chkconfig opensmd on");
system("ibstat");
system("hca_self_test.ofed");