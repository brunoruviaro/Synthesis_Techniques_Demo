// ************************************
// Waveshaping Synthesis (GUI)
// Patch 1 - Visualization of the basic concept
// Bruno Ruviaro, 2013-08-14
// ************************************

/*

How to start:
Select all (ctrl + A), then evaluate (ctrl + period).

SINE WAVE INPUT:
Amplitude of input is a key parameter of waveshaping synthesis.
Higher amplitudes, more distortion of original shape.
Lower amplitudes, less distortion of original shape.

TRANSFER FUNCTION:
Choose the desired amount (amplitude) for each partial, between 0-1.

OUTPUT (examples):
Choose between continuous tone, two examples of short notes, and one pattern example (Pbind).
*/

s.waitForBoot({

	/////////////////
	// Variables
	/////////////////

	var updateSineView, pBindExample, player, continuous, continuousButton, applyChangesButton, distortionBus, updateCheby, harmonics;

	distortionBus = Bus.control(s, 1); // input amp goes into this Bus
	harmonics = Array.newClear(10); // store values from Number Boxes

	/////////////////
	// Main Window
	/////////////////

	Window.closeAll;

	f = FlowView.new(
		bounds: 580@600,
		margin: 10@10, gap: 10@10)
	.background_(Color.white);

	f.onClose = {s.freeAll; player.stop};
	CmdPeriod.doOnce({Window.closeAll});

	////////////////////
	// Input Row (GUI)
	////////////////////

	// Sub-FlowView
	g = FlowView.new(f, 310@160, margin: 10@10)
	.background_(Color.red(0.8, 0.6));

	// Label: Input (sine wave)
	StaticText.new(g, 150@30)
	.string_("INPUT (sine wave)")
	.align_(\top)
	.font_(Font("Verdana", 14, true));

	g.startRow;

	// EZNumber for amplitude
	o = EZNumber.new(
		parent: g,
		bounds: Rect(0, 0, 188, 80),
		label: " ",
		controlSpec: ControlSpec(0.0, 1.0, 'lin', 0.01),
		action: {arg box;
			updateSineView.value(box.value);
			distortionBus.value = box.value;
		},
		numberWidth: 90,
		initVal: 0.5)
	// unitWidth: 0)
	.font_(Font("Verdana", 30))
	.numberView.align_(\center);

	// Init distortionBus (corresponds to input amplitude box)
	distortionBus.value = 0.5;

	g.startRow;

	// Simple label for number box
	StaticText.new(g, g.bounds.width-20@20)
	.string_("amplitude")
	.align_(\center)
	.font_(Font("Verdana", 14));

	// Plotter for Sine Wave (Input GUI)
	x = CompositeView.new(f, Rect(0, 0, 240, 160));
	a = Plotter.new("Input", parent: x)
	.value_(Signal.sineFill(1000, [1]) * 0.5)
	.setProperties(
		\backgroundColor, Color.red(0.8, 0.6));
	a.minval = -1; a.maxval = 1;
	a.refresh;

	updateSineView = {arg amp;
		a.value = Signal.sineFill(1000, [1]) * amp;
		a.minval = -1;
		a.maxval = 1;
		a.refresh;
	};

	////////////////////////////////
	// Transfer Function Row (GUI)
	////////////////////////////////

	// Sub-FlowView
	h = FlowView.new(f, 560@150, margin: 10@10)
	.background_(Color.yellow(0.9, 0.5));

	// Label Chebyshev
	StaticText.new(h, 280@30)
	.string_("TRANSFER FUNCTION (Chebyshev)")
	.align_(\top)
	// .background_(Color.red)
	.font_(Font("Verdana", 14, true));

	h.startRow;

	// Array of number boxes
	c = Array.fill(10, {arg i;
		EZNumber.new(
			parent: h,
			bounds: 50@60,
			label: (i+1).asString ++ "f",
			controlSpec: ControlSpec(0, 1, 'lin', 0.1),
			action: {arg thisBox;
				harmonics = c.collect({arg item; item.value});
				applyChangesButton.states = [["apply changes", Color.red]];
				thisBox.setColors(numNormalColor: Color.red);
			},
			initVal: 1.0.rand.round(0.1),
			layout: 'line2')
		.font_(Font("Verdana", 18))
		.setColors()
		.numberView.align_(\center);
	});

	// At start up
	harmonics = c.collect({arg item; item.value});

	// Apply changes to Chebyshev function
	applyChangesButton = Button.new(
		parent: CompositeView(h, 580@40)/*.background_(Color.red)*/,
		bounds: Rect(0, 5, 535, 27))
	.states_([["apply changes", Color.grey(0.8)]])
	.action_({arg thisButton;
		applyChangesButton.states = [["apply changes", Color.gray(0.8)]];
		c.do({arg item; item.normalColor_(Color.black)});
		updateCheby.value(harmonics);
		// if continuous note is running, stop it and play a new one
		if(continuousButton.value==1,
					{
						continuous.release;
						continuous = Synth("shaper", [\transFunc, b, \att, 1, \dist, distortionBus.asMap]);},
					{/*do nothing*/});


			});

	////////////////////////////////
	// Playback Examples Row (GUI)
	////////////////////////////////

	i = FlowView.new(f, 300@250, margin: 10@10, gap: 15@15)
	.background_(Color.green(0.4, 0.5));

	// CompositeView for Stethoscope
	y = CompositeView.new(f, Rect(0, 0, 250, 250));
	// .background_(Color.yellow(0.5));

	// Label: Input (sine wave)
	StaticText.new(i, 160@30)
	.string_("OUTPUT (examples)")
	.align_(\top)
	.font_(Font("Verdana", 14, true));

	// Scope
	Stethoscope.new(s, view: y);

	// Scope Label (and hiding space for scope options)
	k = CompositeView.new(y, Rect(2, 0, 250, 25))
	.background_(Color.white);

	// Label: Input (sine wave)
	StaticText.new(k , 230@30)
	.string_("output waveform")
	.align_(\top)
	.font_(Font("Verdana", 14, true));

	i.startRow;

	// Buttons
	continuousButton = Button.new(i, 280@50)
	.states_([["Continuous"], ["Continuous", Color.white, Color.black]])
	.action_({arg button;
		if(button.value==1,
			{continuous = Synth("shaper", [\transFunc, b, \att, 1, \dist, distortionBus.asMap])},
			{continuous.release});
	});

	Button.new(i, 132@50)
	.states_([["Short Note 1"]])
	.action_({
		// Choose duration
		var shortNoteDur = rrand(0.8, 4);
		// Play note
		{var freq = rrand(100, 300);
			LeakDC.ar(Shaper.ar(
				bufnum: b,
				in: Splay.ar(
					SinOsc.ar(
						freq: [freq, freq*1.25, freq*1.4],
						mul: EnvGen.kr(Env.perc(0.01, shortNoteDur), doneAction: 2))
		)))}.play;
		// Display amplitude change in EZNumber box
		{
			100.do({arg i;
				{o.valueAction = i.linlin(0, 99, 1, 0).round(0.01)}.defer;
				(shortNoteDur/100).wait;
			})
		}.fork;
		// button.value.postln;
	});

		Button.new(i, 132@50)
	.states_([["Short Note 2"]])
	.action_({
		// Choose duration
		var shortNoteDur = rrand(0.5, 2);
		// Play note
		{var freq = rrand(60, 400);
			LeakDC.ar(Shaper.ar(
				bufnum: b,
				in: Splay.ar(
					SinOsc.ar(
						freq: [freq, freq*2, freq*4],
						mul: EnvGen.kr(Env.perc(0.01, shortNoteDur), doneAction: 2))
		)))}.play;
		// Display amplitude change in EZNumber box
		{
			100.do({arg i;
				{o.valueAction = i.linlin(0, 99, 1, 0).round(0.01)}.defer;
				(shortNoteDur/100).wait;
			})
		}.fork;
		// button.value.postln;
	});

	Button.new(i, 280@50)
	.states_([["Pbind"], ["Pbind", Color.white, Color.black]])
	.action_({arg button;
		if(button.value==1, {player = pBindExample.play}, {player.stop; player = nil});

	});

	////////////////////////////////
	// AUDIO ///////////////////////
	////////////////////////////////


	SynthDef("shaper", {
		arg freq = 440, gate = 1, amp = 0.6, dist = 0.4, transFunc, att = 0.1, sus = 1, rel = 1;
		var snd, env;
		env = EnvGen.kr(Env.asr(att, sus, rel), gate, doneAction: 2);
		snd = Shaper.ar(transFunc, SinOsc.ar(freq, 0, Lag.kr(dist)));
		snd = LeakDC.ar(snd * env * amp);
		Out.ar(0, snd!2);
	}).add;

	// Define function to update Cheby buffer
	updateCheby = {arg array;
		// Buffer.freeAll;
		b = Buffer.alloc(s, 1024, 1, { |buf| buf.chebyMsg(array) });
		"end".postln;
	};

	// Create first with start up values
	updateCheby.value(harmonics);

	pBindExample = Pbind(
		\instrument, "shaper",
		\scale, Scale.phrygian,
		\degree, Pseq([
			Ptuple([
				Pseq([5, 6, 5, 6, 8, 7, 6, 7], 4),
				Pseq([3, 4, 3, 5, 5, 5, 5, 4], 4),
				Pseq([0, 0, 0, 2, 3, 4, 3, 1], 4)
			], 1),
			Ptuple([
				Pseq([7, 8, 9, 10, 6, 7, 8, 9, 8, 8, 7, 6, 5, 4]),
				Pseq([3, 5, 4, 4, 3, 4, 5, 4, 3, 2, 3, 4, 5, 7]),
				Pseq([-7, -8, -8, -5, -4, -6, -8, -8, -10, -9, -11, -10, -9, -9])
			])
		], inf),
		\dur, Pseq([
			Pseq([0.15, 0.15, 0.25, 0.25, 0.15, 0.15, 0.25, 0.2], 4),
			Prand([0.3, 0.43, 0.383], 14)
		], inf),
		\legato, Pseq([Pseq([0.1], 32), Pseq([0.5], 14)], inf),
		\amp, 0.5,
		\dist, Pseq([0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8], inf),
		\transFunc, Pfunc({b});
	).collect({arg event; {o.valueAction_(event[\dist])}.defer; event});


}); // end of block
