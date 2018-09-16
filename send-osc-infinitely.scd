// Here's a loop that sends osc messages resembling the format of our osc messages, place the cursor in the 'region' below
// (the code between the brackets and hit enter to start running it)

// Note: if you have the wrong ip address or port SC will throw an error after sending about 5 message bursts


(  // begin 'region'

// Define the IP address and osc port here
~oscOut = NetAddr.new("172.17.1.10",9000);

Tdef(\a,
	{
		inf.do{
			// wait 1 second (1 second delay between messages)
			0.1.wait;
			"sending osc".postln;
			//                            acc    mag     gyro  h  t
			~oscOut.sendMsg("/left/all",  0,0,0, 0,0,0, 0,0,0, 0, 0);
			~oscOut.sendMsg("/right/all", 0,0,0, 0,0,0, 0,0,0, 0, 0);
		}

}).play

) // end region
