# serverip:19999
system("firewall-cmd --zone=external --add-port=19999/tcp --permanent");
system ("firewall-cmd --reload"); #reload

chdir("/opt/");
system("curl -Ss 'https://raw.githubusercontent.com/netdata/netdata/master/packaging/installer/install-required-packages.sh' >/tmp/install-required-packages.sh && bash /tmp/install-required-packages.sh -i netdata -y");
system("curl -Ss 'https://raw.githubusercontent.com/netdata/netdata/master/packaging/installer/install-required-packages.sh' >/tmp/install-required-packages.sh && bash /tmp/install-required-packages.sh -i netdata-all -y");
system("yum install autoconf automake curl gcc git libmnl-devel libuuid-devel openssl-devel libuv-devel lz4-devel Judy-devel elfutils-libelf-devel make nc pkgconfig python zlib-devel cmake -y");

system("yum install -y 'dnf-command(config-manager)'");
system("yum config-manager --set-enabled powertools");
system("yum install -y epel-release");
system("yum install -y http://repo.okay.com.mx/centos/8/x86_64/release/okay-release-1-3.el8.noarch.rpm");
system("yum install -y autoconf automake curl gcc git cmake libuuid-devel openssl-devel libuv-devel lz4-devel make nc pkgconfig python3 zlib-devel");
system("yum install -y http://mirror.centos.org/centos/8/PowerTools/x86_64/os/Packages/Judy-devel-1.0.5-18.module_el8.1.0+217+4d875839.x86_64.rpm");

system("git clone https://github.com/netdata/netdata.git --depth=100 --recursive");
chdir("/opt/netdata/");
system("./netdata-installer.sh --dont-wait");

system("/usr/sbin/netdata"); #start netdata
#killall netdata -> close netdata

