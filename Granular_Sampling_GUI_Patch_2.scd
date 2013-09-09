// ************************************
// Granular Synthesis Demo (GUI)
// Patch 2 - Granular Sampling with Multiple Files
// Bruno Ruviaro, 2013-08-21
// ************************************

/*

Use the "add files" button to load several wave or aif files.
This granulator needs mono files. If you open a stereo file,
only the left channel will be actually used.

Transp: rate of transposition in semitones.
Duration: duration of individual samples (sequential: "one sample every X seconds").
Pan: distribution of samples in the stereo field (left / right).
Amplitude: amplitude of individual samples.
Reverse: probability of a sample to be played backwards (0-100%).
Rests: probability of rests to occur (0-100%).
Overlap: smaller numbers are more 'staccato', bigger numbers more 'legato'.

Samples will be chosen randomly from any of the loaded sound files.

How to start: select all (ctrl + A), then evaluate (ctrl + enter).
(on a Mac, use the command key instead of control)

*/

s.waitForBoot({

	var win, subwin, openButton, startButton, durSlider, transpSlider, ampSlider, panSlider, restSlider, reverseSlider, overlapSlider, displayFileName, transpToRate, bufferList, staticTextList, rateLo, rateHi, durLo, durHi, panLo, panHi, ampLo, ampHi, restProb, reverseProb, overlap, pattern, player;

	// Init values
	rateLo = 1; rateHi = 1;
	durLo = 0.1; durHi = 0.2;
	panLo = 0; panHi = 0;
	ampLo = 0.3; ampHi = 0.4;
	restProb = 0.1;
	overlap = 1;
	reverseProb = 0;

	Window.closeAll;


	staticTextList = List.new;

	// Main window
	win = Window.new("Granular Sampling - Sequential, Multiple Files", Rect(50, 50, 600, 560), false).front;
	win.background = Color.grey(0.1, 0.9);
	win.onClose = { player.stop };


	// Sub view to group all sliders
	subwin = CompositeView.new(win, Rect(20, 220, 560, 325))
	// .background_(Color.red(0.4))
	;
	subwin.decorator = FlowLayout(subwin.bounds, margin: 0@0, gap: 5@10);

	// FUNCTIONS

	// Convert transpSlider values (in semitones)
	// to rate values for TGrains (1 = no transp):
	transpToRate = {arg transp; transp.linexp(-24, 24, 0.25, 4)};

	// Display file names on random places on window
	displayFileName = {arg fileName;
		var left, top, width, height;
		width = 150;
		height = 30;
		left = rrand(0, win.bounds.width-width);
		top = rrand(0, 220-height);

		staticTextList.add(
			StaticText.new(win, Rect(left, top, width, height))
			.string_(fileName.asString)
			.stringColor_(Color.gray);
		);

		openButton.front;
	};


	openButton = Button.new(win, Rect(240, 90, 120, 30))
	.states_([["add files", Color.black, Color.gray]])
	.action_({
		// Stop player if it's running:
		if(player.isNil, {"do nothing"}, { player.stop; player = nil; });
		// Let user select files:
		Dialog.openPanel(
			okFunc: {arg pathList;
				pathList.do({arg path;
					bufferList.add(Buffer.readChannel(s, path, channels: [0]));
					displayFileName.value(path.split.last);
				});
			},
			cancelFunc: { "cancelled".postln },
			multipleSelection: true);
	});


	transpSlider = EZRanger(
		parent: subwin,
		bounds: 560@30,
		label: "Transp  ",
		controlSpec: ControlSpec(
			minval:	-24, // two octaves below
			maxval: 24, // two octaves above
			warp: 'lin',
			step: 1, // step by semitones
			units: " ST"),
		action: {arg v;
			rateLo = transpToRate.value(v.lo);
			rateHi = transpToRate.value(v.hi)
		},
		initVal: [0, 0],
		labelWidth: 60,
		unitWidth: 30)
	.setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey, Color.white, Color.yellow);

	durSlider = EZRanger(
		parent: subwin,
		bounds: 560@30,
		label: "Duration  ",
		controlSpec: ControlSpec(
			minval:	0.05,
			maxval: 2,
			warp: 'exp',
			step: 0.01,
			units: "sec"),
		action: {arg v;
			durLo = v.lo;
			durHi = v.hi;
		},
		initVal: [durLo, durHi],
		labelWidth: 70,
		unitWidth: 30)
	.setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey, Color.white, Color.yellow);

	panSlider = EZRanger(
		parent: subwin,
		bounds: 560@30,
		label: "Pan     ",
		controlSpec: ControlSpec(
			minval:	-1,
			maxval: 1,
			warp: 'lin',
			step: 0.1,
			units: "L/R"),
		action: {arg v;
			panLo = v.lo;
			panHi = v.hi;
		},
		initVal: [panLo, panHi],
		labelWidth: 60,
		unitWidth: 30)
	.setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey, Color.white, Color.yellow);


	ampSlider = EZRanger(
		parent: subwin,
		bounds: 560@30,
		label: "Amplitude ",
		controlSpec: ControlSpec(
			minval:	0.0,
			maxval: 1,
			warp: 'lin',
			step: 0.01,
			units: "amp"),
		action: {arg v;
			ampLo = v.lo;
			ampHi = v.hi;
		},
		initVal: [ampLo, ampHi],
		labelWidth: 78,
		unitWidth: 35)
	.setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey, Color.white, Color.yellow);


	reverseSlider = EZSlider(
		parent: subwin,
		bounds: 560@30,
		label: "Reverse ",
		controlSpec: ControlSpec(
			minval:	0,
			maxval: 100,
			warp: 'lin',
			step: 1,
			units: "%"),
		action: {arg v;
			reverseProb = v.value/100;
		},
		initVal: reverseProb,
		labelWidth: 60,
		unitWidth: 35)
	.setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey, Color.white, Color.yellow);

	restSlider = EZSlider(
		parent: subwin,
		bounds: 560@30,
		label: "Rests  ",
		controlSpec: ControlSpec(
			minval:	0,
			maxval: 100,
			warp: 'lin',
			step: 1,
			units: "%"),
		action: {arg v;
			restProb = v.value/100;
		},
		initVal: 0.0,
		labelWidth: 50,
		unitWidth: 35)
	.setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey, Color.white, Color.yellow);

	overlapSlider = EZSlider(
		parent: subwin,
		bounds: 560@30,
		label: "Overlap ",
		controlSpec: ControlSpec(
			minval:	0.1,
			maxval: 2,
			warp: 'lin',
			step: 0.1),
		action: {arg v;
			overlap = v.value;
		},
		initVal: overlap,
		labelWidth: 63,
	/*unitWidth: 35*/)
	.setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey, Color.white, Color.yellow);


	// Start button
	startButton = Button.new(subwin, 560@50)
	.states_([["START", Color.black, Color.gray], ["STOP", Color.black, Color.gray]])
	.action_({arg button;
		if(button.value==1,
			{ player = pattern.play;
				("Now sampling from " ++ bufferList.size ++ " sound files").postln;
				/*bufferList.postln;
				[rateLo, rateHi].postln;
				[durLo, durHi].postln;
				[ampLo, ampHi].postln;
				"".postln;*/
			},
			{ player.stop; player = nil; });
	});

	/////////////////
	// SynthDef
	/////////////////

	SynthDef("grain-asr", {arg bufnum, rate = 1, reverse = 1, startPos = 0, gate = 1, att = 0.1, rel = 0.1, amp = 1, pan = 0;
		var env, snd;
		env = EnvGen.kr(Env.asr(att, amp, rel), gate, doneAction: 2);
		snd = PlayBuf.ar(1, bufnum, rate: rate * reverse, startPos: startPos);
		snd = snd * env;
		Out.ar(0, Pan2.ar(snd, pan));
	}).add;

	// Buffer list

	bufferList = List.newClear(1); // Prand won't like if initial list is empty

	// Pattern

	pattern = Pbind(
		\instrument, "grain-asr",
		\buffer, Prand(bufferList, inf),
		\bufnum, Pfunc({arg evt; evt.at(\buffer).bufnum}),
		\startPos, Pwhite(0, Pfunc({arg evt; evt.at(\buffer).numFrames})),
		\dur, Pwhite(Pfunc({durLo}), Pfunc({durHi})),
		\makeRest, Pif(Pfunc({ restProb.coin }), Rest, 709),
		\rate, Pwhite(Pfunc({rateLo}), Pfunc({rateHi})),
		\reverse, Pif(Pfunc({ reverseProb.coin }), -1, 1),
		\amp, Pwhite(Pfunc({ampLo}), Pfunc({ampHi})),
		\pan, Pwhite(Pfunc({panLo}), Pfunc({panHi})),
		\legato, Pfunc({overlap})
	);

	bufferList.pop; // remove 'nil', we only want actual buffers here

}); // end of block
