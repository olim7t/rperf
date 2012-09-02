set terminal png size 1200,500

set datafile commentschars "pr"
set xdata time
set timefmt "%H:%M:%S"

set ylabel "CPU %"

set key outside bottom

plot \
  "vmstat.log" using 1:14 title 'User' with lines, \
  "vmstat.log" using 1:15 title 'System' with lines, \
  "vmstat.log" using 1:16 title 'Idle' with lines
