// /cop/x, copY,
// left: displacement, heading
// Generative


// Music interactions:
/*
- /cop/x - percussive synth with note from generative scale pings when /cop/x threshold hit on either side
- synth holds at lowish level until threshold is passed again when release is triggered

- displacement:
- threshold triggers a sound which plays as long as displacement is above some threshold
- maybe as it gets closer back down to threshold, something about the synth f?

- heading:
- this seems more like a value that will be used to indicate motions, rather than something that will be mapped raw?
- global frequency - open footed plays higher freq, opens up a filter etc..?


Generataive ideas:
- pick some melody (sequence of a few notes from scale) for one motion. Or maybe a few consonant melodies that can be iterated through (a phrase or a few phrases?)
- /cop/x, displacement, etc... are responsible for deviating enough (but not too much) from that melody to make it interesting/not too repetitive
- deviation based on how long they've been doing that motion for - or how many notes triggered perhaps:
- motion change picks a new melody
- if

- Different but consonant/coordinated melodies for each sensor? Polyphonic melodies?
- Or is it better to have just one - perhaps more intuitive/less overwhelming

*/


Able {
	var <>motion; // lunge, squat, walk, balance, undefined, etc... -> SC symbols
	var <>motionTimer; // number of seconds that have elapsed since current motion has started

	var <>sensors; // a Dictionary of AbleSensors where key corresponds to osc addr conventions

	var <>runningSynths;
	var <>patterns;
	var <>melody; // a Melody - also contains the scale
	var <> pythonRecvPort;

	var <>unrealNetAddr;

	var <> motions;
	var <> automaticMotions;
	var <> oscFuncs;

	classvar <> motions;
	classvar <> sensorThresholds;

	*initClass{
		Able.motions = [\lunge,\squat,\walk,\stand];

		Able.sensorThresholds = Dictionary.new;

		Able.sensorThresholds[\lunge] = Dictionary.new;
		Able.sensorThresholds[\lunge]["/cop/x"] = Threshold.new(-0.5, 0.5);
		Able.sensorThresholds[\lunge]["/cop/y"] = Threshold.new(-0.5, 0.5);
		Able.sensorThresholds[\lunge]["/left/toe"] = Threshold.new(-inf,6000);
		Able.sensorThresholds[\lunge]["/right/toe"] = Threshold.new(-inf,6000);
		Able.sensorThresholds[\lunge]["/left/heel"] = Threshold.new(-inf,6000);
		Able.sensorThresholds[\lunge]["/right/heel"] = Threshold.new(-inf,6000);
		Able.sensorThresholds[\lunge]["/left/pressure"] = Threshold.new(-inf,500);
		Able.sensorThresholds[\lunge]["/right/pressure"] = Threshold.new(-inf,500);

		Able.sensorThresholds[\walk] = Dictionary.new;
		Able.sensorThresholds[\walk]["/cop/x"] = Threshold.new(-0.5, 0.5);
		Able.sensorThresholds[\walk]["/cop/y"] = Threshold.new(-0.5, 0.5);
		Able.sensorThresholds[\walk]["/left/toe"] = Threshold.new(-inf,6000);
		Able.sensorThresholds[\walk]["/right/toe"] = Threshold.new(-inf,6000);
		Able.sensorThresholds[\walk]["/left/heel"] = Threshold.new(-inf,6000);
		Able.sensorThresholds[\walk]["/right/heel"] = Threshold.new(-inf,6000);
		Able.sensorThresholds[\walk]["/left/pressure"] = Threshold.new(-inf,600);
		Able.sensorThresholds[\walk]["/right/pressure"] = Threshold.new(-inf,600);

		Able.sensorThresholds[\stand] = Dictionary.new;
		Able.sensorThresholds[\stand]["/cop/x"] = Threshold.new(-0.8, 0.8);
		Able.sensorThresholds[\stand]["/cop/y"] = Threshold.new(-0.8, 0.8);
		Able.sensorThresholds[\stand]["/left/toe"] = Threshold.new(-inf,6000);
		Able.sensorThresholds[\stand]["/right/toe"] = Threshold.new(-inf,6000);
		Able.sensorThresholds[\stand]["/left/heel"] = Threshold.new(-inf,6000);
		Able.sensorThresholds[\stand]["/right/heel"] = Threshold.new(-inf,6000);
		Able.sensorThresholds[\stand]["/left/pressure"] = Threshold.new(-inf,6000);
		Able.sensorThresholds[\stand]["/right/pressure"] = Threshold.new(-inf,6000);

		Able.sensorThresholds[\squat] = Dictionary.new;
		Able.sensorThresholds[\squat]["/cop/x"] = Threshold.new(-0.5, 0.5);
		Able.sensorThresholds[\squat]["/cop/y"] = Threshold.new(-0.5, 0.5);
		Able.sensorThresholds[\squat]["/left/toe"] = Threshold.new(-inf,6000);
		Able.sensorThresholds[\squat]["/right/toe"] = Threshold.new(-inf,6000);
		Able.sensorThresholds[\squat]["/left/heel"] = Threshold.new(-inf,6000);
		Able.sensorThresholds[\squat]["/right/heel"] = Threshold.new(-inf,6000);
		Able.sensorThresholds[\squat]["/left/pressure"] = Threshold.new(1200,1600); // -inf to half their weight plus a bit (extra pressure when you push from a squat)
		Able.sensorThresholds[\squat]["/right/pressure"] = Threshold.new(1200,1600);

	}

	*new{
		|motion=\undefined, sensors, initialMelody, pythonRecvPort=10000, unrealIP="127.0.0.1", unrealPort=8000, automaticMotions=true|

		if (sensors.isNil, {
			sensors = Dictionary.new;
			sensors["/cop/x"] = AbleSensor.new(lowerThreshold:-0.5,upperThreshold:0.5);
			sensors["/cop/y"] = AbleSensor.new(lowerThreshold:-0.5,upperThreshold:0.5);
			sensors["/left/toe"] = AbleSensor.new([],'left',-inf,6000);
			sensors["/right/toe"] = AbleSensor.new([],'left',-inf,6000);
			sensors["/left/heel"] = AbleSensor.new([],'left',-inf,6000);
			sensors["/right/heel"] = AbleSensor.new([],'left',-inf,6000);
			sensors["/left/pressure"] = AbleSensor.new([],'left',-inf,6000);
			sensors["/right/pressure"] = AbleSensor.new([],'left',-inf,6000);
		});

		if(initialMelody.isNil,{
			initialMelody = Melody.generateMelody(Scale.major.degrees+60);
		});

		^super.new.init(motion, sensors, initialMelody,pythonRecvPort,unrealIP, unrealPort, automaticMotions);
	}

	init{
		|motion, sensors, initialMelody, pythonRecvPort,unrealIP, unrealPort, automaticMotions|
		this.motion = motion;
		this.motions = [this.motion];
		this.sensors = sensors;
		this.melody = initialMelody;
		this.pythonRecvPort = pythonRecvPort;
		this.unrealNetAddr = NetAddr.new(unrealIP, unrealPort);
		this.automaticMotions = automaticMotions;

		this.runningSynths = Dictionary.new();
		this.patterns = Dictionary.new();
		this.motionTimer = Clock.seconds;
		this.oscFuncs = [];
	}


	boot{
		Server.default.options.memSize = 8192*16;

		Server.default.waitForBoot({
			AbleSynths.boot();
			this.initOsc();

			// sets all motion-specific oscfuncs and stuff
			this.setMotion(this.motion);
			"Able booted".postln;
		});
	}

	initOsc{
		var f = {
			OSCFunc(this.handleMotionChange,"/label",recvPort:this.pythonRecvPort);


			OSCFunc({
				|msg|
				if(msg[1]==1,{
					"walk".postln;
					this.setMotion(\walk);
				});
			},path:"/1/multitoggle1/1/1",recvPort:10000);

			OSCFunc(
				{
					|msg|
					if(msg[1]==1,{
						"stand".postln;
						this.setMotion(\stand);
					});
			},path:"/1/multitoggle1/2/1",recvPort:10000);

			OSCFunc({
				|msg|
				if(msg[1]==1,{
					"squat".postln;
					this.setMotion(\squat);
				});
			},path:"/1/multitoggle1/2/2",recvPort:10000);

			OSCFunc({
				|msg|
				if(msg[1]==1,{
					"lunge".postln;
					this.setMotion(\lunge);
				});
			},path:"/1/multitoggle1/1/2",recvPort:10000);




			"Base osc loaded".postln;
		};
		f.value();
		CmdPeriod.add(f);
		CmdPeriod.add({this.enableOscFuncs});
	}

	enableOscFuncs {
		this.oscFuncs.do{
			|i|
			i.enable;
		};
		"Motion-specific osc loaded".postln;
	}

	setScale{
		|scale|
		this.melody.setScale(scale);
	}

	setOscHandlers{
		this.oscFuncs.do{
			|i|
			i.disable;
		};
		this.oscFuncs = [];
		switch(this.motion,
			\lunge, {this.lungeOscFuncs},
			\walk, {this.walkOscFuncs},
			\squat, {this.squatOscFuncs},
			\stand, {this.standOscFuncs}
		);
	}

	setThresholds{
		this.sensors = this.sensors.collect({
			|sensor, sensorName|
			var thresh = Able.sensorThresholds[this.motion][sensorName];
			if( thresh.notNil,{
				sensor.threshold = thresh;
			},{
				("No default sensor threshold for "++sensorName.asString).warn;
			});
			sensor;
		});
	}

	setEnvironmentalSounds{
		switch(this.motion,
			\lunge,{
				this.runningSynths["water"] = Synth(\water, [\amp,-55.dbamp]);
				this.runningSynths["birds"] = Synth(\birds,[\density, 0.2,\amp,-45.dbamp]);
				this.runningSynths["wind"] = Synth(\wind, [\amp,-60.dbamp]);

			},
			\walk,{
				this.runningSynths["birds"] = Synth(\birds,[\density, 0.4,\amp,-50.dbamp]);
				this.runningSynths["wind"] = Synth(\wind, [\amp,-55.dbamp]);
			},
			\stand,{
				this.runningSynths["birds"] = Synth(\birds,[\density, 0.8,\amp,-40.dbamp]);
				this.runningSynths["wind"] = Synth(\wind, [\amp,-70.dbamp]);
			},
			\squat,{
				this.runningSynths["birds"] = Synth(\birds,[\density, 0.1,\amp,-45.dbamp]);
				this.runningSynths["wind"] = Synth(\wind, [\amp,-66.dbamp]);
			}
		);
	}

	setMotion{
		|motion|
		if( Able.motions.includes(motion),{
			this.motion = motion;
			// TODO - figure out why this generates an error when run on able.boot
			this.unrealNetAddr.sendMsg("/"++(this.motion.asString));
			this.runningSynths.do{|i| i.set(\gate,0);};
			this.runningSynths = Dictionary.new;
			this.patterns.do{|i| i.stop};
			this.setOscHandlers();
			this.setThresholds();
			this.setEnvironmentalSounds();
		},{
			"unsupported motion type".warn;
		});
	}

	handleMotionChange{
		var f = {
			|msg|
			var newMotion = msg[1].asString.toLower.asSymbol;
			var motionProbabilities = Dictionary.new;
			var mostLikelyMotion;
			("NN predicted motion: "++newMotion).postln;
			if( this.automaticMotions,{
				if(Able.motions.includes(newMotion),{

					this.motions = this.motions.insert(0, newMotion).keep(5);

					motionProbabilities['lunge'] = this.motions.count({|v| v==\lunge});
					motionProbabilities['walk'] = this.motions.count({|v| v==\walk});
					motionProbabilities['squat'] = this.motions.count({|v| v==\squat});
					motionProbabilities['stand'] = this.motions.count({|v| v==\stand});

					mostLikelyMotion = motionProbabilities.findKeyForValue(motionProbabilities.maxItem);

					if(mostLikelyMotion != this.motion,{
						this.setMotion(mostLikelyMotion.asSymbol);
					});
				},{
					"Invalid motion type received".warn;
				});
			});
		};
		^f;
	}

	oscFunc {
		|f,path,recvPort|
		var a = OSCFunc({|msg| "osc received".postln;f.value(msg)},path,recvPort:recvPort);
		this.oscFuncs = this.oscFuncs.add(a);
	}


	lungeOscFuncs{

		// /cop/x
		this.oscFunc({
			|msg|
			var val = msg[1].asFloat;
			this.sensors["/cop/x"].push(val);
		},"/cop/x",recvPort:pythonRecvPort);

		// /left/toe
		this.oscFunc({
			|msg|
			var val = msg[1].asFloat;
			var pressure;
			this.sensors["/left/toe"].push(val);
			pressure = this.sensors["/left/toe"].value + this.sensors["/left/heel"].value;
			this.sensors["/left/pressure"].push(pressure);
			if(this.sensors["/left/pressure"].crossedThresholdOut,{
				(instrument:\kick_m, midinote:this.melody.next,dur:2,pan:0.3).play;
			});
		},"/left/toe",recvPort:this.pythonRecvPort);

		// /left/heel
		this.oscFunc({
			|msg|
			var val = msg[1].asFloat;
			this.sensors["/left/heel"].push(val);
		},"/left/heel", recvPort:this.pythonRecvPort);

		// /right/toe
		this.oscFunc({
			|msg|
			var val = msg[1].asFloat;
			var pressure;
			this.sensors["/right/toe"].push(val);
			pressure = this.sensors["/right/toe"].value + this.sensors["/right/heel"].value;
			this.sensors["/right/pressure"].push(pressure);
			if(this.sensors["/right/pressure"].crossedThresholdOut,{
				(instrument:\kick_m, midinote:this.melody.current+[7,-5].choose,dur:2,pan:-0.3).play;
			});
		},"/right/toe",recvPort:this.pythonRecvPort);

		// /right/heel
		this.oscFunc({
			|msg|
			var val = msg[1].asFloat;
			this.sensors["/right/heel"].push(val);
		},"/right/heel",recvPort: this.pythonRecvPort);
	}

	squatOscFuncs{

		if(this.runningSynths["/right/squat"].isNil,{this.runningSynths["/right/squat"] = Synth.new(\squat,[\motion,0,\pan,0.25])});

		if(this.runningSynths["/left/squat"].isNil,{this.runningSynths["/left/squat"] = Synth.new(\squat,[\motion,0,\pan,-0.25])});


		// /left/toe
		this.oscFunc({
			|msg|
			var val = msg[1].asFloat;
			var pressure;
			this.sensors["/left/toe"].push(val);
			pressure = this.sensors["/left/toe"].value + this.sensors["/left/heel"].value;
			this.sensors["/left/pressure"].push(pressure);
			if(this.runningSynths["/left/squat"].notNil,{
				var v = this.sensors["/left/pressure"].value.linlin(this.sensors["/left/pressure"].threshold.lower,this.sensors["/left/pressure"].threshold.upper,0,1);
				this.runningSynths["/left/squat"].set(\motion,v);
			});
		},"/left/toe",recvPort:this.pythonRecvPort);

		// /left/heel
		this.oscFunc({
			|msg|
			var val = msg[1].asFloat;
			this.sensors["/left/heel"].push(val);
		},"/left/heel",recvPort: this.pythonRecvPort);





		// /right/toe
		this.oscFunc({
			|msg|
			var val = msg[1].asFloat;
			var pressure;
			this.sensors["/right/toe"].push(val);
			pressure = this.sensors["/right/toe"].value + this.sensors["/right/heel"].value;
			this.sensors["/right/pressure"].push(pressure);
			if(this.runningSynths["/right/squat"].notNil,{
				var v = this.sensors["/right/pressure"].value.linlin(this.sensors["/right/pressure"].threshold.lower,this.sensors["/right/pressure"].threshold.upper,0,1);
				this.runningSynths["/right/squat"].set(\motion,v);
			});
		},"/right/toe",recvPort:this.pythonRecvPort);

		// /right/heel
		this.oscFunc({
			|msg|
			var val = msg[1].asFloat;
			this.sensors["/right/heel"].push(val);
		},"/right/heel",recvPort: this.pythonRecvPort);

	}

	walkOscFuncs{
		// /cop/x
		this.oscFunc({
			|msg|
			var val = msg[1].asFloat;
			this.sensors["/cop/x"].push(val);
		},"/cop/x",recvPort:pythonRecvPort);


		// /left/toe
		this.oscFunc({
			|msg|
			var val = msg[1].asFloat;
			var pressure;
			this.sensors["/left/toe"].push(val);
			pressure = this.sensors["/left/toe"].value + this.sensors["/left/heel"].value;
			this.sensors["/left/pressure"].push(pressure);
			if(this.sensors["/left/pressure"].crossedThresholdOut,{
				(instrument:\leafCrunch,db:-40).play;
			});
		},"/left/toe",recvPort:this.pythonRecvPort);

		// /left/heel
		this.oscFunc({
			|msg|
			var val = msg[1].asFloat;
			this.sensors["/left/heel"].push(val);
		},"/left/heel", recvPort:this.pythonRecvPort);

		// /right/toe
		this.oscFunc({
			|msg|
			var val = msg[1].asFloat;
			var pressure;
			this.sensors["/right/toe"].push(val);
			pressure = this.sensors["/right/toe"].value + this.sensors["/right/heel"].value;
			this.sensors["/right/pressure"].push(pressure);
			if(this.sensors["/right/pressure"].crossedThresholdOut,{
				(instrument:\leafCrunch,db:-40).play;
			});
		},"/right/toe",recvPort:this.pythonRecvPort);

		// /right/heel
		this.oscFunc({
			|msg|
			var val = msg[1].asFloat;
			this.sensors["/right/heel"].push(val);
		},"/right/heel",recvPort: this.pythonRecvPort);


	}

	standOscFuncs{

		// '/cop/x'
		this.oscFunc({
			|msg|

			var val = msg[1].asFloat;
			this.sensors["/cop/x"].push(val);

			if (this.sensors["/cop/x"].crossedThresholdOut(),{
				var delta = this.sensors["/cop/x"].delta(15);
				this.patterns["/cop/x"]=Pbindef('/cop/x',
					\instrument,\pressure,
					\midinote, Pseq(this.melody.notes%12+60,inf),
					\db,Pseq([Pseq((-20,-21..-100),1),Pseq([-100],inf)],inf),
					\dur,1/3/2
				).play;
				Pbindef('/cop/x-2').stop;
				this.runningSynths["/cop/x"] = Synth.new(\generic,[
					\freq: this.melody.current.midicps,
					\sustain: 4,
					\iPan: 0,
					\fPan: delta/2,
					\attack: delta.abs.linexp(0,2,2,0.001)
				]);
			},{
				if (this.sensors["/cop/x"].crossedThresholdIn(),{
					this.patterns["/cop/x"]=Pbindef('/cop/x',
						\instrument,\pressure,
						\midinote, Pfunc({this.melody.next%12+60}),
						\db,Pseq([-20],inf),
						\dur,1/3/2
					).play;
					this.patterns["/cop/x-2"]=Pbindef('/cop/x-2',
						\instrument,\generic,
						\midinote, Pfunc({Utility.min(this.melody.notes)%12+60}),
						\db,-48,
						\dur,4,
						\legato,1.3
					).play;
					if(this.runningSynths["/cop/x"].notNil,{this.runningSynths["/cop/x"].set(\gate,0)});
				});
			});
		},path:"/cop/x",recvPort:this.pythonRecvPort);
	}
}


