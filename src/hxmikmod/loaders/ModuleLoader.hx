/**
 *
 * hxMikMod sound library
 * Copyright (C) 2011 Jouko Pynnönen <jouko@iki.fi>
 *             
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

package hxmikmod.loaders;

import hxmikmod.DataReader;
import hxmikmod.structure.Instrument;
import hxmikmod.structure.Module;
import hxmikmod.structure.Sample;
import hxmikmod.event.TrackerEvent;
import hxmikmod.event.TrackerEventDispatcher;
import hxmikmod.Mem;
import flash.utils.Timer;
import flash.events.TimerEvent;
import flash.utils.ByteArray;

class Filter
{
	public var filter:Int;
	public var inf:Int;
}

class ModuleLoader
{
	public var modreader:DataReader;
	public var of:Module;
	
	public static var finetune:Array<Int> = [
		8363,8413,8463,8529,8581,8651,8723,8757,
		7895,7941,7985,8046,8107,8169,8232,8280
	];
	
	var type:String;
	var version:String;
	
	public function init():Bool
	{
		return false;
	}

	public function test(reader:DataReader):Bool
	{
		return false;
	}

	public function load(curious:Bool):Bool
	{
		return false;
	}

	public function cleanup()
	{
	}

	public function loadTitle():String
	{
		return null;
	}
	
	public function start(maxchan:Int, curious:Bool):Bool
	{
		var ok:Bool;
		var mf:Module;
		
		TrackerEventDispatcher.dispatchEvent(new TrackerLoadingEvent(TrackerLoadingEvent.PROGRESS, "loading..."));
		
		/* init the module structure with vanilla settings */
		of = new Module();
		of.bpmlimit = 33;
		of.initvolume = 128;
		for (t in 0 ... Defs.UF_MAXCHAN)
			of.chanvol[t] = 64;
		for (t in 0 ... Defs.UF_MAXCHAN)
			of.panning[t] = ((t + 1) & 2)!=0 ? Defs.PAN_RIGHT : Defs.PAN_LEFT;
		
		/* init module loader and load the header / patterns */
		if (init())
		{
			modreader._mm_rewind();
			ok = load(curious);
			
			/* propagate inflags=flags for in-module samples */
			for (t in 0 ... of.numsmp)
			{
				if (of.samples[t].inflags == 0)
				{
					of.samples[t].inflags = of.samples[t].flags;
				}
			}
		}
		else
		{
			ok = false;
		}
		TrackerEventDispatcher.dispatchEvent(new TrackerLoadingEvent(TrackerLoadingEvent.PROGRESS));
		
		/* free loader and unitrk allocations */
		cleanup();
		MUnitrk.UniCleanup();
		if(!ok)
		{
			modreader.rollback();
			return false;
			//null;
		}

		if(!loadSamples())
		{
			modreader.rollback();
			return false;
			//null;
		}

		mf = new Module();
		if (mf == null)
		{
			modreader.rollback();
			return false;
			//null;
		}

		
		/* If the module doesn't have any specific panning, create a
           MOD-like panning, with the channels half-separated. */
		if ((of.flags & Defs.UF_PANNING) == 0)
		{
			for (t in 0 ... of.numchn)
			{
				of.panning[t] = ((t + 1) & 2) != 0 ? Defs.PAN_HALFRIGHT : Defs.PAN_HALFLEFT;
			}
		}

		/* Copy the static MODULE contents into the dynamic MODULE struct. */
		//memcpy(mf,&of,sizeof(MODULE));
		mf = of;
		// ???
		if (maxchan > 0)
		{
			if((mf.flags&Defs.UF_NNA)==0&&(mf.numchn<maxchan))
			                        maxchan = mf.numchn; else
			                  if((mf.numvoices!=0)&&(mf.numvoices<maxchan))
			                        maxchan = mf.numvoices;
			if(maxchan<mf.numchn) mf.flags |= Defs.UF_NNA;
			if(MDriver.MikMod_SetNumVoices_internal(maxchan,-1))
			{
				modreader._mm_iobase_revert();
				playerFree(mf);
				return false;
				//null;
			}
		}

		TrackerEventDispatcher.dispatchEvent(new TrackerLoadingEvent(TrackerLoadingEvent.PROGRESS, "processing samples..."));
		// do sample loading bit by bit
		SLoader.reset();
		new IncrementalLoader(this, 300, mf).start();
		return true;
	}

	public function playerFree(mf:Module)
	{
		if (mf != null)
		{
			MPlayer.Player_Exit_internal(mf);
		}
	}

	public function loadSamples():Bool
	{
		var si:Int=0;
		var u:Int;
		for (u in 0 ... of.numsmp)
		{
			var s=of.samples[u];
			if (s.length!=0) SLoader.SL_RegisterSample(s,Defs.MD_MUSIC,modreader);
		}

		
		/*
        for(u=of.numsmp,s=of.samples;u;u--,s++)
                if(s->length) SL_RegisterSample(s,Defs.MD_MUSIC,modreader);
	*/
		return true;
	}

	public function allocPositions(total:Int):Bool
	{
		if(total==0)
		{
			modreader._mm_errno=Defs.MMERR_NOT_A_MODULE;
			return false;
		}

		of.positions=new Array<Int>();
		for (i in 0 ... total) of.positions[i]=0;
		return true;
	}

	public function allocPatterns():Bool
	{
		var s:Int;
		var t:Int;
		var tracks=0;
		if((of.numpat==0)||(of.numchn==0))
		{
			modreader._mm_errno=Defs.MMERR_NOT_A_MODULE;
			return false;
		}

		
		/* Allocate track sequencing array */
		//if(!(of.patterns=(Int*)_mm_calloc((Int)(of.numpat+1)*of.numchn,sizeof(Int)))) return 0;
		//if(!(of.pattrows=(Int*)_mm_calloc(of.numpat+1,sizeof(Int)))) return 0;
		of.patterns=new Array<Int>();
		of.pattrows=new Array<Int>();
		for (t in 0 ... of.numpat+1)
		{
			of.pattrows[t]=64;
			for (s in 0 ... of.numchn)
			                	of.patterns[(t*of.numchn)+s]=tracks++;
		}

		return true;
	}

	public function allocTracks():Bool
	{
		if(of.numtrk==0)
		{
			modreader._mm_errno = Defs.MMERR_NOT_A_MODULE;
			return false;
		}

		of.tracks=new Array<Int>();
		//if(!(of.tracks=(Int **)_mm_calloc(of.numtrk,sizeof(Int *)))) return 0;
		return (of.tracks!=null);
	}

	public function allocInstruments():Bool
	{
		var t:Int;
		var n:Int;
		if(of.numins==0)
		{
			modreader._mm_errno=Defs.MMERR_NOT_A_MODULE;
			return false;
		}

		//if(!(of.instruments=(INSTRUMENT*)_mm_calloc(of.numins,sizeof(INSTRUMENT))))
		//        return 0;
		of.instruments=new Array<Instrument>();
		for (t in 0 ... of.numins)
		{
			of.instruments[t] = new Instrument();
			for (n in 0 ... Defs.INSTNOTES)
			{
				
				/* Init note / sample lookup table */
				of.instruments[t].samplenote[n]   = n;
				of.instruments[t].samplenumber[n] = t;
			}

			of.instruments[t].globvol = 64;
		}

		return true;
	}

	public function allocSamples():Bool
	{
		var u:Int;
		if(of.numsmp==0)
		{
			modreader._mm_errno = Defs.MMERR_NOT_A_MODULE;
			return false;
		}

		//if(!(of.samples=(SAMPLE*)_mm_calloc(of.numsmp,sizeof(SAMPLE)))) return 0;
		of.samples=new Array<Sample>();
		for (u in 0 ... of.numsmp)
		{
			of.samples[u]=new Sample();
			of.samples[u].panning = 128;
			
			/* center */
			of.samples[u].handle  = -1;
			of.samples[u].globvol = 64;
			of.samples[u].volume  = 64;
		}

		return true;
	}

	
	/* Creates a CSTR out of a character buffer of 'len' bytes, but strips any
      terminating non-printing characters like 0, spaces etc.                    */
	public function DupStr(s:String,len:Int,strict:Bool):String
	{
		var t:Int;
		var d="";
		
		/* Scan for last printing char in buffer [includes high ascii up to 254] */
		while(len!=0)
		{
			if(s.charCodeAt(len-1)>0x20) break;
			len--;
		}

		
		/* Scan forward for possible NULL character */
		if(strict)
		{
			var nul=-1;
			for (t in 0 ... len) if (s.charCodeAt(t)==0 && nul==-1) nul=t;
			if (nul!=-1 && nul<len) len=nul;
		}

		
		/* When the buffer wasn't completely empty, allocate a cstring and copy the
           buffer into that string, except for any control-chars */
		for (t in 0 ... len) d+=(s.charCodeAt(t)<32)?'.':s.substr(t,1);
		return d;
	}

	public function readComment(len:Int):Bool
	{
		if (len != 0)
		{
			var i:Int;
			//if(!(of.comment=(CHAR*)_mm_malloc(len+1))) return 0;
			//_mm_read_IntS(of.comment,len,modreader);
			of.comment = modreader._mm_read_string(len);
			~/\r/g.replace(of.comment,"\n");
			
			/* translate IT linefeeds */
			//for(i=0;i<len;i++)
			//        if(of.comment[i]=='\r') of.comment[i]='\n';
			//
			//of.comment[len]=0;      /* just in case */
		}

		if (of.comment=="") of.comment=null;
		return true;
	}
	
	//-----------------------------------
	// MLUtils
	//-----------------------------------
	
	private static var remap:Array<Int> = new Array<Int>();
	//[UF_MAXCHAN];   /* for removing empty channels */
	private var poslookup:Array<Int>;
	
	/* lookup table for pattern jumps after blank pattern removal */
	private var poslookupcnt:Int;
	private var origpositions:Array<Int>;
	private var filters:Bool;
	
	/* resonant filters in use */
	private var activemacro:Int;
	
	/* active midi macro number for Sxx,xx<80h */
	private var filtermacros:Array<Int>;
	//[UF_MAXMACRO];    /* midi macro settings */
	private var filtersettings:Array<Filter>;
	//[UF_MAXFILTER]; /* computed filter settings */
	
	/* Generic effect writing routine */
	private function UniEffect(eff:Int, dat:Int)
	{
		if ((eff == 0) || (eff >= Defs.UNI_LAST)) return;
		MUnitrk.UniWriteByte(eff);
		if(MUnitrk.unioperands[eff]==2)
			MUnitrk.UniWriteWord(dat);
		else
			MUnitrk.UniWriteByte(dat);
	}

	
	/*  Appends UNI_PTEFFECTX opcode to the unitrk stream. */
	private function UniPTEffect(eff:Int, dat:Int)
	{
		if ((eff != 0) ||
			(dat != 0) ||
			(of.flags & Defs.UF_ARPMEM) != 0)
		{
			UniEffect(Defs.UNI_PTEFFECT0 + eff, dat);
		}
	}

	
	/* Appends UNI_VOLEFFECT + effect/dat to unistream. */
	private function UniVolEffect(eff:Int,dat:Int)
	{
		if((eff!=0)||(dat!=0))
		{
			/* don't write empty effect */
			MUnitrk.UniWriteByte(Defs.UNI_VOLEFFECTS);
			MUnitrk.UniWriteByte(eff);
			MUnitrk.UniWriteByte(dat);
		}
	}

	private function UniInstrument(x:Int)
	{
		UniEffect(Defs.UNI_INSTRUMENT,x);
	}

	private function UniNote(x:Int)
	{
		UniEffect(Defs.UNI_NOTE,x);
	}

	
	/*========== Order stuff */
	
	/* handles S3M and IT orders */
	private function S3MIT_CreateOrders(curious:Bool)
	{
		of.numpos = 0;
		for (i in 0 ... poslookupcnt) of.positions[i]=0;
		//memset(of.positions,0,poslookupcnt*sizeof(Int));
		for (i in 0 ... 256) poslookup[i] = -1;
		//memset(poslookup,-1,256);
		for (t in 0 ... poslookupcnt)
		{
			var order=origpositions[t];
			if(order==255) order=Defs.LAST_PATTERN;
			of.positions[of.numpos]=order;
			poslookup[t]=of.numpos;
			
			/* bug fix for freaky S3Ms / ITs */
			if(origpositions[t]<254) of.numpos++; else
			                        
			/* end of song special order */
			if((order==Defs.LAST_PATTERN)&&(!(curious=!curious))) break;
		}
	}

	private static inline function toInt(b:Int)
	{
		b=b&255;
		if (b>=128) b-=256;
		return b;
	}

	
	/*========== Effect stuff */
	
	/* handles S3M and IT effects */
	private function S3MIT_ProcessCmd(cmd:Int,inf:Int,flags:Int 
	/*unsigned*/
	)
	{
		var hi:Int;
		var lo:Int;
		lo=inf&0xf;
		hi=inf>>4;
		
		/* process S3M / IT specific command structure */
		if(cmd!=255)
		{
			switch(cmd)
			{
				case 1: 
					/* Axx set speed to xx */
					UniEffect(Defs.UNI_S3MEFFECTA,inf);
				case 2: 
					/* Bxx position jump */
					if (inf<poslookupcnt)
					{
						
						/* switch to curious mode if necessary, for example
											   sympex.it, deep joy.it */
						if((toInt(poslookup[inf])<0)&&(origpositions[inf]!=255))
																		S3MIT_CreateOrders(true);
						if(!(toInt(poslookup[inf])<0))
																		UniPTEffect(0xb,poslookup[inf]);
					}
				case 3: 
					/* Cxx patternbreak to row xx */
					if ((flags & Defs.S3MIT_OLDSTYLE!=0) && (flags & Defs.S3MIT_IT)==0)
							UniPTEffect(0xd,(inf>>4)*10+(inf&0xf)); else
							UniPTEffect(0xd,inf);
				case 4: 
					/* Dxy volumeslide */
					UniEffect(Defs.UNI_S3MEFFECTD,inf);
				case 5: 
					/* Exy toneslide down */
					UniEffect(Defs.UNI_S3MEFFECTE,inf);
				case 6: 
					/* Fxy toneslide up */
					UniEffect(Defs.UNI_S3MEFFECTF, inf);
				case 7: 
					/* Gxx Tone portamento, speed xx */
					if (flags & Defs.S3MIT_OLDSTYLE!=0)
						UniPTEffect(0x3, inf);
					else
						UniEffect(Defs.UNI_ITEFFECTG,inf);
				case 8: 
					/* Hxy vibrato */
					if (flags & Defs.S3MIT_OLDSTYLE!=0)
						UniPTEffect(0x4, inf);
					else
						UniEffect(Defs.UNI_ITEFFECTH,inf);
				case 9: 
					/* Ixy tremor, ontime x, offtime y */
					if (flags & Defs.S3MIT_OLDSTYLE!=0)
						UniEffect(Defs.UNI_S3MEFFECTI, inf);
					else                     
						UniEffect(Defs.UNI_ITEFFECTI,inf);
				case 0xa: 
					/* Jxy arpeggio */
					UniPTEffect(0x0,inf);
				case 0xb: 
					/* Kxy Dual command H00 & Dxy */
					if (flags & Defs.S3MIT_OLDSTYLE!=0)
						UniPTEffect(0x4, 0);
					else
						UniEffect(Defs.UNI_ITEFFECTH,0);
					UniEffect(Defs.UNI_S3MEFFECTD,inf);
				case 0xc: 
					/* Lxy Dual command G00 & Dxy */
					if (flags & Defs.S3MIT_OLDSTYLE!=0)
						UniPTEffect(0x3, 0);
					else
						UniEffect(Defs.UNI_ITEFFECTG,0);
					UniEffect(Defs.UNI_S3MEFFECTD,inf);
				case 0xd: 
					/* Mxx Set Channel Volume */
					UniEffect(Defs.UNI_ITEFFECTM,inf);
				case 0xe: 
					/* Nxy Slide Channel Volume */
					UniEffect(Defs.UNI_ITEFFECTN,inf);
				case 0xf: 
					/* Oxx set sampleoffset xx00h */
					UniPTEffect(0x9,inf);
				case 0x10: 
					/* Pxy Slide Panning Commands */
					UniEffect(Defs.UNI_ITEFFECTP,inf);
				case 0x11: 
					/* Qxy Retrig (+volumeslide) */
					MUnitrk.UniWriteByte(Defs.UNI_S3MEFFECTQ);
					if(inf!=0 && lo==0 && (flags & Defs.S3MIT_OLDSTYLE)==0)
						MUnitrk.UniWriteByte(1); else
						MUnitrk.UniWriteByte(inf);
				case 0x12: 
					/* Rxy tremolo speed x, depth y */
					UniEffect(Defs.UNI_S3MEFFECTR,inf);
				case 0x13: 
					/* Sxx special commands */
					if (inf>=0xf0)
					{
						/* change resonant filter settings if necessary */
						if((filters)&&((inf&0xf)!=activemacro))
						{
							activemacro=inf&0xf;
							for (inf in 0 ... 0x80)
																					filtersettings[inf].filter=filtermacros[activemacro];
						}
					} else
					{
						/* Scream Tracker does not have samples larger than
							64 Kb, thus doesn't need the SAx effect */
						if (!((flags & Defs.S3MIT_SCREAM)!=0 && ((inf & 0xf0) == 0xa0)))
							UniEffect(Defs.UNI_ITEFFECTS0,inf);
					}
				case 0x14: 
					/* Txx tempo */
					if (inf >= 0x20)
					{
						UniEffect(Defs.UNI_S3MEFFECTT, inf);
					}
					else
					{
						if((flags & Defs.S3MIT_OLDSTYLE)==0)
																		
						/* IT Tempo slide */
						UniEffect(Defs.UNI_ITEFFECTT,inf);
					}
				case 0x15: 
					/* Uxy Fine Vibrato speed x, depth y */
					if(flags & Defs.S3MIT_OLDSTYLE!=0)
						UniEffect(Defs.UNI_S3MEFFECTU, inf);
					else
						UniEffect(Defs.UNI_ITEFFECTU,inf);
				case 0x16: 
					/* Vxx Set Global Volume */
					UniEffect(Defs.UNI_XMEFFECTG,inf);
				case 0x17: 
					/* Wxy Global Volume Slide */
					UniEffect(Defs.UNI_ITEFFECTW,inf);
				case 0x18: 
					/* Xxx amiga command 8xx */
					if(flags & Defs.S3MIT_OLDSTYLE!=0)
					{
						if (inf > 128)
							UniEffect(Defs.UNI_ITEFFECTS0,0x91);
						/* surround */
						else
							UniPTEffect(0x8,(inf==128)?255:(inf<<1));
					}
					else
					{
						UniPTEffect(0x8,inf);
					}
				case 0x19: 
					/* Yxy Panbrello  speed x, depth y */
					UniEffect(Defs.UNI_ITEFFECTY,inf);
				case 0x1a: 
					/* Zxx midi/resonant filters */
					if(filtersettings[inf].filter!=0)
					{
						MUnitrk.UniWriteByte(Defs.UNI_ITEFFECTZ);
						MUnitrk.UniWriteByte(filtersettings[inf].filter);
						MUnitrk.UniWriteByte(filtersettings[inf].inf);
					}
			}
		}
	}

	
	/*========== Linear periods stuff */
	private static var noteindex:Array<Int>;
	private static var noteindexcount;
	private function AllocLinear():Array<Int>
	{
		if (of.numsmp > noteindexcount)
		{
			noteindexcount = of.numsmp;
			if (noteindex==null) noteindex=new Array();
			//noteindex=realloc(noteindex,noteindexcount*sizeof(int));
		}

		return noteindex;
	}

	private function FreeLinear()
	{
		noteindex=null;
		noteindexcount=0;
	}

	private function speed_to_finetune(speed:Int,sample:Int):Int
	{
		var ctmp=0;
		var tmp:Int;
		var note=1;
		var finetune=0;
		speed>>=1;
		while((tmp=MPlayer.getfrequency(of.flags,MPlayer.getlinearperiod(note<<1,0)))<speed)
		{
			ctmp=tmp;
			note++;
		}

		if(tmp!=speed)
		{
			if((tmp-speed)<(speed-ctmp))
			              while(tmp>speed)
			                tmp=MPlayer.getfrequency(of.flags,MPlayer.getlinearperiod(note<<1,--finetune)); else
			{
				note--;
				while (ctmp < speed)
				{
					ctmp = MPlayer.getfrequency(of.flags, MPlayer.getlinearperiod(note << 1,++finetune));
				}
			}
		}

		noteindex[sample]=note-4*Defs.OCTAVE;
		return finetune;
	}
}


