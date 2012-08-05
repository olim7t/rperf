#!/bin/bash

BASEDIR=`dirname $0`
PID_FILE=${BASEDIR}/pids

if [ ! -f ${PID_FILE} ] ; then
  echo "PID file does not exist. Is monitoring already stopped?"
  exit 1
fi

cat ${PID_FILE} | while read PID
do
  kill ${PID}
done
mv ${PID_FILE} ${PID_FILE}.bak

cd ${BASEDIR}
tar czf logs.tgz *.log
