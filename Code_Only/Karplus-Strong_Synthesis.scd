s.boot;

(
SynthDef("pop", {arg freq = 1;
	var snd;
	snd = Impulse.ar(freq);
	Out.ar(0, snd);
}).add;
)

// 10 pops per second
Synth("pop", [\freq, 10]);

// 100 times per second (becomes a pitch)
Synth("pop", [\freq, 100]);

// freq = 0 returns a single impulse
Synth("pop", [\freq, 0]);

CombN



(
SynthDef("popDelay", {arg freq = 0, delayTime = 0.2;
	var snd, delay;
	snd = Impulse.ar(freq);
	delay = CombN.ar(in: snd, maxdelaytime: 2, delaytime: delayTime, decayTime: 1);
	Out.ar(0, snd+delay);
}).add;
)

Synth("popDelay")

Synth("popDelay", [\freq, 1/2, \delayTime, 0.1])

























// excitation signal is WhiteNoise, triggered twice a second with varying OnePole coef
(
    {Pluck.ar(
	in: WhiteNoise.ar(0.1),
	trig: Impulse.kr(2),
	maxdelaytime: 440.reciprocal,
	delaytime: 440.reciprocal,
	decaytime: 10,
    coef: MouseX.kr(0, 0.999))
    }.play;
)


// Write a SynthDef based on the above.











// a group of angry fretless mandolin players
(
    {
        var freq, numparts;
        numparts = 10;
        freq = SinOsc.kr(Array.fill(numparts, {Rand(0.05, 0.2)}),
            Array.fill(numparts, {Rand(0, 1.0)})).range(1000, 3000);
        LeakDC.ar(
            Pan2.ar(
                Pluck.ar(
                    WhiteNoise.ar(0.1).dup(numparts),
                    Impulse.kr(Array.fill(numparts, {Rand(10, 12)})),
                    100.reciprocal, freq.reciprocal, 2, Rand(0.01, 0.2), mul: 1),
                Array.fill(numparts, {Rand.new(-1.0, 1.0)}))
            .sum
            );
        }.play;
)