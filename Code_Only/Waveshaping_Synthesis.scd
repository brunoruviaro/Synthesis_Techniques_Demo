// Waveshaping Synthesis

// http://chrisjeffs.com/blog/?p=750


// http://new-supercollider-mailing-lists-forums-use-these.2681727.n2.nabble.com/Wave-shaping-transfer-function-using-Shaper-td7591877.html

// Freqscope to see spectrum
FreqScope.new;

// Clean up all Buffers
Buffer.freeAll;

// Create one buffer to store transfer function
b = Buffer.alloc(s, 1024, 1);

// Create arbitrary transfer function
// Note that it must be half of buffer size + 1
t = Signal.fill(513, { |i| i.linlin(0.0, 512.0, -1.0, 1.0) });

// The above is just a linear function
t.plot;

// Convert it to the official Wavetable format at twice the size
b.sendCollection(t.asWavetableNoWrap);

// Shaper has no effect because of the linear transfer function
{Shaper.ar(b, SinOsc.ar(440, 0, MouseY.kr(0, 1)))!2}.scope;

// Now try a different arbitrary function
t = Signal.fill(513, { |i| i.linlin(0.0, 512.0, -1.0, 1.0)+rrand(0, 0.1) });
t = t.normalizeTransfer; // good for Shaper
t.plot;
b.sendCollection(t.asWavetableNoWrap);
b.plot;
{Shaper.ar(b, SinOsc.ar(440, 0, MouseY.kr(0, 1)))!2}.scope;

// Another:
t = Signal.fill(513, { |i| i.linlin(0.0, 512.0, -1.0, 1.0)+[0, 0.1].choose});
t = t.normalizeTransfer; // good for Shaper
t.plot;
b = Buffer.alloc(s, 1024, 1);
b.sendCollection(t.asWavetableNoWrap);
b.plot;
{Shaper.ar(b, SinOsc.ar(440, 0, MouseY.kr(0, 1)))!2}.scope;

// Creating harmonic spectra:
// direct shortcut using chebyMsg
b = Buffer.alloc(s, 1024, 1, { |buf| buf.chebyMsg([1,0,0.1,0,0.1,0,0.01]) });
b.plot;
{Shaper.ar(b, SinOsc.ar(440, 0, MouseY.kr(0, 1)))!2}.scope;

// Another way (cheby message to a Buffer)
e = Buffer.alloc(s, 1024, 1);
e.cheby([1, 0.5, 1, 0.125]);
{Shaper.ar(e, SinOsc.ar(440, 0, MouseY.kr(0, 1)))!2}.scope;

// Make a Synth to play around
(
SynthDef("shaper", {
	arg freq = 440, gate = 1, amp = 0.6, dist = 0.4, transFunc;
	var snd, env;
	env = EnvGen.kr(Env.adsr(0.1), gate, doneAction: 2);
	snd = Shaper.ar(transFunc, SinOsc.ar(freq, 0, dist));
	snd = snd * env * amp;
	Out.ar(0, snd!2);
}).add;
)
x = Synth("shaper", [\transFunc, b]);
x.set(\dist, 0.9);
x.release;

(
Pbind(
	\instrument, "shaper",
	\degree, Pseq([Pseries(1, 2, 12)], inf), // + Pwhite(0, 1),
	\dist, Pwhite(0.1, 0.41),
	\transFunc, b, //Prand([b, e], inf),
	\dur, Pseq([0.4, 0.1, 0.3], inf),
	\amp, 0.1, //Pwhite(0.2, 0.4),
	\legato, 0.1 //0.1
).play;
)