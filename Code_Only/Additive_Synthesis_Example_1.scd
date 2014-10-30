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
 
        Out.ar(0, Pan2.ar(son * 0.3));
 
}.freqscope;  // Use ".freqscope" or ".scope", both are illustrative.
)

