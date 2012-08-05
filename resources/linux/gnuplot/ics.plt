set terminal png size 1200,500
set output "ics.png"

set xdata time
set timefmt "%H:%M:%S"

set title "Involuntary context switches / s"
set nokey

set yrange [0:]
plot "switches_total.log" using 1:3 with lines
