/////////////////////////
// Frequency Modulation
/////////////////////////

/*
Frequency Modulation (FM)

"FM was applied to sound synthesis by John Chowning in 1967, though he only published his results in 1973. Yamaha licensed the patents and in 1983 released the Yamaha DX7 synthesiser, which went on to sell 300,000 units, the most commercially successful synthesiser of all time. You might know the 'slow version' of FM already: a vibrato.

Rather than plugging the modulator into the amplitude of the carrier, we're going to plug the modulator into the carrier frequency. There will be three parameters, the carrier frequency C, the modulation frequency M, and the modulation depth or frequency deviation D."

Adapted from Nick Collins' SC tutorial (2.4 Modulation Synthesis)
*/


// Example with Graphical User Interface (GUI):
"http://sccode.org/1-4UA".openOS;




// Open the Frequency Analyzer for visualization:
FreqScope.new;

// Let's make a simple "vibrato" around 440 Hz - say, an oscillation between 420-460 Hz:

{ SinOsc.ar(freq: 440 + SinOsc.ar(5).range(-20, 20), mul: 0.2)}.play

// Same as above, written differently to clarify relevant parameters:
(
{
	var carrier, modulator, carfreq, modfreq, freqdev;
	carfreq = 440;
	modfreq = 5;
	freqdev = 20;
	modulator = SinOsc.ar(freq: modfreq, mul: freqdev);
	carrier = SinOsc.ar(freq: carfreq + modulator, mul: 0.2);
}.play;
)

/* =======

TAKE A CLOSER LOOK: in the modulator above, writing

SinOsc.ar(5).range(-20, 20)

...is the same as:

SinOsc.ar(5, mul: 20)

Both end up generating numbers between -20 and +20.

========= */


// Rewrite the code using MouseX and MouseY to control carfreq and modfreq. Make sure your modfreq range lets you play from vibrato range and beyond. What is the audible 'vibrato' range?

(
{
	var carrier, modulator, carfreq, modfreq, freqdev;
	carfreq = /* insert mouse control here */;
	modfreq = /* insert mouse control here */;
	freqdev = 20;
	modulator = SinOsc.ar(freq: modfreq, mul: freqdev);
	carrier = SinOsc.ar(freq: carfreq + modulator, mul: 0.2);
}.play;
)





/*
FM SPECTRUM

The resulting spectrum of FM has an infinite number of sidebands, but of varying strength. Based on the values we choose for the parameters C, M and D we can make very thick spectrums, or only a light modulation effect. The sidebands turn up at

C + kM where k is any integer, ie. C, C+M, C-M, C+2M, C-2M, ...

By changing the modulation frequency and depth, you can see how the energy in the sidebands is redistributed (see Curtis Roads' Computer Music Tutorial if you're curious about the formula behind it).
*/




// ===================
// MODULATION INDEX
// ===================
/*

There is a much more musically effective way to control FM, through the modulation index I, defined as:

I = D/M

The ratio of frequency deviation D to modulation frequency M.

If modulation index I is small, there is little audible FM effect. The higher I is, the stronger the energy in the sidebands. In our usual 'vibrato' example,

carfreq = 440 Hz
modfreq = 5 Hz
freqdev = 20

...the modulation index would be 4 (20/5).

*/

(
{
	var carrier, modulator, carfreq, modfreq, freqdev, modindex;
	carfreq = 440;
	modfreq = 4; // try other numbers here
	modindex = MouseY.kr(0.01, 10);
	// i = d/m, so d = m*i
	freqdev = modfreq * modindex;
	modulator = SinOsc.ar(freq: modfreq, mul: freqdev);
	carrier = SinOsc.ar(freq: carfreq + modulator, mul: 0.1);
}.play;
)

// GUI control with modulation index:
"http://sccode.org/1-4UB".openOS;

// =======================
// Building a FM SynthDef
// =======================

// Pretty much like the above, plus basic goodies
// such as envelope control and panning
(
SynthDef("FM1", {arg carfreq = 440, modfreq = 5, modindex = 10, amp = 0.1, pos = 0, gate = 1, attack = 0.01, release = 0.3;
	var carrier, modulator, freqdev, env;
	// i = d/m, so d = m*i
	freqdev = modfreq * modindex;
	modulator = SinOsc.ar(freq: modfreq, mul: freqdev);
	carrier = SinOsc.ar(freq: carfreq + modulator, mul: 0.1);
	env = Env.asr(
		attackTime: attack,
		sustainLevel: amp,
		releaseTime: release
	).kr(doneAction: 2, gate: gate);
	carrier = Pan2.ar(in: carrier, pos: pos, level: env);
	Out.ar(0, carrier);
}).add;
)

