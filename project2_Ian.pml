//starts communication as client
//nonce, id
chan channel = [0] of {mtype, mtype}
    
active proctype Alice(){
	//create nonce
	byte nonce;
	pid Apid = _pid;

	select(nonce : 0 .. 254);
	printf("A pid=%d, nonce=%d\n",_pid,nonce);
	// Send encrypted data (message, ID, and nonce) to Bob through chan
	channel ! Apid,nonce;
    
	// Receive Alice's and Bob's encrypted nonces
    
	// Send back Bob's nonce
}

//recieves communication as server
active proctype Bob(){
	byte Anonce;
	pid Apid;
	// create nonce
	byte nonce;
	select(nonce : 0 .. 254);
    
	// Receive encrypted data (message, ID, and nonce) from Alice through chan
	channel ? Apid,Anonce ->
	// Send both encrypted nonces
	printf("A pid=%d, nonce=%d, B pid=%d\n",Apid,Anonce,_pid);
	// Receive own nonce back
}
