
		// VARIABLES ///////////////////
		var numpl = 2;
		var proc = NetAddr("127.0.0.1", 12321);
		var procfx = NetAddr("127.0.0.1", 12322);
		var g0 = Group.new(s);
		var g0b = Group.after(g0);
		var g1 = Group.after(g0b);
		var g2 = Group.after(g1);
		//Score Index/Cursor
		var scoreixbuf = Buffer.alloc(s, s.sampleRate*16);
		var scoreixAbus = Bus.audio(s);
		var scoreixKbus = Bus.control(s);
		//Loop Index/Cursor
		var loopixbuf = Buffer.alloc(s, s.sampleRate*16);
		var loopixAbus = Bus.audio(s);
		var loopixKbus = Bus.control(s);
		//Sample Buffer
		var liveprocbuf = Buffer.alloc(s, s.sampleRate*16);
		var zerobuf = Buffer.alloc(s, s.sampleRate*16);
		//Sample Bus
		var sampbus = Bus.audio(s);
		var scorerunfunc, scrctlwin, scrctlbut;
		//Control Busses
		var kbus = {Bus.control(s, 33)}!20;
		var totalframes = 44100*16;
		var freezebuf = Buffer.alloc(s, s.sampleRate*2); //buffer for freeze effect
		var envbufs = SoundFile.collectIntoBuffers("/Users/jyang/GitHub/superimposition/Superimposition_Final_Score/grainEnv/*");
		var playa = 0;

		//SYNTH DEFS
		SynthDef(\indexer, {
			arg buf, spd=1, start=0, end=1, abus=99, kbus, t_tr=0, pos=0;
			var index, indexnorm;
			index = Phasor.ar(t_tr, BufRateScale.kr(buf)*spd, start*BufFrames.kr(buf), end*BufFrames.kr(buf), pos*BufFrames.kr(buf));
			indexnorm = index.linlin(0.0, BufFrames.kr(buf), 0.0, 1.0);
			Out.ar(abus, index);
			Out.kr(kbus, indexnorm);
		}).add;


		OSCdef(\getix, {|msg|
			var pl = msg[1].asInteger;
			scoreixKbus.get({ |val|
				liveprocbuf.get( (val*(44100*16)).round, { |msg| procfx.sendMsg("/ix", pl, val.asFloat, msg.asFloat) });
			});
		}, "/getix");




		//Score IX //////////////////////////
		OSCdef( \getscoreidx,{ scoreixKbus.get({arg val; proc.sendMsg("/scoreix", val)}) }, "/getscoreidx");
		//FX
		OSCdef(\getloopix, {|msg|
			var pl = msg[1].asInteger;
			loopixKbus.get({ |val| procfx.sendMsg("/loopix", pl, val.asFloat) });
		}, "/getloopix");
		OSCdef(\setix, {|msg|
			var pl = msg[1].asInteger;
			var start = msg[2].asFloat;
			var end = msg[3].asFloat;
			s.sendMsg(\n_free, 6000+pl);
			s.sendMsg( \s_new, \indexer, 6000+pl, 0, g0.nodeID, \buf, loopixbuf.bufnum, \spd, 1, \start, start,
				\end, end, \abus, loopixAbus.index, \kbus, loopixKbus.index);
			s.sendMsg( \n_set, 5000+pl, \idxbus, loopixAbus.index);
		}, "/setix");
		OSCdef(\mainix, {|msg|
			var pl = msg[1].asInteger;
			s.sendMsg(\n_free, 6000+pl);
			s.sendMsg( \n_set, 5000+pl, \idxbus, scoreixAbus.index );
		}, "/mainix");





		OSCdef(\inpause, {|msg|
			var pl = msg[4].asInteger;
			switch( pl,
				1, { s.sendMsg(\n_set, 4000, \buf, zerobuf.bufnum) },
				0, {s.sendMsg(\n_set, 4000, \buf, liveprocbuf.bufnum) }
			);
		}, "/inpause");




/*
HAVE A SLAVE PHASOR W/RESET & LATENCY ADJUSTMENT


*/