Melody {
	var <> notes; // list of notes in sequence
	var <> index; // current index in the list of notes
	var <> playCount; // number of times current melody has played. resets when notes change
	var <> mutateCount;
	var <> mutateEvery;
	var <> history; // list of lists of notes (old notes)
	var <> scale;

	*new{
		|notes, scale, mutateEvery|
		if(mutateEvery.isNil,{mutateEvery = inf});
		^super.new.init(notes, scale, mutateEvery);
	}

	init{
		|notes, scale, mutateEvery|
		this.mutateEvery = mutateEvery;
		this.notes = notes;
		this.scale = scale;
		this.index = 0;
		this.playCount = 0;
		this.history =[];
		this.mutateCount = 0;
	}

	setNotes{
		|notes|
		this.history = this.history.push(this.notes);
		this.notes = notes;
		this.playCount = 0;
	}

	next{
		var note = this.notes[this.index];
		this.index = (this.index+1);
		if(this.index>=this.notes.size,{
			this.index = 0;
			this.playCount = this.playCount+1;
			if(this.playCount%this.mutateEvery==0,{
				"mutate".postln;
				this.mutate();
			});
		});
		^note;
	}

	current{
		^this.notes[this.index];
	}

	mutate {
		var newNotes;
		var chances;
		var root, third, fifth, seventh;
		var newNote;

		this.history = this.history.add(this.notes);
		this.index = 0;
		this.playCount = 0;
		this.mutateCount = this.mutateCount + 1;
		newNotes = this.notes.copy;
		newNotes.removeAt(newNotes.size.rand);
		root = Utility.min(newNotes);
		third = this.scale[(this.scale.indexOfEqual(root)+2)%this.scale.size];
		fifth = this.scale[(this.scale.indexOfEqual(root)+4)%this.scale.size];
		seventh = this.scale[(this.scale.indexOfEqual(root)+6)%this.scale.size];

		if (newNotes.includes(third) && newNotes.includes(fifth),{
			"musical match".postln;
			newNote = seventh;
		});

		if (newNotes.includes(fifth)&& newNotes.includes(third).not,{
			"musical match".postln;
			newNote = third;
		});


		if (newNotes.includes(third)&& newNotes.includes(fifth).not,{
			"musical match".postln;
			newNote = fifth;
		});

		if(newNote.isNil, {
			// Reduce probability of picking a note already in the melody

			chances = (1-(this.scale.collect({
				|i|
				var times = this.notes.count({|j|i==j});
				times

			})/this.notes.size)).normalizeSum;
			newNote = this.scale.wchoose(chances);
		});

		newNotes.insert((newNotes.size+1).rand, newNote);
		this.notes = newNotes;
	}

	*generateMelody {
		|scale, mutateEvery|
		var mel = [];
		wchoose([4,3,8],[4,2,1].normalizeSum).do{
			mel = mel.addFirst(scale.choose);
		};

		// if melody is only 4 notes, 50/50 chance that an altered version of 1st 4 will be 2nd
		// melody
		if(mel.size==4 && 2.rand == 1,{
			var altered = mel;
			var max = Utility.max(mel);
			var newNote = if(scale[scale.indexOf(max)].notNil,{
				scale[(scale.indexOf(max)+[1,-1].choose)%scale.size];
			},{scale.choose});
			altered[mel.indexOf(max)] = newNote;
			mel = mel++altered;
		});
		^Melody.new(mel, scale, mutateEvery);
	}
}


