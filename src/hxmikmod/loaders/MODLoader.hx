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

import flash.utils.ByteArray;
import hxmikmod.DataReader;
import hxmikmod.Defs;
import hxmikmod.MUnitrk;
import hxmikmod.MLutils;
import hxmikmod.MODULE;
import hxmikmod.Mem;

/*========== Module structure */
class MSAMPINFO
{
	public var samplename:String;
	public var length:Int;
	public var finetune:Int;
	public var volume:Int;
	public var reppos:Int;
	public var replen:Int;
	public function new()
	{
	}
}

class MODULEHEADER
{
	public var songname:String;
	//CHAR songname[21];                      /* the songname.. 20 in module, 21 in memory */
	public var samples:Array<MSAMPINFO>;
	// samples[31];          /* all sampleinfo */
	public var songlength:Int;
	
	/* number of patterns used */
	public var magic1:Int;
	
	/* should be 127 */
	public var positions:Array<Int>;
	//ByteArray; //[128];           /* which pattern to play at pos */
	public var magic2:String;
	//ByteArray; // [4];                        /* string "M.K." or "FLT4" or "FLT8" */
	public function new()
	{
		samples=new Array<MSAMPINFO>();
		for (i in 0...31) samples[i]=new MSAMPINFO();
	}
}

class MODTYPE
{
	public var id:Array<Int>;
	// [5]
	public var channels:Int;
	public var name:String;
	public function new()
	{
	}
}

class MODNOTE
{
	public var a:Int;
	public var b:Int;
	public var c:Int;
	public var d:Int;
	public function new()
	{
	}
}

class MODLoader extends ModuleLoader
{
	
	/*========== Loader variables */
	static var MODULEHEADERSIZE=0x438;
	static var protracker="Protracker";
	static var startrekker="Startrekker";
	static var fasttracker="Fasttracker";
	static var oktalyser="Oktalyser";
	static var oktalyzer="Oktalyzer";
	static var taketracker="TakeTracker";
	static var orpheus="Imago Orpheus (MOD format)";
	static var mh:MODULEHEADER;
	static var patbuf:Array<MODNOTE>;
	static var modtype:Int;
	static var trekker:Int;
	
	/*========== Loader code */
	
	/* given the module ID, determine the number of channels and the tracker
      description ; also alters modtype */
	// returns number of channels or -1
	static function MOD_CheckType(id:String,descr:Array<String>):Int
	{
		modtype = trekker = 0;
		var numchn=0;
		
		/* Protracker and variants */
		if (id=="M.K." || id=="M!K!")
		{
			descr[0] = protracker;
			modtype = 0;
			return 4;
		}

		
		/* Star Tracker */
		if (~/^FLT[0-9]/.match(id) || ~/^EXO[0-9]/.match(id))
		{
			descr[0] = startrekker;
			modtype = trekker = 1;
			numchn=Std.parseInt(id.substr(3,1));
			if (numchn==4 || numchn==8) return numchn;
			return -1;
		}

		
		/* Oktalyzer (Amiga) */
		if (id=="OKTA")
		{
			descr[0]=oktalyzer;
			modtype = 1;
			return 8;
		}

		
		/* Oktalyser (Atari) */
		if (id=="CD81")
		{
			descr[0] = oktalyser;
			modtype = 1;
			return 8;
		}

		
		/* Fasttracker */
		if (~/^[0-9]CHN/.match(id))
		{
			descr[0]=fasttracker;
			modtype = 1;
			numchn=id.charCodeAt(0)-48;
			// '0'
			return numchn;
		}

		
		/* Fasttracker or Taketracker */
		//if (((!memcmp(id + 2, "CH", 2)) || (!memcmp(id + 2, "CN", 2)))
		//        && (isdigit(id[0])) && (isdigit(id[1]))) {
		if (~/^[0-9][0-9]C[HN]/.match(id))
		{
			if (id.charAt(3) == "H")
			{
				descr[0] = fasttracker;
				modtype = 2;
				
				/* this can also be Imago Orpheus */
			} else
			{
				descr[0] = taketracker;
				modtype = 1;
			}

			numchn=(id.charCodeAt(0)-48)*10+(id.charCodeAt(1)-48);
			return numchn;
		}

		return -1;
	}

