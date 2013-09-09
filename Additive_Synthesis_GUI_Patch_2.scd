// ************************************
// Additive Synthesis Demo (GUI)
// Patch 2 - Harmonic Series with Multislider
// Bruno Ruviaro, 2013-07-23
// ************************************

/*

Multislider interface to control 32 partials of a harmonic series.

Two modes of playing:

"Continuous Tone" - it simply plays a continuous tone as you change the spectrum.

"Percussive Tone" - you can play single percussive tones triggered with the 'perc' button, and control attack and decay values of these notes.

How to start: select all (ctrl + A), then evaluate (ctrl + enter).

Click and drag on the white rectangle to draw the spectrum.

*/

s.waitForBoot({

	var spectrum, numharm, fundamental, win, continuousOut, percussiveOut, multiSlider, volumeSlider, modeButton, singleNoteButton, attackSlider, releaseSlider, subwin, singleNoteRoutine, att = 0.01, rel = 2, ampBus, sndBus;

	numharm = 32;
	fundamental = 110;

	ampBus = Bus.control(s);
	ampBus.value = 0.1;
	sndBus = Bus.audio(s, 2);

	// Main window
	Window.closeAll;
	win = Window.new("Additive Synthesis", Rect(400, 30, 590, 670));
	win.view.decorator = FlowLayout(win.view.bounds, 20@20, 20@20);
	win.onClose = {s.freeAll; "Done!".postln; "".postln};
	CmdPeriod.doOnce({win.close});
	win.front;

	// Multislider
	multiSlider = MultiSliderView(win, Rect(0, 0, 550, 300));
	multiSlider.value = Array.fill(numharm, {0.0});
	multiSlider.isFilled = true;
	multiSlider.indexThumbSize = 13.0;
	multiSlider.gap = 4;
	/*multiSlider.action = {multiSlider.value.do({arg value, count;
		spectrum[count].set(\amp, value); [value, count].postln})};*/

	multiSlider.action = {arg multi;
		var index = multi.index;
		var value = multi.currentvalue;
		spectrum[index].set(\amp, value);
		[index, value.round(0.01)].postln};

	// Volume slider
	volumeSlider = EZSlider(
		parent: win,
		bounds: 560 @ 60,
		label: "VOLUME",
		controlSpec: ControlSpec(1, 100, \lin, 1, 10, "%"),
		action: {|ez| ampBus.set(ez.value/100)},
		initVal: 10,
		unitWidth: 30)
	.setColors(
		stringColor: Color.black,
		sliderBackground: Color.grey(0.9),
		numNormalColor: Color.black);

	// Mode button (toggle between continuous and percussive)
	modeButton = Button(win, 550 @110);
	modeButton.states = [
		["CONTINUOUS TONE (click here to switch to percussive mode)", Color.black, Color.new255(255, 255, 114)],
		["PERCUSSIVE TONE (click here to switch to continuous mode)", Color.black, Color.new255(255, 204, 194)]
	];
	modeButton.action = {arg state;
		if(state.value==0,
			{
				volumeSlider.valueAction = 10;
				continuousOut.set(\gate, 1);
				"CONTINUOUS MODE ON".postln;
				singleNoteButton.states = [["perc"]];
				subwin.background = Color.grey(0.6, 0);
			},
			{
				continuousOut.set(\gate, 0);
				"PERCUSSIVE MODE ON - click on perc button".postln;
				singleNoteButton.states = [["perc", Color.black, Color.new255(255, 204, 194)]];
				subwin.background = Color.grey(0.6, 1);
			}
	)};

	// CompositeView (sub window)
	subwin = CompositeView(win, 550@100);
	subwin.background = Color.grey(0.6, 0);

	// Button for triggering single percussive note
	singleNoteButton = Button(subwin, Rect(10, 10, 70, 80));
	singleNoteButton.states = [["perc"]];
	singleNoteButton.action = {
		if(modeButton.value==1, {
			percussiveOut = Synth("percussiveOut", [\inbus, sndBus, \att, att, \rel, rel, \amp, ampBus.asMap], addAction: \addToTail);
			"bang!".postln});
	};

	// Attack and Release controls for percussive notes
	attackSlider = EZSlider(
		parent: subwin,
		bounds: Rect(left: 80, top: 15, width: 460, height: 30),
		label: "Attack",
		controlSpec: ControlSpec(0.01, 4.0, \exp, 0.001, 0.1, "sec"),
		action: {|ez| att = ez.value},
		initVal: 0.01,
		unitWidth: 30)
	.setColors(
		stringColor: Color.black,
		sliderBackground: Color.grey(0.7),
		numNormalColor: Color.black);

	releaseSlider = EZSlider(
		parent: subwin,
		bounds: Rect(80, 55, 460, 30),
		label: "Release",
		controlSpec: ControlSpec(0.3, 5, \exp, 0.01, 2, "sec"),
		action: {|ez| rel = ez.value},
		initVal: 2,
		unitWidth: 30)
	.setColors(
		stringColor: Color.black,
		sliderBackground: Color.grey(0.7),
		numNormalColor: Color.black);

	// Routine to add SynthDefs, wait for Server reply, then start Synths
	{
		SynthDef("additive-multislider", {
			arg outbus, freq = 440, amp = 0.01;
			var snd = SinOsc.ar(freq, 0, Lag.kr(amp, 3));
			Out.ar(outbus, snd!2);
		}).add;

		SynthDef("continuousOut", {
			arg inbus, amp = 0.1, gate = 1, att = 0.1, sus = 1, rel = 1;
			var env = EnvGen.kr(Env.asr(att, sus, rel), gate);
			Out.ar(0, In.ar(inbus, 2) * amp * env * 0.05);
		}).add;

		SynthDef("percussiveOut", {
			arg inbus, amp = 0.1, att = 0.01, rel = 2;
			var env = EnvGen.kr(Env.perc(att, rel), doneAction: 2);
			Out.ar(0, In.ar(inbus, 2) * amp * env * 0.05);
		}).add;

		// Wait for SynthDefs to be added...
		s.sync;

		// Now call the Synths:
		spectrum = Array.fill(numharm, {arg i; Synth("additive-multislider", [\freq, fundamental * (i+1), \amp, 0.0, \outbus, sndBus])});

		continuousOut = Synth("continuousOut", [\inbus, sndBus, \amp, ampBus.asMap], addAction: \addToTail);

	}.fork;

	s.meter;
	"Additive Synthesis Demo 2".postln;
	"".postln;

}); // end of block.
