#!/bin/sh

if [ $# -ne 1 ]
then
	echo "Call $0 <interface>"
	exit 1
fi

dtrace -q -C -n '
dtrace:::BEGIN
{
	CSUM_IP			= 0x00000001;	/* IP header checksum offload */
	CSUM_IP_UDP		= 0x00000002;	/* UDP checksum offload */
	CSUM_IP_TCP		= 0x00000004;	/* TCP checksum offload */
	CSUM_IP_SCTP		= 0x00000008;	/* SCTP checksum offload */
	CSUM_IP_TSO		= 0x00000010;	/* TCP segmentation offload */
	CSUM_IP_ISCSI		= 0x00000020;	/* iSCSI checksum offload */

	CSUM_INNER_IP6_UDP	= 0x00000040;
	CSUM_INNER_IP6_TCP	= 0x00000080;
	CSUM_INNER_IP6_TSO	= 0x00000100;
	CSUM_IP6_UDP		= 0x00000200;	/* UDP checksum offload */
	CSUM_IP6_TCP		= 0x00000400;	/* TCP checksum offload */
	CSUM_IP6_SCTP		= 0x00000800;	/* SCTP checksum offload */
	CSUM_IP6_TSO		= 0x00001000;	/* TCP segmentation offload */
	CSUM_IP6_ISCSI		= 0x00002000;	/* iSCSI checksum offload */

	CSUM_INNER_IP		= 0x00004000;
	CSUM_INNER_IP_UDP	= 0x00008000;
	CSUM_INNER_IP_TCP	= 0x00010000;
	CSUM_INNER_IP_TSO	= 0x00020000;

	CSUM_ENCAP_VXLAN	= 0x00040000;	/* VXLAN outer encapsulation */
	CSUM_ENCAP_RSVD1	= 0x00080000;

	CSUM_ALL		= 0x000FFFFF;
}

fbt::ifhwioctl:entry
/initialized == 0 && execname == "ifconfig"/
{
	hwassist = args[1]->if_hwassist;
	initialized = 1;
}

dtrace:::END
{
	printf("\thwassist=%x", hwassist);
	first = 1;
	if (hwassist & CSUM_IP)
		printf("%s%s", (first ? (first=0, "<") : ","), "CSUM_IP");
	if (hwassist & CSUM_IP_UDP)
		printf("%s%s", (first ? (first=0, "<") : ","), "CSUM_IP_UDP");
	if (hwassist & CSUM_IP_TCP)
		printf("%s%s", (first ? (first=0, "<") : ","), "CSUM_IP_TCP");
	if (hwassist & CSUM_IP_SCTP)
		printf("%s%s", (first ? (first=0, "<") : ","), "CSUM_IP_SCTP");
	if (hwassist & CSUM_IP_TSO)
		printf("%s%s", (first ? (first=0, "<") : ","), "CSUM_IP_TSO");
	if (hwassist & CSUM_IP_ISCSI)
		printf("%s%s", (first ? (first=0, "<") : ","), "CSUM_IP_ISCSI");
	if (hwassist & CSUM_INNER_IP6_UDP)
		printf("%s%s", (first ? (first=0, "<") : ","), "CSUM_INNER_IP6_UDP");
	if (hwassist & CSUM_INNER_IP6_TCP)
		printf("%s%s", (first ? (first=0, "<") : ","), "CSUM_INNER_IP6_TCP");
	if (hwassist & CSUM_INNER_IP6_TSO)
		printf("%s%s", (first ? (first=0, "<") : ","), "CSUM_INNER_IP6_TSO");
	if (hwassist & CSUM_IP6_UDP)
		printf("%s%s", (first ? (first=0, "<") : ","), "CSUM_IP6_UDP");
	if (hwassist & CSUM_IP6_TCP)
		printf("%s%s", (first ? (first=0, "<") : ","), "CSUM_IP6_TCP");
	if (hwassist & CSUM_IP6_SCTP)
		printf("%s%s", (first ? (first=0, "<") : ","), "CSUM_IP6_SCTP");
	if (hwassist & CSUM_IP6_TSO)
		printf("%s%s", (first ? (first=0, "<") : ","), "CSUM_IP6_TSO");
	if (hwassist & CSUM_IP6_ISCSI)
		printf("%s%s", (first ? (first=0, "<") : ","), "CSUM_IP6_ISCSI");
	if (hwassist & CSUM_INNER_IP)
		printf("%s%s", (first ? (first=0, "<") : ","), "CSUM_INNER_IP");
	if (hwassist & CSUM_INNER_IP_UDP)
		printf("%s%s", (first ? (first=0, "<") : ","), "CSUM_INNER_IP_UDP");
	if (hwassist & CSUM_INNER_IP_TCP)
		printf("%s%s", (first ? (first=0, "<") : ","), "CSUM_INNER_IP_TCP");
	if (hwassist & CSUM_INNER_IP_TSO)
		printf("%s%s", (first ? (first=0, "<") : ","), "CSUM_INNER_IP_TSO");
	if (hwassist & CSUM_ENCAP_VXLAN)
		printf("%s%s", (first ? (first=0, "<") : ","), "CSUM_ENCAP_VXLAN");
	if (hwassist & CSUM_ENCAP_RSVD1)
		printf("%s%s", (first ? (first=0, "<") : ","), "CSUM_ENCAP_RSVD1");
	if (hwassist & ~CSUM_ALL)
		printf("%s%s", (first ? (first=0, "<") : ","), "...");
	if (!first) printf(">");
}
' -c "ifconfig $1"
