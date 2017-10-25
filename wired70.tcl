set cbr_size [lindex $argv 3]; 
set cbr_rate 11.0Mb
set cbr_pckt_per_sec [lindex $argv 2] ;
set cbr_interval [expr 1.0/$cbr_pckt_per_sec] ;
#set cbr_interval 0.00005 ;
set num_row 0; #[lindex $argv 0] ;
set num_col 0; #[lindex $argv 0] ;
set num_nodes [lindex $argv 0] ;
set num_edges [lindex $argv 1] ;
set x_dim 150 ; #[lindex $argv 1]
set y_dim 150 ; #[lindex $argv 1]
set time_duration 25 ; #[lindex $argv 5] ;#50
set start_time 50 ;#100
set parallel_start_gap 0.0
set cross_start_gap 0.0



#CHNG
set num_parallel_flow 0 ;#[lindex $argv 0]	# along column
set num_cross_flow 0 ;#[expr $num_row*$num_col] ;#[lindex $argv 0]		#along row
set num_random_flow [expr $num_nodes] ;
set num_sink_flow 0 ;#[expr $num_row*$num_col] ;#sink
set sink_node $num_nodes ;
set grid 0
set extra_time 10 ;#10


set tcp_src Agent/UDP
set tcp_sink Agent/Null



set nm /home/ashiq/Desktop/1305070_ns2/wired70.nam
set tr /home/ashiq/Desktop/1305070_ns2/wired70.tr
set topo_file /home/ashiq/Desktop/1305070_ns2/wired70.txt

# 
# Initialize ns
#
set ns_ [new Simulator]

set tracefd [open $tr w]
$ns_ trace-all $tracefd



#Open the nam trace file
set namtrace [open $nm w]
$ns_ namtrace-all $namtrace


set topofile [open $topo_file "w"]
$ns_ rtproto DV




#remove-all-packet-headers
#add-packet-header DSDV AODV ARP LL MAC CBR IP
 

puts "start node creation"
for {set i 0} {$i < [expr $num_nodes]} {incr i} {
	set node_($i) [$ns_ node]
}

#set i 0
#while {$i < $num_nodes } {

	#Set random position for nodes
#	set x_pos [expr int($x_dim*rand())] ;#random settings
#	set y_pos [expr int($y_dim*rand())] ;#random settings

#	$node_($i) set X_ $x_pos
#	$node_($i) set Y_ $y_pos
#	$node_($i) set Z_ 0.0

	#puts -nonewline $topo "$i x: [$node_($i) set X_] y: [$node_($i) set Y_] \n"
#	incr i;
#};

if {$num_sink_flow > 0} { ;#sink
	set sink_node [expr $num_nodes] ;#sink id
	set node_($sink_node) [$ns_ node]
	if {$sink_node < $num_nodes} {
		puts "*********ERROR: SINK NODE id($sink_node) is too LOW********"		
	}
	set sink_start_gap [expr 1.0/$num_sink_flow]
}

puts "node creation complete"
#CHNG
if {$num_parallel_flow > $num_row} {
	set num_parallel_flow $num_row
}

#CHNG
if {$num_cross_flow > $num_col} {
	set num_cross_flow $num_col
}

#CHNG
#for {set i 0} {$i < [expr $num_parallel_flow + $num_cross_flow + $num_random_flow  + $num_sink_flow]} {incr i} { ;#sink
for {set i 0} {$i < [expr $num_edges]} {incr i} { 
#    set udp_($i) [new Agent/UDP]
#    set null_($i) [new Agent/Null]

	set udp_($i) [new $tcp_src]
	$udp_($i) set class_ $i
	set null_($i) [new $tcp_sink]
	$udp_($i) set fid_ $i
	if { [expr $i%2] == 0} {
		$ns_ color $i Blue
	} else {
		$ns_ color $i Red
	}

} 

################################################PARALLEL FLOW

