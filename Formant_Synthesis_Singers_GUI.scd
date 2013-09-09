// ************************************
// Formant Synthesis Demo (GUI)
// Patch 1 - Singing vowels
// Bruno Ruviaro, 2013-08-29
// ************************************

/*
Four voice types available:
Soprano, Alto, Tenor, Bass (buttons SATB).

Two vibrato controls: speed and depth (horizontal sliders).

Fundamental frequency control (vertical slider).

Vowel control: choose a vowel for each corner of the 2D space (drop down menus).

How to start: select all (ctrl + A), then evaluate (ctrl + enter).
(on a Mac, use the command key instead of control)

*/

s.waitForBoot({

	var formantTable, win, subwin, slider2D, vowels, menu00, menu01, menu11, menu10, display00, display01, display11, display10, f00, f01, f11, f10, fxy, synth, startButton, buttonsSATB, selectedSATB, updateAll, freqSlider, fundamentalFrequency, vibratoSpeed, vibratoDepth, vibratoSpeedSlider, vibratoDepthSlider;

	// This was taken from FormantTable class from SC3plugins.
	// Hard-coded here so that this patch won't depend on SC3plugins.
	formantTable = IdentityDictionary.new;
	formantTable.put(\sopranoA, [[800, 1150, 2900, 3900, 4950], [0, -6, -32, -20, -50].dbamp, [80, 90, 120, 130, 140]]);
	formantTable.put(\sopranoE, [[350, 2000, 2800, 3600, 4950], [0, -20, -15, -40, -56].dbamp, [60, 100, 120, 150, 200]]);
	formantTable.put(\sopranoI, [[270, 2140, 2950, 3900, 4950], [0, -12, -26, -26, -44].dbamp, [60, 90, 100, 120, 120]]);
	formantTable.put(\sopranoO, [[450, 800, 2830, 3800, 4950], [0, -11, -22, -22, -50].dbamp, [70, 80 ,100, 130, 135]]);
	formantTable.put(\sopranoU, [[325, 700, 2700, 3800, 4950], [0, -16, -35, -40, -60].dbamp, [50, 60, 170, 180, 200]]);
	formantTable.put(\altoA, [[800, 1150, 2800, 3500, 4950], [0, -4, -20, -36, -60].dbamp, [80, 90, 120, 130, 140]]);
	formantTable.put(\altoE, [[400, 1600, 2700, 3300, 4950], [0, -24, -30, -35, -60].dbamp, [60, 80, 120, 150, 200]]);
	formantTable.put(\altoI, [[350, 1700, 2700, 3700, 4950], [0, -20, -30, -36, -60].dbamp, [50, 100, 120, 150, 200]]);
	formantTable.put(\altoO, [[450, 800, 2830, 3500, 4950], [0, -9, -16, -28, -55].dbamp, [70, 80, 100, 130, 135]]);
	formantTable.put(\altoU, [[325, 700, 2530, 3500, 4950], [0, -12, -30, -40, -64].dbamp, [50, 60, 170, 180, 200]]);
	formantTable.put(\counterTenorA, [[660, 1120, 2750, 3000, 3350], [0, -6, -23, -24, -38].dbamp, [80, 90, 120, 130, 140]]);
	formantTable.put(\counterTenorE, [[440, 1800, 2700, 3000, 3300], [0, -14, -18, -20, -20].dbamp, [70, 80, 100, 120, 120]]);
	formantTable.put(\counterTenorI, [[270, 1850, 2900, 3350, 3590], [0, -24, -24, -36, -36].dbamp, [40, 90, 100, 120, 120]]);
	formantTable.put(\counterTenorO, [[430, 820, 2700, 3000, 3300], [0, -10, -26, -22, -34].dbamp, [40, 80, 100, 120, 120]]);
	formantTable.put(\counterTenorU, [[370, 630, 2750, 3000, 3400], [0, -20, -23, -30, -34].dbamp, [40, 60, 100, 120, 120]]);
	formantTable.put(\tenorA, [[650, 1080, 2650, 2900, 3250], [0, -6, -7, -8, -22].dbamp, [80, 90, 120, 130, 140]]);
	formantTable.put(\tenorE, [[400, 1700, 2600, 3200, 3580], [0, -14, -12, -14, -20].dbamp, [70, 80, 100, 120, 120]]);
	formantTable.put(\tenorI, [[290, 1870, 2800, 3250, 3540], [0, -15, -18, -20, -30].dbamp, [40, 90, 100, 120, 120]]);
	formantTable.put(\tenorO, [[400, 800, 2600, 2800, 3000], [0, -10, -12, -12, -26].dbamp, [40, 80, 100, 120, 120]]);
	formantTable.put(\tenorU, [[350, 600, 2700, 2900, 3300], [0, -20, -17, -14, -26].dbamp, [40, 60, 100, 120, 120]]);
	formantTable.put(\bassA, [[600, 1040, 2250, 2450, 2750], [0, -7, -9, -9, -20].dbamp, [60, 70, 110, 120, 130]]);
	formantTable.put(\bassE, [[400, 1620, 2400, 2800, 3100], [0, -12, -9, -12, -18].dbamp, [40, 80, 100, 120, 120]]);
	formantTable.put(\bassI, [[250, 1750, 2600, 3050, 3340], [0, -30, -16, -22, -28].dbamp, [60, 90, 100, 120, 120]]);
	formantTable.put(\bassO, [[400, 750, 2400, 2600, 2900], [0, -11, -21, -20, -40].dbamp, [40, 80, 100, 120, 120]]);
	formantTable.put(\bassU, [[350, 600, 2400, 2675, 2950], [0, -20, -32, -28, -36].dbamp, [40, 80, 100, 120, 120]]);

	// convert bandwidth to 1/q
	formantTable.keysDo({ arg key;
		formantTable[key][0].do({ arg center, i;
			formantTable[key][2][i] = formantTable[key][2][i] / center;
		});
	});


	vowels = ["I", "E", "A", "O", "U"];
	fundamentalFrequency = 100;
	vibratoSpeed = 6;
	vibratoDepth = 7;

	// Interpolation between corners
	fxy = {arg x, y;

		3.collect({arg e;
			5.collect({arg i;
				( f00[e][i] * (1-x) * (1-y) ) +
				( f10[e][i] * x * (1-y) ) +
				( f01[e][i] * (1-x) * y ) +
				( f11[e][i] * x * y );
		})});
	};

	// Main Window
	Window.closeAll;
	win = Window("Formant Synthesis", Rect(150, 150, 500, 480)).front;
	win.onClose = {"done".postln};
	// win.background = Color.gray(0.87, 0.95);
	win.background = Color.new255(193, 98, 90, 235);

	// Slider2D
	slider2D = Slider2D(win, Rect(50, 40, 400, 400))
	.x_(0.5) // initial location of x
	.y_(0.5) // initial location of y
	.action_({arg sl;
		var interpol = fxy.value(sl.x, sl.y);
		if(synth.isNil.not,
			{ synth.set(
				\freqs, interpol[0],
				\amps, interpol[1],
				\qs, interpol[2]) },
			{ "not playing".postln });
	});

	// Vowel display (inside Slider2D)
	display00 = StaticText(win, Rect(65, 355, 50, 80))
	.font_(Font(size: 80))
	.stringColor_(Color.gray(0.8))
	.align_(\center)
	.string_("i");

	display01 = StaticText(win, Rect(60, 40, 60, 75))
	.font_(Font(size: 80))
	.stringColor_(Color.gray(0.8))
	.align_(\center)
	.string_("i");

	display11 = StaticText(win, Rect(380, 40, 50, 75))
	.font_(Font(size: 80))
	.stringColor_(Color.gray(0.8))
	.align_(\center)
	.string_("i");

	display10 = StaticText(win, Rect(380, 355, 50, 80))
	.font_(Font(size: 80))
	.stringColor_(Color.gray(0.8))
	.align_(\center)
	.string_("i");

	// Menus
	menu00 = PopUpMenu(win, Rect(10, 440, 40, 30))
	.items_(vowels)
	.action_({ |v|
		var key = (selectedSATB ++ v.item).asSymbol;
		f00 = formantTable.at(key);
		key.postln;
		f00.postln;
		display00.string = v.item.toLower;
	});

	menu01 = PopUpMenu(win, Rect(10, 10, 40, 30))
	.items_(vowels)
	.action_({ |v|
		var key = (selectedSATB ++ v.item).asSymbol;
		f01 = formantTable.at(key);
		key.postln;
		f01.postln;
		display01.string = v.item.toLower;
	});

	menu11 = PopUpMenu(win, Rect(450, 10, 40, 30))
	.items_(vowels)
	.action_({ |v|
		var key = (selectedSATB ++ v.item).asSymbol;
		f11 = formantTable.at(key);
		key.postln;
		f11.postln;
		display11.string = v.item.toLower;
	});

	menu10 = PopUpMenu(win, Rect(450, 440, 40, 30))
	.items_(vowels)
	.action_({ |v|
		var key = (selectedSATB ++ v.item).asSymbol;
		f10 = formantTable.at(key);
		key.postln;
		f10.postln;
		display10.string = v.item.toLower;
	});


	// Fundamental Frequency Slider
	freqSlider = EZSlider(
		parent: win,
		bounds: Rect(457, 100, 35, 290),
		label: "freq",
		controlSpec: ControlSpec(90, 880, 'exp', 1),
		action: {arg slider;
			fundamentalFrequency = slider.value;
			if(synth.isNil.not,
				{synth.set(\freq, fundamentalFrequency)})
		},
		initVal: fundamentalFrequency,
		layout: 'vert');

	// Vibrato Speed Slider
	vibratoSpeedSlider = EZSlider(
		parent: win,
		bounds: Rect(50, 10, 232, 20),
		label: "vibrato speed",
		controlSpec: ControlSpec(2, 9, 'lin', 1),
		action: {arg slider;
			vibratoSpeed = slider.value;
			if(synth.isNil.not,
				{synth.set(\vibratoSpeed, vibratoSpeed)})
		},
		initVal: vibratoSpeed,
		labelWidth: 100,
		numberWidth: 30);

	// Vibrato Depth Slider
	vibratoDepthSlider = EZSlider(
		parent: win,
		bounds: Rect(270, 10, 170, 20),
		label: "depth",
		controlSpec: ControlSpec(1, 12, 'lin', 1),
		action: {arg slider;
			vibratoDepth = slider.value;
			if(synth.isNil.not,
				{synth.set(\vibratoDepth, vibratoDepth)})
		},
		numberWidth: 30,
		initVal: vibratoDepth);


	// Function to use when a new SATB button
	// is clicked: update all four corners

	updateAll = {
		var f00key, f01key, f11key, f10key;
		f00key = (selectedSATB ++ menu00.item).asSymbol;
		f01key = (selectedSATB ++ menu01.item).asSymbol;
		f11key = (selectedSATB ++ menu11.item).asSymbol;
		f10key = (selectedSATB ++ menu10.item).asSymbol;
		f00 = formantTable.at(f00key);
		f01 = formantTable.at(f01key);
		f11 = formantTable.at(f11key);
		f10 = formantTable.at(f10key);
		[f00key, f01key, f11key, f10key].postln;
	};

	// Singer Buttons (will go inside a subview)
	subwin = CompositeView(win, Rect(8, 100, 40, 280));
	subwin.addFlowLayout(5@5, 5@5);

	buttonsSATB = Array.fill(4, {arg i;
		var satb = ["S", "A", "T", "B"];
		Button(subwin, 25@65)
		.states_([[satb[i]], [satb[i], Color.black, Color.gray]])
		.font_(Font(size: 20))
		.action_({arg button;
			if(button.value==1,
				{
					case
					{i==0} {
						selectedSATB = "soprano";
						buttonsSATB[[1,2,3]].do{|bt| bt.value=0};
						updateAll.value;
						freqSlider.valueAction_(580);
					}
					{i==1} {
						selectedSATB = "alto";
						buttonsSATB[[0,2,3]].do{|bt| bt.value=0};
						updateAll.value;
						freqSlider.valueAction_(380);
					}
					{i==2} {
						selectedSATB = "tenor";
						buttonsSATB[[0,1,3]].do{|bt| bt.value=0};
						updateAll.value;
						freqSlider.valueAction_(280);
					}
					{i==3} {
						selectedSATB = "bass";
						buttonsSATB[[0,1,2]].do{|bt| bt.value=0};
						updateAll.value;
						freqSlider.valueAction_(100);
					};

					selectedSATB.postln;
				},
				{("button " ++ i ++ " says goodbye").postln});

		});
	});

	// Button initialization
	buttonsSATB[3].valueAction = 1; // bass
	// Menus initialization
	menu00.valueAction = 0; // bassI
	menu01.valueAction = 1; // bassE
	menu11.valueAction = 2; // bassA
	menu10.valueAction = 3; // bassO

	// Start Button
	startButton = Button(win, Rect(200, 445, 100, 25))
	.states_([["start", Color.white, Color.green(0.6, 0.6)], ["stop", Color.white, Color.red(0.4, 0.3)]])
	.action_({arg button;
		if(button.value==1,
			{synth = Synth("formantVoice", [
				\freq, fundamentalFrequency,
				\vibratoSpeed, vibratoSpeed,
				\vibratoDepth, vibratoDepth])},
			{synth.release; synth = nil})
	});


	// SynthDef
	SynthDef("formantVoice", { arg
		freqs = #[ 400, 750, 2400, 2600, 2900 ],
		amps = #[ 1, 0.28, 0.08, 0.1, 0.01 ],
		qs = #[ 0.1, 0.1, 0.04, 0.04, 0.04 ],
		lag = 0.5,
		vibratoSpeed = 6,
		vibratoDepth = 4,
		freq = 220,
		gate = 1;

		var vibrato, in, env, snd;

		vibrato = SinOsc.kr(vibratoSpeed, mul: vibratoDepth);
		in = Saw.ar(Lag.kr(freq + vibrato, 0.2));
		env = EnvGen.kr(Env.asr(1), gate, doneAction: 2);
		snd = Mix.new(BBandPass.ar(in, Lag.kr(freqs, lag), Lag.kr(qs, lag)) * Lag.kr(amps, lag)).dup;

		Out.ar(0, snd * env);

	}).add;


}); // end of block;
