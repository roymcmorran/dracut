#!/bin/sh

. /lib/dracut-lib.sh

# Let the command line override our host id.
spl_hostid=$(getarg spl_hostid=)
if [ "${spl_hostid}" != "" ] ; then
	info "ZFS: Using hostid from command line: ${spl_hostid}"
	AA=$(echo ${spl_hostid} | cut -b 1,2)
	BB=$(echo ${spl_hostid} | cut -b 3,4)
	CC=$(echo ${spl_hostid} | cut -b 5,6)
	DD=$(echo ${spl_hostid} | cut -b 7,8)
	printf "\x$DD\x$CC\x$BB\x$AA" >/etc/hostid
elif [ -f /etc/hostid ] ; then
	info "ZFS: Using hostid from /etc/hostid: `hostid`"
else
	warn "ZFS: No hostid found on kernel command line or /etc/hostid.  "
	warn "ZFS: Pools may not import correctly."
fi

case "${root}" in
	""|zfs|zfs:)
		# We'll take root unset, root=zfs, or root=zfs:
		# No root set, so we want to read the bootfs attribute.  We
		# can't do that until udev settles so we'll set dummy values
		# and hope for the best later on.
		root="zfs:AUTO"
		rootok=1
		wait_for_zfs=1

		info "ZFS: Enabling autodetection of bootfs after udev settles."
		;;

	ZFS\=*|zfs:*|zfs:FILESYSTEM\=*|FILESYSTEM\=*)
		# root is explicit ZFS root.  Parse it now.  We can handle
		# a root=... param in any of the following formats:
		# root=ZFS=rpool/ROOT
		# root=zfs:rpool/ROOT
		# root=zfs:FILESYSTEM=rpool/ROOT
		# root=FILESYSTEM=rpool/ROOT

		# Strip down to just the pool/fs
		root="${root#zfs:}"
		root="${root#FILESYSTEM=}"
		root="zfs:${root#ZFS=}"
		rootok=1
		wait_for_zfs=1

		info "ZFS: Set ${root} as bootfs."
		;;
esac

# Make sure Dracut is happy that we have a root and will wait for ZFS
# modules to settle before mounting.
if [ "${wait_for_zfs}" = "1" ]; then
	ln -s /dev/null /dev/root 2>/dev/null
	echo '[ -e /dev/zfs ]' > ${hookdir}/initqueue/finished/zfs.sh
fi
