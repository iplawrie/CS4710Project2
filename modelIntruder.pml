mtype = { akey, bkey, aid, bid, anonce, bnonce }

typedef Message {
    mtype key;
    mtype data1; //ID or nonce
    mtype data2; //ID or nonce
};

bool exited[2] = false;

chan channel = [0] of { Message, mtype, mtype }

ltl livenessAlice { <>(exited[0]==true) }
ltl livenessBob { <>(exited[1] == true) }
ltl liveness { <>(exited[0]==true && exited[1]==true) }

//          _ _          
//    /\   | (_)         
//   /  \  | |_  ___ ___ 
//  / /\ \ | | |/ __/ _ \
// / ____ \| | | (_|  __/
///_/    \_\_|_|\___\___|
active proctype Alice(){

    int Anonce;
    select(Anonce : 1 .. 50);
    
    int Bnonce;
    
// Construct message for first rendezvous
    Message message;
    message.key = bkey;
    message.data1 = aid;
    message.data2 = Anonce;
    int messageType = 1;
    mtype receiverID = bid;

// Send encrypted data (message, ID, and nonce) to Bob through chan
    channel ! message, messageType, receiverID;

// Receive Bob's encrypted nonce and confirm Alice's encrypted nonce
    messageType = 2;
    receiverID = aid;
    channel ?? message, eval(messageType), eval(receiverID);
    Bnonce = message.data2;

// Construct message for third rendezvous
    message.key = bkey;
    message.data1 = Bnonce;
    message.data2 = aid;
    messageType = 3;
    receiverID = bid;

// Send back Bob's nonce
    channel ! message, messageType, receiverID;

    printf("Alice's nonce is %d. Alice says Bob's nonce is %d\n", Anonce, Bnonce);
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

// Receive encrypted data (message, ID, and nonce) from Alice through chan
    Message message;
    int messageType = 1;
    mtype receiverID = bid;
    channel ?? message, eval(messageType), eval(receiverID);
    Anonce = message.data2;

// Construct message for second rendezvous
    message.key = akey;
    message.data1 = Anonce;
    message.data2 = Bnonce;
    messageType = 2;
    receiverID = aid;

// Send both encrypted nonce
    channel ! message, messageType, receiverID;
    
// Receive and confirm own nonce
    messageType = 3;
    receiverID = bid;
    channel ?? message, eval(messageType), eval(receiverID);
        
    printf("Bob's nonce is %d. Bob says Alice's nonce is %d\n", Bnonce, Anonce);
    printf("Bob Exits\n");
    exited[1] = true;
}

//  _____ _                _ _      
// / ____| |              | (_)     
//| |    | |__   __ _ _ __| |_  ___ 
//| |    | '_ \ / _` | '__| | |/ _ \
//| |____| | | | (_| | |  | | |  __/
// \_____|_| |_|\__,_|_|  |_|_|\___|
active proctype charlie(){
    int Cnonce;
    select(Cnonce : 100 .. 150);
    Message message;
    Message newMessage;
    int messageType;
    mtype receiverID;

//snoop for packet
    channel ?? message, messageType, receiverID;
    select(messageType: 1 .. 3);
    select(receiverID: bid .. aid);
//make a new message with values available to charlie
    if
    :: newMessage.data1 = aid;
    :: newMessage.data1 = bid;
    :: newMessage.data1 = Cnonce;
    :: newMessage.data1 = message.data2
    fi;
    
    if
    :: newMessage.data2 = aid;
    :: newMessage.data2 = bid;
    :: newMessage.data2 = Cnonce;
    :: newMessage.data2 = message.data1
    fi;
    
    if
    :: receiverID == bid ->
        newMessage.key = bkey;
    :: receiverID == aid ->
        newMessage.key = akey;
    fi;
    
    if
    :: channel ! message, messageType, receiverID; //Forward received message
    :: channel ! newMessage, messageType, receiverID; //Forward new message
    fi;
    
    printf("Charlie Exits\n");
}
