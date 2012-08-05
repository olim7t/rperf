set terminal png size 1200,500

set datafile commentschars "pr"
set xdata time
set timefmt "%H:%M:%S"

set key outside bottom

set yrange [0:]
set ylabel "Memory (MB)"

set y2tics
set y2range [0:]
set y2label "Swap (MB/s)"

plot \
  "vmstat.log" using 19:4 title 'Free' axes x1y1 with lines, \
  "vmstat.log" using 19:7 title 'Swap in' axes x1y2 with lines, \
  "vmstat.log" using 19:8 title 'Swap out' axes x1y2 with lines
