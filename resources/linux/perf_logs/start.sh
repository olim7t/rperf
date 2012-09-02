#!/bin/bash

BASEDIR=`dirname $0`
PID_FILE=${BASEDIR}/pids

if [ -f ${PID_FILE} ] ; then
  echo "PID file exists. Is monitoring already running?"
  exit 1
fi

cat /proc/cpuinfo > ${BASEDIR}/cpuinfo.log

nohup ${BASEDIR}/timed_vmstat.sh > ${BASEDIR}/vmstat.log 2>&1 <&- &
echo $! >> ${PID_FILE}

nohup pidstat -w 5 > ${BASEDIR}/pidstat.log 2>&1 <&- &
echo $! >> ${PID_FILE}

nohup iostat -xdmtz 5 > ${BASEDIR}/iostat.log 2>&1 <&- &
echo $! >> ${PID_FILE}

