set terminal png size 1200,500

set datafile commentschars "pr"
set xdata time
set timefmt "%H:%M:%S"

set ylabel "CPU %"

set key outside bottom

plot \
  "vmstat.log" using 19:13 title 'User' with lines, \
  "vmstat.log" using 19:14 title 'System' with lines, \
  "vmstat.log" using 19:15 title 'Idle' with lines
