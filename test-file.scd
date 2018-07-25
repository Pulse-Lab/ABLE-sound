~n = NetAddr.new("127.0.0.1",10000)
~n.sendMsg("/motion","walk");
~n.sendMsg("/copx",11,2,3,4)

Server.default.options.sampleRate = 48000

(
~able = Able(
	motion:\walk,
	sensors:nil,
	initialMelody: Melody.new([60,64,67],Scale.major.degrees+60,mutateEvery:4),
	pythonRecvPort:10000,

	unrealIP:"127.0.0.1",
	unrealPort:8000,
	automaticMotions: false
);
~able.automaticMotions = false;
~able.boot()
)

~ab

~able.motion


~able.sensors["/cop/x"].value

~able.sensors["/cop/x"].threshold.lower = -0.2
~able.sensors["/cop/x"].threshold.upper = 0.2

~able.sensors["/cop/y"].threshold.lower = -0.2
~able.sensors["/cop/y"].threshold.upper = 0.2


~able.automaticMotions

~able.setMotion('walk')

~able.runningSynths["wind"].set(\amp, -40.dbamp);
~able.runningSynths["water"].set(\amp, -60.dbamp);
~able.runningSynths["birds"].set(\amp, -0.dbamp);

~able.sensors["/right/pressure"].threshold = Threshold.new(lower:1200,upper:1600);
~able.sensors["/left/pressure"].threshold = Threshold.new(lower:1200,upper:1600);

~able.sensorThresholds[\lunge]["/right/pressure"] = Threshold.new(-inf, inf);



~able.runningSynths["/right/squat"].set(\motion,0.1)



~able.sensors["/right/pressure"].threshold = Threshold.new(lower:1400,upper:1600);


~able.runningSynths

~able.sensors["/left/heel"].value

~able.sensors["/left/pressure"].values;

(
~n = NetAddr.new("127.0.0.1",10000);
~n.sendMsg("/left/heel",0);
~n.sendMsg("/right/heel",0);
{
	var trig = Impulse.kr(10);
	SendReply.kr(trig,cmdName:"/test",values:[MouseX.kr(0,10000),MouseY.kr(0,10000)]);
}.play;
OSCdef(\cop,{
	|msg|
	var x = msg[3];
	var y = msg[4];
	("x: "+x).postln;
	("y: "+y).postln;
	~n.sendMsg("/left/toe", x);
	~n.sendMsg("/right/toe", y);
},path:"/test",recvPort:NetAddr.langPort);
)


().play
~out.isRunning

(
SynthDef(\copX,
	{

		|motion=0, freq = 220, amp = 0.1, pan = 0, gate = 0.25,attack=0.01|
		var audio,env, lfo;
		var delayT = 0.1;

		audio = Mix.ar(BPF.ar(WhiteNoise.ar,freq:([0,7,19,-12,-24,2,9,14,11,4].midiratio)*freq,rq:(Line.kr(0.05,0.001,attack))*(4.dbamp)));

		lfo = SinOsc.ar(1/5,mul:50);
		audio = RLPF.ar(audio,1000+lfo,rq:0.8);

		audio = RHPF.ar(audio,freq:5000+lfo,rq:0.5);
env = EnvGen.ar(Env.adsr(attackTime:attack,sustainLevel:0.1),gate:gate,doneAction:2);

		audio = audio*env*amp;
audio = Pan2.ar(audio,Line.kr(0,pan,dur:attack));


/*		6.do{
			audio = audio +DelayN.ar(audio,0.5,delayT,-3.dbamp);
		};*/
		// audio = audio*EnvGen.ar(Env([1,1],[at+sus+rt+delayT*6+0.1]),doneAction:2);

		Out.ar(0,audio);

}).add;

~n = Synth(\copX,[\freq:69.midicps]);
	// (instrument:\copX,midinote:43).play;
)

~n.set(\gate,0)




(
OSCdef(\walk,
	{
	|msg|
		if(msg[1]==1,{
			"walk".postln;
			~able.setMotion(\walk);
		});
},path:"/1/multitoggle1/1/1",recvPort:10000);

OSCdef(\stand,
	{
	|msg|
		if(msg[1]==1,{
			"stand".postln;
			~able.setMotion(\stand);
		});
},path:"/1/multitoggle1/2/1",recvPort:10000);

OSCdef(\squat,
	{
	|msg|
		if(msg[1]==1,{
			"squat".postln;
			~able.setMotion(\squat);
		});
},path:"/1/multitoggle1/2/2",recvPort:10000);

OSCdef(\lunge,
	{
	|msg|
		if(msg[1]==1,{
			"lunge".postln;
			~able.setMotion(\lunge);
		});
},path:"/1/multitoggle1/1/2",recvPort:10000);
)





/*					Pbindef(
				\copX,
				\instrument,\pressure,
				\midinote, Pseq([this.melody.current,this.melody.current+[7,12].choose,this.melody.current+[-5,19].choose],inf),
				\dur,0.25+[-0.125,0,0.125,0.25,0.08].choose,
				\db,Pseq((-30,(-33)..(-100)),1)
				).play(quant:0);*/

		});

		/*		if ( this.copX.threshold.outside(val) &&
		this.copX.insideThreshold(), {
		this.runningSynths["copX"] = Synth.new(\generic,[
		\freq: this.melody.next.midicps,
		\sustain: 4]);

		Pbindef(\copX,
		\instrument,\pressure,
		\midinote, Pseq(this.melody.notes,inf),
		\db,Pseq([Pseq((-50,-49..-30),1),Pseq([-30],inf)],inf),
		\dur,1/3/2
		).play(quant:0);

		/*					Pbindef(
		\copX,
		\instrument,\pressure,
		\midinote, Pseq([this.melody.current,this.melody.current+[7,12].choose,this.melody.current+[-5,19].choose],inf),
		\dur,0.25+[-0.125,0,0.125,0.25,0.08].choose,
		\db,Pseq((-30,(-33)..(-100)),1)
		).play(quant:0);*/

		});*/
