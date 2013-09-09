// ************************************
// Subtractive Synthesis Demo (GUI)
// Patch 1 - Filtering a noise source
// Bruno Ruviaro, 2013-07-26
// ************************************

/*

Use the 2D slider to choose filter frequency (x-axis) and filter rq (y-axis). Use the menu to choose noise source: Pink Noise, White Noise, Gray Noise, Brown Noise, or Clip Noise.

Watch the Frequency Analyzer window to see how the spectrum changes.

*/

s.waitForBoot({
	var noise, win, slider2d, menu, controlX, controlY, volumeSlider, button;
	noise = {arg whichNoise = 0, whichFilter = 0, amp = 0.06, ffreq = 1000, rq = 0.8;
		var snd;
		amp = Lag.kr(amp, 1);
		snd = Select.ar(
			which: whichNoise,
			array: [
				PinkNoise.ar(amp),
				WhiteNoise.ar(amp * 0.6),
				GrayNoise.ar(amp * 0.7),
				BrownNoise.ar(amp),
				ClipNoise.ar(amp * 0.5)]);
		snd = Select.ar(
			which: whichFilter,
			array: [
				BPF.ar(snd, ffreq, rq),
				BRF.ar(snd, ffreq, rq)]);
		Out.ar(0, [snd, snd]);
	}.play;

	win = Window(
		name: "Subtractive Synthesis - Patch 1",
		bounds: Rect(300, 100, 600, 560));
	win.background = Color.black;

	// Slider
	controlX = ControlSpec(
		minval: 100,
		maxval: 10000,
		warp: \exp,
		step: 0.1);
	controlY = ControlSpec(
		minval: 1.0,
		maxval: 0.001,
		warp: \exp,
		step: 0.001);
	slider2d = Slider2D(win, Rect(10, 10, 580, 500));
	slider2d.x = controlX.unmap(1000);
	slider2d.y = controlY.unmap(0.5);
	slider2d.background = Color.new255(255, 102, 255);
	slider2d.knobColor = Color.black;
	slider2d.action = {|slider|
		noise.set(
			\ffreq, controlX.map(slider.x),
			\rq, controlY.map(slider.y))};

	// Noise Source menu
	menu = PopUpMenu(win, Rect(10, 520, 120, 30));
	menu.items = ["Pink Noise", "White Noise", "Gray Noise", "Brown Noise", "Clip Noise"];
	menu.action = {arg menu;
		noise.set(\whichNoise, menu.value);
		case
		{menu.value==0} {slider2d.background = Color.new255(255, 102, 255)}
		{menu.value==1} {slider2d.background = Color.new255(255, 255, 255)}
		{menu.value==2} {slider2d.background = Color.new255(192, 192, 192)}
		{menu.value==3} {slider2d.background = Color.new255(139, 69, 19)}
		{menu.value==4} {slider2d.background = Color.new255(0, 0, 0)}};

	// Filter Type button
	button = Button(win, Rect(140, 520, 40, 30));
	button.states = [["BPF", Color.white, Color.black], ["BRF", Color.white, Color.red]];
	button.action = {arg button;
		if(button.value==0,
			{
				noise.set(\whichFilter, 0);
				slider2d.knobColor = Color.black;
			},
			{
				volumeSlider.valueAction = -24;
				SystemClock.sched(0.5, {noise.set(\whichFilter, 1)});
				slider2d.knobColor = Color.red;
			});
	};

	// Volume slider
	volumeSlider = EZSlider(
		parent: win,
		bounds: Rect(190, 520, 390, 30),
		label: "VOLUME",
		controlSpec: ControlSpec(-60, 0, \lin, 0.1, -24, "dB"),
		action: {|ez| noise.set(\amp, ez.value.dbamp)},
		initVal: -24)
	.setColors(
		stringColor: Color.white,
		sliderBackground: Color.grey(0.9),
		numNormalColor: Color.black);

	FreqScope.new;
	win.front;
	CmdPeriod.doOnce({Window.closeAll});
	win.onClose = {s.freeAll; Window.closeAll};

}); // end of block