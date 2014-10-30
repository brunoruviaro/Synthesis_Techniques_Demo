Array.series(5, 10, 2).postln;

(
    //Variables
    var rapports_harmo, frequencies;
   
    //in/harmonic factors
    rapports_harmo = Array.rand(20, 1.0, 32.0);
    //rapports_harmo = Array.series(20, 1.0, 32.0);
    rapports_harmo.postln;
   
    //Synth def
    (
    SynthDef(\help_Control_Sines, { arg out=0;
        var sines, control, numsines;
        numsines = 20;
        control = NamedControl.kr(\array, Array.rand(numsines, 1.0, 32.0));
        sines = Mix(SinOsc.ar(control * MouseX.kr(50.0, 3000.0, 0.0, 0.2), 0, numsines.reciprocal)) ;
        Out.ar(out, sines ! 2);
    }).add
    );
   
    //synth activation
    b = Synth(\help_Control_Sines, [array: rapports_harmo]);
   
)

// later, recalculate ratios and send to synth
b.setn(\array, Array.rand(20, 1.0, 32.0));