	override public function Test():Bool
	{
		var id:String;
		var descr=new Array<String>();
		descr[0]="";
		MLoader.modreader._mm_fseek(MODULEHEADERSIZE, SEEK_SET);
		if ((id=MLoader.modreader._mm_read_string(4))==null)
		                return false;
		if (MOD_CheckType(id, descr)!=-1)
		                return true;
		return false;
	}

	override public function Init():Bool
	{
		mh=new MODULEHEADER();
		return (mh!=null);
	}

	override public function Cleanup()
	{
		mh=null;
		patbuf=null;
	}

	static function ConvertNote(n:MODNOTE, lasteffect:Int):Int
	{
		var instrument:Int;
		var effect:Int;
		var effdat:Int;
		var note:Int;
		var period:Int;
		var lastnote=0;
		
		/* extract the various information from the 4 bytes that make up a note */
		instrument = (n.a & 0x10) | (n.c >> 4);
		period = ((n.a & 0xf) << 8) + n.b;
		// cast
		effect = n.c & 0xf;
		effdat = n.d;
		
		/* Convert the period to a note number */
		note = 0;
		if (period!=0)
		{
			var fnote:Int=7*Defs.OCTAVE;
			for (note in 0 ... 7*Defs.OCTAVE)
			                        if (period >= Defs.npertab[note])
			{
				fnote=note;
				break;
			}

			note=fnote;
			// just
			if (note == 7 * Defs.OCTAVE)
			                        note = 0; else
			                        note++;
		}

		//Player.Log("instr="+instrument+" per="+period+" eff="+effect+","+effdat);
		if (instrument!=0)
		{
			
			/* if instrument does not exist, note cut */
			if ((instrument > 31) || (mh.samples[instrument - 1].length==0))
			{
				MLutils.UniPTEffect(0xc, 0);
				if (effect == 0xc)
				                                effect = effdat = 0;
			} else
			{
				
				/* Protracker handling */
				if (modtype==0)
				{
					
					/* if we had a note, then change instrument... */
					if (note!=0)
					                                        MLutils.UniInstrument(instrument - 1);
					
					/* ...otherwise, only adjust volume... */ else
					{
						
						/* ...unless an effect was specified, which forces a new
                                           note to be played */
						if (effect!=0 || effdat!=0)
						{
							MLutils.UniInstrument(instrument - 1);
							note = lastnote;
						} else
						                                                MLutils.UniPTEffect(0xc,mh.samples[instrument-1].volume & 0x7f);
					}
				} else
				{
					
					/* Fasttracker handling */
					MLutils.UniInstrument(instrument - 1);
					if (note==0)
					                                        note = lastnote;
				}
			}
		}

		if (note!=0)
		{
			MLutils.UniNote(note + 2 * Defs.OCTAVE - 1);
			lastnote = note;
		}

		
		/* Convert pattern jump from Dec to Hex */
		if (effect == 0xd)
		                effdat = (((effdat & 0xf0) >> 4) * 10) + (effdat & 0xf);
		
		/* Volume slide, up has priority */
		if ((effect == 0xa) && (effdat & 0xf)!=0 && (effdat & 0xf0)!=0)
		                effdat &= 0xf0;
		
		/* Handle ``heavy'' volumes correctly */
		if ((effect == 0xc) && (effdat > 0x40))
		                effdat = 0x40;
		
		/* An isolated 100, 200 or 300 effect should be ignored (no
           "standalone" porta memory in mod files). However, a sequence such
           as 1XX, 100, 100, 100 is fine. */
		if ((effdat==0) && ((effect == 1)||(effect == 2)||(effect ==3)) &&
		                (lasteffect < 0x10) && (effect != lasteffect))
		                effect = 0;
		MLutils.UniPTEffect(effect, effdat);
		if (effect == 8)
		                MLoader.of.flags |= Defs.UF_PANNING;
		return effect;
	}

