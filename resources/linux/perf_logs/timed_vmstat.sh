#!/bin/bash
# -t option is not supported on Ubuntu
vmstat -S M -n 5 | awk '{now=strftime("%T "); print now $0; fflush()}'
