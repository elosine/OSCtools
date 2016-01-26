

// VARIABLES ///////////////////
//Groups
~g0 = Group.new(s);
~g1 = Group.after(g0b);
~g2 = Group.after(g1);
~cd=();
//check if name exists in dictionary
~cd.put(\bigJ, Dictionary.new);
~cd[\bigJ].put(\kbus, Bus.control(s));
~cd[\bigJ][\kbus]
~cd[\bigJ].put(\abus, Bus.audio(s));
~cd[\bigJ][\abus]
~cd[\bigJ].put(\synth, Synth(\indexer, [\dur, 3.0, \abus, ~cd[\bigJ][\abus], \kbus, ~cd[\bigJ][\kbus]]));
~cd[\bigJ][\synth]

OSCdef(\mkclk, {|msg|
	//make a new control and audio bus, add the index synth to index group
	//register index number, maybe in a dictionary with a certain user defined name?

}, "/mkclk");



//SYNTH DEFS
SynthDef(\indexer, {
	arg dur=3.0, spd=1.0, start=0.0, end=1.0, abus, kbus, t_tr=0, pos=0, samprate = 44100.0;
	var index, indexnorm, numframes;
	numframes = dur*samprate;
	index = Phasor.ar(t_tr, spd, start*numframes, end*numframes, pos*numframes);
	indexnorm = index.linlin(0.0, numframes, 0.0, 1.0);
	Out.ar(abus, index);
	Out.kr(kbus, indexnorm);
}).add;
a = Synth(\indexer, [\abus, ~iabus[0], \kbus, ~ikbus[0] ]);






/*

START W/CONTROL RATE AND MAKE STOPWATCH INTERFACE
HOW TO CONFIGURE STOPWATCH?

OSC ARRAY WITH CONTAINERS
OR
TEXT FILE WITH SETTINGS
START/STOP/PAUSE/JUMP TO PLACE IN SCORE
REPORT TIME CONTAINERS
GUI TOOL THAT KEEPS TRACK OF ALL REGISTERED STOPWATCHES & CONTROLS


AUDIO RATE
HAVE A SLAVE PHASOR W/RESET & LATENCY ADJUSTMENT


*/