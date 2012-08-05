set terminal png size 1200,500

limit="`echo $LIMIT`"

set xdata time
set timefmt "%H:%M:%S"

set title "Voluntary context switches/s (5% cpu=".limit.")"
set nokey

set yrange [0:]
plot "switches_total.log" using 1:2 with lines
