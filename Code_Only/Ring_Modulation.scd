/////////////////////
// Ring Modulation
/////////////////////

// A straight multiplication of two signals:
//
// carrier * modulator
//
// Adapted from Nick Collins' tutorial (2.4 Modulation Synthesis)

/*
For simple sine waves, the spectrum ends up with two frequencies (two sidebands), at C+M and C-M, where C is the carrier frequency and M is the modulator frequency. Example:
If Carrier = 600 and Modulator = 350, resulting frequencies are 950 and 250.
*/

// Single line example:
{SinOsc.ar(600) * SinOsc.ar(300) * 0.2}.play;

// Visualize it in a FreqScope:
FreqScope.new;

// Same as above:
(
{
	var carrier, modulator, carrfreq, modfreq;
	carrfreq = 600;
	modfreq = 350;
	carrier = SinOsc.ar(carrfreq);
	modulator = SinOsc.ar(modfreq);
	carrier * modulator * 0.2;
}.scope;
)

// Using MouseX and MouseY to control carrier and modulator:
(
{
	var carrier, modulator, carrfreq, modfreq;
	carrfreq = MouseX.kr(440, 5000);
	modfreq = MouseY.kr(1, 5000);
	carrier = SinOsc.ar(carrfreq);
	modulator = SinOsc.ar(modfreq);
	carrier * modulator * 0.2;
}.scope;
)

// Same as above, but using a different source (Saw instead of SinOsc):
(
{
	var carrier, modulator, carrfreq, modfreq;
	carrfreq = MouseX.kr(440, 5000);
	modfreq = MouseY.kr(1, 5000);
	carrier = Saw.ar(carrfreq);
	modulator = Saw.ar(modfreq);
	carrier * modulator * 0.2;
}.scope
)


/*
For more complex waves than sines, we get many more components to the spectrum of the multiplied signals.
But if C and M are harmonic, the sidebands are also harmonic.
For those who want to see some proof, it all follows from the mathematical relation cos(C)*cos(M) = 0.5*(cos(C-M) + cos(C+M))
*/