(
Pbind(
    \instrument, "FM1",
    \dur, 0.3,
    \carfreq, Pwhite(100, 1000),
    \modfreq, Pwhite(10, 500),
    \pmindex, Pwhite(2, 12),
    \amp, Pwhite(0.2, 0.5),
	\attack, 0.01,
	\release, Pwhite(0.1, 1),
	\pos, Pwhite(-1, 1.0)
).play;
)



// Slight modification to allow for Pbind pitch convenience
// (essentially, use word 'freq' instead of 'carfreq')
(
SynthDef("FM2", {arg freq = 440, modfreq = 5, modindex = 10, amp = 0.1, pos = 0, gate = 1, attack = 0.01, release = 0.3;
	var carrier, modulator, freqdev, env;
	// i = d/m, so d = m*i
	freqdev = modfreq * modindex;
	modulator = SinOsc.ar(freq: modfreq, mul: freqdev);
	carrier = SinOsc.ar(freq: freq + modulator);
	env = Env.asr(
		attackTime: attack,
		sustainLevel: amp,
		releaseTime: release
	).kr(doneAction: 2, gate: gate);
	carrier = Pan2.ar(in: carrier, pos: pos, level: env);
	Out.ar(0, carrier * 0.5);
}).add;
)

(
Pbind(
    \instrument, "FM2",
    \dur, 0.3,
	\degree, Pseq([0, 1, 2, 3, 4, 5, 6, 7, 8, 9], inf),
    \modfreq, 6, // try higher numbers here
    \pmindex, Pwhite(2, 12),
    \amp, 0.3,
	\attack, 0.01,
	\release, Pwhite(0.1, 0.3),
	\pos, Pwhite(-1, 1.0)
).play;
)

(
Pbind(
    \instrument, "FM2",
    \dur, 0.2,
	\degree, [-4, 0, 3, 5, 9],
	\ctranspose, Pseq([0, 1, 4, 5, 10], inf),
	\modfreq, Pwhite(1, 4), // try higher numbers here
    \pmindex, Pwhite(1, 7), // try higher numbers here
    \amp, 0.3,
	\attack, 0.01,
	\release, 0.2,
	\pos, Pwhite(-1, 1.0)
).play;
)





















// Advanced: See also Vibrato, PMOsc, and SinOscFB (UGens).

/*
SC actually has a PM UGen (Phase Modulation synthesis and Frequency Modulation synthesis are basically the same sound), so this example could also look like this
*/

{PMOsc.ar(300,550,2,mul:0.3).dup}.play;


/*
This is an example from the PMOsc help page in SC3: every two seconds, an FM sound fades in and out over 9 seconds, somewhere in the stereo field, with an index growing from 0 to somewhere as high as 12 (and any float in between). The result is a nice swarming drone of varying FM sounds.
*/

(
Routine({
	loop{
		{
			LinPan2.ar(
				EnvGen.ar(Env.linen(2, 5, 2), doneAction: 2)
				*
				PMOsc.ar(2000.rand, 800.rand, Line.kr(0.0, 12.0.rand, 9), 0, 0.1),
				1.0.rand2
			)
		}.play;
		2.wait;
	};
}).play;
)

// Similar to above but rewritten as SynthDef
(
SynthDef("pmosc", {arg carfreq = 440, modfreq = 250, pmindex = 12, dur = 1, amp = 0.1, attack = 0.01, release = 0.3, gate = 1, pos = 0;
    var env = Env.asr(
        attackTime: attack,
        sustainLevel: amp,
        releaseTime: release).kr(doneAction: 2, gate: gate);
    var snd = PMOsc.ar(
		carfreq: carfreq,
		modfreq: modfreq,
		pmindex: Line.kr(0.0, pmindex, dur));
    snd = LinPan2.ar(in: snd, pos: pos, level: env);
    Out.ar(0, snd)
}).add;
)

// Example:
(
Pbind(
    \instrument, "pmosc",
    \dur, Pwhite(2, 10),
    \carfreq, Pwhite(100, 1000),
    \modfreq, Pwhite(10, 500),
    \pmindex, Pwhite(5, 12),
    \amp, Pwhite(0, 0.1),
	\attack, Pwhite(1, 3),
	\release, Pwhite(5, 9),
	\pos, Pwhite(-1, 1.0)
).play;
)

