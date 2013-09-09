// ************************************
// Additive Synthesis Demo (GUI)
// Patch 1 - Harmonic Series
// Bruno Ruviaro, 2013-07-22
// ************************************

/*

Simple button grid to play first 16 partials of a harmonic series:

01 02 03 04
05 06 07 08
09 10 11 12
13 14 15 16

Horizontal Sliders control ADSR envelope.

All partials have equal amplitude.

How to start: select all (ctrl + A), then evaluate (ctrl + enter)
(on a Mac, use the command key instead of control)

*/

s.waitForBoot({

	var win, buttonArray, notesArray, attackSlider, decaySlider, sustainSlider, releaseSlider, volumeSlider, att = 0.01, dec = 0.3, sus = 0.5, rel = 1.0, masterOut = 0.1, fundamental = 110;

	notesArray = Array.newClear(128);

	Window.closeAll;

	win = Window.new("Additive Synthesis - Harmonic Series", Rect(500, 100, 400, 590)).front;
	win.background = Color.grey;
	win.alpha = 0.95;

	win.onClose = {s.freeAll; "Done!".postln};
	CmdPeriod.doOnce({win.close});

	win.view.decorator = FlowLayout(win.view.bounds, margin: 10@10, gap: 20@10 );

	buttonArray = Array.fill(16, {Button(win.view, 80@80)});

	buttonArray.do({arg item, count;
		item.states = [[(count+1).asString, Color.black], [(count+1).asString, Color.black, Color.green]]});

	buttonArray.do({arg item, count;
		item.action = {arg state;
			case
			{state.value==1} {notesArray[count] = Synth("addsynth", [
				\freq,  fundamental * (count+1),
				\amp, 0.1,
				\att,  att,
				\dec,  dec,
				\sus,  sus,
				\rel,  rel])}
			{state.value==0} {notesArray[count].release}
	}});

	attackSlider = EZSlider(
		parent: win,
		bounds: 360 @ 30,
		label: "Attack",
		controlSpec: ControlSpec(0.01, 4.0, \exp, 0.01, 0.1, "sec"),
		action: {|ez|  att = ez.value},
		initVal: 0.01,
		unitWidth: 30)
	.setColors(
		stringColor: Color.black,
		sliderBackground: Color.grey(0.7),
		numNormalColor: Color.black);

	decaySlider = EZSlider(
		parent: win,
		bounds: 360 @ 30,
		label: "Decay",
		controlSpec: ControlSpec(0.01, 1, \exp, 0.01, 0.1, "sec"),
		action: {|ez|  dec = ez.value},
		initVal: 0.3,
		unitWidth: 30)
	.setColors(
		stringColor: Color.black,
		sliderBackground: Color.grey(0.7),
		numNormalColor: Color.black);

	sustainSlider = EZSlider(
		parent: win,
		bounds: 360 @ 30,
		label: "Sustain",
		controlSpec: ControlSpec(1, 100, \lin, 1, 75, "%"),
		action: {|ez|  sus = ez.value/100.0},
		initVal: 75,
		unitWidth: 30)
	.setColors(
		stringColor: Color.black,
		sliderBackground: Color.grey(0.7),
		numNormalColor: Color.black);

	releaseSlider = EZSlider(
		parent: win,
		bounds: 360 @ 30,
		label: "Release",
		controlSpec: ControlSpec(0.3, 5, \exp, 0.1, 0.5, "sec"),
		action: {|ez|  rel = ez.value},
		initVal: 0.5,
		unitWidth: 30)
	.setColors(
		stringColor: Color.black,
		sliderBackground: Color.grey(0.7),
		numNormalColor: Color.black);

	volumeSlider = EZSlider(
		parent: win,
		bounds: 360 @ 30,
		label: "VOLUME",
		controlSpec: ControlSpec(1, 100, \lin, 1, 10, "%"),
		action: {|ez|  masterOut.set(\amp, ez.value/100)},
		initVal: 10,
		unitWidth: 30)
	.setColors(
		stringColor: Color.white,
		sliderBackground: Color.grey(0.9),
		numNormalColor: Color.grey);

	// SynthDefs

	{
		SynthDef("addsynth", {
			arg freq = 440, amp = 0.1, gate = 1, att = 0.01, dec = 0.3, sus = 0.5, rel = 1;
			var snd, env;
			env = EnvGen.ar(Env.adsr(att, dec, sus, rel), gate, doneAction: 2);
			snd = SinOsc.ar(freq, 0, amp) * env;
			Out.ar(0, snd!2);
		}).add;

		SynthDef(\amp, {arg inbus=0, amp = 0.1;
			ReplaceOut.ar(inbus, In.ar(inbus, 2) * amp);
		}).add;

		// Wait for SynthDefs to be added...
		s.sync;

		// Now call the Master Out Synth:
		 masterOut = Synth("amp", addAction: \addToTail);

	}.fork;

	"Additive Synthesis Demo 1".postln;
	"".postln;

	s.meter;

}); // end of block