#!/bin/bash

# 1. Create data file
DATAFILE="resilience_data.dat"
> "$DATAFILE"

# 2. Parameters
T=15          # Time of failure
R=3           # Resilience factor
C=2           # Base level after crash
EFFORT_RATE=0.8

# 3. Generate data points
for t in $(seq 0 1 30); do
    if (( $(echo "$t < $T" | bc -l) )); then
        effort=$(echo "$EFFORT_RATE * $t" | bc -l)
        performance=$(echo "0.5 * $t" | bc -l)
    elif (( $(echo "$t == $T" | bc -l) )); then
        effort=0
        performance=2
    else
        effort=0
        performance=$(echo "$C + $R * l($t - $T + 1)" | bc -l)
    fi
    echo "$t $effort $performance" >> "$DATAFILE"
done

# 4. Gnuplot script to save as PNG (not GUI!)
GNUPLOT_SCRIPT="resilience_plot.gnuplot"
cat <<EOF > $GNUPLOT_SCRIPT
set terminal pngcairo size 1000,600 enhanced font 'Arial,10'
set output 'resilience_curve.png'
set title "Resilience Curve: Effort vs Performance"
set xlabel "Time"
set ylabel "Value"
set grid
set key outside
plot \\
    "$DATAFILE" using 1:2 with lines title "Effort" lw 2 lt rgb "blue", \\
    "$DATAFILE" using 1:3 with lines title "Performance" lw 2 lt rgb "red", \\
    $T title "Failure Point (T=$T)" with lines lt 2 lc rgb "black"
EOF

# 5. Run gnuplot
gnuplot "$GNUPLOT_SCRIPT"

# 6. Tell the user
echo "✅ Graph saved as 'resilience_curve.png'"