#CHNG
for {set i 0} {$i < [expr $num_parallel_flow]} {incr i} {
	#$ns_ duplex-link $node_($i) $node_($sink_node) 1Mb 10ms DropTail
}
for {set i 0} {$i < $num_parallel_flow } {incr i} {
	$ns_ duplex-link $node_($i) $node_([expr $i+(($num_col)*($num_row-1))]) 1Mb 10ms DropTail
	set udp_node $i
	set null_node [expr $i+(($num_col)*($num_row-1))];#CHNG
	$ns_ attach-agent $node_($udp_node) $udp_($i)
  	$ns_ attach-agent $node_($null_node) $null_($i)
	puts -nonewline $topofile "PARALLEL: Src: $udp_node Dest: $null_node\n"
} 


#CHNG
for {set i 0} {$i < $num_parallel_flow } {incr i} {
     $ns_ connect $udp_($i) $null_($i)
}
#CHNG
for {set i 0} {$i < $num_parallel_flow } {incr i} {
	set cbr_($i) [new Application/Traffic/CBR]
	$cbr_($i) set packetSize_ $cbr_size
	$cbr_($i) set rate_ $cbr_rate
	$cbr_($i) set interval_ $cbr_interval
	$cbr_($i) attach-agent $udp_($i)
} 

#CHNG
for {set i 0} {$i < $num_parallel_flow } {incr i} {
     $ns_ at 0 "$cbr_($i) start"
     $ns_ at [expr 100*rand()] "$cbr_($i) stop"
}


####################################CROSS FLOW
#CHNG
set k $num_parallel_flow 
#for {set i 1} {$i < [expr $num_col-1] } {incr i} {
#CHNG
for {set i 0} {$i < [expr $num_cross_flow]} {incr i} {
	#$ns_ duplex-link $node_($i) $node_($sink_node) 1Mb 10ms DropTail
}
for {set i 0} {$i < $num_cross_flow } {incr i} {
	$ns_ duplex-link $node_([expr $i*$num_col]) $node_([expr ($i+1)*$num_col-1]) 1Mb 10ms DropTail
	set udp_node [expr $i*$num_col];#CHNG
	set null_node [expr ($i+1)*$num_col-1];#CHNG
	$ns_ attach-agent $node_($udp_node) $udp_($k)
  	$ns_ attach-agent $node_($null_node) $null_($k)
	puts -nonewline $topofile "CROSS: Src: $udp_node Dest: $null_node\n"
	incr k
} 

#CHNG
set k $num_parallel_flow
#CHNG
for {set i 0} {$i < $num_cross_flow } {incr i} {
	$ns_ connect $udp_($k) $null_($k)
	incr k
}
#CHNG
set k $num_parallel_flow
#CHNG
for {set i 0} {$i < $num_cross_flow } {incr i} {
	set cbr_($k) [new Application/Traffic/CBR]
	$cbr_($k) set packetSize_ $cbr_size
	$cbr_($k) set rate_ $cbr_rate
	$cbr_($k) set interval_ $cbr_interval
	$cbr_($k) attach-agent $udp_($k)
	incr k
} 

#CHNG
set k $num_parallel_flow
#CHNG
for {set i 0} {$i < $num_cross_flow } {incr i} {
	$ns_ at 0 "$cbr_($i) start"
     	$ns_ at [expr 100*rand()] "$cbr_($i) stop"
	incr k
}
#######################################################################RANDOM FLOW
set r $k
set rt $r
set num_node $num_nodes

for {set i 1} {$i < [expr $num_edges+1]} {incr i} {
	set p [expr int($num_node*rand())] ;
	set q $p;
	while {$p==$q} {
		set q [expr int($num_node*rand())] ;
	}
	$ns_ duplex-link $node_($p) $node_($q) 1Mb 10ms DropTail
	set udp_node $p ;
	set null_node $q ;
	$ns_ attach-agent $node_($udp_node) $udp_($rt)
  	$ns_ attach-agent $node_($null_node) $null_($rt)
	puts -nonewline $topofile "RANDOM:  Src: $udp_node Dest: $null_node\n"
	incr rt
} 

