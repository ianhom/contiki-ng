#!/bin/bash

# Contiki directory
CONTIKI=$1
# Test basename
BASENAME=01-native-ping

IPADDR=fd00::302:304:506:708

# Starting Contiki-NG native node
echo "Starting native node"
make -C $CONTIKI/examples/hello-world
sudo $CONTIKI/examples/hello-world/hello-world.native > node.log 2> node.err &
CPID=$!
sleep 2

# Do ping
echo "Pinging"
ping6 $IPADDR -c 5 | tee $BASENAME.log
# Fetch ping6 status code (not $? because this is piped)
STATUS=${PIPESTATUS[0]}

echo "Closing native node"
sleep 2
pgrep hello-world | sudo xargs kill -9

if [ $STATUS -eq 0 ] ; then
  cp $BASENAME.log $BASENAME.testlog
  printf "%-32s TEST OK\n" "$BASENAME" | tee -a $BASENAME.testlog;
else
  mv $BASENAME.log $BASENAME.faillog

  echo ""
  echo "---- node.log"
  cat node.log

  echo ""
  echo "---- node.err"
  cat node.err

  cp $BASENAME.log $BASENAME.faillog
  printf "%-32s TEST FAIL\n" "$BASENAME" | tee -a $BASENAME.testlog;
fi

rm node.log
rm node.err

# We do not want Make to stop -> Return 0
# The Makefile will check if a log contains FAIL at the end
exit 0
