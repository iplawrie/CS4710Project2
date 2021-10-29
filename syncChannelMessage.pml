#define N 8
chan request = [0] of {byte}
chan reply = [0] of {bool}
active [N] proctype myProc(){
	byte input;
        if
                ::(_pid  %  2  ==  0)->
			printf("%d is requesting\n", _pid)
			request ! _pid;
			reply ? _;
			printf("%d got response back\n", _pid);		
                ::(_pid  %  2  !=  0)->
			request ? input ->
				printf("Initiator %d requested and receiver %d replyed\n", input, _pid);
				reply ! true;
        fi;
}
