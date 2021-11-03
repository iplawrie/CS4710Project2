# CS4710Project2

Questions:
1. "Another abstraction concern is regarding agent IDs, nonces and keys. In real-world systems, 
these are all multi-bit numbers. However, to keep the state space small and to simplify our model,
we model them as ‘mtype’. We model encrypted messages as a user-defined data type that includes three
fields, all of type ‘mtype’. These fields respectively represent a key, and two other pieces of
data, each one of them being anything such as nonce or ID."
  What does this mean? What types are we supposed to be using and what are we passing?
  
symbolic can be mtype = { ack, nak, err, next, accept } and use eval to see if the symbolic value matches 

Message {key=symbolic mtype, nonce/ID, nonce/ID} -> mtype
Packet {Message, messageNumber=which message(1-3) is being sent, ID of the recieving process=symbolic mtype} -> can be mtype or specified
packet is being sent in the channel
