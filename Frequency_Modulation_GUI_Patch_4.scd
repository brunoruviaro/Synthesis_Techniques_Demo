// ************************************
// Frequency Modulation Fun (GUI)
// Patch 4 - Using Frequency Ratio
// Bruno Ruviaro, 2013-08-12
// ************************************

/*

Experiment with frequency modulation by specifying
contours for Carrier Frequency, Modulation Index,
and Amplitude Envelope. Also adjust duration of events.
In this version you don't specify Modulator Frequency
directly, but rather you specify the Frequency Ratio:

// freqRatio = carrFreq / modFreq

For example, for carrFreq = 440 Hz and // freqRatio = 2,
then modFreq will be set to 220 Hz. Integer freqRatio
values will give you harmonic spectra; Non-integer

Select all (ctrl + A), then evaluate (ctrl + period).

*/

s.waitForBoot({


	// Envs
	var ampEnv, carrFreqEnv, modIndexEnv;
	// EnvelopeViews
	var evCarrFreq, evModIndex, evAmp;
	// Sliders
	var volumeSlider, durationSlider, freqRatioSliderA, freqRatioSliderB, carrFreqSlider, modIndexSlider;
	// StaticTexts for Frequency Ratio
	var freqRatioDisplay, freqRatioDisplaySimplified;
	// Frequency Ratio variables
	var freqRatioA, freqRatioB, freqRatio;
	// Custom functions
	var scaleEnv, updateDisplay, findSimplestRatio, adjustEnv, printEnvData;
	// Miscellaneous variables
	var numberOfPoints, timeScale, win, subwin, font, labelColor, windowColor, presetArray, presetButtons, masterOut;

	/*
	, , , , , , , , , , freqRatioDisplayAnumber, freqRatioDisplayBnumber, , , , , ;
	*/

	///////////////////////////
	// Various initializations
	///////////////////////////

	timeScale = 3; // total duration of a "note"
	numberOfPoints = 8; // how many points in the breakpoint envelopes
	presetArray = Array.newClear(12); // number of presets
	freqRatioA = 2; // first number for big display A:B
	freqRatioB = 1; // second number for big display A:B
	freqRatio = freqRatioA / freqRatioB; // for actual Synth call
	font = Font("Verdana", 16, bold: true);
	labelColor = Color.white;
	windowColor = Color.grey(0.3);

	/////////////////////////
	// Initialize Envelopes
	/////////////////////////

	carrFreqEnv = Env.new(
		levels: {1.0.rand}!numberOfPoints,
		times: ({1.0.rand}!(numberOfPoints-1)).normalizeSum
	);

	modIndexEnv = Env.new(
		levels: {1.0.rand}!numberOfPoints,
		times: ({1.0.rand}!(numberOfPoints-1)).normalizeSum
	);

	ampEnv = Env.new(
		// using 'put' to make sure first and last are 0.0
		levels: ({1.0.rand}!numberOfPoints).put(0, 0).put(numberOfPoints-1, 0),
		times: ({1.0.rand}!(numberOfPoints-1)).normalizeSum
	);

	//////////////////////
	// Initialize Windows
	//////////////////////

	Window.closeAll;

	win = Window.new("Frequency Modulation Fun with Frequency Ratio", Rect(50, 50, 915, 400), resizable: false);
	win.front;
	win.background = windowColor;
	win.alpha = 0.95;

	// What to do on close (or ctrl+period)
	win.onClose = {s.freeAll};
	CmdPeriod.doOnce({Window.closeAll});

	subwin = FlowView.new(
		parent: win,
		bounds: Rect(710, 230, 185, 150),
		margin: 10@10,
		gap: 10@10;
	);

	///////////////////////////////
	// EnvelopeViews (3)
	///////////////////////////////

	evCarrFreq = EnvelopeView(win, Rect(40, 20, 300, 150))
	// .thumbWidth_(30.0)
	// .thumbHeight_(15.0)
	.setEnv(carrFreqEnv)
	.drawLines_(true)
	.selectionColor_(Color.red)
	.drawRects_(true)
	.step_(0.01)
	.keepHorizontalOrder_(true)
	.action_({arg b;
		// ["GOT IT", b.value].postln;
		// evCarrFreq.setString(0, 100.rand.asString);
		carrFreqEnv.levels = b.value[1];
		carrFreqEnv.times = b.value[0].differentiate.drop(1);
		scaleEnv.value(carrFreqEnv, 50, 1000);
	})
	.thumbSize_(18);

	evModIndex = EnvelopeView(win, Rect(40, 210, 300, 150))
	.setEnv(modIndexEnv)
	.drawLines_(true)
	.selectionColor_(Color.red)
	.drawRects_(true)
	.step_(0.01)
	.keepHorizontalOrder_(true)
	.action_({arg b;
		modIndexEnv.levels = b.value[1];
		modIndexEnv.times = b.value[0].differentiate.drop(1);
		scaleEnv.value(modIndexEnv, 0, 10);
	})
	.thumbSize_(18);

	evAmp = EnvelopeView(win, Rect(360, 210, 320, 150))
	.setEnv(ampEnv)
	.drawLines_(true)
	.selectionColor_(Color.red)
	.drawRects_(true)
	.step_(0.01)
	.keepHorizontalOrder_(true)
	.action_({arg b;
		ampEnv.levels = b.value[1];
		ampEnv.times = b.value[0].differentiate.drop(1);
		ampEnv.duration_(timeScale);
	})
	.thumbSize_(18);

	///////////////////////////////
	// Sliders (6)
	///////////////////////////////

	// carrFreq
	carrFreqSlider = Slider(win, Rect(20, 21, 20, 148))
	.action_({arg slider;
		var v = slider.value;
		carrFreqEnv = Env.new(
			levels: v!numberOfPoints, // straight line
			times: (0.1!(numberOfPoints-1)).normalizeSum);
		evCarrFreq.setEnv(carrFreqEnv);
		evCarrFreq.action.value(evCarrFreq); // does all the stuff
	});

	// modIndex
	modIndexSlider = Slider(win, Rect(20, 210, 20, 148))
	.action_({arg slider;
		var v = slider.value;
		modIndexEnv = Env.new(
			levels: v!numberOfPoints, // straight line
			times: (0.1!(numberOfPoints-1)).normalizeSum);
		evModIndex.setEnv(modIndexEnv);
		evModIndex.action.value(evModIndex); // does all the stuff
	});

	// freqRatio A
	freqRatioSliderA = Slider(win, Rect(360, 21, 40, 148))
	.action_({arg slider;
		var a = (slider.value*8+1).round(1).asInteger; // integers only
		freqRatioA = a;
		freqRatio = freqRatioA / freqRatioB;
		updateDisplay.value;
	});

	// freqRatio B
	freqRatioSliderB = Slider(win, Rect(640, 21, 40, 148))
	.action_({arg slider;
		var b = (slider.value*9+0.1).round(0.1); // may have decimals
		freqRatioB = b;
		freqRatio = freqRatioA / freqRatioB;
		updateDisplay.value;
	});

	// master volume
	volumeSlider = EZSlider(
		parent: win,
		bounds: Rect(830, 10, 50, 170),
		label: "volume",
		controlSpec: ControlSpec(-60, 0, \lin, 1, -40, "dB"),
		action: {|ez| masterOut.set(\amp, ez.value.dbamp)},
		unitWidth: 30,
		labelWidth: 80,
		layout: 'vert')
	.setColors(
		stringColor: labelColor,
		numNormalColor: Color.black);

	volumeSlider.numberView.align = \center;
	volumeSlider.unitView.align = \center;

	// duration
	durationSlider = EZSlider(
		parent: win,
		bounds: Rect(665, 184, 240, 40),
		label: "dur",
		controlSpec: ControlSpec(1, 13, \lin, 0.1, timeScale, "sec"),
		action: {|ez|
			timeScale = ez.value;
			evCarrFreq.action.value(evCarrFreq);
			evModIndex.action.value(evModIndex);
			evAmp.action.value(evAmp)},
		numberWidth: 35,
		unitWidth: 30,
		layout: 'horz')
	.setColors(
		stringColor: labelColor,
		numNormalColor: Color.black);

	durationSlider.numberView.align = \center;


	///////////////////////////////
	// Static Texts (4)
	///////////////////////////////

	// freqRatio Big Display
	freqRatioDisplay = StaticText(win, Rect(400, 20, 240, 140))
	// .background_(Color.blue)
	.string_(freqRatioA.asString ++ ":" ++ freqRatioB.asString)
	.font_(Font("Verdana", 80))
	.align_(\center)
	.stringColor = Color.grey;

	// freqRatio Small Display (simplest ratio equivalence)
	freqRatioDisplaySimplified = StaticText(win, Rect(400, 140, 240, 20))
	// .background_(Color.blue)
	.string_(" ") // display empty at initialization
	.font_(Font("Verdana", 18))
	.align_(\center)
	.stringColor = Color.grey;

	// Unnamed StaticTexts (labels)
	StaticText(win, Rect(20, 165, 200, 40))
	.string_("Carrier Frequency")
	.font_(font)
	.stringColor = labelColor;
	StaticText(win, Rect(445, 160, 250, 40))
	.string_("Frequency Ratio")
	.font_(font)
	.stringColor = labelColor;
	StaticText(win, Rect(20, 355, 250, 40))
	.string_("Modulation Index")
	.font_(font)
	.stringColor = labelColor;
	StaticText(win, Rect(360, 355, 250, 40))
	.string_("Amplitude Envelope")
	.font_(font)
	.stringColor = labelColor;

	///////////////////////////////
	// Buttons (14)
	///////////////////////////////

	// Play
	Button(win, Rect(710, 21, 100, 147))
	.states_([["PLAY", Color.black]])
	.action_({
		// All Envs arrive here already scaled (levels and times)!
		// Custom function "scaleEnv" is used elsewhere every time
		// a change is made (EnvViews or Sliders).
		Synth.new("freq-mod-with-envs", [
			\carrFreqEnv, carrFreqEnv,
			\freqRatio, freqRatio,
			\modIndexEnv, modIndexEnv,
			\ampEnv, ampEnv
		]);
	})
	.font_(Font("Verdana", 20));

	// 12 Presets
	presetButtons = Array.fill(12, {arg i;
		Button(subwin, 30@30)
		.states_([[i.asString]])
		.action_({presetArray[i].value; "Preset % recalled".postf(i); "".postln});
	});

	// Print current settings
	Button(subwin, 150@20)
	.states_([["print current settings"]])
	.action_({
		"**************************".postln;
		"**************************".postln;
		"To save the settings below as a Preset,".postln;
		"copy all lines and paste them into".postln;
		"one of the existing preset functions".postln;
		"For instance,".postln;
		"".postln;
		"presetArray[9] = { <copy settings here> };".postln;
		"".postln;
		"**************************".postln;
		printEnvData.value;
		"**************************".postln;
	});


	//////////////////////////////////////////
	// Custom functions
	//////////////////////////////////////////

	// This simple custom function just scales an Envelope
	// to desired ranges (levels, times) so that it is
	// ready to go when a Synth uses them.
	scaleEnv = {arg thisEnv, minVal, maxVal;

		thisEnv.levels = thisEnv.levels.linlin(0, 1, minVal, maxVal);
		thisEnv.duration_(timeScale);
		thisEnv.duration_(timeScale);
		// "scaling done!".postln;
	};

	// Ugly...
	adjustEnv = {arg anEnv, inMin = 50, inMax = 1000;
		var anotherEnv = Env.newClear(numberOfPoints);
		anotherEnv.levels = anEnv.levels.linlin(inMin, inMax, 0, 1);
		anotherEnv.times = anEnv.times;
	};

	// Find simplest ratio (for display purposes only).
	// Returns a String to be used directly in freqRatioDisplaySimplified
	findSimplestRatio = {arg a, b;

		var test = b.round(0.1).frac;
		var results;

		case

		// b is integer
		{test==0.0} {
			var gcd = gcd(a.asInteger, b.asInteger);
			// if already at simplest possible integer ratio,
			// display nothing;
			// else, display simplest integer ratio
			if(gcd==1,
				{" "},
				{
					results = [a, b] / gcd;
					results[0].asString ++ ":" ++ results[1].asString
				}
			);
		}

		// b is x.5
		{test==0.5} {
			a = a * 2;
			b = b * 2;
			// from above, e.g., 2:1.5 (a:b) becomes 4:3, etc.
			results = [a, b] / gcd(a.asInteger, b.asInteger);
			results[0].asString ++ ":" ++ results[1].asString;
		}

		// b is non-Integer and non x.5, no simplest ratio available
		{true} {" "};
	};

	updateDisplay = {

		freqRatioDisplay.string = freqRatioA.asString ++ ":" ++ freqRatioB.asString;
		freqRatioDisplaySimplified.string = findSimplestRatio.value(freqRatioA, freqRatioB);

	};

	//
	// Initialize very first envelope views (at time of first eval)
	//

	evCarrFreq.action.value(evCarrFreq);
	evModIndex.action.value(evModIndex);
	evAmp.action.value(evAmp);


	////////////////
	// SynthDefs
	////////////////

	{

		SynthDef("freq-mod-with-envs", {arg freqRatio;

			var carrFreq, carrFreqEnv, carrFreqCtl, modFreq, modFreqEnv, modFreqCtl, modIndex, modIndexEnv, modIndexCtl, carrier, modulator, amp, ampEnv, ampCtl;

			// Note: variable 'numberOfPoints' is
			// defined at very beginning of the page.

			carrFreqEnv = Env.newClear(numberOfPoints);
			carrFreqCtl = \carrFreqEnv.kr(carrFreqEnv.asArray);
			carrFreq = EnvGen.kr(carrFreqCtl);

			// A:B = carrFreq:modFreq, thus carrFreq = modFreq * B/A
			modFreq = carrFreq * freqRatio.reciprocal;

			modIndexEnv = Env.newClear(numberOfPoints);
			modIndexCtl = \modIndexEnv.kr(modIndexEnv.asArray);
			modIndex = EnvGen.kr(modIndexCtl);

			ampEnv = Env.newClear(numberOfPoints);
			ampCtl = \ampEnv.kr(ampEnv.asArray);
			amp = EnvGen.kr(ampCtl, doneAction: 2);

			modulator = SinOsc.ar(freq: modFreq, mul: modIndex * modFreq);
			carrier = SinOsc.ar(freq: carrFreq + modulator, mul: amp);

			Out.ar(0, [carrier, carrier]);

		}).add;


		SynthDef(\amp, {arg inbus=0, amp = 0.1;
			ReplaceOut.ar(inbus, In.ar(inbus, 2) * amp);
		}).add;

		// Wait for SynthDefs to be added...
		s.sync;

		// Now call the Master Out Synth:
		masterOut = Synth("amp", [\amp, volumeSlider.value.dbamp], addAction: \addToTail);

	}.fork;


	///////////////////////////
	//////// 12 PRESETS ///////
	///////////////////////////

	presetArray[0] = {

		carrFreqEnv = Env.new([ 715, 715, 715, 715, 715, 715, 715, 715 ],[ 0.294, 0.315, 0.294, 0.294, 0.294, 0.315, 0.294 ]);
		modIndexEnv = Env.new([ 3.7, 3.5, 3.2, 3.1, 2.8, 2.4, 2, 0 ],[ 0.21, 0.252, 0.252, 0.294, 0.231, 0.546, 0.315 ]);
		ampEnv = Env.new([ 0, 0.02, 0.08, 0.2, 0.31, 0.57, 0.97, 0 ],[ 0.588, 0.441, 0.462, 0.294, 0.105, 0.147, 0.063 ]);
		freqRatio = 2/3;
		freqRatioSliderA.valueAction = 0.15873015873016;
		freqRatioSliderB.valueAction = 0.32539682539683;
		evCarrFreq.setEnv(adjustEnv.value(carrFreqEnv));
		evModIndex.setEnv(adjustEnv.value(modIndexEnv, 0, 10));
		evAmp.setEnv(ampEnv);
		timeScale = 2.1;
		durationSlider.value = 2.1;

	};

	presetArray[1] = {

		carrFreqEnv = Env.new([ 905, 905, 905, 905, 905, 905, 905, 905 ],[ 0.294, 0.315, 0.294, 0.294, 0.294, 0.315, 0.294 ]);
		modIndexEnv = Env.new([ 3.7, 3.5, 3.2, 3.1, 2.8, 2.4, 2, 0 ],[ 0.21, 0.252, 0.252, 0.294, 0.231, 0.546, 0.315 ]);
		ampEnv = Env.new([ 0, 1, 0.58, 0.31, 0.18, 0.09, 0.05, 0 ],[ 0.042, 0.084, 0.231, 0.315, 0.462, 0.504, 0.462 ]);
		freqRatio = 2/6.4;
		freqRatioSliderA.valueAction = 0.15873015873016;
		freqRatioSliderB.valueAction = 0.6984126984127;
		evCarrFreq.setEnv(adjustEnv.value(carrFreqEnv));
		evModIndex.setEnv(adjustEnv.value(modIndexEnv, 0, 10));
		evAmp.setEnv(ampEnv);
		timeScale = 2.1;
		durationSlider.value = 2.1;


	};

	presetArray[2] = {

		carrFreqEnv = Env.new([ 145, 145, 145, 145, 145, 145, 145, 145 ],[ 0.224, 0.24, 0.224, 0.224, 0.224, 0.24, 0.224 ]);
		modIndexEnv = Env.new([ 3.7, 3.7, 3.7, 3.7, 3.7, 3.7, 3.7, 3.7 ],[ 0.224, 0.24, 0.224, 0.224, 0.224, 0.24, 0.224 ]);
		ampEnv = Env.new([ 0, 1, 0.76, 0.47, 0.29, 0.2, 0.09, 0 ],[ 0, 0.112, 0.24, 0.352, 0.304, 0.256, 0.336 ]);
		freqRatio = 2/5;
		freqRatioSliderA.valueAction = 0.16666666666667;
		freqRatioSliderB.valueAction = 0.54761904761905;
		evCarrFreq.setEnv(adjustEnv.value(carrFreqEnv));
		evModIndex.setEnv(adjustEnv.value(modIndexEnv, 0, 10));
		evAmp.setEnv(ampEnv);
		timeScale = 1.6;
		durationSlider.value = 1.6;

	};

	presetArray[3] = {

		carrFreqEnv = Env.new([ 145, 145, 145, 145, 145, 145, 145, 145 ],[ 0.224, 0.24, 0.224, 0.224, 0.224, 0.24, 0.224 ]);
		modIndexEnv = Env.new([ 3.7, 3.7, 3.7, 3.7, 3.7, 3.7, 3.7, 3.7 ],[ 0.224, 0.24, 0.224, 0.224, 0.224, 0.24, 0.224 ]);
		ampEnv = Env.new([ 0, 1, 0.76, 0.47, 0.29, 0.2, 0.09, 0 ],[ 0, 0.112, 0.24, 0.352, 0.304, 0.256, 0.336 ]);
		freqRatio = 1/1;
		freqRatioSliderA.valueAction = 0.047619047619048;
		freqRatioSliderB.valueAction = 0.1031746031746;
		evCarrFreq.setEnv(adjustEnv.value(carrFreqEnv));
		evModIndex.setEnv(adjustEnv.value(modIndexEnv, 0, 10));
		evAmp.setEnv(ampEnv);
		timeScale = 1.6;
		durationSlider.value = 1.6;

	};

	presetArray[4] = {

		carrFreqEnv = Env.new([ 724.5, 724.5, 724.5, 724.5, 724.5, 724.5, 724.5, 724.5 ],[ 0.224, 0.24, 0.224, 0.224, 0.224, 0.24, 0.224 ]);
		modIndexEnv = Env.new([ 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6 ],[ 0.224, 0.24, 0.224, 0.224, 0.224, 0.24, 0.224 ]);
		ampEnv = Env.new([ 0, 0.98, 1, 0.67, 0.38, 0.18, 0.08, 0 ],[ 0, 0.16, 0.24, 0.4, 0.208, 0.224, 0.368 ]);
		freqRatio = 3/2;
		freqRatioSliderA.valueAction = 0.3015873015873;
		freqRatioSliderB.valueAction = 0.20634920634921;
		evCarrFreq.setEnv(adjustEnv.value(carrFreqEnv));
		evModIndex.setEnv(adjustEnv.value(modIndexEnv, 0, 10));
		evAmp.setEnv(ampEnv);
		timeScale = 1.6;
		durationSlider.value = 1.6;


	};

	presetArray[5] = {

		carrFreqEnv = Env.new([ 724.5, 724.5, 724.5, 724.5, 724.5, 724.5, 724.5, 724.5 ],[ 0.224, 0.24, 0.224, 0.224, 0.224, 0.24, 0.224 ]);
		modIndexEnv = Env.new([ 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6 ],[ 0.224, 0.24, 0.224, 0.224, 0.224, 0.24, 0.224 ]);
		ampEnv = Env.new([ 0, 0.98, 1, 0.67, 0.38, 0.18, 0.08, 0 ],[ 0, 0.16, 0.24, 0.4, 0.208, 0.224, 0.368 ]);
		freqRatio = 1/2;
		freqRatioSliderA.valueAction = 0.0079365079365079;
		freqRatioSliderB.valueAction = 0.20634920634921;
		evCarrFreq.setEnv(adjustEnv.value(carrFreqEnv));
		evModIndex.setEnv(adjustEnv.value(modIndexEnv, 0, 10));
		evAmp.setEnv(ampEnv);
		timeScale = 1.6;
		durationSlider.value = 1.6;

	};

	presetArray[6] = {

		carrFreqEnv = Env.new([ 724.5, 724.5, 724.5, 724.5, 724.5, 724.5, 724.5, 724.5 ],[ 0.224, 0.24, 0.224, 0.224, 0.224, 0.24, 0.224 ]);
		modIndexEnv = Env.new([ 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6 ],[ 0.224, 0.24, 0.224, 0.224, 0.224, 0.24, 0.224 ]);
		ampEnv = Env.new([ 0, 0.98, 1, 0.67, 0.38, 0.18, 0.08, 0 ],[ 0, 0.16, 0.24, 0.4, 0.208, 0.224, 0.368 ]);
		freqRatio = 1/3;
		freqRatioSliderA.valueAction = 0.0079365079365079;
		freqRatioSliderB.valueAction = 0.32539682539683;
		evCarrFreq.setEnv(adjustEnv.value(carrFreqEnv));
		evModIndex.setEnv(adjustEnv.value(modIndexEnv, 0, 10));
		evAmp.setEnv(ampEnv);
		timeScale = 1.6;
		durationSlider.value = 1.6;

	};

	presetArray[7] = {

		carrFreqEnv = Env.new([ 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000 ],[ 0.308, 0.33, 0.308, 0.308, 0.308, 0.33, 0.308 ]);
		modIndexEnv = Env.new([ 3.6, 3.6, 3.6, 3.6, 3.6, 3.6, 3.6, 3.6 ],[ 0.308, 0.33, 0.308, 0.308, 0.308, 0.33, 0.308 ]);
		ampEnv = Env.new([ 0, 1, 1, 0.76, 0.38, 0.18, 0.08, 0 ],[ 0, 0.22, 0.528, 0.352, 0.286, 0.308, 0.506 ]);
		freqRatio = 2/1.2;
		freqRatioSliderA.valueAction = 0.12698412698413;
		freqRatioSliderB.valueAction = 0.11904761904762;
		evCarrFreq.setEnv(adjustEnv.value(carrFreqEnv));
		evModIndex.setEnv(adjustEnv.value(modIndexEnv, 0, 10));
		evAmp.setEnv(ampEnv);
		timeScale = 2.2;
		durationSlider.value = 2.2;

	};

	presetArray[8] = {

		carrFreqEnv = Env.new([ 411, 392, 335, 354, 335, 392, 373, 449 ],[ 0.60618556701031, 0.51958762886598, 0.64948453608247, 0.64948453608247, 0.64948453608247, 0.56288659793814, 0.56288659793814 ]);
		modIndexEnv = Env.new([ 0, 0.8, 2.1, 2.3, 3.4, 6, 5.9, 0 ],[ 0.59393939393939, 0.76363636363636, 1.0606060606061, 0.50909090909091, 0.38181818181818, 0.63636363636364, 0.25454545454545 ]);
		ampEnv = Env.new([ 0, 0.71, 0.74, 0.74, 0.84, 0.75, 0.35, 0 ],[ 0.756, 0.714, 0.63, 0.294, 0.42, 0.378, 1.008 ]);
		freqRatio = 7/3;
		freqRatioSliderA.valueAction = 0.76984126984127;
		freqRatioSliderB.valueAction = 0.32539682539683;
		evCarrFreq.setEnv(adjustEnv.value(carrFreqEnv));
		evModIndex.setEnv(adjustEnv.value(modIndexEnv, 0, 10));
		evAmp.setEnv(ampEnv);
		timeScale = 4.2;
		durationSlider.value = 4.2;


	};

	presetArray[9] = {

		carrFreqEnv = Env.new([ 648.5, 601, 667.5, 620, 667.5, 629.5, 648.5, 648.5 ],[ 0.08, 0.06, 0.06, 0.07, 0.08, 0.51, 0.14 ]);
		modIndexEnv = Env.new([ 10, 10, 10, 9.7, 10, 10, 3.8, 0 ],[ 0.13, 0.09, 0.12, 0.16, 0.19, 0.09, 0.22 ]);
		ampEnv = Env.new([ 0, 0.73, 0.7, 0.57, 0.48, 0.21, 0.8, 0 ],[ 0.03, 0.21, 0.18, 0.18, 0.05, 0.22, 0.13 ]);
		freqRatio = 8/3;
		freqRatioSliderA.valueAction = 0.83333333333333;
		freqRatioSliderB.valueAction = 0.32539682539683;
		evCarrFreq.setEnv(adjustEnv.value(carrFreqEnv));
		evModIndex.setEnv(adjustEnv.value(modIndexEnv, 0, 10));
		evAmp.setEnv(ampEnv);
		timeScale = 1;
		durationSlider.value = 1;

	};

	presetArray[10] = {

		carrFreqEnv = Env.new([ 800.5, 800.5, 800.5, 800.5, 800.5, 800.5, 800.5, 800.5 ],[ 0.14, 0.15, 0.14, 0.14, 0.14, 0.15, 0.14 ]);
		modIndexEnv = Env.new([ 5.1, 4.9, 3.9, 3.6, 3.7, 2.6, 1.2, 1.2 ],[ 0.05, 0.08, 0.09, 0.07, 0.21, 0.33, 0.17 ]);
		ampEnv = Env.new([ 0, 0.82, 0.7, 0.57, 0.48, 0.41, 0.32, 0 ],[ 0.02, 0.22, 0.18, 0.18, 0.12, 0.14, 0.14 ]);
		freqRatio = 3/2;
		freqRatioSliderA.valueAction = 0.23809523809524;
		freqRatioSliderB.valueAction = 0.20634920634921;
		evCarrFreq.setEnv(adjustEnv.value(carrFreqEnv));
		evModIndex.setEnv(adjustEnv.value(modIndexEnv, 0, 10));
		evAmp.setEnv(ampEnv);
		timeScale = 1;
		durationSlider.value = 1;

	};

	presetArray[11] = {

		carrFreqEnv = Env.new([ 506, 211.5, 287.5, 990.5, 990.5, 933.5, 192.5, 50 ],[ 0.69, 0.48, 0.3, 0.18, 0.27, 0.63, 0.45 ]);
		modIndexEnv = Env.new([ 6.6, 1.9, 7.4, 2.9, 0.5, 2.4, 1.2, 1.2 ],[ 0.66, 0.18, 0.54, 0.09, 0.54, 0.48, 0.51 ]);
		ampEnv = Env.new([ 0, 0.94, 0.93, 1, 1, 0.84, 0.71, 0 ],[ 0.27, 0.54, 0.66, 0.84, 0.24, 0.27, 0.18 ]);
		freqRatio = 6/1;
		freqRatioSliderA.valueAction = 0.57142857142857;
		freqRatioSliderB.valueAction = 0.095238095238095;
		evCarrFreq.setEnv(adjustEnv.value(carrFreqEnv));
		evModIndex.setEnv(adjustEnv.value(modIndexEnv, 0, 10));
		evAmp.setEnv(ampEnv);
		timeScale = 3;
		durationSlider.value = 3;

	};

	/////////////////////////////////////////////
	// Function: "Print Current Settings" ///////
	/////////////////////////////////////////////

	printEnvData = {

		("carrFreqEnv = Env.new(" ++ carrFreqEnv.levels ++ "," ++ carrFreqEnv.times ++ ");").postln;

		("modIndexEnv = Env.new(" ++ modIndexEnv.levels ++ "," ++ modIndexEnv.times ++ ");").postln;

		("ampEnv = Env.new(" ++ ampEnv.levels ++ "," ++ ampEnv.times ++ ");").postln;

		("freqRatio = " ++ freqRatioA ++ "/" ++ freqRatioB ++ ";").postln;

		("freqRatioSliderA.valueAction = " ++ freqRatioSliderA.value ++ ";").postln;

		("freqRatioSliderB.valueAction = " ++ freqRatioSliderB.value ++ ";").postln;

		"evCarrFreq.setEnv(adjustEnv.value(carrFreqEnv));".postln;

		"evModIndex.setEnv(adjustEnv.value(modIndexEnv, 0, 10));".postln;

		"evAmp.setEnv(ampEnv);".postln;

		("timeScale = " ++ timeScale ++ ";").postln;

		("durationSlider.value = " ++ timeScale ++ ";").postln;

	};


}); // end of block
