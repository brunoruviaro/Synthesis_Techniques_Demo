/////////////////////////////
// Amplitude Modulation (AM)
/////////////////////////////

// What happens when you plug the output of one oscillator into the MUL: of another oscillator? (in other words, when you use one oscillator to control the amplitude of another oscillator)

// The result is AMPLITUDE MODULATION.

// At slow rates, it sounds like a tremolo.
// At faster rates, it sounds like a richer timbre (spectrum).

// Try out the code from http://sccode.org/1-4Uy





// Listen to this simple "tremolo" example:
{ SinOsc.ar(freq: 440, mul: SinOsc.ar(5).range(0, 0.3)) }.scope;

// "scope" is the same as "play", with the added feature of opening a small "stethoscope" window to let us visualize the waveform. Keep that window open for the rest of this tutorial. It's also nice to open a Frequency Analyzer window to see the spectrum:

FreqScope.new;

/*
Remember:

(a) amplitudes are normally expected to be between 0 and 1, BUT:
(b) oscillators normally output numbers between -1 and +1.

SO,

We need to scale the output of the .ar oscillator so that it is in the range 0/1 ("unipolar"), not -1/+1 ("bipolar").
*/

// ========================================
// BIPOLAR UNIPOLAR WTF?
// Easy.
// Check out the difference between a bipolar and unipolar signal:
{ SinOsc.ar(freq: 440, mul: 0.5) }.scope; // bipolar, -0.5 to 0.5
{ SinOsc.ar(freq: 440).range(0, 1) }.scope; // unipolar, 0 to 1
{ SinOsc.ar(440).range(0.5, 0.7) }.scope; // another unipolar example
// ========================================



// Notice that our first example
{ SinOsc.ar(freq: 440, mul: SinOsc.ar(5).range(0, 0.3)) }.play;

// ...could also be written like this (it's the same):
(
{
	var apple, banana;
	apple = SinOsc.ar(freq: 5).range(0, 0.3);
	banana = SinOsc.ar(freq: 440, mul: apple)
}.play;
)

// Try using other numbers for the freq of 'apple' above (the modulator).
// When does the tremolo start sounding like something else?

/*
Apple and bananas are great, but not very descriptive words for what is happening in Amplitude Modulation. "CARRIER" and "MODULATOR" are the official terms.
The oscillator whose amplitude is being modulated is called "carrier" (C).
The oscillator that modulates is called "modulator" (M).
*/

(
{
	var carrier, modulator;
	carrier = SinOsc.ar(freq: 440);
	modulator = SinOsc.ar(freq: 4).range(0, 0.3);
	carrier * modulator;
}.play;
)


// The resulting spectrum of AM is a complex one: in addition to the carrier frequency (the "main note"), it also contains extra frequencies above and below it. Specifically, they are the sum and difference frequencies (C + M and C - M). So for an AM sound with C = 600 Hz and M = 350 Hz, the resulting frequencies are 250, 600, 950. Try it below, and watch the Freq Analyzer window.

(
{
	var carrier, modulator, carrfreq, modfreq;
	carrfreq = 600;
	modfreq = 300;
	carrier = SinOsc.ar(carrfreq);
	modulator = SinOsc.ar(modfreq).range(0, 0.7);
	carrier * modulator;
}.scope;
)



// Now change the code above replacing the fixed frequencies for MouseX and MouseY control. Make sure your modfreq control allows you to explore both low modulation frequencies ("tremolo range") and higher ones.



// ================================
// SynthDefs to use with Pbinds
// ================================

// Very simple one. Notes always have same attack and 1 second duration.
// Not very flexible in terms of controlling various parameters.
// Mono.

(
SynthDef("AM1", { arg carfreq = 440, modfreq = 5, amp = 0.5;
	var carrier, modulator, env;
	env = Env.perc(attackTime: 0.01, releaseTime: 1, level: amp).kr(2);
	modulator = SinOsc.ar(modfreq).range(0, 1);
	carrier = SinOsc.ar(freq: carfreq, mul: modulator);
	carrier = carrier * env;
	Out.ar(0, carrier)
}).add;
)

