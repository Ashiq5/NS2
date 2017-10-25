BEGIN {
	max_node = 2000;
	nSentPackets = 0.0 ;		
	nReceivedPackets = 0.0 ;
	rTotalDelay = 0.0 ;
	max_pckt = 10000;
	
	header=20;
	idHighestPacket = 0;
	idLowestPacket = 100000;
	rStartTime = 10000.0;
	rEndTime = 0.0;
	nReceivedBytes = 0;

	nDropPackets = 0.0;


}

{
#	event = $1;    time = $2;    node = $3;    type = $4;    reason = $5;    node2 = $5;    
#	packetid = $6;    mac_sub_type=$7;    size=$8;    source = $11;    dest = $10;    energy=$14;

	strEvent = $1 ;			rTime = $2 ;
	fromNode = $3 ;
	toNode = $4 ;			idPacket = $12 ;
	strType = $5 ;			nBytes = $6;

	



	if ( strType == "cbr") {
		if (idPacket > idHighestPacket) idHighestPacket = idPacket;
		if (idPacket < idLowestPacket) idLowestPacket = idPacket;

#		if(rTime>rEndTime) rEndTime=rTime;
#			printf("********************\n");
		#if(rTime<rStartTime) {
		#	rStartTime=rTime;
		#}

		if ( strEvent == "+" ) {
			#nSentPackets += 1 ;	rSentTime[ idPacket ] = rTime ;
#			printf("%15.5f\n", nSentPackets);
		}
		if ( strEvent == "-" ) {
			nSentPackets += 1 ;	rSentTime[ idPacket ] = rTime ;
#			printf("%15.5f\n", nSentPackets);
		}
		if ( strEvent == "r" ) {
#		if ( strEvent == "r" && idPacket >= idLowestPacket) {
			nReceivedPackets += 1 ;		nReceivedBytes += (nBytes-header);
#			printf("%15.0f\n", $6); #nBytes);
			rReceivedTime[ idPacket ] = rTime ;
			rDelay[idPacket] = rReceivedTime[ idPacket] - rSentTime[ idPacket ];
			rTotalDelay += rDelay[idPacket]; 

#			printf("%15.5f   %15.5f\n", rDelay[idPacket], rReceivedTime[ idPacket] - rSentTime[ idPacket ]);
		}
		if( strEvent == "d")
		{
			#if(rTime>rEndTime) rEndTime=rTime;
#			if(rTime<rStartTime) rStartTime=rTime;
			nDropPackets += 1;
		}
	}

	

	
	if(rTime<rStartTime) rStartTime=rTime;
	if(rTime>rEndTime) rEndTime=rTime;

}

END {
	rTime = rEndTime - rStartTime ;
	rThroughput = nReceivedBytes*8 / rTime;
	rPacketDeliveryRatio = nReceivedPackets / nSentPackets * 100 ;
	rPacketDropRatio = nDropPackets / nSentPackets * 100;


	if ( nReceivedPackets != 0 ) {
		rAverageDelay = rTotalDelay / nReceivedPackets ;
	}


#	printf( "AverageDelay: %15.5f PacketDeliveryRatio: %10.2f\n", rAverageDelay, rPacketDeliveryRatio ) ;


	#printf( "Throughput%15.2f\nAverage Delay%15.5f\nSent Packets%15.2f\nReceived Packets%15.2f\nDrop Packets%15.2f\nPacket Delivery Ratio%10.2f\nPacket Drop Ratio%10.2f\nTime%10.5f\n", rThroughput, rAverageDelay, nSentPackets, nReceivedPackets, nDropPackets, rPacketDeliveryRatio, rPacketDropRatio,rTime) ;
	printf( "Throughput%15.2f\nAverage Delay%15.5f\nPacket Delivery Ratio%10.2f\nPacket Drop Ratio%10.2f\n", rThroughput, rAverageDelay, rPacketDeliveryRatio, rPacketDropRatio) ;

#	printf("%15.2f, %15.2f", rStartTime, rEndTime);
}
