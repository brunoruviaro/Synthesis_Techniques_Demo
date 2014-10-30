// ************************************
// Amplitude and Frequency Modulation
// ************************************

/* What happens if, instead of having a fixed number for frequency and amplitude, we have ANOTHER oscillator providing ever-changing values? */

// Here's a simple sine (same old example, no modulation):

// Definition
SynthDef("simpleSine", {arg freq = 440, amp = 0.1;
	var sound;
	sound = SinOsc.ar(freq: freq, mul: amp);
	Out.ar(0, sound);
}).add;

// Play one note
Synth("simpleSine", [\freq, 500, \amp, 0.2]);


// Now let's add some modulation into the amplitude

// Definition
SynthDef("simpleSineAmpMod", {arg freq = 440, amp = 0.1;
	var sound, modulator;
	modulator = SinOsc.kr(2).range(0.2, 1);
	sound = SinOsc.ar(freq: freq, mul: modulator);
	sound = sound * amp;
	Out.ar(0, sound);
}).add;

// Play one note
Synth("simpleSineAmpMod", [\freq, 500, \amp, 0.2]);

// What is happening? The sine oscillator with nickname "modulator" is oscillating at 2 Hz (two cycles per second), sending out numbers within the range 0.2 and 1. Then another sine oscillator, nickname "sound", is just producing our regular sine wave that we are going to hear. Note that now we assign "modulator" as the mul parameter of our sound, as opposed to a single amplitude value as before. This means that the volume of the sound will be going up and down following the numbers produced by "modulator" (in this case, going up and down between 0.2 and 1, twice per second). Why 0.2 and 1? Any numbers between 0 and 1 will do. Remember, for amplitudes, we generally want to keep numbers between 0 (silence) and 1 (maximum amplitude).


/////////////////////////////////////////////////////////////

// Now let's add some modulation into the frequency only.

// Definition
SynthDef("simpleSineFreqMod", {arg freq = 440, amp = 0.1;
	var sound, modulator;
	modulator = SinOsc.kr(2).range(-50, 50);
	sound = SinOsc.ar(freq: freq + modulator, mul: amp);
	Out.ar(0, sound);
}).add;

// Play one note
Synth("simpleSineFreqMod", [\freq, 660, \amp, 0.2]);


// What is happening? The sine oscillator with nickname "modulator" is oscillating at 2 Hz (two cycles per second), sending out numbers within the range -50 and +50. Then other sine oscillator, nicknamed "sound", is just producing our regular sine wave that we are going to hear. Note that now we add "modulator" to frequency parameter of our sound. This means that the frequency of the sound will be DEVIATING up and down by -/+50 (the numbers sent by "modulator".



////////////////////////////////////////////////////////
// Little exercise for tomorrow (Monday):

// Play with the code above changing some of the numbers.
// In particular, experiment changing the ranges of the modulators.
// What happens when you increase the frequency of oscillation of the modulator?
// How does it sound with various ranges of amplitude and frequency modulation?

// Just send me by e-mail one example of each: one for Amplitude Modulation, one for Frequency Modulation. They can be as simple as copying the examples above but changing some of the numbers to create an interesting sound.