(
Pbind(
	\instrument, "AM1",
	\carfreq, 440,
	\modfreq, Pseq([1, 5, 10, 50, 100], inf),
	\amp, 0.2,
	\dur, 0.5
).play;
)

// ===============================
// A bit more flexible SynthDef.
// Duration of notes responds to Pbind duration
// Allows attack time to be controlled from Pbind
// Renamed 'carfreq' to 'freq' so that we can use Pbind pitch conveniences (degree, note, etc)
// Added control 'pos' for panning position (-1 left, 0 middle, 1, right speaker).

(
SynthDef("AM2", { arg freq = 440, modfreq = 5, amp = 0.5, attack = 0.01, dur = 1, pos = 0;
	var carrier, modulator, env;
	modulator = SinOsc.ar(modfreq).range(0, 1);
	carrier = SinOsc.ar(freq: freq, mul: modulator);
	env = Env.perc(attackTime: attack, releaseTime: dur - attack, level: amp).kr(2);
	carrier = carrier * env;
	Out.ar(0, Pan2.ar(carrier, pos))
}).add;
)

(
Pbind(
	\instrument, "AM2",
	\degree, Pseq([0, 2], inf),
	\modfreq, Pseq([1, 5, 10, 50, 100], inf),
	\amp, 0.4,
	\dur, 0.2,
	\pos, Pwhite(-1, 1.0)
).play;
)

(
Pbind(
	\instrument, "AM2",
	\degree, Pseq([0, 1, 2, 3, 4], inf),
	\modfreq, Prand([13, 35, 20, 39, 11], inf),
	\amp, Pwhite(0.1, 0.4),
	\attack, Pwhite(0.01, 0.05),
	\dur, Prand([0.2, 0.1], inf)
).play;
)

// Notice that higher modfreqs change the pitch significantly, so that using
// scale degrees may not be *that* meaningful (you don't hear them as scale degrees).
(
Pbind(
	\instrument, "AM2",
	\degree, Pseq([0, 1, 2, 3, 4], inf),
	\modfreq, Prand([130, 145, 200, 500, 300], inf),
	\amp, Pwhite(0.1, 0.4),
	\dur, Prand([0.2, 0.1, 1], inf)
).play;
)


// ===============================
// An even more flexible SynthDef.
// Duration of notes responds to Pbind duration
// Allows attack AND release time to be controlled from Pbind
// No danger of messing up envelope

(
SynthDef("AM3", { arg freq = 440, modfreq = 5, amp = 0.5, attack = 0.01, release = 0.1, pos = 0, gate = 1;
	var carrier, modulator, env;
	modulator = SinOsc.ar(modfreq).range(0, 1);
	carrier = SinOsc.ar(freq: freq, mul: modulator);
	env = Env.asr(
		attackTime: attack,
		sustainLevel: amp,
		releaseTime: release).kr(doneAction: 2, gate: gate);
	carrier = carrier * env;
	Out.ar(0, Pan2.ar(carrier, pos))
}).add;
)

(
Pbind(
	\instrument, "AM3",
	\freq, Pseries(100, 50, 20),
	\modfreq, Pseq([1, 500, 10, 50, 100], inf),
	\amp, 0.2,
	\attack, 0.02,
	\release, 0.1,
	\pos, Pwhite(-1, 1),
	\dur, 0.1
).play;
)



















/*
Advanced topic:
Ring Modulation is a type of AM but with a subtle difference: the modulator is bipolar, that is, includes negative values (-1 to +1)

AMPLITUDE MODULATION:
carrier * modulator(unipolar)

RING MODULATION:
carrier * modulator(bipolar)

See tutorial on Ring modulation for more info.
*/




