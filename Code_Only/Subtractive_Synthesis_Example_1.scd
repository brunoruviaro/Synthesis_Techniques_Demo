///////////// Subtractive Synthesis

(
{BPF.ar(
	in: WhiteNoise.ar(0.5),
	freq: MouseY.kr(100, 10000),
	rq: MouseX.kr(0.1, 1)
)}.freqscope;
)

(
{BPF.ar(
	in: Saw.ar(100, 0.5),
	freq: MouseY.kr(100, 10000),
	rq: MouseX.kr(0.1, 1)
)}.freqscope;
)