set rt $r
for {set i 1} {$i < [expr $num_edges+1]} {incr i} {
	$ns_ connect $udp_($rt) $null_($rt)
	incr rt
}
set rt $r
for {set i 1} {$i < [expr $num_edges+1]} {incr i} {
	set cbr_($rt) [new Application/Traffic/CBR]
	$cbr_($rt) set packetSize_ $cbr_size
	$cbr_($rt) set rate_ $cbr_rate
	$cbr_($rt) set interval_ $cbr_interval
	$cbr_($rt) attach-agent $udp_($rt)
	incr rt
} 

set rt $r
for {set i 1} {$i < [expr $num_edges+1]} {incr i} {
	$ns_ at 0 "$cbr_($rt) start"
	$ns_ at [expr 100*rand()] "$cbr_($rt) stop"
	incr rt
}

#######################################################################SINK FLOW
set r $rt
set rt $r
set num_node [expr $num_row*$num_col]
for {set i 0} {$i < [expr $num_sink_flow]} {incr i} {
	#puts "$i"
	$ns_ duplex-link $node_($i) $node_($sink_node) 1Mb 10ms DropTail
	#$ns_ queue-limit $node_($i) $node_($sink_node) 1000B
} 


for {set i 1} {$i < [expr $num_sink_flow+1]} {incr i} {
	set udp_node [expr $i-1] ;#[expr int($num_node*rand())] ;# src node
	set null_node $sink_node
	#while {$null_node==$udp_node} {
	#	set null_node [expr int($num_node*rand())] ;# dest node
	#}
	$ns_ attach-agent $node_($udp_node) $udp_($rt)
  	$ns_ attach-agent $node_($null_node) $null_($rt)
	puts -nonewline $topofile "SINK:  Src: $udp_node Dest: $null_node\n"
	incr rt
} 

set rt $r
for {set i 1} {$i < [expr $num_sink_flow+1]} {incr i} {
	$ns_ connect $udp_($rt) $null_($rt)
	incr rt
}
set rt $r
for {set i 1} {$i < [expr $num_sink_flow+1]} {incr i} {
	set cbr_($rt) [new Application/Traffic/CBR]
	$cbr_($rt) set packetSize_ $cbr_size
	$cbr_($rt) set rate_ $cbr_rate
	$cbr_($rt) set interval_ $cbr_interval
	$cbr_($rt) attach-agent $udp_($rt)
	incr rt
} 

set rt $r
for {set i 1} {$i < [expr $num_sink_flow+1]} {incr i} {
	#$ns_ at [expr $start_time+$i*$sink_start_gap+rand()] "$cbr_($rt) start"
	$ns_ at 0 "$cbr_($rt) start"
	$ns_ at [expr 100*rand()] "$cbr_($rt) stop"
	incr rt
}



puts "flow creation complete"
##########################################################################END OF FLOW GENERATION

# Tell nodes when the simulation ends
#
for {set i 0} {$i < [expr $num_row*$num_col] } {incr i} {
    $ns_ at [expr $start_time+$time_duration] "$node_($i) reset";
}
$ns_ at 100 "finish"
#$ns_ at [expr $start_time+$time_duration +$extra_time] "finish"


proc finish {} {
	puts "finishing"
	global ns_ tracefd nf topofile nm namtrace
	#global ns_ topofile
	$ns_ flush-trace
	close $tracefd
	close $namtrace
	close $topofile
        exec nam $nm &
        exit 0
}


for {set i 0} {$i < [expr $num_row*$num_col]  } { incr i} {
	#$ns_ initial_node_pos $node_($i) 4
}

puts "Starting Simulation..."
$ns_ run 
#$ns_ nam-end-wireless [$ns_ now]