AbleSensor{

	var <>values; // array of values of length 'historySize'
	var <>foot; // left, right, or none (for things like /cop/x)
	var <>threshold; //threshold obj.
	var <>historySize;

	*new{
		|values, foot, lowerThreshold, upperThreshold, historySize=20|
		if(foot.isNil,{foot = "none"});
		if(values.isNil,{values = []});

		^super.new.init(values,foot,lowerThreshold,upperThreshold,historySize);
	}

	init {
		|values, foot, lowerThreshold, upperThreshold, historySize|
		this.values = values;
		this.foot = foot;
		this.historySize = historySize;
		this.threshold = Threshold.new(lowerThreshold,upperThreshold);
	}

	push {
		|val|
		this.values = this.values.addFirst(val);
		this.values = this.values.keep(this.historySize);
	}

	delta{
		|frames = 1|
		^ if( this.values[0].isNil || this.values[frames].isNil,{0},{
			var movingAvg = this.values.copy;
			movingAvg.removeAt(0);
			movingAvg = movingAvg.keep(frames);
			this.values[0] - (movingAvg.mean);

		});
	}

	value{
		^ this.values[0];
	}

	outsideThreshold{
		^ this.threshold.outside(this.value);
	}

	insideThreshold{
		^ this.threshold.inside(this.value);
	}

	crossedThresholdOut{
		var inToOut,outToOut,nullFirst;
		var bool;
		if( this.values[0].isNil || this.values[1].isNil,{
			bool = false;
		},{
			inToOut = this.threshold.outside(this.values[0]) && this.threshold.inside(this.values[1]);
			outToOut = ((this.values[0]>this.threshold.upper) && (this.values[1] < this.threshold.lower)) || ((this.values[0] < this.threshold.lower) && (this.values[1]>this.threshold.upper));
			bool = inToOut || outToOut;

		});
		^bool;
	}


	crossedThresholdIn {
		var bool;
		if( this.values[0].isNil || this.values[1].isNil,{bool = false},{
			bool = this.insideThreshold && (this.threshold.outside(this.values[1]));
		});
		^bool;
	}

}

