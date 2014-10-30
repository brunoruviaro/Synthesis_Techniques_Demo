s.makeGui;

s.meter

{SinOsc.ar(440,0,1)}.play;

{SinOsc.ar(440,0,1)}.play;

~a440 = {SinOsc.ar(440,0,0.1)}.play;
~a880 = {SinOsc.ar(880,0,0.1)}.play;
~e1320 = {SinOsc.ar(1320,0,0.1)}.play;
~a1760 = {SinOsc.ar(1760,0,0.1)}.play;
~cs2200 = {SinOsc.ar(2200,0,0.1)}.play;
~e2640 = {SinOsc.ar(2640,0,0.1)}.play;
~g3080 = {SinOsc.ar(3080,0,0.1)}.play;

~a440 = {SinOsc.ar(440,0,0.1)}.play;
~a880 = {SinOsc.ar(891,0,0.1)}.play;
~e1320 = {SinOsc.ar(1311,0,0.1)}.play;
~a1760 = {SinOsc.ar(1600,0,0.1)}.play;
~cs2200 = {SinOsc.ar(2500,0,0.1)}.play;
~e2640 = {SinOsc.ar(2640,0,0.1)}.play;
~g3080 = {SinOsc.ar(3080,0,0.1)}.play;


~a440.free;
~a880.free;
~e1320.free;
~a1760.free;
~cs2200.free;
~e2640.free;
~g3080.free;

440*7
