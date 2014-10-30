{SinOsc.ar(440,0,0.5)}.play // Creates a concert A sine tone


{SinOsc.ar(440, 0, 0.5)}.plot;
{LFSaw.ar(440, 0, 0.5)}.play;
{LFTri.ar(440, 0, 0.5)}.plot;

{LFNoise0.ar(MouseX.kr(1,100))}.play;

{SinOsc.ar(440,0,0.5) + SinOsc.ar(100,0,0.5)}.play


{SinOsc.ar([440,660],0,0.5)}.play

{Mix(SinOsc.ar([440, 660],0,0.5))}.play // Mixes however many channels down into a single mono output

{Mix(SinOsc.ar([440, MouseY.kr(660, 1900)],0,0.5))}.freqscope;


{SinOsc.ar([800,1500,2200,3050,4000,4900,5700,6600],0,[0.3,0.3,0.25,0.2,0.1,0.1,0.05,0.05])}.scope

{Mix(SinOsc.ar([800,1500,2200,3050,4000,4900,5700,6600],0,[0.3,0.3,0.25,0.2,0.1,0.1,0.05,0.05]))}.freqscope;
