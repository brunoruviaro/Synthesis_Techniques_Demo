// ************************************
// Waveshaping Synthesis (GUI)
// Patch 1 - Visualization of the basic concept
// Bruno Ruviaro, 2013-08-14
// ************************************

/*

How to start:
Select all (ctrl + A), then evaluate (ctrl + period).

This is a simple interface to visualize relationship between:

- input waveform (a sine wave in this example)
- transfer function
- output waveform

Amplitude of input is a key parameter of waveshaping synthesis.
Higher amplitudes, more distortion of original shape.
Lower amplitudes, less distortion of original shape.
Use the amplitude slider to check this out.

You can assume that all x and y axes are -1 to +1.

How to understand what is going on:
For any given input value (i.e., a sample value taken from the y-axis of input), the waveshaper calculates an output sample by looking up the corresponding output value (y-axis) in the transfer function. So for example, if a given input sample is at +0.9 (y-axis), the waveshaper looks up +0.9 on the x-axis of the transfer function, finds a corresponding new value between -1/+1, and that becomes the output sample.

A linear transfer function (first preset) will cause the output to be exactly the same as the input.

Note: this patch makes no sound. It is just a visual demo.

*/

(

var size = 256, inputWaveform, transferFunction, updateOutput, currentScale = 1, windowColor, buttonArray, linearFunction, chebyFunction1, chebyFunction2;

//
// TRANSFER FUNCTIONS
//

// output same as input
linearFunction = Array.fill(size+1, { |i| i-1});
// even partials
chebyFunction1 = Signal.chebyFill(size+1, [0, 1, 0, 0, 0, 1]).linlin(-1, 1, 0, size).round;
// odd partials
chebyFunction2 = Signal.chebyFill(size+1, [1, 0, 1, 0, 1, 0]).linlin(-1, 1, 0, size).round;

//
// GUI WINDOW
//

Window.closeAll;

w = Window.new("Waveshaping Synthesis - visual demo", Rect(50, 50, 610, 640), false);
w.front;
windowColor = Color.white;
w.background = windowColor;

x = CompositeView.new(w, Rect(10, 10, 500, 200)).background_(windowColor);
y = CompositeView.new(w, Rect(10, 220, 500, 200)).background_(windowColor);
z = CompositeView.new(w, Rect(10, 430, 500, 200)).background_(windowColor);

a = Plotter.new("Input", parent: x);
b = Plotter.new("Transfer", parent: y);
c = Plotter.new("Output", parent: z);

StaticText(x, Rect(5, 0, 50, 20))
.string_("input");
StaticText(y, Rect(5, 0, 200, 20))
.string_("transfer function");
StaticText(z, Rect(5, 0, 50, 20))
.string_("output");

//
// FEEDING THE PLOTS
//

// Input
inputWaveform = Signal.sineFill(size, [1]).linlin(-1, 1, 1, size).round;
// Note: linlin above returns a simple Array, not a Signal
a.value = inputWaveform;
a.setProperties(\backgroundColor, Color.red(1, 0.5));
a.setProperties(\gridOnX, false);
a.setProperties(\gridOnY, false);
a.minval = 0; a.maxval = size;
a.refresh;

// Transfer Function
transferFunction = linearFunction.copy;
b.value = transferFunction;
b.setProperties(\backgroundColor, Color.yellow(1, 0.4));
b.setProperties(\gridOnX, false);
b.setProperties(\gridOnY, false);
b.minval = 0; b.maxval = size;
b.editMode = true;
b.editFunc = {
	c.value = updateOutput.value;
	buttonArray.do{|i| i.value=0};
};
b.refresh;

// Output
updateOutput = {
	Array.fill(size, { |i|
		var inputSample, outputSample;
		inputSample = a.value.round.at(i);
		outputSample = b.value.at(inputSample);
	});
};

c.value = updateOutput.value;
c.setProperties(\backgroundColor, Color.green(0.9, 0.4));
c.setProperties(\gridOnX, false);
c.setProperties(\gridOnY, false);
c.minval = 0; c.maxval = size;
c.refresh;

// Input Amplitude Slider
d = Slider(w, Rect(520, 10, 80, 200))
.value_(1)
.background_(Color.grey(0.9, 0.9))
.focusColor_(Color.red(1, 0.3))
.knobColor_(Color.red(1, 0.3))
.action_({arg slider;
	var scale, newMax, offset, scaledArray;
	scale = slider.value.round(0.01);
	// Ignore repeated values with if/else
	if(currentScale == scale,
		{/*[currentScale, scale, "do nothing"].postln*/},
		{
			newMax = size * scale;
			offset = (size - newMax) / 2;
			scaledArray = inputWaveform.linlin(0, size, 0, newMax) + offset;
			a.value = scaledArray;
			c.value = updateOutput.value;
			a.minval = 0; a.maxval = size; a.refresh;
			c.minval = 0; c.maxval = size; c.refresh;
			currentScale = scale;
	});
});

// Preset buttons
buttonArray = Array.newClear(3);

buttonArray[0] = Button(w, Rect(520, 220, 80, 60))
.states_([
	["linear", Color.black],
	["linear", Color.black, Color.grey(0.6)]])
.value_(1)
.action_({arg button;
	if(button.value==1, {
		transferFunction = linearFunction.copy;
		b.value = transferFunction;
		b.minval = 0; b.maxval = size;
		b.refresh;
		c.value = updateOutput.value;
		c.minval = 0; c.maxval = size; c.refresh;
		buttonArray[1].value = 0;
		buttonArray[2].value = 0;
	});
});

buttonArray[1] = Button(w, Rect(520, 290, 80, 60))
.states_([
	["cheby 1", Color.black],
	["cheby 1", Color.black, Color.grey(0.6)]])
.action_({arg button;
	if(button.value==1, {
		transferFunction = chebyFunction1.copy;
		b.value = transferFunction;
		b.minval = 0; b.maxval = size;
		b.refresh;
		c.value = updateOutput.value;
		c.minval = 0; c.maxval = size; c.refresh;
		buttonArray[0].value = 0;
		buttonArray[2].value = 0;
	});
});

buttonArray[2] = Button(w, Rect(520, 360, 80, 60))
.states_([
	["cheby 2", Color.black],
	["cheby 2", Color.black, Color.grey(0.6)]])
.action_({arg button;
	if(button.value==1, {
		transferFunction = chebyFunction2.copy;
		b.value = transferFunction;
		b.minval = 0; b.maxval = size;
		b.refresh;
		c.value = updateOutput.value;
		c.minval = 0; c.maxval = size; c.refresh;
		buttonArray[0].value = 0;
		buttonArray[1].value = 0;
	});
});

50.do({
	StaticText(w, Rect(
		rrand(520, 590),
		rrand(430, 615),
		10,
		10))
.string_(".");
});

StaticText(w, Rect(520, 430, 10, 10))
.string_(".");
StaticText(w, Rect(590, 430, 10, 10))
.string_(".");
StaticText(w, Rect(520, 615, 10, 10))
.string_(".");
StaticText(w, Rect(590, 615, 10, 10))
.string_(".");

) // end of block



