(
SynthDef("membrane", {arg t_trig = 1, amp = 0.5, tension = 0.05, loss = 0.999, rel = 1;

	var snd, env, excitation;

	env = EnvGen.kr(
		envelope: Env.perc(releaseTime: rel),
		gate: t_trig,
		levelScale: amp,
		doneAction: 0);

	excitation = PinkNoise.ar(0.4) * env;
	// tension should be between 0.01, 0.1
	/*loss = MouseY.kr(0.999999, 0.999, 'exponential');*/

	snd = MembraneHexagon.ar(excitation, tension, loss);

	Out.ar(0, snd!2);

}).add;
)

(
Pmono("membrane",
	\tension, 0.05,
	\loss, Pfunc({ rrand(0.999, 0.999) }),
	\rel, 0.3,
	\amp, 0.2,
	\t_trig, 1,
	\dur, Pseq([0.1, 0.1, 0.2, 0.31], inf)
).play;
)


// Waveguide

(
{ var excitation = EnvGen.kr(Env.perc(releaseTime: 1),
                            MouseButton.kr(0, 1, 0),
                             timeScale: 1, doneAction: 2
	                            ) * PinkNoise.ar(0.4);
  var tension = MouseX.kr(0.01, 0.1);
  var loss = MouseY.kr(0.999999, 0.999, 1);
  MembraneHexagon.ar(excitation, tension, loss)*0.5;
}.play;
)
