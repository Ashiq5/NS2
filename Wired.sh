#INPUT: output file AND number of iterations
output_file_format="wired";
under="_";
all="all";
iteration_float=2.0;

start=2
end=2

rm "$output_file_format$under$all.out"

iteration=$(printf %.0f $iteration_float);

r=$start

while [ $r -le $end ]
do
echo "total iteration: $iteration"
###############################START A ROUND
l=0;thr=0.0;del=0.0;s_packet=0.0;r_packet=0.0;d_packet=0.0;del_ratio=0.0;
dr_ratio=0.0;time=0.0;
i=0
while [ $i -lt $iteration ]
do
#################START AN ITERATION
echo "                             EXECUTING $(($i+1)) th ITERATION"
read node
read flow
ns example4.tcl $node $flow $(($i+1))
echo "SIMULATION COMPLETE. BUILDING STAT......"
awk -f rule_wired_udp.awk trace-aodv-wired.tr > "$output_file_format$under$i.out"
while read val
do
	l=$(($l+1))

	echo "val $val tru $thr"

	output_file="$output_file_format$under$all.out"
	
	if [ "$l" == "1" ]; then
		thr=$(echo "scale=5; $thr+$val/$iteration_float" | bc)
		echo -ne "throughput: $val " >> $output_file
	elif [ "$l" == "2" ]; then
		del=$(echo "scale=5; $del+$val/$iteration_float" | bc)
		echo -ne "delay: $val " >> $output_file
	elif [ "$l" == "3" ]; then
		s_packet=$(echo "scale=5; $s_packet+$val/$iteration_float" | bc)
		echo -ne "send packet: $val " >> $output_file
	elif [ "$l" == "4" ]; then
		r_packet=$(echo "scale=5; $r_packet+$val/$iteration_float" | bc)
		echo -ne "received packet: $val " >> $output_file
	elif [ "$l" == "5" ]; then
		d_packet=$(echo "scale=5; $d_packet+$val/$iteration_float" | bc)
		echo -ne "drop packet: $val " >> $output_file
	elif [ "$l" == "6" ]; then
		del_ratio=$(echo "scale=5; $del_ratio+$val/$iteration_float" | bc)
		echo -ne "delivery ratio: $val " >> $output_file
	elif [ "$l" == "7" ]; then
		dr_ratio=$(echo "scale=5; $dr_ratio+$val/$iteration_float" | bc)
		echo -ne "drop ratio: $val " >> $output_file
	elif [ "$l" == "8" ]; then
		time=$(echo "scale=5; $time+$val/$iteration_float" | bc)
		echo -ne "time: $val " >> $output_file
	fi

	echo "$val"
done < "$output_file_format$under$i.out"

i=$(($i+1))
l=0
#################END AN ITERATION
done

output_file="$output_file_format$under$r.out"

echo -ne "Throughput:          $thr " > $output_file
echo -ne "AverageDelay:         $del " >> $output_file
echo -ne "Sent Packets:         $s_packet " >> $output_file
echo -ne "Received Packets:         $r_packet " >> $output_file
echo -ne "Dropped Packets:         $d_packet " >> $output_file
echo -ne "PacketDeliveryRatio:      $del_ratio " >> $output_file
echo -ne "PacketDropRatio:      $dr_ratio " >> $output_file
echo -ne "Total time:  $time " >> $output_file

r=$(($r+1))
#######################################END A ROUND
done
