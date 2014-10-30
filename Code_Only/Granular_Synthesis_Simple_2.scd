///////////////////////////////
// Granular Sampling Examples
//
// 2013-11-16
//
////////////////////////////////

// Create SynthDef using GrainBuf
(
SynthDef("granular_sampling", {arg trigger = 0, graindur = 0.2, sndbuf, transp = 1, pos = 0, pan = 0, envbuf = -1, amp = 1, gate = 1;
	var env, snd;
	env = EnvGen.kr(Env.asr, gate, levelScale: amp, doneAction: 2);
	snd = GrainBuf.ar(
		numChannels: 2,
		trigger: Impulse.kr(trigger),
		dur: graindur,
		sndbuf: sndbuf,
		rate: transp,
		pos: pos,
		pan: pan,
		envbufnum: envbuf);
	Out.ar(0, snd * env);
}).add;
)

/*
Explanation of parameters:
- trigger: how many grains per second. Zero means just one grain.
- dur: duration of the grain, in seconds.
- sndbuf: the buffer where the sound file is loaded.
- rate: transposition rate. 1 = no transp, 2 = octave above, 1/2 = octave below.
- pos: position (0-1) in the sound file from where to read the grain.
- envbuf: the amplitude envelope of a single grain (-1 gives a dfault env).
*/

// Here's how to load a sound file into a buffer:
b = Buffer.read(s, "/media/BTR/Music/short-drone-mono.wav");
c = Buffer.read(s, "/media/BTR/Music/wheels-mono.wav");

// Listen to the sound file if you like:
{PlayBuf.ar(1, b)}.play;

// Play one single grain:
x = Synth("granular_sampling", [\sndbuf, b])
x.release;

// Play 4 grains per second:
x = Synth("granular_sampling", [\sndbuf, b, \trigger, 4])
x.release;

// Choose position in the sound file:
x = Synth("granular_sampling", [\sndbuf, b, \trigger, 4, \pos, 0.7])
x.release;

// Pbind Example 1:
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 0, // zero means 1 note = 1 grain. Get thicker with  higher numbers.
	\graindur, 0.1, // try different grain durations
	\sndbuf, b, // choose sound file
	\transp, 1, // transpose!
	\pos, Pseq([0, 0.1, 0.2], inf), // position in the sound to read
	\pan, Pwhite(-1, 1), // left to right speakers (-1 to 1)
	\amp, Pwhite(0.5, 0.7), // amplitude
	\envbuf, -1, // -1 is just the default grain envelope
	\dur, 0.5; // duration of Pbind notes
).play;
)

// The default grain envelope is like a "bell shape", smooth attack and decay.
// Try now applying a custom grain envelope, for example a percussive one.
// Note that GrainBuf requires that we put it into a Buffer:

z = Buffer.sendCollection(s, Env.perc.discretize, 1);

// Now in the Pbind you can use "z" for envbuf instead of -1.

// Pbind Example 2

(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, Pseq([Pseq([0.1], 15), 0.2], inf),
	\sndbuf, b,
	\transp, Pseq([ Pseq([1], 7), Prand([1, 0.9], 1) ], inf),
	\pos, Pseq([0, 0.1, 0.2, 0.5, 0.1, 0.1, 0.32, 0.2322], inf) * Prand([1, 2], inf),
	\pan, Pwhite(-0.5, 0.5),
	\amp, Pwhite(0.8, 1),
	\envbuf, z,
	\dur, 0.15;
).play;
)

// Pbind Example 3
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, 0.05,
	\sndbuf, b,
	\transp, 12, //Pwrand([1, 2], [0.9, 0.1], inf),
	\pos, Pxrand([0.8, 0.1, 0.11, 0.12], inf),
	\pan, Pwhite(-0.4, 0.4),
	\amp, 0.5,
	\envbuf, z,
	\dur, Pseq([Pseq([1/16], 15), Pseq([1/64, 1/64, 1/32], 1)], inf) * 3,
).play;
)

// Pbind Example 4
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, Pseq([0.9, 2.9, 0.9, 2, 0.5], inf),
	\sndbuf, c,
	\transp, Pseq([0.5, 0.5, 0.5, 1, 0.5], inf),
	\pos, Pseq([0.12, 0.12, 0, 0.13, 0.14], inf),
	\pan, 0,
	\amp, 1.5,
	\envbuf, z,
	\dur, Pseq([1, 1, Rest(1/2), 1/2, 1], inf) * 1/2,
).play;
)

// Pbind Example 4
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 13,
	\graindur, 4,
	\sndbuf, b,
	\transp, Pwhite(0.9, 1.2),
	\pos, Pseq([0.12, 0.12, 0, 0.13, 0.14], inf) + Pwhite(0, 0.01),
	\pan, 0,
	\amp, 1,
	\envbuf, -1,
	\dur, 0.9,
).play;
)


