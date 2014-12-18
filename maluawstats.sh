#!/bin/bash
# g0 2013 < http://ipduh.com/contact >

# maluawstats: Merge Apache Logs and Update AWStats 
# for all hosts with awstats.name.tld.conf in /etc/awstasts

# The assumed setup is described at http://alog.ipduh.com/2014/12/install-debian-packaged-awstats.html

VERBOSE=true
CONFDIR='/etc/awstats'
AWSTATS='/usr/lib/cgi-bin/awstats.pl'
MALUASLOCK='/tmp/maluawstats.lock'
ERROR_PREF="maluawstats error:"
WARN_PREF="maluawstats warning:"
DEFAULT_NICENESS=10

export PATH=$PATH:/usr/sbin:/usr/bin:/sbin:/bin

logger -s "maluawstats: starting ..."

[ -d $CONFDIR ] || { logger -s "$ERROR_PREF missing awstats config Dir $CONFDIR";  exit 3; }
[ -f $AWSTATS ] || { logger -s "$ERROR_PREF missing $AWSTATS"; exit 3; }
[ -f $MALUASLOCK ] && { logger -s "$ERROR_PREF lock $MALUASLOCK exists"; exit 3; }

touch $MALUASLOCK
ERROR=`mktemp --tmpdir maluawstats.XXXXXX`
trap 'rm -f $ERROR' EXIT
echo $ERROR > $MALUASLOCK

. /etc/default/awstats #debian defaults
if (( "$AWSTATS_NICE" < -20 )) || (( "$AWSTATS_NICE" > 19 )) || [ -z $AWSTATS_NICE ]
then
  AWSTATS_NICE=$DEFAULT_NICENESS
fi

YMDTODAY=`date -u +%Y%m%d`
YMDYESTERDAY=`expr $YMDTODAY - 1`

cd $CONFDIR

[ $VERBOSE ] && { logger -s "maluawstats: hi"; }

for i in `ls awstats.*.conf`; 
do 
  egrep '^###MALUAWSTATS_SKIP' $i &>/dev/null 
  if [ ! $? -eq 0 ]
  then
    
    [ $VERBOSE ] && { logger -s "maluawstats: processing $i"; }

    DOMAIN=`grep 'SiteDomain' $i |awk -F '="' '{print $2}' |awk -F '"' '{print $1}'` 
    FILEDOMAIN=`echo $i |sed 's/^awstats\.\(.*\)\.conf/\1/'`
    [ "$DOMAIN" == "$FILEDOMAIN" ] || { logger -s "$WARN_PREF $i should be awstats.$DOMAIN.conf "; }
    
    DATADIR=`grep 'DirData' $i |awk -F '="' '{print $2}' |awk -F '"' '{print $1}'`
    [ -d "$DATADIR" ] || { logger -s "$WARN_PREF creating $DATADIR for $DOMAIN"; mkdir -p $DATADIR; }  

    LOGFILE=`grep 'LogFile' $i |awk -F '="' '{print $2}' |awk -F '"' '{print $1}'`

    grep ${YMDYESTERDAY} "${DATADIR}/maluawstats.log" &>/dev/null
    if [ $? -eq 0 ]
    then
      logger -s "WARN_PREF $DOMAIN is OKed, skipping"
    else
      ls /logs/sites/${DOMAIN}/access/${YMDYESTERDAY}.* &>/dev/null
      if [ $? -eq 0 ]
      then
        cat /logs/sites/${DOMAIN}/access/${YMDYESTERDAY}.* >> ${LOGFILE}     
     
        nice -n $AWSTATS_NICE ${AWSTATS} --configdir=${CONFDIR} --config=${DOMAIN} -update 2>$ERROR 2>&1
        if [ ! $? -eq 0 ]
        then
          logger -s "$ERROR_PREF $DOMAIN,$DATADIR,$LOGFILE"  
        else
          echo "$YMDYESTERDAY OK" >> "${DATADIR}/maluawstats.log"
        fi 
       
      else
        logger -s "$WARN_PREF No $DOMAIN logs for $YMDYESTERDAY"
      fi
    fi 

  fi
done

logger -s "maluawstats: bye."
rm -f $MALUASLOCK
exit 0
