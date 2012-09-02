set terminal png size 1200,500

set datafile commentschars "pr"
set xdata time
set timefmt "%H:%M:%S"

set title "Scheduler run queue"
set nokey

plot "vmstat.log" using 1:2 with lines
