=b
https://blog.csdn.net/oPrinceme/article/details/51001849
driver(LTS download): https://www.mellanox.com/products/infiniband-drivers/linux/mlnx_ofed
=cut

system("dnf install createrepo python36-devel kernel-rpm-macros elfutils-libelf-devel tcsh tk -y");
system("mount -o ro,loop MLNX_OFED_LINUX*.iso /mnt");
chdir("/mnt");
system("./mlnxofedinstall --add-kernel-support");
#system("/etc/init.d/openibd restart");
