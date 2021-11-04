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

bool exited[2] = false;

chan channel = [0] of { Packet }


//          _ _          
//    /\   | (_)         
//   /  \  | |_  ___ ___ 
//  / /\ \ | | |/ __/ _ \
// / ____ \| | | (_|  __/
///_/    \_\_|_|\___\___|
active proctype Alice(){

    Packet recPacket;
    int Anonce;
    select(Anonce : 1 .. 50);
    
    int Bnonce;
    
// Construct message for first rendezvous
    Message message;
    message.key = bkey;
    message.data1 = aid;
    message.data2 = Anonce;
    int messageType = 1;
    mtype receiverID = aid;

// Send encrypted data (message, ID, and nonce) to Bob through chan
    channel ! message, messageType, receiverID;

// Receive Bob's encrypted nonce and confirm Alice's encrypted nonce
    recPacket.messageType = 2;
    recPacket.receiverID = aid
    channel ?? message, eval(recPacket.messageType), eval(recPacket.receiverID);

    //if
        //:: recPacket.message.data1 == Anonce && recPacket.messageType == 2 && recPacket.receiverID == aid ->
	    //skip;
	//:: else->
	    //printf("Invalid packet\n")
            //goto end;
    //fi;

    Bnonce = message.data2

// Construct message for third rendezvous
    message.key = bkey;
    message.data1 = Bnonce;
    message.data2 = aid;
    messageType = 3;
    receiverID = bid;

// Send back Bob's nonce
    channel ! message, messageType, receiverID
    printf("Alice's nonce is %d. Alice says Bob's nonce is %d\n", Anonce, Bnonce);

//end:
    printf("Alice Exits\n");
    exited[0] = true;
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
    select(Bnonce : 50 .. 100);
    Packet recPacket;

// Receive encrypted data (message, ID, and nonce) from Alice through chan
    Message message;
    recPacket.messageType = 1;
    recPacket.receiverID = bid;
    channel ? message, eval(recPacket.messageType), eval(recPacket.receiverID);
    //if 
	//:: packet.messageType == 1 && packet.receiverID == bid ->
		//skip;
	//:: else ->
	    //printf("Invalid messageType\n") 
	    //goto end;
    //fi;

    Anonce = message.data2;

// Construct message for second rendezvous
    message.key = akey;
    message.data1 = message.data2;
    message.data2 = Bnonce;
    int messageType = 2;
    mtype receiverID = aid;

// Send both encrypted nonce
    channel ! message, messageType, receiverID;
    
// Receive and confirm own nonce
    recPacket.messageType = 3;
    recPacket.receiverID = bid;
    channel ? message, eval(recPacket.messageType), eval(recPacket.receiverID);
    
    //if 
	//:: packet.messageType == 3 && packet.receiverID == bid && packet.message.data1 == Bnonce ->
	    //skip;
	//:: else->
	    //printf("Invalid messageType\n") 
	    //goto end;
    //fi;
        
    printf("Bob's nonce is %d. Bob says Alice's nonce is %d\n", Bnonce, Anonce);

end:
    printf("Bob Exit\n");
    exited[1] = true
}
