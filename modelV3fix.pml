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

//starts communication as client
active proctype Alice(){
    bool confirmed = false;
    int Bnonce;

// Construct message for first rendezvous
    Packet packet;
    packet.message.key = bkey;
    packet.message.data1 = aid;
    packet.message.data2 = anonce;
    packet.messageType = 1;
    packet.receiverID = bid;

// Send encrypted data (message, ID, and nonce) to Bob through chan
    channel ! packet;
    
    Packet recPacket;
    
// Receive Bob's encrypted nonce and confirm Alice's encrypted nonce
    channel ? recPacket;    
    
    if
        :: recPacket.message.data1 == anonce ->
            confirmed = true;
    fi;
    
    Bnonce = recPacket.message.data2
    
// Construct message for third rendezvous
    packet.message.key = bkey;
    packet.message.data1 = Bnonce;
    packet.message.data2 = 0;
    packet.messageType = 3;
    packet.receiverID = bid;
    
// Send back Bob's nonce
    channel ! packet
    printf("Alice's nonce is %d. Alice says Bob's nonce is %d\n", anonce, Bnonce);
}

//recieves communication as server
active proctype Bob(){
    bool confirmed = false;
    
    Packet packet;
    
// Receive encrypted data (message, ID, and nonce) from Alice through chan
    channel ? packet;
    
// Construct message for second rendezvous
    packet.message.key = akey;
    packet.message.data1 = packet.message.data2;
    packet.message.data2 = bnonce;
    packet.messageType = 2;
    packet.receiverID = aid;
    
// Send both encrypted nonce
    channel ! packet;

    mtype x = bnonce;

// Receive and confirm own nonce
    channel ? eval(x)->
        confirmed = true;
    printf("Bob's nonce is %d. Bob says Alice's nonce is %d\n", bnonce, anonce);
}
