#!/bin/bash
# g0 2014 < http://ipduh.com/contact >
# Create a basic AWStats Config for an Apache host
# The assumed setup is described at http://alog.ipduh.com/2014/12/install-debian-packaged-awstats.html

CONFDIR='/etc/awstats'

cat <<EHD > ${CONFDIR}/awstats.${1}.conf
Include "${CONFDIR}/awstats.conf"
SiteDomain="${1}"
HostAliases="www.${1}"
DirData="/logs/sites/${1}/awstats"
LogFile="/logs/sites/${1}/access_all"
EHD

[ "${2}" ==  "maluawstats_skip" ] && { echo "###MALUAWSTATS_SKIP" >> ${CONFDIR}/awstats.${1}.conf ; }
