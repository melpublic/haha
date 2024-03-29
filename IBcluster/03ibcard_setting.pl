=b
https://support.huaweicloud.com/usermanual-hpc/hpc_01_0004.html
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/networking_guide/sec-Configuring_IPoIB#sec-Understanding_IPoIB_communication_modes
=cut
$old_NC='eno1';
$Nic_inner='ib0';

system("ifup $old_NC");
# get MAC of each internet card
`ip add show $old_NC`=~ m{192.168.0.(\d{1,3})\/24};
my $fourthdigital = $1;
my %mac;
my $ipne = `ip add show $Nic_inner`;      
$ipne =~ /((\w+:){19}\w+)/;# the first matched item is mac!
$mac{$Nic_inner}="$1";      
print "$mac{$Nic_inner}\n";

#inner net setting
`echo "BOOTPROTO=static" > /etc/sysconfig/network-scripts/ifcfg-$Nic_inner`;
`echo "DEVICE=$Nic_inner" >> /etc/sysconfig/network-scripts/ifcfg-$Nic_inner`;
`echo "NAME=$Nic_inner" >> /etc/sysconfig/network-scripts/ifcfg-$Nic_inner`;
`echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-$Nic_inner`;
`echo "IPADDR=192.168.0.$fourthdigital" >> /etc/sysconfig/network-scripts/ifcfg-$Nic_inner`;
`echo "NETMASK=255.255.255.0" >> /etc/sysconfig/network-scripts/ifcfg-$Nic_inner`;
`echo "GATEWAY=192.168.0.101" >> /etc/sysconfig/network-scripts/ifcfg-$Nic_inner`;
`echo "DNS1=8.8.8.8" >> /etc/sysconfig/network-scripts/ifcfg-$Nic_inner`;
`echo "DNS2=140.117.11.1" >> /etc/sysconfig/network-scripts/ifcfg-$Nic_inner`;
`echo "BROADCAST=192.168.0.255" >> /etc/sysconfig/network-scripts/ifcfg-$Nic_inner`;
#`echo "UUID=$nmcli{$Nic_inner}" >> /etc/sysconfig/network-scripts/ifcfg-$Nic_inner`;
`echo "HWADDR=$mac{$Nic_inner}" >> /etc/sysconfig/network-scripts/ifcfg-$Nic_inner`; 
`echo "TYPE=InfiniBand" >> /etc/sysconfig/network-scripts/ifcfg-$Nic_inner`;
`echo "MTU=65520" >> /etc/sysconfig/network-scripts/ifcfg-$Nic_inner`;
`echo "IPV4_FAILURE_FATAL=yes" >> /etc/sysconfig/network-scripts/ifcfg-$Nic_inner`;
`echo "IPV6INIT=no" >> /etc/sysconfig/network-scripts/ifcfg-$Nic_inner`;
`echo "CONNECTED_MODE=yes" >> /etc/sysconfig/network-scripts/ifcfg-$Nic_inner`;
`echo "PREFIX=24" >> /etc/sysconfig/network-scripts/ifcfg-$Nic_inner`;

system("ifdown $Nic_inner");## stop this NIC and force it to use new seeting by the following command 
system("ip addr flush dev $Nic_inner");## remove all previous setting (because we want to assign new informatio)  
system("ifup $Nic_inner"); ## use new setting

`sed -i 's/ONBOOT=yes/ONBOOT=no/1' /etc/sysconfig/network-scripts/ifcfg-$old_NC`;
system("ifdown $old_NC");