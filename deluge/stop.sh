#! /bin/sh

# If deluge-pre-stop.sh exists, run it
if [ -x /scripts/deluge-pre-stop.sh ]
then
   echo "Executing /scripts/deluge-pre-stop.sh"
   /scripts/deluge-pre-stop.sh
   echo "/scripts/deluge-pre-stop.sh returned $?"
fi

kill $(pidof deluged)
kill $(pidof deluge-web)

# If deluge-post-stop.sh exists, run it
if [ -x /scripts/deluge-post-stop.sh ]
then
   echo "Executing /scripts/deluge-post-stop.sh"
   /scripts/deluge-post-stop.sh
   echo "/scripts/deluge-post-stop.sh returned $?"
fi
