// ************************************
// Ring Modulation (GUI)
// Patch 1 - Basic Demo
// Bruno Ruviaro, 2013-08-02
// ************************************

/*

Simple interface to experiment with with Ring Modulation.
Ring Modulation is the multiplication of two bipolar signals (Carrier and Modulator) by one another. It is a type of Amplitude Modulation.
A bipolar signal outputs values between -1 and +1. The resulting spectrum contains the sum and the difference of C and M frequencies.
Watch the spectrum on the Frequency Analyzer window.

How to start:
Select all (ctrl + A), then evaluate (ctrl + period).


*/

s.waitForBoot({

	var win, carrFreqKnob, carrFreqNumber, carrFreqLabel, modFreqKnob, modFreqNumber, modFreqLabel, volumeSlider, defaultFont, carrSpec, modSpec, synth, carrMenu;

	defaultFont = Font("Verdana", 16, bold: true);

	// Main window
	Window.closeAll;

	win = Window.new("Ring Modulation", Rect(20, 400, 610, 280));
	win.onClose = {s.freeAll; Window.closeAll; "Ring Modulation window closed.".postln; "".postln};
	win.background = Color.yellow(0.8);
	win.alpha = 0.9;
	FreqScope.new;
	win.front;

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
	carrFreqNumber.background = Color.yellow(0.8);
	carrFreqNumber.alpha = 0.9;
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
	modFreqNumber.background = Color.yellow(0.8);
	modFreqNumber.alpha = 0.9;
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
		bounds: Rect(510, 20, 70, 200),
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

	// Menu
	carrMenu = PopUpMenu(win, Rect(510, 230, 70, 30));
	carrMenu.items = ["Sine", "Blip", "Saw"];
	carrMenu.background = Color.white;
	carrMenu.font = Font("Verdana", 13, bold: true);
	carrMenu.action = {arg menu; synth.set(\which, menu.value)};

	{
		SynthDef("ring-mod", {arg carrFreq = 440, modFreq = 2, amp = 0.06, which = 0;
			var carrier, modulator;
			carrier = Select.ar(which,
				[
					SinOsc.ar(Lag.kr(carrFreq)),
					Blip.ar(Lag.kr(carrFreq), 5),
					Saw.ar(Lag.kr(carrFreq))
			]);
			modulator = SinOsc.ar(Lag.kr(modFreq));
			Out.ar(0, carrier * modulator * amp);
		}).add;

		s.sync;

		synth = Synth("ring-mod");

	}.fork;

	CmdPeriod.doOnce({win.close});

}); // end of waitForBoot