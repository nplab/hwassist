# hwassist

Script that prints the value of FreeBSD's `if_hwassist` for a network interface.

With root privilege, call

```
./hwassist.sh <interface>
```

## How it works

The shell script starts `dtrace`, which runs `ifconfig` for the given interface
that triggers the configured dtrace probe. The probe starts a dtrace action 
that reads the `if_hwassist` value of the interface and prints its value
directly beneath the output of `ifconfig`.

The dtrace action prints the value in hexadecimal followed by the name of the
`CSUM_*` flags set (based on the value) in angle brackets.

## Background

FreeBSD allows an user to enable or disable transmission checksum offloading
(`TXCSUM`) or (`TXCSUM6`) and transmission segmentation offloading
(`TSO` or `TSO6`) on an network interface. For example, enabling `TXCSUM` with
`ifconfig` on interface em0:

```
ifconfig em0 txcsum
```

For which protocols the interface performs checksum offloading is not
transparent. The driver sets the protocol specific `CSUM_*` flags in the
`if_hwassist` field of interface's `struct ifnet`. This script allows to
read and print this field.

This is an example output of the script for the igb3 interface.

```
sudo ./hwassist.sh igb3
igb3: flags=1008943<UP,BROADCAST,RUNNING,PROMISC,SIMPLEX,MULTICAST,LOWER_UP> metric 0 mtu 1500
	options=4e503bb<RXCSUM,TXCSUM,VLAN_MTU,VLAN_HWTAGGING,JUMBO_MTU,VLAN_HWCSUM,TSO4,TSO6,VLAN_HWFILTER,VLAN_HWTSO,RXCSUM_IPV6,TXCSUM_IPV6,HWSTATS,MEXTPG>
	ether ...
	media: Ethernet autoselect (1000baseT <full-duplex>)
	status: active
	nd6 options=29<PERFORMNUD,IFDISABLED,AUTO_LINKLOCAL>
	hwassist=1e1e<CSUM_IP_UDP,CSUM_IP_TCP,CSUM_IP_SCTP,CSUM_IP_TSO,CSUM_IP6_UDP,CSUM_IP6_TCP,CSUM_IP6_SCTP,CSUM_IP6_TSO>
```

The `ifconfig` output shows with the options that `TXCSUM` and `TXCSUM_IPV6` is
enabled. The `dtrace` output (last line) shows with hwassist that the interface
supports checksum offloading for, among others IPv4 UDP (`CSUM_IP_UDP`), 
IPv4 TCP (`CSUM_IP_TCP`), and IPv4 SCTP (`CSUM_IP_SCTP`). Since it does not list
`CSUM_IP`, it also shows that the interface does not support checksum offloading
for the IP header checksum.
