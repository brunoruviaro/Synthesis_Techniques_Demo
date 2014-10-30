e = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
z = Buffer.sendCollection(s, e.discretize, 1);

(
b = Buffer.alloc(s, 512, 1);
// b.sine1(1.0 / [1, 2, 3, 4]);
b.sine1([1, 0.3, 0.3, 0.4, 0.9, 0, 0.1]);
x = { Osc.ar(b, 200, 0, 0.5) }.play;
)
b.plot;

[]

// a custom envelope
winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
z = Buffer.sendCollection(s, winenv.discretize, 1);

z.plot;


(
SynthDef(\buf_grain_test, {arg gate = 1, rate = 1,  amp = 0.1, sndbuf, envbuf = -1;
	    var pan, snd, env, freqdev;

	    // use mouse x to control panning
	    pan = 0; //MouseX.kr(-1, 1);
	    env = EnvGen.kr(
		Env.asr(0.01, 1, 0.1),
		        /*Env([0, 1, 0], [1, 1], \sin, 1),*/
		        gate,
		        doneAction: 2);
	snd = GrainBuf.ar(
		numChannels: 2,
		trigger: Impulse.kr(MouseX.kr(5, 50)), //,
		dur: 0.1,
		sndbuf: sndbuf,
		rate: rate, //LFNoise1.kr.range(0.5, 2),
		pos: 0, //LFNoise2.kr(0.1).range(0, 1),
		interp: 2,
		pan: pan,
		envbufnum: envbuf);
	    Out.ar(0, FreeVerb.ar(LPF.ar(snd * env * amp, 1000)));
    }).add;
)

x = Synth("buf_grain_test", [\sndbuf, b]);
x.set(\amp, 0.3);
x.set(\envbuf, z);
x.release;

(
Pbind(
\instrument, "buf_grain_test",
	\rate, Pwhite(10, 20),
	\dur, Pwhite(0.1, 0.41),
	\legato, 0.6
).play;
)