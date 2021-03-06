#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh
#
# root=cifs://[user:pass@]<server>/<folder>
#
# This syntax can come from DHCP root-path as well.
#
# If a username or password are not specified as part of the root, then they
# will be pulled from cifsuser and cifspass on the kernel command line,
# respectively.
#

type getarg >/dev/null 2>&1 || . /lib/dracut-lib.sh
. /lib/cifs-lib.sh

#Don't continue if root is ok
[ -n "$rootok" ] && return

# This script is sourced, so root should be set. But let's be paranoid
[ -z "$root" ] && root=$(getarg root=)
[ -z "$netroot" ] && netroot=$(getarg netroot=)

# Root takes precedence over netroot
if [ "${root%%:*}" = "cifs" ] ; then

    # Don't continue if root is ok
    [ -n "$rootok" ] && return

    if [ -n "$netroot" ] ; then
        warn "root takes precedence over netroot. Ignoring netroot"

    fi
    netroot=$root
    unset root
fi

# If it's not cifs we don't continue
[ "${netroot%%:*}" = "cifs" ] || return

# Check required arguments
cifs_to_var $netroot

# If we don't have a server, we need dhcp
if [ -z "$server" ] ; then
    DHCPORSERVER="1"
fi;

# Done, all good!
rootok=1

echo '[ -e $NEWROOT/proc ]' > $hookdir/initqueue/finished/cifsroot.sh
