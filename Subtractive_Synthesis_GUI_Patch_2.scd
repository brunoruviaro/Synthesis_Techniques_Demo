// ************************************
// Subtractive Synthesis Demo (GUI)
// Patch 2 - Patterns of Filtered Noise
// Bruno Ruviaro, 2013-07-27
// ************************************

/*

White Noise triggered by either Impulses of LFPulse;
Then filtered by a Band Pass Filter (BPF).
16 different Patterns are created using this basic synth.

*/

s.waitForBoot({

	var win, buttonArray, padsArray, patternArray, volumeSlider, menu, whichBus, masterOut = 0.1;

	padsArray = Array.newClear(16);
	patternArray = Array.newClear(16);

	/*~masterOut = 0.1;*/

	whichBus = Bus.control(s, 1);
	whichBus.value = 0;

	Window.closeAll;
	s.meter;
	win = Window.new("Subtractive Synthesis - Patterns of Filtered Noise", Rect(450, 160, 480, 540)).front;

	win.background = Color.new255(102, 102, 102, 150);
	win.alpha = 0.95;

	// Change the gaps and margins to see how they work
	win.view.decorator = FlowLayout(win.view.bounds, margin: 10@10, gap: 20@20 );

	buttonArray = Array.fill(16, {Button(win.view, 100@100)});

	buttonArray.do({arg item, count;
		item.states = [[], [[], Color.black, Color.rand]]});

	buttonArray.do({arg item, count;
		item.action = {arg state;
			case
			{state.value==1} {padsArray[count] = patternArray[count].play}
			{state.value==0} {padsArray[count].stop}
	}});

	// subwin = CompositeView(win, Rect(0, 0, 460, 50));
	// subwin.background = Color.rand;

	// Noise Source menu
	menu = PopUpMenu(win, 80 @ 35);
	menu.items = ["Pop", "Rasp"];
	menu.action = {arg menu;
		case
		{menu.value==0} {whichBus.set(0.0)}
		{menu.value==1} {whichBus.set(1.0)}};

	volumeSlider = EZSlider(
		parent: win,
		bounds: 355 @ 35,
		label: "VOLUME",
		controlSpec: ControlSpec(-40, 3, \lin, 0.01, -12, "dB"),
		action: {|ez| masterOut.set(\amp, ez.value.dbamp)},
		unitWidth: 30)
	.setColors(
		stringColor: Color.white,
		sliderBackground: Color.grey(0.9),
		numNormalColor: Color.grey);


	// Patterns

	patternArray[0] = Pbind(
		\instrument, "noise-quneo-2",
		\freq, Pwhite(100, 5500),
		\pulseFreq, Pwhite(5, 10),
		\dur, 0.3,
		\amp, Pwhite(0.1, 0.5),
		\rq, Pwhite(0.001, 0.05));

	patternArray[1] = Pbind(
		\instrument, "noise-quneo-2",
		\degree, Pseq([0,3,5,7,9,11,14,17], inf),
		\pulseFreq, Pwhite(1, 9),
		\dur, 0.3,
		\amp, 1,
		\rq, 0.01);

	patternArray[2] = Pbind(
		\instrument, "noise-quneo-2",
		\degree, Prand([0,3,5,7,9,11,14,17], inf) - 12,
		\pulseFreq, Pwhite(1, 9),
		\dur, 0.3,
		\sustain, 0.1,
		\amp, 1,
		\rq, 0.1);

	patternArray[3] = Pbind(
		\instrument, "noise-quneo-2",
		\degree, Pxrand([0,3,5,7,9,11,14,17], inf) + 12,
		\pulseFreq, Pwhite(1, 9),
		\dur, Pseq([0.2, 0.3, 0.2, 0.4], inf) * Pwhite(2, 4),
		\sustain, 0.6,
		\amp, Pwhite(0.3, 0.6),
		\rq, Prand([0.05, 0.1], inf));

	patternArray[4] = Pbind(
		\instrument, "noise-quneo-2",
		\scale, Scale.phrygian,
		\degree, Pseq([0,3,5,7,9,11,14,17], inf),
		\pulseFreq, Pwhite(5, 19),
		\dur, 0.3,
		\amp, 1,
		\rq, Pwhite(0.005, 0.01));

	patternArray[5] = Pbind(
		\instrument, "noise-quneo-2",
		\scale, Scale.phrygian,
		\degree, Pseq([0,3,5,7,9,11,14,17], inf) + Pwrand([0, 1], [0.9, 0.1], inf),
		\pulseFreq, Pwhite(5, 19),
		\dur, 0.33,
		\amp, 1,
		\rq, Pwhite(0.005, 0.01));

	patternArray[6] = Pbind(
		\instrument, "noise-quneo-2",
		\scale, Scale.phrygian,
		\degree, Pseq([0,3,5,7,9,11,14,17], inf) + Pwrand([0, 1], [0.9, 0.1], inf),
		\pulseFreq, 0.5,
		\dur, Pseq( (0.1!60) ++ (0.2!8)   , inf),
		\amp, 1,
		\rq, Pwrand([0.005, 0.01], [0.95, 0.05], inf));

	patternArray[7] = Pbind(
		\instrument, "noise-quneo-2",
		\freq, Pwhite(1000, 9500),
		\pulseFreq, Pwhite(5, 10),
		\dur, 0.3,
		\amp, Pwhite(0.1, 0.5),
		\rq, Pwhite(0.001, 0.05));

	patternArray[8] = Pbind(
		\instrument, "noise-quneo-2",
		\degree, Pshuf([4,3,5,7,9,11,14,17], inf),
		\pulseFreq, Pwhite(1, 9),
		\dur, 0.3,
		\amp, 1,
		\rq, 0.01);

	patternArray[9] = Pbind(
		\instrument, "noise-quneo-2",
		\note, Prand([0,3,5,7,9,11,14,17], inf),
		\pulseFreq, Pwhite(1, 9),
		\dur, 0.3,
		\sustain, 0.1,
		\amp, 1,
		\rq, 0.1);

	patternArray[10] = Pbind(
		\instrument, "noise-quneo-2",
		\degree, Pxrand([0,3,5,7,9,11,14,17], inf) - 12,
		\pulseFreq, Pwhite(1, 9),
		\dur, Pseq([0.2, 0.1, 0.2, 0.4], inf) * Pwhite(1, 4),
		\sustain, 0.2,
		\amp, Pwhite(0.3, 0.6),
		\rq, Prand([0.05, 0.1], inf));

	patternArray[11] = Pbind(
		\instrument, "noise-quneo-2",
		\scale, Scale.phrygian,
		\degree, Pseq([0,5,9,3,7,11], inf),
		\pulseFreq, Pwhite(5, 19),
		\dur, 0.3,
		\amp, 1,
		\rq, Pwhite(0.005, 0.01));

	patternArray[12] = Pbind(
		\instrument, "noise-quneo-2",
		\scale, Scale.phrygian,
		\degree, Pseq([0,3,5,7,9,11,14,17], inf) + Pwrand([0, 12], [0.5, 0.5], inf),
		\pulseFreq, Pwhite(1, 19),
		\dur, 0.43,
		\amp, 1,
		\rq, Pwhite(0.005, 0.01));

	patternArray[13] = Pbind(
		\instrument, "noise-quneo-2",
		\scale, Scale.locrian,
		\degree, Pseq([7,8,6,5,4,3,2,1,0,4], inf) + Pwrand([0, 1], [0.9, 0.1], inf),
		\pulseFreq, 0.5,
		\dur, Pseq( (0.1!10) ++ (0.2!8)   , inf),
		\amp, 0.6,
		\rq, Pwrand([0.005, 0.01], [0.95, 0.05], inf));

	patternArray[14] = Pbind(
		\instrument, "noise-quneo-2",
		\degree, Pxrand([1,3,4,7], inf) + 24,
		\pulseFreq, Pwhite(1, 9),
		\dur, Pseq([0.2, 0.3, 0.1, 0.4], inf) * Pwhite(2, 4),
		\sustain, 0.6,
		\amp, Pwhite(0.3, 0.6),
		\rq, Prand([0.05, 0.1], inf));

	patternArray[15] = Pbind(
		\instrument, "noise-quneo-2",
		\scale, Scale.mixolydian,
		\degree, Pseq([0,7,5,3,9,11,0], inf) + 12,
		\pulseFreq, Pwhite(5, 19),
		\dur, 0.5,
		\amp, 0.5,
		\rq, Pwhite(0.05, 0.09));

	// SynthDefs

	{
		SynthDef("noise-quneo-2", {arg freq = 1000, pulseFreq = 10, amp = 0.1, rq = 0.001, att = 0.01, dec = 0.3, sus = 1, rel = 1, gate = 1;
			var snd, env;
			env = EnvGen.kr(Env.adsr(att, dec, sus, rel), gate: gate, doneAction: 2);
			snd = BPF.ar(
				in: WhiteNoise.ar(Select.ar(In.kr(whichBus),
					[
						Impulse.ar(pulseFreq),
						LFPulse.ar(pulseFreq,0,0.5) * 0.01
					]
				)),
				freq: freq,
				rq: Lag.kr(rq, 1));
			snd = snd * env * Lag.kr(amp, 1) * 100;
			snd = Clip.ar(snd, -0.5, 0.5);
			Out.ar(0, [snd, snd]);
		}).add;

		SynthDef(\amp, {arg inbus=0, amp = 0.1;
			ReplaceOut.ar(inbus, In.ar(inbus, 2) * amp);
		}).add;

		// Wait for SynthDefs to be added...
		s.sync;

		// Now call the Master Out Synth:
		masterOut = Synth("amp", addAction: \addToTail);

	}.fork;

	win.onClose = {
		padsArray.do{ |item, count| padsArray[count].stop};
		Window.closeAll;
		masterOut.free;
		"Done!".postln;
	};

	CmdPeriod.doOnce({Window.closeAll});

	"Subtractive Synthesis Demo 2".postln;
	"".postln;

}); // end of block