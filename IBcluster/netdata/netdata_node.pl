# https://learn.netdata.cloud/docs/agent/streaming/

$MASTER_SERVER_IPPORT = '140.117.59.195:19999';

chdir("/opt/");
#system("git clone https://github.com/netdata/netdata.git --depth=100 --recursive");

system("curl -Ss 'https://raw.githubusercontent.com/netdata/netdata/master/packaging/installer/install-required-packages.sh' >/tmp/install-required-packages.sh && bash /tmp/install-required-packages.sh -i netdata -y");
system("curl -Ss 'https://raw.githubusercontent.com/netdata/netdata/master/packaging/installer/install-required-packages.sh' >/tmp/install-required-packages.sh && bash /tmp/install-required-packages.sh -i netdata-all -y");
system("yum install autoconf automake curl gcc git libmnl-devel libuuid-devel openssl-devel libuv-devel lz4-devel Judy-devel elfutils-libelf-devel make nc pkgconfig python zlib-devel cmake -y");

system("yum install -y 'dnf-command(config-manager)'");
system("yum config-manager --set-enabled powertools");
system("yum install -y epel-release");
system("yum install -y http://repo.okay.com.mx/centos/8/x86_64/release/okay-release-1-3.el8.noarch.rpm");
system("yum install -y autoconf automake curl gcc git cmake libuuid-devel openssl-devel libuv-devel lz4-devel make nc pkgconfig python3 zlib-devel");
system("yum install -y http://mirror.centos.org/centos/8/PowerTools/x86_64/os/Packages/Judy-devel-1.0.5-18.module_el8.1.0+217+4d875839.x86_64.rpm");

chdir("/opt/netdata/");
system("./netdata-installer.sh --dont-wait");

system("/usr/sbin/netdata"); #start netdata
#killall netdata -> close netdata

#/etc/netdata/netdata.conf
$hostname = `hostname`;
chomp($hostname);
`sed -i '19s/# hostname = $hostname/hostname = $hostname/1' /etc/netdata/netdata.conf`;
#`sed -i 's/# memory mode = dbengine/memory mode = none/1' /etc/netdata/netdata.conf`;
#`sed -i 's/# mode = static-threaded/mode = none/1' /etc/netdata/netdata.conf`;

#/etc/netdata/stream.conf
$uuid = `uuidgen`;
chomp($uuid);
`echo "[stream]" > /etc/netdata/stream.conf`;
`echo "enabled = yes" >> /etc/netdata/stream.conf`;
`echo "destination = $MASTER_SERVER_IPPORT" >> /etc/netdata/stream.conf`;
`echo "api key = $uuid" >> /etc/netdata/stream.conf`;

system("systemctl restart netdata");

#/opt/stream.conf
`echo "#$hostname" >> /opt/stream.conf`;
`echo "[$uuid]" >> /opt/stream.conf`;
`echo "enabled = yes" >> /opt/stream.conf`;
`echo "default history = 3600" >> /opt/stream.conf`;
`echo "default memory mode = save" >> /opt/stream.conf`;
`echo "health enabled by default = auto" >> /opt/stream.conf`;
`echo "allow from = *" >> /opt/stream.conf`;