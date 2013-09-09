// ************************************
// Additive Synthesis Demo (GUI)
// Patch 4 - Inharmonic Partials with Multislider
// Bruno Ruviaro, 2013-07-24
// ************************************

/*

Multislider interface to control up to 16 inharmonic partials of a timbre.

Two modes of play:

"Continuous Tone" - it simply plays a continuous tone as you change the spectrum.
"Percussive Tone" - you can play single percussive tones triggered with the 'perc' button, and control attack and decay values of these notes.

How to start: select all (ctrl + A), then evaluate (ctrl + enter).
(on a Mac, use the command key instead of control)

Click and drag on the big white rectangle to draw the spectrum.

*/

s.waitForBoot({

	var spectrum, numharm, win, continuousOut, percussiveOut, multiSlider, volumeSlider, fundamentalSlider, modeButton, singleNoteButton, attackSlider, releaseSlider, subwin, singleNoteRoutine, att = 0.01, rel = 2, ampBus, sndBus, fundamentalBus, knobArray, partialArray;

	numharm = 16;

	partialArray = Array.newClear(16);

	fundamentalBus = Bus.control(s, 1);
	fundamentalBus.set(110);

	ampBus = Bus.control(s);
	ampBus.value = 0.1;

	sndBus = Bus.audio(s, 2);

	// Main window
	Window.closeAll;
	win = Window.new("Additive Synthesis", Rect(400, 30, 660, 670));
	win.view.decorator = FlowLayout(win.view.bounds, 20@20, 10@10);
	win.front;

	win.onClose = {s.freeAll; "Done!".postln; "".postln};
	CmdPeriod.doOnce({win.close});

	// Multislider
	multiSlider = MultiSliderView(win, Rect(0, 0, 620, 250));
	multiSlider.value = Array.fill(numharm, {0.0});
	multiSlider.isFilled = true;
	multiSlider.indexThumbSize = 29.0;
	multiSlider.gap = 9;
	multiSlider.action = {multiSlider.value.do({arg value, count;
		spectrum[count].set(\amp, value)})};

	// Knob.new(win, Rect(20, 0, 30, 30));
	knobArray = Array.fill(16, {Knob(win, 29@29)});

	knobArray.do({arg item, count;
		knobArray[count].centered = true;
		knobArray[count].value = rrand(0.4, 0.6).round(0.01); // de-centered positions (center=0.5)
		knobArray[count].action = {arg knob;
			// update array of partials
			partialArray[count] = knob.value.linlin(0, 1, -0.2, 0.2).round(0.01) + count + 1;
			// if this partial is currently playing, update its partial number (thus freq):
			if(spectrum[count].isNil.not,
				{spectrum[count].set(\partial, partialArray[count])})}});


	// Initialize array of partials with first knob values
	partialArray.do({arg item, count;
		partialArray[count] = knobArray[count].value.linlin(0, 1, -0.2, 0.2).round(0.01) + count + 1});
	// in the line above, "+ 0.5" adjusts for knob center = 0.5 (becomes center = 1);
	// this deviation value then is multiplied by the partial number

	fundamentalSlider = EZSlider(
		parent: win,
		bounds: 620 @ 40,
		label: "FREQ",
		controlSpec: ControlSpec(50, 200, \lin, 1, 110, "Hz"),
		action: {|ez| fundamentalBus.set(ez.value)},
		initVal: 110,
		unitWidth: 30)
	.setColors(
		stringColor: Color.black,
		sliderBackground: Color.grey(0.9),
		numNormalColor: Color.black);

	// Volume slider
	volumeSlider = EZSlider(
		parent: win,
		bounds: 620 @ 40,
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
	modeButton = Button(win, 620 @110);
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
	subwin = CompositeView(win, 620@100);
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
		bounds: Rect(left: 80, top: 15, width: 530, height: 30),
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
		bounds: Rect(80, 55, 530, 30),
		label: "Release",
		controlSpec: ControlSpec(0.3, 10, \exp, 0.01, 2, "sec"),
		action: {|ez| rel = ez.value},
		initVal: 2,
		unitWidth: 30)
	.setColors(
		stringColor: Color.black,
		sliderBackground: Color.grey(0.7),
		numNormalColor: Color.black);

	// Routine to add SynthDefs, wait for Server reply, then start Synths
	{
		SynthDef("additive-multislider-2", {
			arg outbus, fundamental = 110, partial = 2.1, amp = 0.01;
			var snd = SinOsc.ar(fundamental * partial, 0, Lag.kr(amp, 3));
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
		spectrum = Array.fill(numharm, {arg i; Synth("additive-multislider-2", [\fundamental, fundamentalBus.asMap, \partial, partialArray[i], \amp, 0.0, \outbus, sndBus])});

		continuousOut = Synth("continuousOut", [\inbus, sndBus, \amp, ampBus.asMap], addAction: \addToTail);

	}.fork;

	partialArray.postln;

	s.meter;
	"Additive Synthesis Demo 2".postln;
	"".postln;

}); // end of block.
