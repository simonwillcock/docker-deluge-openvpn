#!/bin/sh

# Source our persisted env variables from container startup
. /etc/deluge/environment-variables.sh

# This script will be called with tun/tap device name as parameter 1, and local IP as parameter 4
# See https://openvpn.net/index.php/open-source/documentation/manuals/65-openvpn-20x-manpage.html (--up cmd)
echo "Up script executed with $*"
if [ "$4" = "" ]; then
   echo "ERROR, unable to obtain tunnel address"
   echo "killing $PPID"
   kill -9 $PPID
   exit 1
fi

# If deluge-pre-start.sh exists, run it
if [ -x /scripts/deluge-pre-start.sh ]
then
   echo "Executing /scripts/deluge-pre-start.sh"
   /scripts/deluge-pre-start.sh
   echo "/scripts/deluge-pre-start.sh returned $?"
fi

echo "Updating DELUGE_BIND_ADDRESS_IPV4 to the ip of $1 : $4"
export DELUGE_BIND_ADDRESS_IPV4=$4

#echo "Generating transmission settings.json from env variables"
## Ensure DELUGE_HOME is created
#mkdir -p ${DELUGE_HOME}
dockerize -template /etc/deluge/settings.tmpl:${DELUGE_HOME}/settings.json

#echo "sed'ing True to true"
#sed -i 's/True/true/g' ${DELUGE_HOME}/settings.json

#if [ ! -e "/dev/random" ]; then
#  # Avoid "Fatal: no entropy gathering module detected" error
#  echo "INFO: /dev/random not found - symlink to /dev/urandom"
#  ln -s /dev/urandom /dev/random
#fi

. /etc/deluge/userSetup.sh

if [ "true" = "$DROP_DEFAULT_ROUTE" ]; then
  echo "DROPPING DEFAULT ROUTE"
  ip r del default || exit 1
fi

echo "STARTING DELUGED"
exec su --preserve-environment ${RUN_AS} -s /bin/bash -c "deluged -d -c /config -L info -l /data/deluged.log" &
#exec su --preserve-environment abc -s /bin/bash -c "deluged -d -c /data -L info -l /data/deluged.log" &
echo "STARTING DELUGE-WEB"
exec su --preserve-environment ${RUN_AS} -s /bin/bash -c "deluge-web -c /config" &
#exec su --preserve-environment abc -s /bin/bash -c "deluge-web -c /data" &

#if [ "$OPENVPN_PROVIDER" = "PIA" ]
#then
#    echo "CONFIGURING PORT FORWARDING"
#    exec /etc/deluge/updatePort.sh &
#else
#    echo "NO PORT UPDATER FOR THIS PROVIDER"
#fi

# If deluge-post-start.sh exists, run it
if [ -x /scripts/deluge-post-start.sh ]
then
   echo "Executing /scripts/deluge-post-start.sh"
   /scripts/deluge-post-start.sh
   echo "/scripts/deluge-post-start.sh returned $?"
fi

echo "Deluge startup script complete."
