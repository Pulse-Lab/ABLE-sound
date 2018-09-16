(
~able = Able(
	// Motion to start with
	motion:\walk,
	// No real need to change this ever... (should probably be removed as a param)
	sensors:nil,
	// 'Melody' object for generative/evolving Melody (see below for more details)
	initialMelody: Melody.new([60,64,67],Scale.major.degrees+60,mutateEvery:4),
	// what port to listen on for messages from python
	pythonRecvPort:10000,
	// where to send messages to unreal
	unrealIP:"127.0.0.1",
	unrealPort:8000,
	// If motion changes according to Python's inferred current motion or not
	automaticMotions: false
);
~able.boot()
)

// ~able.sensors is a dictionary from the message address to AbleSensor objects
// The AbleSensor class provides convenience for sensor values to be low-pass filtered
// and to make threshold-crossing cleaner
~able.sensors["/cop/x"].value
~able.sensors["/cop/x"].threshold.lower = -0.2
~able.sensors["/cop/x"].threshold.upper = 0.2
~able.sensors["/cop/y"].threshold.lower = -0.2
~able.sensors["/cop/y"].threshold.upper = 0.2

// Set the motion to 'walk'
~able.setMotion('walk')

// ~able.runningSynths - a dictionary of current synths that are running
~able.runningSynths["wind"].set(\amp, -40.dbamp);
~able.runningSynths["water"].set(\amp, -60.dbamp);
~able.runningSynths["birds"].set(\amp, -0.dbamp);


// This is a convenient thingy for testing how the sound will react to values without having to
// have the sensor hooked up.
// The (x,y) location of the mouse can be read to simulate any sensor value received by
// SC (toe, heel, cop/x, cop/y, etc...). (see 'OSCdef(\test...)' below)
(
~n = NetAddr.new("127.0.0.1",10000);
~n.sendMsg("/left/heel",0);
~n.sendMsg("/right/heel",0);
{
	var trig = Impulse.kr(10);
	SendReply.kr(trig,cmdName:"/test",values:[MouseX.kr(-1,1),MouseY.kr(-1,1)]);
}.play;

OSCdef(\test,{
	|msg|
	var x = msg[3]; // Mouse-X position (from -1 to 1)
	var y = msg[4]; // Mouse-y position (from -1 to 1)
	("x: "+x).postln;
	("y: "+y).postln;

	~n.sendMsg("/cop/x", x); // Simulate /cop/x with mouse-x position
	~n.sendMsg("/cop/y", y); // Simulate /cop/y with mouse-y position
},path:"/test",recvPort:NetAddr.langPort);
)
