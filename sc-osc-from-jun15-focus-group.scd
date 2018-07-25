
Server.default.options.memSize= 8192*4;
Server.default.boot;
(
var unreal = NetAddr.new("127.0.0.1",port:8000);
var scOscPort = 10000;

var time = Clock.seconds;
var deltaT = 0;

var scale = Scale.major.degrees++(Scale.major.degrees+12)++(Scale.major.degrees+24)+60;

var note = scale.choose;

var motionSynthAmp = -12.dbamp;
var motionSynthTopRight = Synth.new(\motion,[pan:1,freq: (note+36+7).midicps, amp:motionSynthAmp]);
var motionSynthTopLeft = Synth.new(\motion,[pan:-1,freq: (note+36+7).midicps, amp:motionSynthAmp]);
var motionSynthBottomLeft = Synth.new(\motion,[pan:-1,freq: (note+12).midicps, amp:motionSynthAmp]);
var motionSynthBottomRight = Synth.new(\motion,[pan:1,freq: (note+12).midicps, amp:motionSynthAmp]);
var copX = 0;
var copY = 0;

var expectedDisplacementMax = 1; // 100cm
var leftDisplacementThreshold = 6; // 20cm
var leftDisplacementThresholdTrig = false;
var rightDisplacementThreshold = leftDisplacementThreshold;  // if sensors are different might need to calibrate differently
var rightDisplacementThresholdTrig = false;
var distance = {|x1,y1,x2,y2| 1-(sqrt(pow(x2-x1,2) + pow(y2-y1,2))/(sqrt(8)));};




distance.value(1,1,copX,copY).postln;

// detuning

OSCdef(\copX,
	{
		|msg|
		copX = msg[1].clip(-1,1);
		// "x: ".post;
		// copX.postln;
		// "y: ".post;
		// copY.postln;
		msg.postln;
		// distance.value(0,0,copX,copY).postln;
		if(distance.value(0,0,copX,copY).linlin(0.5,1,0,1)>=0.5,{
			deltaT = deltaT+(Clock.seconds-time);
			// time = Clock.seconds;
			deltaT.postln;
		});
		time = Clock.seconds;
		if(deltaT >= 10,{
			note = scale.choose;
/*			motionSynthTopRight.set(\gate, note.midicps+36+7);
			motionSynthTopLeft.set(\freq, note.midicps+36+7);
			motionSynthBottomLeft.set(\freq, note.midicps);
			motionSynthBottomRight.set(\freq, note.midicps);*/

			Pbind(\instrument,\pressure,\midinote,Pseq([note,note+7,note+12,note+14],1),\dur,Prand([1,2,0.5],inf)).play;
			// (instrument:\pressure,midinote:note).play;

			motionSynthTopRight.set(\gate, 0);
			motionSynthTopLeft.set(\gate, 0);
			motionSynthBottomLeft.set(\gate, 0);
			motionSynthBottomRight.set(\gate, 0);

			motionSynthTopRight = Synth.new(\motion,[pan:1,freq: (note+36+7).midicps, amp:motionSynthAmp,motion:pow(distance.value(1,1,copX,copY),3)]);
			motionSynthTopLeft = Synth.new(\motion,[pan:-1,freq: (note+36+7).midicps, amp:motionSynthAmp, motion:pow(distance.value(-1,1,copX,copY),3)]);
			motionSynthBottomLeft = Synth.new(\motion,[pan:-1,freq: (note+12).midicps, amp:motionSynthAmp,motion:pow(distance.value(-1,-1,copX,copY),3)]);
			motionSynthBottomRight = Synth.new(\motion,[pan:1,freq: (note+12).midicps, amp:motionSynthAmp,pow(distance.value(1,-1,copX,copY),3)]);

			deltaT = 0;
		});


		// squaring these values isn't great - motion isn't intuitive
		motionSynthTopRight.set(\motion, pow(distance.value(1,1,copX,copY),1));
		motionSynthTopLeft.set(\motion, pow(distance.value(-1,1,copX,copY),1));
		motionSynthBottomLeft.set(\motion, pow(distance.value(-1,-1,copX,copY),1));
		motionSynthBottomRight.set(\motion, pow(distance.value(1,-1,copX,copY),1));

		unreal.sendMsg("/cop/x", msg[1]);
},path:"/cop/x",recvPort:scOscPort);

OSCdef(\copY,
	{
		|msg|
		copY = msg[1].clip(-1,1);
		copY.postln;
		unreal.sendMsg("/cop/y", msg[1]);
},path:"/cop/y",recvPort:scOscPort);



OSCdef(\leftDisplacement,
	{
		|msg|
		var x = msg[1];
		("/left/displacement"+x).postln;
		if( leftDisplacementThresholdTrig && (x<leftDisplacementThreshold),{
			leftDisplacementThresholdTrig = false;
		});

		if( x> leftDisplacementThreshold && leftDisplacementThresholdTrig.not,{
			(instrument:\birds,\midinote: scale.choose, initialPan:copX, finalPan: x.linlin(0,expectedDisplacementMax,0,1),db:-10).play;
			leftDisplacementThresholdTrig = true;
		});

},path:"/left/displacement",recvPort:scOscPort);


OSCdef(\rightDisplacement,
	{
		|msg|
		var x = msg[1];
		("/right/displacement"+x).postln;

		if( rightDisplacementThresholdTrig && (x<rightDisplacementThreshold),{
			rightDisplacementThresholdTrig = false;
		});

		if( x> rightDisplacementThreshold && rightDisplacementThresholdTrig.not,{
			(instrument:\birds,\midinote: scale.choose, initialPan:copX, finalPan: x.linlin(0,expectedDisplacementMax,0,1),db:-10).play;
			rightDisplacementThresholdTrig = true;
		});

},path:"/right/displacement",recvPort:scOscPort);


)






















































