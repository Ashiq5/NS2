#!/bin/bash

if [ $# != 5 ]; then
	echo "Invalid format"
	echo "Provide #num_row/col , #x_dimension , #y_dimension, #packets per sec , tx range multiplier"
	echo "Ex : 5 150 150 500 2"
	exit 0
fi



nodes=$1
dimension=$2
d=$3;
packets_per_sec=$4
tx_range_mult=$5

throughput=0.0
delay=0.0
delivery_ratio=0.0
drop_ratio=0.0
energy=0.0

r=0
it=2
itf=3.0
while [ $r -le $it ]
do
echo "Iteration $(($r + 1)) starting"
ns 802_11_udp.tcl $nodes $dimension $d $packets_per_sec $tx_range_mult
awk -f rule_wireless_udp.awk multi_radio_802_11_random.tr > output.out
i=0
while read val
do
if [ $i = 0 ]; then
	throughput=$(echo "scale=5; $throughput+$val/$itf" | bc)
elif [ $i = 1 ]; then
	delay=$(echo "scale=5; $delay+$val/$itf" | bc)
elif [ $i = 2 ]; then
	delivery_ratio=$(echo "scale=5; $delivery_ratio+$val/$itf" | bc)
elif [ $i = 3 ]; then
	drop_ratio=$(echo "scale=5; $drop_ratio+$val/$itf" | bc)
elif [ $i = 4 ]; then
	energy=$(echo "scale=5; $energy+$val/$itf" | bc)
fi

let i=$(($i+1))
done < output.out 
echo "Iteration $(($r + 1)) finished"
r=$(($r+1))
done



echo "Throughput     : $throughput"
echo "Delay          : $delay"
echo "Delivery Ratio : $delivery_ratio"
echo "Drop Ratio     : $drop_ratio"
echo "Energy         : $energy"


