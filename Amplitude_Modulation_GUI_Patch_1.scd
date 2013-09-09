// ************************************
// Amplitude Modulation (GUI)
// Patch 1 - Basic Demo
// Bruno Ruviaro, 2013-08-02
// ************************************

/*

Very simple interface to play with basic amplitude modulation.
Amplitude Modulation (AM): one oscillator controls the amplitude of another.
Imagine a note the amplitude of which goes up and down at a given speed.

Select all (ctrl + A), then evaluate (ctrl + period).
Watch the spectrum on the Frequency Analyzer window.

*/

s.waitForBoot({

	var win, carrFreqKnob, carrFreqNumber, carrFreqLabel, modFreqKnob, modFreqNumber, modFreqLabel, volumeSlider, defaultFont, carrSpec, modSpec, synth;

	defaultFont = Font("Verdana", 16, bold: true);

	// Main window
	Window.closeAll;
	FreqScope.new;
	win = Window.new("Amplitude Modulation", Rect(20, 400, 610, 280));
	win.onClose = {s.freeAll; Window.closeAll; "Amplitude Modulation window closed.".postln; "".postln};
	win.front;
	win.background = Color.grey;
	win.alpha = 0.95;

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
	carrFreqNumber.background = Color.grey;
	carrFreqNumber.alpha = 0.95;
	carrFreqNumber.align = \center;
	carrFreqNumber.string = 440;
	carrFreqNumber.font = defaultFont;

	// Carrier Frequency Label
	carrFreqLabel = StaticText.new(win, Rect(20, 240, 200, 25));
	carrFreqLabel.string = "Carrier Frequency";
	carrFreqLabel.align = \center;
	carrFreqLabel.font = defaultFont;

	// Modulator Frequency Knob
	modSpec = ControlSpec(0.5, 5000, 'exp', 0, 2, " Hz");
	modFreqKnob = Knob.new(win, Rect(260, 20, 200, 200))
	.action = {arg v;
		var freq = modSpec.map(v.value);
		modFreqNumber.string = freq.round(0.1);
		synth.set(\modFreq, freq)};
	modFreqKnob.value = modSpec.unmap(modSpec.default);

	// Modulator Frequency Number
	modFreqNumber = StaticText.new(win, Rect(320, 210, 80, 25));
	modFreqNumber.background = Color.grey;
	modFreqNumber.alpha = 0.95;
	modFreqNumber.align = \center;
	modFreqNumber.string = 2;
	modFreqNumber.font = defaultFont;

	// Modulator Frequency Label
	modFreqLabel = StaticText.new(win, Rect(260, 240, 200, 25));
	modFreqLabel.string = "Modulator Frequency";
	modFreqLabel.align = \center;
	modFreqLabel.font = defaultFont;

	// Volume Slider
	volumeSlider = EZSlider(
		parent: win,
		bounds: Rect(510, 20, 70, 230),
		label: "VOLUME",
		controlSpec: ControlSpec(-40, 0, \lin, 0.1, -24, "dB"),
		action: {|ez| synth.set(\amp, ez.value.dbamp)},
		labelWidth: 80,
		unitWidth: 30,
		layout: 'vert')
	.setColors(
		stringColor: Color.black,
		sliderBackground: Color.grey(0.9),
		numNormalColor: Color.black)
	.font = Font("Verdana", 14, bold: true);

	volumeSlider.numberView.align = \center;
	volumeSlider.unitView.align = \center;

	{
		SynthDef("amp-mod", {arg carrFreq = 440, modFreq = 2, amp = 0.06;
			var carrier, modulator;
			carrier = SinOsc.ar(carrFreq);
			modulator = SinOsc.ar(modFreq).range(0, 0.8);
			Out.ar(0, carrier * modulator * amp);
		}).add;

		s.sync;

		synth = Synth("amp-mod");

	}.fork;

	CmdPeriod.doOnce({win.close});

}); // end of waitForBoot