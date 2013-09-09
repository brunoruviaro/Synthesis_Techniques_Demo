// ************************************
// Frequency Modulation (GUI)
// Patch 2 - FM with Modulation Index
// Bruno Ruviaro, 2013-08-03
// ************************************

/*

Another interface to experiment with frequency modulation, now using Modulation Index. The Modulation Index is arguably a more musical way to control FM. This index I is defined as:

I = D/M

Modulation Index (I) is the ratio of Frequency Deviation (D) to Modulation Frequency (M).
Index is zero = no modulation.
Index is small = little audible FM.
Index gets higher = the more complex the spectrum.

Select all (ctrl + A), then evaluate (ctrl + period).
Watch the spectrum on the Frequency Analyzer window.

*/

s.waitForBoot({

	var win, carrFreqKnob, carrFreqNumber, carrFreqLabel, modFreqKnob, modFreqNumber, modFreqLabel, freqDevKnob, freqDevNumber, freqDevLabel, modIndexKnob, modIndexNumber, modIndexLabel, volumeSlider, defaultFont, defaultColor, defaultAlpha, defaultStringColor, carrSpec, modSpec, devSpec, indexSpec, synth;

	defaultFont = Font("Verdana", 16, bold: true);
	defaultColor = Color.red(0.8);
	defaultAlpha = 0.87;
	defaultStringColor = Color.white;

	// Main window
	Window.closeAll;
	FreqScope.new;
	win = Window.new("Frequency Modulation", Rect(20, 400, 1020, 280));
	win.onClose = {s.freeAll; Window.closeAll; "Frequency Modulation window closed.".postln; "".postln};
	win.front;
	win.background = defaultColor;
	win.alpha = defaultAlpha;

	// Carrier Frequency Knob
	carrSpec = ControlSpec(20, 20000, 'exp', 0, 440, " Hz");
	carrFreqKnob = Knob.new(win, Rect(20, 20, 200, 200))
	.action = {arg v;
		var freq = carrSpec.map(v.value);
		carrFreqNumber.string = freq.round;
		synth.set(\carrFreq, freq)};
	carrFreqKnob.value = carrSpec.unmap(carrSpec.default);

	// Carrier Frequency Number
	carrFreqNumber = StaticText.new(win, Rect(80, 210, 80, 25));
	carrFreqNumber.background = defaultColor;
	carrFreqNumber.alpha = defaultAlpha;
	carrFreqNumber.align = \center;
	carrFreqNumber.string = carrSpec.default;
	carrFreqNumber.font = defaultFont;
	carrFreqNumber.stringColor = defaultStringColor;

	// Carrier Frequency Label
	carrFreqLabel = StaticText.new(win, Rect(20, 240, 200, 25));
	carrFreqLabel.string = "Carrier Frequency";
	carrFreqLabel.align = \center;
	carrFreqLabel.font = defaultFont;
	carrFreqLabel.stringColor = defaultStringColor;

	// Modulator Frequency Knob
	modSpec = ControlSpec(0.5, 5000, 'exp', 0, 5, " Hz");
	modFreqKnob = Knob.new(win, Rect(250, 20, 200, 200))
	.action = {arg v;
		// first update modFreq gui and use it for synth
		var modFreq, freqDev, modIndex;
		modFreq = modSpec.map(v.value);
		modFreqNumber.string = modFreq.round(0.1);
		synth.set(\modFreq, modFreq);
		// now update freqDev gui
		modIndex = indexSpec.map(modIndexKnob.value);
		freqDev = modIndex * modFreq;
		freqDevNumber.string = freqDev.round;
	};
	modFreqKnob.value = modSpec.unmap(modSpec.default);

	// Modulator Frequency Number
	modFreqNumber = StaticText.new(win, Rect(310, 210, 80, 25));
	modFreqNumber.background = defaultColor;
	modFreqNumber.alpha = defaultAlpha;
	modFreqNumber.align = \center;
	modFreqNumber.string = modSpec.default;
	modFreqNumber.font = defaultFont;
	modFreqNumber.stringColor = defaultStringColor;

	// Modulator Frequency Label
	modFreqLabel = StaticText.new(win, Rect(250, 240, 200, 25));
	modFreqLabel.string = "Modulator Frequency";
	modFreqLabel.align = \center;
	modFreqLabel.font = defaultFont;
	modFreqLabel.stringColor = defaultStringColor;

	/* Frequency Deviation Knob
	devSpec = ControlSpec(1, 5000, 'exp', 0, 20, " Hz");
	freqDevKnob = Knob.new(win, Rect(480, 20, 200, 200))
	.action = {"do nothing".postln;/*arg v;
		var freq = devSpec.map(v.value);
		freqDevNumber.string = freq.round;
		synth.set(\freqDev, freq)*/};
	freqDevKnob.value = devSpec.unmap(devSpec.default);
	*/

	// Frequency Deviation Number
	freqDevNumber = StaticText.new(win, Rect(510, 100, 130, 55));
	freqDevNumber.background = defaultColor;
	freqDevNumber.alpha = defaultAlpha;
	freqDevNumber.align = \center;
	freqDevNumber.string = 0; // initial value
	freqDevNumber.font = Font("Verdana", 36, bold: true);
	freqDevNumber.stringColor = Color.red(0.5);

	// Frequency Deviation Label
	freqDevLabel = StaticText.new(win, Rect(480, 240, 200, 25));
	freqDevLabel.string = "Frequency Deviation";
	freqDevLabel.align = \center;
	freqDevLabel.font = defaultFont;
	freqDevLabel.stringColor = Color.red(0.5);

	// Modulation Index Knob
	indexSpec = ControlSpec(0, 10, 'lin', 0, 0, "modIndex");
	modIndexKnob = Knob.new(win, Rect(710, 20, 200, 200))
	.action = {arg v;
		var modIndex, modFreq, freqDev;
		// update index gui, use it for synth
		modIndex = indexSpec.map(v.value);
		modIndexNumber.string = modIndex.round(0.01);
		synth.set(\modIndex, modIndex);
		// now update freqDev gui
		modFreq = modSpec.map(modFreqKnob.value);
		freqDev = modIndex * modFreq;
		freqDevNumber.string = freqDev.round;
	};
	modIndexKnob.value = indexSpec.unmap(indexSpec.default);

	// Modulation Index Number
	modIndexNumber = StaticText.new(win, Rect(770, 210, 80, 25));
	modIndexNumber.background = defaultColor;
	modIndexNumber.alpha = defaultAlpha;
	modIndexNumber.align = \center;
	modIndexNumber.string = indexSpec.default;
	modIndexNumber.font = defaultFont;
	modIndexNumber.stringColor = defaultStringColor;

	// Modulation Index Label
	modIndexLabel = StaticText.new(win, Rect(710, 240, 200, 25));
	modIndexLabel.string = "Modulation Index";
	modIndexLabel.align = \center;
	modIndexLabel.font = defaultFont;
	modIndexLabel.stringColor = defaultStringColor;

	// Volume Slider
	volumeSlider = EZSlider(
		parent: win,
		bounds: Rect(930, 20, 70, 230),
		label: "VOLUME",
		controlSpec: ControlSpec(-40, 0, \lin, 0.1, -36, "dB"),
		action: {|ez| synth.set(\amp, ez.value.dbamp)},
		labelWidth: 80,
		unitWidth: 30,
		layout: 'vert')
	.setColors(
		stringColor: defaultStringColor,
		sliderBackground: Color.grey(0.9),
		numNormalColor: Color.black)
	.font = Font("Verdana", 14, bold: true);

	volumeSlider.numberView.align = \center;
	volumeSlider.unitView.align = \center;

	{
		SynthDef("freq-mod-by-index", {
			arg carrFreq = 440, modFreq = 5, modIndex = 0, amp = 0.015;
			var carrier, modulator, freqDev;
			// from formula i = freqDev/modfreq:
			freqDev = modIndex * modFreq;
			modulator = SinOsc.ar(freq: modFreq, mul: freqDev);
			carrier = SinOsc.ar(freq: carrFreq + modulator, mul: amp);
			Out.ar(0, [carrier, carrier]);
		}).add;

		s.sync;

		synth = Synth("freq-mod-by-index");

	}.fork;

	CmdPeriod.doOnce({win.close});

}); // end of waitForBoot