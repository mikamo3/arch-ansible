#/usr/bin/env bash
sudo iscsiadm -m discovery -t sendtargets -p 192.168.100.70
sudo iscsiadm -m node --targetname iqn.2005-10.org.freenas.ctl:temp --login