/********* Flash incremental loading **************/
class IncrementalLoader extends Timer
{
	
	var mf:Module;
	var loader:ModuleLoader;
	
	public function new(loader:ModuleLoader, delay:Float, mf:Module)
	{
		super(delay, 1);
		this.loader = loader;
		this.mf = mf;
		addEventListener(TimerEvent.TIMER_COMPLETE, completeHandler);
	}

	function completeHandler(e:TimerEvent)
	{
		var prog = SLoader.SL_LoadSamples();
		switch(prog)
		{
			case 0:  // not complete, reset and start again
				reset();
				start();
			case -1: // failed
				loader.modreader._mm_iobase_revert();
				loader.playerFree(mf);
				TrackerEventDispatcher.dispatchEvent(new TrackerLoadingEvent(TrackerLoadingEvent.FAILED, "Loading failed, err=" + loader.modreader._mm_errno));
			case 1: // done loading
				if (MikModPlayer.init(mf))
				{
					loader.modreader._mm_iobase_revert();
					loader.playerFree(mf);
					TrackerEventDispatcher.dispatchEvent(new TrackerLoadingEvent(TrackerLoadingEvent.FAILED, "Player init failed."));
					return;
				}

				loader.modreader._mm_iobase_revert();
				TrackerEventDispatcher.dispatchEvent(new TrackerLoadingEvent(TrackerLoadingEvent.COMPLETE, "\"" + mf.songname + "\"", 1, mf));
		}
	}
}
