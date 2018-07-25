// Here's a loop that sends osc messages resembling the format of our osc messages, place the cursor in the 'region' below
// (the code between the brackets and hit enter to start running it)

// Note: if you have the wrong ip address or port SC will throw an error after sending about 5 message bursts (not sure why!)


(  // begin 'region'

// Define the IP address and osc port here
~oscOut = NetAddr.new("172.17.1.10",9000);

Tdef(\a,
	{
		inf.do{
			// wait 1 second (1 second delay between messages)
			0.1.wait;

			"sending osc".postln;
			~oscOut.sendMsg("/left/accelerometer/x",3);
			~oscOut.sendMsg("/left/accelerometer/y",3);
			~oscOut.sendMsg("/left/accelerometer/z",3);
			~oscOut.sendMsg("/left/gyro/x",4);
			~oscOut.sendMsg("/left/gyro/y",4);
			~oscOut.sendMsg("/left/gyro/z",4);
			~oscOut.sendMsg("/left/mag/x",7);
			~oscOut.sendMsg("/left/mag/y",7);
			~oscOut.sendMsg("/left/mag/z",7);
			~oscOut.sendMsg("/left/heel",1);
			~oscOut.sendMsg("/left/toe",2);


			~oscOut.sendMsg("/right/accelerometer/x",3);
			~oscOut.sendMsg("/right/accelerometer/y",3);
			~oscOut.sendMsg("/right/accelerometer/z",3);
			~oscOut.sendMsg("/right/gyro/x",4);
			~oscOut.sendMsg("/right/gyro/y",4);
			~oscOut.sendMsg("/right/gyro/z",4);
			~oscOut.sendMsg("/right/mag/x",7);
			~oscOut.sendMsg("/right/mag/y",7);
			~oscOut.sendMsg("/right/mag/z",7);
			~oscOut.sendMsg("/right/heel",1);
			~oscOut.sendMsg("/right/toe",2);
		}

}).play

) // end region





// Chicken scratch notes.....:


//  Dictionary
// "/left/accelerometer/x"   ->   1
// "/left/accelerometer/y"   ->   1
// "/left/accelerometer/z"   ->   1
// "/left/mag/x"   ->   1
// "/left/mag/y"   ->   1

if (dictionary.keys == ["/left/accelerometer/x","/left/accelerometer/y","/left/accelerometer/z","/left/gyro/x" ... ]):
    analyze(dictionary)
    dictionary = Dictionar.new


~a = NetAddr.new("127.0.0.1",9000);

~a.sendMsg("/left/accelerometer/x",1,2,3);

~a.sendMsg("/left/accelerometer/y",1);

~a.sendMsg("/left/accelerometer/z",1);

~a.sendMsg("/left/heel",1);




(
OSCdef(\a,{
	|msg|
	msg.postln;
},path:"/cop/y",recvPort:10000)


)





