	static function ConvertTrack(n:Array<MODNOTE>,ni:Int, numchn:Int):Int
	{
		var t:Int;
		var lasteffect = 0x10;
		
		/* non existant effect */
		MUnitrk.UniReset();
		for (t in 0 ... 64)
		{
			lasteffect = ConvertNote(n[ni],lasteffect);
			MUnitrk.UniNewline();
			ni += numchn;
		}

		return MUnitrk.UniDup();
	}

	
	/* Loads all patterns of a modfile and converts them into the 3 byte format. */
	static function ML_LoadPatterns():Bool
	{
		var t:Int;
		var s:Int;
		var tracks=0;
		if (!MLoader.AllocPatterns())
		                return false;
		if (!MLoader.AllocTracks())
		                return false;
		
		/* Allocate temporary buffer for loading and converting the patterns */
		//if (!(patbuf = (MODNOTE *)_mm_calloc(64U * of.numchn, sizeof(MODNOTE))))
		//        return 0;
		patbuf=new Array<MODNOTE>();
		// trekker not impl
		
		/* Generic module pattern */
		for (t in 0 ... MLoader.of.numpat)
		{
			
			/* Load the pattern into the temp buffer and convert it */
			for (s in 0 ... (64 * MLoader.of.numchn))
			{
				patbuf[s]=new MODNOTE();
				patbuf[s].a = MLoader.modreader._mm_read_UBYTE();
				patbuf[s].b = MLoader.modreader._mm_read_UBYTE();
				patbuf[s].c = MLoader.modreader._mm_read_UBYTE();
				patbuf[s].d = MLoader.modreader._mm_read_UBYTE();
				//trace("pat="+t+" note="+s+" a="+patbuf[s].a+" b="+patbuf[s].b+" c="+patbuf[s].c+" d="+patbuf[s].d);
			}

			for (s in 0 ... MLoader.of.numchn)
			{
				if (0==(MLoader.of.tracks[tracks++] = ConvertTrack(patbuf, s, MLoader.of.numchn)))
				                                        return false;
				//trace("track "+(tracks-1)+": "+MLoader.of.tracks[tracks-1]);
			}
		}

		return true;
	}

