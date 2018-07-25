(

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

		// audio = Mix.ar(Saw.ar(freq*smoothMotion.linlin(0,1,1,4)*[1,1.02,1.03,7.midiratio],mul:amp))*(-6.dbamp);

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

)



a = Synth.new(\water,[\db,-33])

b = Synth.new(\wind,[\db,-25])

c = Synth.new(\birds, [\db,-20])



c.set(\gate,0);

a.set(\gate,0)

AbleSynths.buffers["birds2.wav"]














(

var birds1 = Buffer.read(Server.default, path:"/Users/pulselab/Documents/ABLE/sound/samples/birds1.wav");
var birds2 = Buffer.read(Server.default, path:"/Users/pulselab/Documents/ABLE/sound/samples/birds2.wav");
var birds3 = Buffer.read(Server.default, path:"/Users/pulselab/Documents/ABLE/sound/samples/birds3.wav");
var birds4 = Buffer.read(Server.default, path:"/Users/pulselab/Documents/ABLE/sound/samples/birds4.wav");
var buffers = [birds1,birds2,birds3,birds4];
// ~outBus = Bus.audio(Server.default,2).index;

var kick = Buffer.read(s,"C:/Users/jamie/AppData/Local/SuperCollider/downloaded-quarks/Dirt-Samples/808bd/BD0075.WAV");
var pai = Buffer.read(s,"C:/Users/jamie/AppData/Local/SuperCollider/downloaded-quarks/Personal-Samples/recordings/pai-swamp.wav");
var kick17 = Buffer.read(s,"C:/Users/jamie/AppData/Local/SuperCollider/downloaded-quarks/Personal-Samples/kick/HIE_Kick_17.wav");

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


SynthDef(\birds,
	{
		|freq=440, amp=0.05, sustain=1, attack=0.5, release = 3,initialPan = 0, finalPan=0|

		var audio, env, noise, buf1, buf2;

		// Randomly picks 2 of the bird chirping sound files and adds them together
		// starts at a random position in each of the files and loops them so things aren't
		// too repetitive
		buf1 = Select.kr(Rand(0,4).floor,buffers);
		buf2 = Select.kr(Rand(0,4).floor,buffers);
		audio = PlayBuf.ar(2,bufnum:buf1,startPos:BufFrames.kr(buf1)*Rand(0,1),loop:1);
		audio = Mix.ar(audio + PlayBuf.ar(2,bufnum:buf2,startPos:BufFrames.kr(buf2)*Rand(0,1),loop:1));


		// Some subtractive synthesis to make things sound sort of ambient/fuller
		// reacts to the 'freq' argument so we can pitch this up/down
		noise = RHPF.ar(WhiteNoise.ar(-40.dbamp),freq:Amplitude.kr(audio,attackTime:0.1,releaseTime:0.1).linlin(0,1,5,22000),rq:0.1)*Line.ar(1,0,sustain);
		// Whitenoise Bandpass filtered at intervals in the major scale
		noise = noise + Mix.ar(BPF.ar(WhiteNoise.ar,freq:[-12,0,2,4,7,9,11,12,14,19,24].midiratio*freq,rq:0.01)*(-18.dbamp))*Line.ar(1,0,sustain*1.5);

		// make the noise 6 db louder
		noise = noise*(16.dbamp);

		// Simple trapezoidal envelope; attack time, sustain time, release time
		env = EnvGen.ar(Env.new([0,1,1,0],[attack,sustain,release]),doneAction:2);

		// Mix the sound buffers with the filtered noise
		audio = Mix.ar(audio + noise);

		// Apply the envelope and amplitude control
		audio = audio*env*amp;

		// Stereo panning that starts at 'initialPan' and moves to 'finalPan' over the sustain duration
		audio = Pan2.ar(audio, Line.kr(initialPan, finalPan,dur:sustain));

		// Send the audio signal to the output bus
		Out.ar(0, audio);

}).add;



// A sort of ambient synth we might leave on the whole time with some birds chirping
// You can play this synth once and later change parts of it (like it's fundamental pitch or other things we might add) .. see below
SynthDef(\ambient,
	{
		|freq=440, amp=0.1,attack=1, gate =0.24,release =2, pan=0|
		var env,audio,bufSelector,buf,bufTrigger;

		// Subtractive synthesis
		audio = Mix.ar(BPF.ar(WhiteNoise.ar,freq:[-24,-17,-15,-20,-12,-5,0,4,7,9,11,12,14,19].midiratio*freq,rq:0.01))*(-12.dbamp);

		// Randomly triggering random bird chirps from the 4 bird files
		// some little cracks happen when soudfile changes, will fix that soon...
		bufSelector = LPF.kr(WhiteNoise.kr,freq:1/12); // random low-frequency
		buf = Select.kr(bufSelector.linlin(-0.008,0.008,0,4).floor, buffers);
		bufTrigger = Trig1.kr(bufSelector,3);
		audio = audio + PlayBuf.ar(2,bufnum:buf,startPos:BufFrames.kr(buf)*Rand(0,1),trigger:bufTrigger,loop:1);

		// We might add more environmental sounds here too
		// ...

		// An ASR envelope, attacks over 'attack' sustains at level of 1, and releases for 'release' when
		// 'gate' is set to zero. Envelope will fire again if set to a positive number  after having been 0
		env = EnvGen.ar(Env.asr(attackTime:attack,sustainLevel:1,releaseTime:release),gate:gate,doneAction:2);


		// pan and apply envelopes
		audio = amp*audio*env;
		audio = Pan2.ar(audio,pan);

		Out.ar(0,audio);
}).add;


SynthDef(\motion,
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

		// audio = Mix.ar(Saw.ar(freq*smoothMotion.linlin(0,1,1,4)*[1,1.02,1.03,7.midiratio],mul:amp))*(-6.dbamp);

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

)













~motion = Synth(\motion,[motion:0.5,freq:72.midicps])
~motion2 = Synth(\motion,[motion:0.5,freq:67.midicps])


~motion.set(\freq,[60].midicps)

// Play for4 seconds (+attack and release), midinote 60 (mid C), pan from center to right speaker
(instrument:\birds,sustain:1,initalPan:0,finalPan:-1,midinote:[67,60],db:-10).play


// Instantianting a synth makes it start playing. Store that instance in ~ambient
~ambient = Synth.new(\ambient,[amp:-35.dbamp,freq:440])

// Reset the frequency to something else (I'm sure there's some way we could make this a gradual transition like a crossfade)
// Note we can't use 'midinote' here, must use \freq and midicps
~ambient.set(\freq,60.midicps)

~ambient.set(\freq,67.midicps,\amp, -10.dbamp)

// Trigger the end of the envelope (ie. the 'release')
~ambient.set(\gate,0)

// Retrigger the envelope to attack again.
~ambient.set(\gate,1)




~scale = Scale.major.degrees++(Scale.major.degrees+12)++(Scale.major.degrees+24)+48;


// pressure on toe = low:
//   a new note is chosen from scale
//   applying pressure raises volume
//   that note is played until pressure lowers again (?) maybe things would play too long that way though?
//   once pressure is low again, new note is chosen

// Choosing a note to switch to is done by checking what the heel of that same foot is playing and playing a nice
//  (perfect? major?) musical interval from it

// What is the sound like?
// Thresholds of pressure that make some percussive envelope trigger with some light ambience
// Perhaps bell-like? (fm)
// right foot is panned right, left panned left (any movement?) maybe stereo width changes for tandem exercise

Server.default.options.memSize = 8192*8
(
SynthDef(\pressure, {
	|freq=440, amp = 0.1, gate = 0.24, pan=0, mod = 16, attack=1, release=2, trig=0.25 |

	var audio, modulator, env, fmEnv, newFreq;



	env = EnvGen.ar(Env.perc(),doneAction:2);
	newFreq = freq;

	audio = Mix.ar(SinOsc.ar([1,3]))*((-26).dbamp);
	audio = audio*env;

	4.do{
		|i|
		audio = audio + (DelayN.ar(audio, 4, 0.25*i)*(-6.dbamp));
	};

	audio = audio*env;

	audio = Pan2.ar(audio,pan);

	Out.ar(0, audio);
}).add;
(instrument:\pressure,midinote:~scale.choose).play
)

(
SynthDef(\pressure,
	{
		|freq = 440, amp = 0.1, pan = 0, mod =16,attack=0.01, release=1|

		var audio, modulator, env;
		var delayInterval = 0.25;
		var randMax = 0.25;
		var masterEnv;
		freq = freq *2;
		modulator = LPF.kr(SinOsc.kr(freq*16,mul:freq*4),20000);

		audio = SinOsc.ar(freq+modulator, mul:amp)*(-10.dbamp);
		env = EnvGen.ar(Env.perc(attack,release),doneAction:0);
		audio = audio *env;

		3.do {
			|i|
			audio = audio +(DelayN.ar(audio,2, delayInterval+Rand(0,randMax), mul:-3.dbamp));
		};

		masterEnv = EnvGen.ar(Env.new([1,1],times:[delayInterval*3+attack+release+randMax]),doneAction:2);

		audio = HPF.ar(audio,4000);
		audio = audio * masterEnv;
		audio = Pan2.ar(audio,pan);

		Out.ar(0,audio);

}).add;
(instrument:\pressure,midinote:~scale.choose+0,pan:0).play
)

(instrument,

60.midicps/4

(
SynthDef(\motion,
	{
		// expect motion as a value from 0 to 1
		|motion=0, freq = 220, amp = 0.1, pan = 0, gate = 0.25|
		var audio,env,smoothFreq, smoothMotion, lfo;
		var delayT = 0.1;

		smoothFreq = LPF.kr(freq, 1/3);

		smoothMotion = LPF.kr(motion.clip(0,1),1/3);

		// audio = Mix.ar(Saw.ar([smoothFreq,smoothFreq*1.02,smoothFreq*0.98]++([smoothFreq,smoothFreq*1.02,smoothFreq*0.98]*1.5),mul:amp/30));

		audio = Mix.ar(BPF.ar(WhiteNoise.ar,freq:([0,7,19,-12,-24,2,9,14,11,4].midiratio)*smoothFreq,rq:0.01)*0.25);

		// audio = Mix.ar(Saw.ar(freq*smoothMotion.linlin(0,1,1,4)*[1,1.02,1.03,7.midiratio],mul:amp))*(-6.dbamp);

		lfo = SinOsc.ar(1/5,mul:50);
		audio = RLPF.ar(audio,400*smoothMotion.linlin(0,1,1,4)+lfo,rq:0.8);

		audio = HPF.ar(audio,freq:100);

		env = EnvGen.ar(Env.asr(),gate:gate,doneAction:2);

		audio = audio*env*smoothMotion;
		audio = Pan2.ar(audio,pan);


		6.do{
			audio = audio +DelayN.ar(audio,0.5,delayT,-3.dbamp);
		};
		// audio = audio*EnvGen.ar(Env([1,1],[at+sus+rt+delayT*6+0.1]),doneAction:2);

		Out.ar(0,audio);

}).add;

SynthDef(\kick_m,
	{
	|freq,amp,sustain,attack=0.01|

		var audio, arpegio,arpegioFreqEnv,arpegioEnv,arpegDur,noise3, soft,softEnv,noise,noise2;
		freq=freq/2;
		softEnv = EnvGen.ar(Env.perc(attackTime:0.2,releaseTime:sustain),doneAction:0);
		arpegDur = 1/5.5;

		audio = PlayBuf.ar(1,kick,rate:0.85*(freq.cpsmidi%12).midiratio,doneAction:0);
		audio = Mix.ar(audio);
		audio = LPF.ar(audio,100);
		audio = audio * (-12.dbamp);

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
		arpegio = arpegio*Line.ar(1,0,dur:sustain)*Line.ar(1,0,dur:sustain);

		arpegio = arpegio+noise+soft+noise3;
		arpegio = Compander.ar(arpegio,audio,thresh:(-30.dbamp),slopeBelow:1,slopeAbove:1/3,clampTime:0.01,relaxTime:0.2);


		noise2 = [Dust.ar(Line.ar(200,50,dur:sustain)),Dust.ar(Line.ar(200,50,dur:sustain))]*Line.ar(1,0,sustain*4);
		noise2 = noise2*EnvGen.ar(Env.new([0,0,1,0],[0.34,0.1,sustain]))*(-30.dbamp);

		audio = audio +noise2+arpegio;

		audio = Compander.ar(audio,audio,-35.dbamp,slopeAbove:2,mul:12.dbamp)*amp*(-24.dbamp);
		DetectSilence.ar(audio,amp:0.0005,doneAction:2);
		Out.ar(~outBus,Pan2.ar(audio,0));
}).add;

)



~a = Synth(\motion,[pan:-1])

~a.set(\motion,0.2)

~a.set(\freq,72.midicps);


~b = Synth(\sweepMotion,[pan:1])

~b.set(\motion,0.1)

XFade2.kr(

~b.set(\freq,55.midicps);

~b.set(\amp,0.3)




(
SynthDef(\pad3,
	{
	|freq=440, amp=0.1, out=0, at=0.5, rt=2, sustain,gate=1,lfoFreq=0.25,sus=1,resonance=0.15, panScatter=0,lpf=1,delayT=0.1|
		var audio,env, lpfEnv,lfo;
		amp = amp.clip(0,1);
		resonance = resonance.clip(0,1)/2;
		audio = Mix.ar(Saw.ar([freq,freq*1.02,freq*0.98]++([freq,freq*1.02,freq*0.98]*1.5),mul:amp/40));
		lpfEnv = EnvGen.ar(Env.linen(attackTime:at,sustainTime:sustain,releaseTime:rt),doneAction:0);
		lfo = SinOsc.ar(lfoFreq,mul:0.5,add:1);
		audio = RLPF.ar(audio, freq*lpf*lfo,0.25);
		audio = Compander.ar(audio,audio,0.dbamp,1,slopeAbove:1/20,clampTime:0.001,relaxTime:0.001);
		env = EnvGen.ar(Env.linen(attackTime:at,sustainTime:sus,releaseTime:rt),doneAction:0);
		audio = audio*env;

		6.do{
			audio = audio +DelayN.ar(audio,0.5,delayT,-3.dbamp);
		};
		audio = audio*EnvGen.ar(Env([1,1],[at+sus+rt+delayT*6+0.1]),doneAction:2);
		// audio = FreeVerb.ar(audio,0.6,room:0.9);
		audio = Pan2.ar(audio,panScatter*(lfo-1));

		Out.ar(0,Pan2.ar(audio,0));
	}
).add;
(instrument:\pad3,sustain:10

).play
)


(~scale.choose).midiratio
(
Routine{
	~a.set(\trig,-1);
	0.1.wait;
	~a.set(\freq,60.midicps);
	~a.set(\trig,0.25);
}.play
)

1.1%1

(3.3623*10).round/10

amp.dbamp%3-(3/2)

(
{
	// ((SinOsc.ar(freq:11)*10).round/10).poll(10)
	Latch.kr(SinOsc.ar(),MouseX.kr(0,1)%0.125-(0.125/2)).poll
}.play
)


// pressure rising on feet - maybe one foot is one pitch, the other is complementing
// Or toe and heel complementing

// Lateral movement (like side shuffling)
// Forward movement
// backwards movement

// Angle of feet (like lunges)



//

// tandem vs. semi tandem?/ balance wobbling?

//