Threshold{
	var <>lower;
	var <>upper;

	*new{
		|lower,upper|
		^super.new.init(lower,upper);
	}

	init{
		|lower,upper|
		if(lower.isNil,{lower = -1*inf});
		if(upper.isNil,{upper = inf});
		if(upper<lower,{
			"upper must be <= lower".warn;
			lower = upper;
		});
		this.lower = lower;
		this.upper = upper;
	}

	outside{
		|val|
		^ (val<(this.lower)) || (val>(this.upper));
	}

	inside{
		|val|
		^ this.outside(val).not
	}
}

Utility {
	//uhg -- opps, 'maxItem' is a thing
	*max {
		|col|
		var m = (-1)*inf;
		col.do{
			|i|
			m = max(i,m);
		};
		^m;
	}

	*min{
		|col|
		var m = inf;
		col.do{
			|i|
			m = min(m,i);
		}
		^m;
	}
}



AbleSynths{

	classvar <>buffers;

	*boot{
		AbleSynths.loadBuffers;
		{AbleSynths.loadSynths}.defer(2);
	}

	*loadBuffers{
		AbleSynths.buffers = Dictionary.new;
		Server.default.waitForBoot({
			var p = PathName(Platform.userAppSupportDir++"/Extensions/ABLE/samples");
			p.filesDo({
				|i|
				var path = i.absolutePath;
				if (path.endsWith(".wav"),{
					i.fileName.postln;
					AbleSynths.buffers[i.fileName.asString] = Buffer.read(Server.default,path);
				});
			});
		});

	}

	*loadSynths{
		var cmdp;
		~outBus = Bus.audio(Server.default,2).index;

		SynthDef(\kick_m,
			{
				|freq,amp,sustain,attack=0.01,pan=0,release=1|

				var audio, arpegio,arpegioFreqEnv,arpegioEnv,arpegDur,noise3, soft,softEnv,noise,noise2;
				freq=freq/2;
				softEnv = EnvGen.ar(Env.perc(attackTime:0.2,releaseTime:sustain),doneAction:0);
				arpegDur = 1/5.5;

				// audio = PlayBuf.ar(1,kick,rate:0.5*(freq.cpsmidi%12).midiratio,doneAction:0);
				audio = SinOsc.ar(30)*EnvGen.ar(Env.perc(attack,sustain,curve:-8));
				audio = Mix.ar(audio);
				audio = LPF.ar(audio,100);
				audio = HPF.ar(audio,15);
				audio = audio * (-16.dbamp);

				noise3 = RHPF.ar(WhiteNoise.ar(-50.dbamp),freq:Line.kr(600,20000,dur:attack),rq:0.1)*Line.ar(1,0,sustain);

				soft = SinOsc.ar((1,1.001..1.004)*freq*Line.kr(4,4,sustain/8))*Line.ar(1,0,sustain);
				soft = Mix.ar(soft)*(-64.dbamp);

				noise = BPF.ar(
					WhiteNoise.ar,
					freq:[0,7,19,24,12,4,2,9,11,14,-12].midiratio*freq,
					rq:0.01);
				noise = Mix.ar(noise)*(-18.dbamp)*Line.ar(1,0,sustain*1.5);

				arpegioFreqEnv = EnvGen.kr(
					Env.circle(
						(0,7..200)
						.collect({|v,i|[v,v].clip(0,100)})
						.flatten.midiratio,times:[0.99,0.01]*arpegDur));
				arpegioEnv = EnvGen.ar(Env.circle([0,1,0],[0.001,0.999]*arpegDur));
				arpegio = SinOsc.ar(
					freq*arpegioFreqEnv+SinOsc.ar(freq*arpegioFreqEnv*16,
						mul:freq*8));
				arpegio = Mix.ar(arpegio)*(-16.dbamp)*arpegioEnv;
				arpegio = LPF.ar(arpegio,Clip.kr(freq,5,21000));
				arpegio = arpegio*Line.ar(1,0,dur:sustain+release)*Line.ar(1,0,dur:sustain+release);

				arpegio = arpegio+noise+soft+noise3;
				arpegio = Compander.ar(arpegio,audio,thresh:(-30.dbamp),slopeBelow:1,slopeAbove:1/3,clampTime:0.01,relaxTime:0.2);

				audio = audio+arpegio;

				audio = Compander.ar(audio,audio,-35.dbamp,slopeAbove:2,mul:12.dbamp)*amp*(-24.dbamp);
				DetectSilence.ar(audio,amp:0.0005,doneAction:2);
				Out.ar(~outBus,Pan2.ar(audio,pan));
		}).add;



		SynthDef(\motion,
			{
				// expect motion as a value from 0 to 1
				|iMotion=0,fMotion=1,motionDur=1, freq = 220, amp = 0.1, pan = 0, gate = 0.25,sustain=1,iPan=0,fPan=0|
				var audio,env, smoothMotion, lfo;
				// var delayT = 0.1;
				var motion = Line.ar(iMotion,fMotion,motionDur);


				audio = Mix.ar(BPF.ar(WhiteNoise.ar,freq:([0,7,19,-12,-24,2,9,14,11,4].midiratio)*freq,rq:0.01)*0.25);


				lfo = SinOsc.ar(1/5,mul:50);
				audio = RLPF.ar(audio,400*motion.linexp(0,1,1,8)+lfo,rq:0.8);

				audio = HPF.ar(audio,freq:100);

				env = EnvGen.ar(Env.asr(),gate:gate,doneAction:2);

				audio = audio*env;//*motion;
				audio = Pan2.ar(audio,Line.kr(iPan,fPan,sustain));


				/*		6.do{
				audio = audio +DelayN.ar(audio,0.5,delayT,-3.dbamp);
				};*/
				Out.ar(0,audio);
		}).add;



		SynthDef(\squat,
			{
				// expect motion as a value from 0 to 1
				|motion=0, freq = 220, amp = 0.1, pan = 0, gate = 0.25|
				var audio,env,smoothFreq, smoothMotion, lfo;
				var delayT = 0.1;

				// smoothFreq = LPF.kr(freq, 1);
				smoothFreq = freq;

				smoothMotion = LPF.kr(motion.clip(0,1),0.5);
				// audio = Mix.ar(Saw.ar([smoothFreq,smoothFreq*1.02,smoothFreq*0.98]++([smoothFreq,smoothFreq*1.02,smoothFreq*0.98]*1.5),mul:amp/30));

				audio = Mix.ar(BPF.ar(WhiteNoise.ar,freq:([0,7,19,-12,-24,2,9,14,11,4].midiratio)*smoothFreq,rq:0.01)*0.25);

				lfo = SinOsc.ar(1/5,mul:50);
				audio = RLPF.ar(audio,400*smoothMotion.linlin(0,1,1,4)+lfo,rq:0.8);

				audio = RHPF.ar(audio,freq:100*(smoothMotion.linlin(0,1,1,10)),rq:0.5);

				audio = LPF.ar(audio,freq:smoothMotion.linlin(0,1,20000,500));

				env = EnvGen.ar(Env.asr(),gate:gate,doneAction:2);

				audio = audio*env*smoothMotion*amp;
				audio = Pan2.ar(audio,pan);


				6.do{
					audio = audio +DelayN.ar(audio,0.5,delayT,-3.dbamp);
				};
				// audio = audio*EnvGen.ar(Env([1,1],[at+sus+rt+delayT*6+0.1]),doneAction:2);

				Out.ar(0,audio);

		}).add;


		SynthDef(\generic,{
			|freq=440, amp=0.01, iPan=0, fPan=0,attack=0.5,gate=0.5, sustain=1,release=4|

			var audio,env,lfo, noise;
			var lfoDepth = 100;

			audio = Saw.ar(freq*([0,-12,7].midiratio)/2,mul:amp*[1,0.5])*(-8.dbamp);
			// audio = SinOsc.ar(freq,mul:amp);
			audio = Mix.ar(audio);//*SinOsc.ar(6+Rand(-0.1,0.1),mul:0.2,add:1);

			noise = BPF.ar(
				in:WhiteNoise.ar,
				freq:[12,19,24,36].midiratio*freq/2,rq:0.01,mul:-40.dbamp)*Line.kr(1,0,attack+(sustain)+(release/2));
			noise = Mix.ar(noise);

			audio = audio + noise;

			lfo = SinOsc.kr(0.6+Rand(-0.2,0.2),mul:lfoDepth,add:lfoDepth);

			audio = LPF.ar(audio,300+lfo);
			audio = HPF.ar(audio,10);

			env = EnvGen.ar(Env.asr(attackTime:attack,sustainLevel:1,releaseTime:2),gate:gate,doneAction:2);


			env = env*EnvGen.ar(Env.new([1,1,0],[attack+sustain,release]),doneAction:2);

			// env = EnvGen.ar(Env.perc(attackTime:attack,releaseTime:sustain+1),gate:gate,doneAction:2);

			audio = audio*env;
			audio = Pan2.ar(audio, Line.kr(iPan,fPan,attack));

			Out.ar(~outBus, audio);
		}).add;

		SynthDef(\leafCrunch,{
			|amp=0.01, pan=0|
			var buf = AbleSynths.buffers["leaves-crunching.wav"];
			var audio,env;
			audio = PlayBuf.ar(2,bufnum:buf,rate:Rand(0.6,1),startPos:Rand(0,buf.numFrames),doneAction:0)*amp;

			audio = audio + (PlayBuf.ar(2,bufnum:buf,rate:Rand(0.6,1),startPos:Rand(0,buf.numFrames),doneAction:0)*amp);
			audio = audio + (PlayBuf.ar(2,bufnum:buf,rate:Rand(0.6,1),startPos:Rand(0,buf.numFrames),doneAction:0)*amp);

			env = EnvGen.ar(Env.new([0,1,0],[0.01,0.5]),doneAction:2);
			audio = audio*env;
			Out.ar(~outBus,Pan2.ar(audio,pos:pan));
		}).add;

		SynthDef(\pressure,
			{
				|freq = 440, amp = 0.1, pan = 0, mod =16,attack=0.01, release=1|

				var audio, modulator, env;
				var delayInterval = 0.25;
				var randMax = 0.25;
				var masterEnv;
				amp = amp*(6.dbamp);
				freq = freq *2;
				modulator = LPF.kr(SinOsc.kr(freq*16,mul:freq*4),20000);

				audio = SinOsc.ar(freq+modulator, mul:amp)*(-10.dbamp);
				env = EnvGen.ar(Env.perc(attack,release),doneAction:0);
				audio = audio *env;

				/*		3.do {
				|i|
				audio = audio +(DelayN.ar(audio,2, delayInterval+Rand(0,randMax), mul:-3.dbamp));
				};*/

				masterEnv = EnvGen.ar(Env.new([1,1],times:[delayInterval*3+attack+release+randMax]),doneAction:2);

				audio = HPF.ar(audio,4000);
				audio = audio * masterEnv;
				audio = Pan2.ar(audio,pan);

				Out.ar(0,audio);

		}).add;



		SynthDef(\water,{
			|amp=0.01,gate=0.25,attack=4,release=4|
			var buf,buf2,audio,env;
			buf = AbleSynths.buffers["water.wav"];
			buf2 = AbleSynths.buffers["water.wav"];
			audio = PlayBuf.ar(2,buf,loop:1);
			audio = audio + (PlayBuf.ar(2,buf2,loop:1));
			audio = audio*amp*(15.dbamp);
			env = EnvGen.ar(Env.asr(attack,1,release),gate:gate,doneAction:2);
			audio = audio*env;

			Out.ar(0,audio);
		}).add;

		/*Synth.new(\water);*/


		SynthDef(\wind,{
			|amp=0.01,gate=0.25,attack=4,release=4|
			var buf,buf2,audio,env;
			buf = AbleSynths.buffers["wind.wav"];
			buf2 = AbleSynths.buffers["wind.wav"];
			audio = PlayBuf.ar(2,buf,startPos:Rand(0,buf.numFrames),loop:1);
			audio = audio + (PlayBuf.ar(2,buf2,loop:1));
			audio = audio*amp*(40.dbamp);
			env = EnvGen.ar(Env.asr(attack,1,release),gate:gate,doneAction:2);
			audio = audio*env;

			Out.ar(0,audio);
		}).add;

		SynthDef(\birds,
			{
				|amp=0.05, attack=4, release = 4,gate=0.25, density=0.1|
				var audio, env, buf1, buf2,buf3,buf4, env1;
				buf1 = AbleSynths.buffers["birds1.wav"];
				buf2 = AbleSynths.buffers["birds2.wav"];
				buf3 = AbleSynths.buffers["birds3.wav"];
				buf4 = AbleSynths.buffers["birds4.wav"];

				audio = PlayBuf.ar(2,bufnum:buf1,startPos:BufFrames.kr(buf1)*WhiteNoise.ar(0.5,add:0.5),loop:1)*EnvGen.ar(Env.asr(0.1,WhiteNoise.kr(mul:0.5,add:1),0.1),gate:SinOsc.ar(density,phase:Rand(0,pi*2)));


				audio = PlayBuf.ar(2,bufnum:buf2,startPos:BufFrames.kr(buf2)*WhiteNoise.ar(0.5,add:0.5),loop:1)*EnvGen.ar(Env.asr(0.1,WhiteNoise.kr(mul:0.5,add:1),0.1),gate:SinOsc.ar(density,phase:Rand(0,pi*2))) + audio;

				audio = PlayBuf.ar(1,bufnum:buf4,startPos:BufFrames.kr(buf4)*WhiteNoise.ar(0.5,add:0.5),loop:1)*EnvGen.ar(Env.asr(0.1,WhiteNoise.kr(mul:0.5,add:1),0.1),gate:SinOsc.ar(density,phase:Rand(0,pi*2))) + audio;

				env = EnvGen.ar(Env.asr(attack,1,release),gate:gate,doneAction:2);

				audio = audio*env*amp*(-10.dbamp);

				Out.ar(0, Pan2.ar(audio,0));

		}).add;





		// master out synth
		SynthDef(\out,{
			|lpf=22000, hpf=10, mix=0,db=0|
			var audio = In.ar(~outBus,2)*(db.dbamp);
			var room = 20;
			var reverberated = GVerb.ar(audio,roomsize:room,earlyreflevel:0.1);
			audio = (mix.clip(0,1))*reverberated+((1-(mix.clip(0,1)))*audio);
			audio = LPF.ar(audio, Clip.kr(lpf,10,22000));
			audio = HPF.ar(audio,Clip.kr(hpf,10,22000));
			audio = Compander.ar(audio,audio,-30.dbamp,slopeAbove:1/2.5,mul:3.dbamp);
			audio = Compander.ar(audio,audio,thresh:-1.dbamp,slopeAbove:1/20);
			Out.ar(0,audio);
		}).add;

		cmdp = {
			{
				~out = Synth.new(\out);
				"new out synth added".postln;
			}.defer(0.1);
		};
		cmdp.value();
		CmdPeriod.add(cmdp);
	}
}