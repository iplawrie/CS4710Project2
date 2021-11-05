mtype = { akey, bkey, aid, bid, anonce, bnonce }

typedef Message {
    mtype key;
    mtype data1; //ID or nonce
    mtype data2; //ID or nonce
};

bool exited[2] = false;

chan channel = [0] of { mtype, mtype, mtype }

ltl liveness {<>(exited[0]==true && exited[1]==true)}

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
    message.data1 = message.data2;
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
    printf("Bob Exit\n");
    exited[1] = true;
}
