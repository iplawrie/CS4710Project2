//starts communication as client
//nonce, id
chan channel = [0] of {mtype, mtype}
    
active proctype Alice(){
	bool confirmed = false;
	byte Bnonce;
	//create nonce
	byte nonce;
	pid Apid = _pid;

	select(nonce : 0 .. 254);

	// Send encrypted data (message, ID, and nonce) to Bob through chan
	channel ! Apid,nonce;
    
	// Receive Alice's and Bob's encrypted nonces
	channel ? Bnonce, eval(nonce) ->
		confirmed = true;
	// Send back Bob's nonce
	channel ! Bnonce
	printf("Alice's nonce is %d. Alice says Bob's nonce is %d\n", nonce, Bnonce);
}

//recieves communication as server
active proctype Bob(){
	bool confirmed = false;
	byte Anonce;
	pid Apid;
	// create nonce
	byte nonce;
	select(nonce : 0 .. 254);
    
	// Receive encrypted data (message, ID, and nonce) from Alice through chan
	channel ? Apid, Anonce;
	// Send both encrypted nonce
	channel ! nonce, Anonce;
	// Receive own nonce back
	channel ? eval(nonce)->
		confirmed = true;
	printf("Bob's nonce is %d. Bob says Alice's nonce is %d\n", nonce, Anonce);
}
