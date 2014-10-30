
// Simple sweep through harmonic series
{ Blip.ar(200,Line.kr(1,100,20),0.2) }.play;

// Same thing, now controlled with mouse

{ Blip.ar(100,MouseY.kr(1,100,1),0.2) }.play;


///////////// Figure 1.1 Example of additive synthesis [from SC book]

(
play({
	var sines = 12, speed = 4;
	Mix.fill(sines, 
		{arg x; 
			Pan2.ar(
				SinOsc.ar(x+1.19*50, 
					mul: max(0, 
						LFNoise1.kr(speed) +
						Line.kr(1, -1, 30)
					)
				), rand2(1.0))})/sines})
)

/////////////








(
x = {   
 
        var freq = MouseX.kr(100, 1000, 1) / SampleRate.ir;
        var distance = 3.00;
        var index = MouseY.kr(0.42, 0.99);
        var theta, beta, num, denom, son;
 
        // Two phasors which will ramp from zero to 2pi
        theta = Phasor.ar(0, freq, 0, 2pi);
        beta  = Phasor.ar(0, freq * distance, 0, 2pi);
 
        num = sin(theta) - (index * sin(theta - beta));
        denom = 1 + index.squared - (2 * index * cos(beta));
 
        son = num / denom;
 
        Out.ar(0, Pan2.ar(son * 0.01));
 
}.freqscope;  // Use ".freqscope" or ".scope", both are illustrative.
)