	override public function Load(curious:Bool):Bool
	{
		var t:Int;
		var scan:Bool;
		//var q:SAMPLE;
		//var s:MSAMPINFO;
		var descr=new Array<String>();
		
		/* try to read module header */
		mh.songname=MLoader.modreader._mm_read_string(20);
		//mh->songname[20] = 0;           /* just in case */
		for (t in 0 ... 31)
		{
			var s = mh.samples[t];
			s.samplename=MLoader.modreader._mm_read_string(22);
			//s->samplename[22] = 0;  /* just in case */
			s.length = MLoader.modreader._mm_read_M_UWORD();
			s.finetune = MLoader.modreader._mm_read_UBYTE();
			s.volume = MLoader.modreader._mm_read_UBYTE();
			s.reppos = MLoader.modreader._mm_read_M_UWORD();
			s.replen = MLoader.modreader._mm_read_M_UWORD();
		}

		mh.songlength = MLoader.modreader._mm_read_UBYTE();
		
		/* this fixes mods which declare more than 128 positions. 
         * eg: beatwave.mod */
		if (mh.songlength > 128)
		{
			mh.songlength = 128;
		}

		mh.magic1 = MLoader.modreader._mm_read_UBYTE();
		mh.positions=MLoader.modreader._mm_read_UBYTES(128);
		//mh.magic2=MLoader.modreader._mm_read_UBYTES(4, MLoader.modreader);
		mh.magic2=MLoader.modreader._mm_read_string(4);
		if (MLoader.modreader.eof())
		{
			MLoader.modreader._mm_errno = Defs.MMERR_LOADING_HEADER;
			return false;
		}

		
		/* set module variables */
		MLoader.of.initspeed = 6;
		MLoader.of.inittempo = 125;
		if ((MLoader.of.numchn=MOD_CheckType(mh.magic2, descr))==-1)
		{
			MLoader.of.numchn=0;
			///
			MLoader.modreader._mm_errno = Defs.MMERR_NOT_A_MODULE;
			return false;
		}

		// trekker not impl
		MLoader.of.songname = MLoader.DupStr(mh.songname,21,true);
		//DupStr(mh->songname, 21, 1);
		MLoader.of.numpos = mh.songlength;
		MLoader.of.reppos = 0;
		
		/* Count the number of patterns */
		MLoader.of.numpat = 0;
		for (t  in 0 ... MLoader.of.numpos)
		                if (mh.positions[t] > MLoader.of.numpat)
		                        MLoader.of.numpat = mh.positions[t];
		
		/* since some old modules embed extra patterns, we have to check the
           whole list to get the samples' file offsets right - however we can find
           garbage here, so check carefully */
		scan = true;
		for (t in MLoader.of.numpos ... 128)
		                if (mh.positions[t] >= 0x80)
		                        scan = false;
		if (scan)
		                for (t in MLoader.of.numpos ... 128)
		{
			if (mh.positions[t] > MLoader.of.numpat)
			                                MLoader.of.numpat = mh.positions[t];
			//if ((curious) && (mh->positions[t]))
			//        MLoader.of.numpos = t + 1;
		}

		MLoader.of.numpat++;
		MLoader.of.numtrk = MLoader.of.numpat * MLoader.of.numchn;
		if (!MLoader.AllocPositions(MLoader.of.numpos))
		                return false;
		for (t in 0 ... MLoader.of.numpos)
		                MLoader.of.positions[t] = mh.positions[t];
		
		/* Finally, init the sampleinfo structures  */
		MLoader.of.numins = MLoader.of.numsmp = 31;
		if (!MLoader.AllocSamples())
		                return false;
		//s = mh.samples;
		//q = MLoader.of.samples;
		var si=0;
		var qi=0;
		for (t in 0 ... MLoader.of.numins)
		{
			var s=mh.samples[si];
			var q=MLoader.of.samples[qi];
			
			/* convert the samplename */
			q.samplename = MLoader.DupStr(s.samplename, 23, true);
			
			/* init the sampleinfo variables and convert the size pointers */
			q.speed = MLoader.finetune[s.finetune & 0xf];
			q.volume = s.volume & 0x7f;
			q.loopstart = s.reppos << 1;
			// cast
			q.loopend = q.loopstart + (s.replen << 1);
			// cast
			q.length = s.length << 1;
			// cast
			q.flags = Defs.SF_SIGNED;
			
			/* Imago Orpheus creates MODs with 16 bit samples, check */
			if ((modtype == 2) && (s.volume & 0x80)!=0)
			{
				q.flags |= Defs.SF_16BITS;
				descr[0] = orpheus;
			}

			if (s.replen > 2)
			                        q.flags |= Defs.SF_LOOP;
			//s++;
			//q++;
			si++;
			qi++;
		}

		MLoader.of.modtype = descr[0];
		//strdup(descr);
		if (!ML_LoadPatterns())
		                return false;
		return true;
	}

	override public function LoadTitle():String
	{
		MLoader.modreader._mm_fseek(0, SEEK_SET);
		var s=MLoader.modreader._mm_read_string(20);
		if (s==null) return null;
		return (MLoader.DupStr(s, 21, true));
	}

	
	/*========== Loader information */
	public function new()
	{
		type="Standard module";
		version="MOD (31 instruments)";
	}
}