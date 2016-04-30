set terminal postscript eps enhanced color font 'Helvetica,14'

unset key
set autoscale
set ylabel "Time (milliseconds)"
show ylabel
set xlabel "Graph size (number of message definitions)" 
show xlabel

# Type 1
set output 'plots/type1_plot.eps'
plot "plots/type1_plot.txt" using 1:($2/1000000.) with lines

# Type 2
set output 'plots/type2_plot.eps'
plot "plots/type2_plot.txt" using 1:($2/1000000.) with lines

# Type 3
set output 'plots/type3_plot.eps'
plot "plots/type3_plot.txt" using 1:($2/1000000.) with lines

# Type 4
set output 'plots/type4_plot.eps'
plot "plots/type4_plot.txt" using 1:($2/1000000.) with lines

# Type 5
set output 'plots/type5_plot.eps'
plot "plots/type5_plot.txt" using 1:($2/1000000.) with lines

# Type 6
set output 'plots/type6_plot.eps'
plot "plots/type6_plot.txt" using 1:($2/1000000.) with lines