// ************************************
// Additive Synthesis Demo (GUI)
// Patch 3 - Inharmonic Partials
// Bruno Ruviaro, 2013-07-24
// ************************************

/*

2 button rows to play up to 16 inharmonic partials of a given fundamental frequency.

Horizontal Sliders control ADSR envelope, Global Volume, and Fundamental Frequency.

All partials have equal amplitude.

How to start: select all (ctrl + A), then evaluate (ctrl + enter)
(on a Mac, use command key instead of control key)

*/

s.waitForBoot({

	var win, buttonArray, knobArray, notesArray, partialArray, attackSlider, decaySlider, sustainSlider, releaseSlider, volumeSlider, fundamentalSlider, slidersWidth, fundamentalBus, updateButtonDisplay, att = 0.01, dec = 0.3, sus = 0.5, rel = 1.0, masterOut = 0.1;

	notesArray = Array.newClear(16);
	partialArray = Array.newClear(16);
	slidersWidth = 375;
	fundamentalBus = Bus.control(s, 1);
	fundamentalBus.set(110);

	Window.closeAll;

	s.meter;

	win = Window.new("Additive Synthesis - Inharmonics", Rect(500, 100, 800, 550)).front;
	win.background = Color.grey;
	win.alpha = 0.95;

	win.onClose = {s.freeAll; "Done!".postln};
	CmdPeriod.doOnce({win.close});

	// Change the gaps and margins to see how they work
	win.view.decorator = FlowLayout(win.view.bounds, margin: 10@10, gap: 20@20 );

	buttonArray = Array.fill(16, {Button(win.view, 80@80)});
	knobArray = Array.fill(16, {Knob(win.view, 80@50)});

	// Little function to update numbers displayed on buttons
	updateButtonDisplay = {arg button, index;
		var current = button.value;
		button.states = [
			[(partialArray[index]).asString, Color.black],
			[(partialArray[index]).asString, Color.black, Color.green]];
		button.value = current;
	};

	knobArray.do({arg item, count;
		knobArray[count].centered = true;
		knobArray[count].value = rrand(0.4, 0.6).round(0.01); // de-centered positions (center=0.5)
		knobArray[count].action = {arg knob;
			// update array of partials
			partialArray[count] = knob.value.linlin(0, 1, -0.2, 0.2).round(0.01) + count + 1;
			// update button display
			updateButtonDisplay.value(buttonArray[count], count);
			// if this partial is currently playing, update its partial number:
			if(notesArray[count].isNil.not,
				{notesArray[count].set(\partial, partialArray[count])})}});


	// Initialize array of partials with first knob values
	partialArray.do({arg item, count;
		partialArray[count] = knobArray[count].value.linlin(0, 1, -0.2, 0.2).round(0.01) + count + 1});
	// in the line above, "+ 0.5" adjusts for knob center = 0.5 (becomes center = 1);
	// this deviation value then is multiplied by the partial number

	// Initialize Buttons with proper number display
	buttonArray.do({arg item, count; updateButtonDisplay.value(item, count)});

	buttonArray.do({arg item, count;
		item.action = {arg state;
			case
			{state.value==1} {notesArray[count] = Synth("addsynth", [
				\fundamental, fundamentalBus.asMap,
				\partial, partialArray[count],
				\amp, 0.1,
				\att,  att,
				\dec,  dec,
				\sus,  sus,
				\rel,  rel])}
			{state.value==0} {notesArray[count].release; notesArray[count] = nil}
	}});

	attackSlider = EZSlider(
		parent: win,
		bounds: slidersWidth @ 30,
		label: "Attack",
		controlSpec: ControlSpec(0.01, 4.0, \lin, 0.01, 0.1, "sec"),
		action: {|ez|  att = ez.value},
		initVal: 0.01,
		unitWidth: 30)
	.setColors(
		stringColor: Color.black,
		sliderBackground: Color.grey(0.7),
		numNormalColor: Color.black);

	decaySlider = EZSlider(
		parent: win,
		bounds: slidersWidth @ 30,
		label: "Decay",
		controlSpec: ControlSpec(0.01, 1, \lin, 0.01, 0.1, "sec"),
		action: {|ez|  dec = ez.value},
		initVal: 0.3,
		unitWidth: 30)
	.setColors(
		stringColor: Color.black,
		sliderBackground: Color.grey(0.7),
		numNormalColor: Color.black);

	sustainSlider = EZSlider(
		parent: win,
		bounds: slidersWidth @ 30,
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
		bounds: slidersWidth @ 30,
		label: "Release",
		controlSpec: ControlSpec(0.3, 6, \lin, 0.1, 0.5, "sec"),
		action: {|ez|  rel = ez.value},
		initVal: 0.5,
		unitWidth: 30)
	.setColors(
		stringColor: Color.black,
		sliderBackground: Color.grey(0.7),
		numNormalColor: Color.black);

	volumeSlider = EZSlider(
		parent: win,
		bounds: slidersWidth*2.05 @ 30,
		label: "VOL",
		controlSpec: ControlSpec(1, 100, \lin, 1, 10, "%"),
		action: {|ez|  masterOut.set(\amp, ez.value/100)},
		initVal: 10,
		unitWidth: 30)
	.setColors(
		stringColor: Color.white,
		sliderBackground: Color.grey(0.9),
		numNormalColor: Color.grey);

	fundamentalSlider = EZSlider(
		parent: win,
		bounds: slidersWidth*2.05 @ 30,
		label: "FREQ",
		controlSpec: ControlSpec(50, 200, \lin, 1, 110, "Hz"),
		action: {|ez| fundamentalBus.set(ez.value)},
		initVal: 110,
		unitWidth: 30)
	.setColors(
		stringColor: Color.white,
		sliderBackground: Color.grey(0.9),
		numNormalColor: Color.grey);

	// SynthDefs

	{
		SynthDef("addsynth", {
			arg fundamental = 110, partial = 2.1, amp = 0.1, gate = 1, att = 0.01, dec = 0.3, sus = 0.5, rel = 1;
			var snd, env, freq;
			freq = fundamental * partial;
			env = EnvGen.ar(Env.adsr(att, dec, sus, rel), gate, doneAction: 2);
			snd = SinOsc.ar(Lag.kr(freq, 1), 0, amp) * env;
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

});