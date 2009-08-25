#!/bin/dash
# Creates the syslog udev rules to be triggered when interface becomes online.
. /lib/dracut-lib.sh

detect_syslog() {
    syslogtype=""
    if [ -e /sbin/rsyslogd ]; then
	   syslogtype="rsyslogd"
    elif [ -e /sbin/syslogd ]; then
       syslogtype="syslogd"
    elif [ /sbin/syslog-ng ]; then
       syslogtype="syslog-ng"
    else
       dwarn "Could not find any syslog binary although the syslogmodule is selected to be installed. Please check."
    fi
    echo "$syslogtype"
    [ -n "$syslogtype" ]
}	

if getarg rdnetdebug ; then
    exec >/tmp/syslog-genrules.$1.$$.out
    exec 2>>/tmp/syslog-genrules.$1.$$.out
    set -x
fi

read syslogtype < /tmp/syslog.type
if [ -z "$syslogtype" ]; then
	syslogtype=$(detect_syslog)
	echo $syslogtype > /tmp/syslog.type
fi
if [ -e "/sbin/${syslogtype}-start" ]; then
	printf 'ACTION=="online", SUBSYSTEM=="net", RUN+="/sbin/'${syslogtype}'-start $env{INTERFACE}"\n' > /etc/udev/rules.d/70-syslog.rules
else
	warn "syslog-genrules: Could not find binary to start syslog of type \"$syslogtype\". Syslog will not be started."
fi