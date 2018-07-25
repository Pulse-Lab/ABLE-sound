/////////////////////////////////////
//     SuperCollider OSC Intro     //
/////////////////////////////////////

// To listen for incoming OSC messages, define an OSCdef:

(

OSCdef(\myOSCdef, // the name of it/reference to it
	func:  // A function to run when a message is received at this address on this port (see 'path' and 'recvPort' below)
	{
		|msg|  // OscDefs take an array as an argument

		var address = msg[0]; // The address is always the first element of the array (so msg[0] would be "/the/osc/address" (a string)

		var value1 = msg[1]; // every index after that are the osc message values;

		// Always handy to print the osc message
		msg.postln;

	},
	path:"/the/osc/address",  // The address we're looking for as a string
	recvPort:8080  // The port we're listening on (we're not actually using 8080 - see the ABLE readme for our OSC conventions!)
)// End OSCdef

)


// To send OSC (we probably don't need to do this from SC but it's really handy for testing (and it's really quick in SC)):

// Define a new 'NetAddr' object and store it in a global variable (global variables have a '~' before them in SC)
// 'hostname' is the IP Address of where you're sending. We'll use the special 'loopback' address "127.0.0.1" which references this computer
// port is the OSC port
~oscOut = NetAddr.new(hostname:"127.0.0.1", port:8080);

// Send a message:
//   Note that 'sendMsg' takes an arbitrary number of arguments, the first of which should be the osc address
~oscOut.sendMsg("/the/osc/address", 1, 2.2, "hello");

// If you evaluated the above oscdef you should see something printed to the post window when your run the above line.
