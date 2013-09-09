// ************************************
// Frequency Modulation (GUI)
// Patch 1 - Simple Demo
// Bruno Ruviaro, 2013-08-03
// ************************************

/*

Simple interface to experiment with basic frequency modulation.
Frequency Modulation (FM): one oscillator controls the frequency of another.
Imagine a note the frequency of which goes up and down at a given speed. (= vibrato!)

Select all (ctrl + A), then evaluate (ctrl + period).
Watch the spectrum on the Frequency Analyzer window.

*/

s.waitForBoot({

	var win, carrFreqKnob, carrFreqNumber, carrFreqLabel, modFreqKnob, modFreqNumber, modFreqLabel, freqDevKnob, freqDevNumber, freqDevLabel, volumeSlider, defaultFont, defaultColor, defaultAlpha, defaultStringColor, carrSpec, modSpec, devSpec, synth;

	defaultFont = Font("Verdana", 16, bold: true);
	defaultColor = Color.red(0.8);
	defaultAlpha = 0.87;
	defaultStringColor = Color.white;

	// Main window
	Window.closeAll;
	FreqScope.new;
	win = Window.new("Frequency Modulation", Rect(20, 400, 820, 280));
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
	modFreqKnob = Knob.new(win, Rect(260, 20, 200, 200))
	.action = {arg v;
		var freq = modSpec.map(v.value);
		modFreqNumber.string = freq.round(0.1);
		synth.set(\modFreq, freq)};
	modFreqKnob.value = modSpec.unmap(modSpec.default);

	// Modulator Frequency Number
	modFreqNumber = StaticText.new(win, Rect(320, 210, 80, 25));
	modFreqNumber.background = defaultColor;
	modFreqNumber.alpha = defaultAlpha;
	modFreqNumber.align = \center;
	modFreqNumber.string = modSpec.default;
	modFreqNumber.font = defaultFont;
	modFreqNumber.stringColor = defaultStringColor;

	// Modulator Frequency Label
	modFreqLabel = StaticText.new(win, Rect(260, 240, 200, 25));
	modFreqLabel.string = "Modulator Frequency";
	modFreqLabel.align = \center;
	modFreqLabel.font = defaultFont;
	modFreqLabel.stringColor = defaultStringColor;

	// Frequency Deviation Knob
	devSpec = ControlSpec(1, 5000, 'exp', 0, 20, " Hz");
	freqDevKnob = Knob.new(win, Rect(500, 20, 200, 200))
	.action = {arg v;
		var freq = devSpec.map(v.value);
		freqDevNumber.string = freq.round;
		synth.set(\freqDev, freq)};
	freqDevKnob.value = devSpec.unmap(devSpec.default);

	// Frequency Deviation Number
	freqDevNumber = StaticText.new(win, Rect(560, 210, 80, 25));
	freqDevNumber.background = defaultColor;
	freqDevNumber.alpha = defaultAlpha;
	freqDevNumber.align = \center;
	freqDevNumber.string = devSpec.default;
	freqDevNumber.font = defaultFont;
	freqDevNumber.stringColor = defaultStringColor;

	// Frequency Deviation Label
	freqDevLabel = StaticText.new(win, Rect(500, 240, 200, 25));
	freqDevLabel.string = "Frequency Deviation";
	freqDevLabel.align = \center;
	freqDevLabel.font = defaultFont;
	freqDevLabel.stringColor = defaultStringColor;

	// Volume Slider
	volumeSlider = EZSlider(
		parent: win,
		bounds: Rect(730, 20, 70, 230),
		label: "VOLUME",
		controlSpec: ControlSpec(-40, 0, \lin, 0.1, -40, "dB"),
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
		SynthDef("freq-mod", {
			arg carrFreq = 440, modFreq = 5, freqDev = 20, amp = 0.01;
			var carrier, modulator;
			modulator = SinOsc.ar(freq: modFreq, mul: freqDev);
			carrier = SinOsc.ar(freq: carrFreq + modulator, mul: amp);
			Out.ar(0, [carrier, carrier]);
		}).add;

		s.sync;

		synth = Synth("freq-mod");

	}.fork;

	CmdPeriod.doOnce({win.close});

}); // end of waitForBoot