// OLD:







//////////////////////////////////////
//         ABLE SC OSC Receivers   //
/////////////////////////////////////


(
// SC listens on port 10000 (see Readme.txt - 'OSC spec' for all conventions)

var scOSCPort = 10000;


////////////////////////////////////////////////////////////////////////////////////////////////
//     All receiving normalized/cleaned sensor values and 'X' and 'Y' values from Python      //
////////////////////////////////////////////////////////////////////////////////////////////////


// Left Foot sensor OSC receivers:
OSCdef(\fromPythonLeftAccelerometer,{
	|msg|
	var address = msg[0]; // "/left/accelerometer"
	var x = msg[1];
	var y = msg[2];
	var z = msg[3];
	msg.postln;

},path:"/left/accelerometer", recvPort:scOSCPort);


OSCdef(\fromPythonLeftGyro,{
	|msg|
	var x = msg[1];
	var y = msg[2];
	var z = msg[3];
	msg.postln;
},path:"/left/gyro", recvPort:scOSCPort);

OSCdef(\fromPythonLeftMag,{
	|msg|
	var x = msg[1];
	var y = msg[2];
	var z = msg[3];
	msg.postln;
},path:"/left/mag", recvPort:scOSCPort);


OSCdef(\fromPythonLeftHeel,{
	|msg|
	var address = msg[0]; // "/left/heel"
	var value = msg[1];
	msg.postln;
},path:"/left/heel", recvPort:scOSCPort);

OSCdef(\fromPythonLeftToe,{
	|msg|
	var value = msg[1];
	msg.postln;
},path:"/left/toe", recvPort:scOSCPort);





// Right Foot sensor OSC receivers:
// (these are identical to the above except for pertaining to the right foot.
OSCdef(\fromPythonRightAccelerometer,{
	|msg|
	var address = msg[0]; // "/right/accelerometer"
	var x = msg[1];
	var y = msg[2];
	var z = msg[3];
	msg.postln;

},path:"/right/accelerometer", recvPort:scOSCPort);


OSCdef(\fromPythonRightGyro,{
	|msg|
	var x = msg[1];
	var y = msg[2];
	var z = msg[3];
	msg.postln;
},path:"/right/gyro", recvPort:scOSCPort);

OSCdef(\fromPythonRightMag,{
	|msg|
	var x = msg[1];
	var y = msg[2];
	var z = msg[3];
	msg.postln;
},path:"/right/mag", recvPort:scOSCPort);


OSCdef(\fromPythonRightHeel,{
	|msg|
	var address = msg[0]; // "/right/heel"
	var value = msg[1];
	msg.postln;
},path:"/right/heel", recvPort:scOSCPort);

OSCdef(\fromPythonRightToe,{
	|msg|
	var value = msg[1];
	msg.postln;
},path:"/right/toe", recvPort:scOSCPort);




////////////////////////
//       X and Y     //
///////////////////////


OSCdef(\fromPythonLeftX,{
	|msg|
	var x = msg[1]; // A value between about -15 and 15;
	x = pow(x.linlin(-15,15,0,2),2)-1; // map from linear range [-15,15] to [0,2], square that range (exponential curve) and subtract 1 so [-1,1] (for panning)

	(instrument:\birds,\initialPan:0, \finalPan:x,midinote:Scale.major.degrees.choose+60, db: -25).play;
	x.postln;
},path:"/left/x",recvPort:scOSCPort);


OSCdef(\fromPythonLeftY,{
	|msg|
	var x = msg[1]; // A value between about -15 and 15;
	x = pow(x.linlin(-15,15,0,2),2)-1; // map from linear range [-15,15] to [0,2], square that range (exponential curve) and subtract 1 so [-1,1] (for panning)

	(instrument:\birds,\initialPan:0, \finalPan:x,midinote:Scale.major.degrees.choose+60, db: -25).play;
	x.postln;
},path:"/left/y",recvPort:scOSCPort);

OSCdef(\fromPythonRightX,{
	|msg|
	var x = msg[1]; // A value between about -15 and 15;
	x = pow(x.linlin(-15,15,0,2),2)-1;

	(instrument:\birds,\initialPan:0, \finalPan:x,midinote:Scale.major.degrees.choose+60, db: -25).play;
	x.postln;
},path:"/right/x",recvPort:scOSCPort);

OSCdef(\fromPythonRightY,{
	|msg|
	var x = msg[1]; // A value between about -15 and 15;
	x = pow(x.linlin(-15,15,0,2),2)-1;

	(instrument:\birds,\initialPan:0, \finalPan:x,midinote:Scale.major.degrees.choose+60, db: -25).play;
	x.postln;
},path:"/right/y",recvPort:scOSCPort);


)



