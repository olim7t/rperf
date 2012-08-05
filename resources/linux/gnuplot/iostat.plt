device="`echo $DEVICE`"
input="iostat_".device.".log"
set title "Disk I/O for device ".device
set terminal png size 1200,500

set xdata time
set timefmt "%H:%M:%S"

set key outside bottom

set yrange [0:]
set ylabel "MB/s"
set ytics nomirror

set y2range [0:]
set y2label "%"
set y2tics

plot \
  input using 1:7 title 'Read MB/s' axes x1y1 with lines, \
  input using 1:8 title 'Write MB/s' axes x1y2 with lines, \
  input using 1:13 title '%util' axes x1y2 with lines
