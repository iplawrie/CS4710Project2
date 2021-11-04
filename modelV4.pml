mtype = { akey, bkey, aid, bid, anonce, bnonce }

typedef Message {
    mtype key;
    mtype data1; //ID or nonce
    mtype data2; //ID or nonce
};

typedef Packet {
    Message message;
    int messageType;
    mtype receiverID;
};

chan channel = [0] of { Packet }


//          _ _          
//    /\   | (_)         
//   /  \  | |_  ___ ___ 
//  / /\ \ | | |/ __/ _ \
// / ____ \| | | (_|  __/
///_/    \_\_|_|\___\___|
active proctype Alice(){

		Packet recPacket;
    bool confirmed = false;
    int Anonce;
    select(Anonce : 1 .. 254);
    
    int Bnonce;
    
// Construct message for first rendezvous
    Packet packet;
    packet.message.key = bkey;
    packet.message.data1 = aid;
    packet.message.data2 = Anonce;
    packet.messageType = 1;
    packet.receiverID = bid;

// Send encrypted data (message, ID, and nonce) to Bob through chan
    channel ! packet;

// Receive Bob's encrypted nonce and confirm Alice's encrypted nonce
    channel ? recPacket;
		mtype x;
    if
        :: recPacket.message.data1 == Anonce && recPacket.messageType == 2 && recPacket.receiverID == aid ->
	    skip;
	:: else->
	    printf("Invalid packet\n")
            goto end;
    fi;
    confirmed = true;

    Bnonce = recPacket.message.data2

// Construct message for third rendezvous
    packet.message.key = bkey;
    packet.message.data1 = Bnonce;
    packet.message.data2 = aid;
    packet.messageType = 3;
    packet.receiverID = bid;
    // Send back Bob's nonce
    channel ! packet
    printf("Alice's nonce is %d. Alice says Bob's nonce is %d\n", anonce, Bnonce);
end:printf("Alice Exits\n");
}


// ____        _     
//|  _ \      | |    
//| |_) | ___ | |__  
//|  _ < / _ \| '_ \ 
//| |_) | (_) | |_) |
//|____/ \___/|_.__/ 
active proctype Bob(){
    bool confirmed = false;
    int Anonce;
    int Bnonce;
    select(Bnonce : 1 .. 254);
    Packet packet;

// Receive encrypted data (message, ID, and nonce) from Alice through chan
    channel ? packet;
    if 
	:: packet.messageType == 1 && packet.receiverID == bid ->
		skip;
	:: else ->
	    printf("Invalid messageType\n") 
	    goto end;
    fi;

		Anonce = packet.message.data2;
// Construct message for second rendezvous
    packet.message.key = akey;
    packet.message.data1 = packet.message.data2;
    packet.message.data2 = Bnonce;
    packet.messageType = 2;
    packet.receiverID = aid;

// Send both encrypted nonce
    channel ! packet;
    
// Receive and confirm own nonce
    channel ? packet;
    
    if 
	:: packet.messageType == 3 && packet.receiverID == bid && packet.message.data1 == Bnonce ->
	    skip;
	:: else->
	    printf("Invalid messageType\n") 
	    goto end;
    fi;
        
    printf("Bob's nonce is %d. Bob says Alice's nonce is %d\n", bnonce, anonce);
end:printf("Bob Exit\n");
}