// For testing:

~n = NetAddr.new("127.0.0.1", 10000);

// Trigger the /left/x receiver, which plays the '\birds' synth
~n.sendMsg("/left/x",15);




(instrument:\birds).play


// birds synth with displacement, left and right panning from (copX) to some displacement amt.

// cop - motion synth
// 4 synths running, one per quadrant. front 2 are 7 semitones up
// hard pans, adjust 'motion' argument for it...

Server.default.options.memSize= 8192*4;

(
var unreal = NetAddr.new("127.0.0.1",port:8000);
var scOscPort = 10000;

var time = Clock.seconds;
var deltaT = 0;

var scale = Scale.major.degrees++(Scale.major.degrees+12)++(Scale.major.degrees+24)+60;

var note = scale.choose;

var motionSynthAmp = -12.dbamp;
var motionSynthTopRight = Synth.new(\motion,[pan:1,freq: (note+36+7).midicps, amp:motionSynthAmp]);
var motionSynthTopLeft = Synth.new(\motion,[pan:-1,freq: (note+36+7).midicps, amp:motionSynthAmp]);
var motionSynthBottomLeft = Synth.new(\motion,[pan:-1,freq: (note+12).midicps, amp:motionSynthAmp]);
var motionSynthBottomRight = Synth.new(\motion,[pan:1,freq: (note+12).midicps, amp:motionSynthAmp]);
var copX = 0;
var copY = 0;

var expectedDisplacementMax = 100; // 100cm
var leftDisplacementThreshold = 50; // 20cm
var leftDisplacementThresholdTrig = false;
var rightDisplacementThreshold = leftDisplacementThreshold;  // if sensors are different might need to calibrate differently
var rightDisplacementThresholdTrig = false;
var distance = {|x1,y1,x2,y2| 1-(sqrt(pow(x2-x1,2) + pow(y2-y1,2))/(sqrt(8)));};




distance.value(1,1,copX,copY).postln;



OSCdef(\copX,
	{
		|msg|
		copX = msg[1].clip(-1,1);
		// "x: ".post;
		// copX.postln;
		// "y: ".post;
		// copY.postln;

		// distance.value(0,0,copX,copY).postln;
		if(distance.value(0,0,copX,copY).linlin(0.5,1,0,1)>=0.5,{
			deltaT = deltaT+(Clock.seconds-time);
			// time = Clock.seconds;
			deltaT.postln;
		});
		time = Clock.seconds;
		if(deltaT >= 10,{
			note = scale.choose;
/*			motionSynthTopRight.set(\gate, note.midicps+36+7);
			motionSynthTopLeft.set(\freq, note.midicps+36+7);
			motionSynthBottomLeft.set(\freq, note.midicps);
			motionSynthBottomRight.set(\freq, note.midicps);*/

			Pbind(\instrument,\pressure,\midinote,Pseq([note,note+7,note+12,note+14],1),\dur,Prand([1,2,0.5],inf)).play;
			// (instrument:\pressure,midinote:note).play;

			motionSynthTopRight.set(\gate, 0);
			motionSynthTopLeft.set(\gate, 0);
			motionSynthBottomLeft.set(\gate, 0);
			motionSynthBottomRight.set(\gate, 0);

			motionSynthTopRight = Synth.new(\motion,[pan:1,freq: (note+36+7).midicps, amp:motionSynthAmp,motion:pow(distance.value(1,1,copX,copY),3)]);
			motionSynthTopLeft = Synth.new(\motion,[pan:-1,freq: (note+36+7).midicps, amp:motionSynthAmp, motion:pow(distance.value(-1,1,copX,copY),3)]);
			motionSynthBottomLeft = Synth.new(\motion,[pan:-1,freq: (note+12).midicps, amp:motionSynthAmp,motion:pow(distance.value(-1,-1,copX,copY),3)]);
			motionSynthBottomRight = Synth.new(\motion,[pan:1,freq: (note+12).midicps, amp:motionSynthAmp,pow(distance.value(1,-1,copX,copY),3)]);

			deltaT = 0;
		});

		motionSynthTopRight.set(\motion, pow(distance.value(1,1,copX,copY),3));
		motionSynthTopLeft.set(\motion, pow(distance.value(-1,1,copX,copY),3));
		motionSynthBottomLeft.set(\motion, pow(distance.value(-1,-1,copX,copY),3));
		motionSynthBottomRight.set(\motion, pow(distance.value(1,-1,copX,copY),3));

		unreal.sendMsg("/cop/x", msg[1]);
},path:"/cop/x",recvPort:scOscPort);

OSCdef(\copY,
	{
		|msg|
		copY = msg[1].clip(-1,1);
		unreal.sendMsg("/cop/y", msg[1]);
},path:"/cop/y",recvPort:scOscPort);



OSCdef(\leftDisplacement,
	{
		|msg|
		var x = msg[1];

		if( leftDisplacementThresholdTrig && (x<leftDisplacementThreshold),{
			leftDisplacementThresholdTrig = false;
		});

		if( x> leftDisplacementThreshold && leftDisplacementThresholdTrig.not,{
			(instrument:\birds,\midinote: ~scale.choose, initialPan:copX, finalPan: x.linlin(0,expectedDisplacementMax,0,1)).play;
			leftDisplacementThresholdTrig = true;
		});

},path:"/left/displacement",recvPort:scOscPort);


OSCdef(\rightDisplacement,
	{
		|msg|
		var x = msg[1];
		if( rightDisplacementThresholdTrig && (x<rightDisplacementThreshold),{
			rightDisplacementThresholdTrig = false;
		});

		if( x> rightDisplacementThreshold && rightDisplacementThresholdTrig.not,{
			(instrument:\birds,\midinote: ~scale.choose, initialPan:copX, finalPan: x.linlin(0,expectedDisplacementMax,0,1)).play;
			rightDisplacementThresholdTrig = true;
		});

},path:"/right/displacement",recvPort:scOscPort);


)


// Test copX and copY with mouse X Y
(
var x =0;
var y = 0;
var sc = NetAddr.new("127.0.0.1",10000);
{SendReply.kr(Impulse.kr(10),cmdName:"/cop/xy",values:[MouseX.kr(-1,1),MouseY.kr(-1,1)])}.play;

OSCdef(\copxy,{|msg| sc.sendMsg("/cop/x",msg[3]); sc.sendMsg("/cop/y",msg[4])},path:"/cop/xy",recvPort:NetAddr.langPort);
)


(
var sc = NetAddr.new("127.0.0.1",10000);
{SendReply.kr(Impulse.kr(10),cmdName:"/displacement/xy",values:[MouseX.kr(-100,100),MouseY.kr(-100,100)])}.play;
OSCdef(\displacementxy,{|msg| sc.sendMsg("/left/displacement",msg[3].abs); sc.sendMsg("/right/displacement",msg[4].abs)},path:"/displacement/xy",recvPort:NetAddr.langPort);
)

)









