
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
import hxmikmod.structure.Instrument;
import hxmikmod.structure.Sample;
import hxmikmod.structure.Module;
import hxmikmod.DataReader;
import hxmikmod.MUnitrk;
import hxmikmod.Defs;
import hxmikmod.Mem;

class XMHEADER
{
	public var id:String;          //ByteArray; //[17]; /* ID text: 'Extended module: ' */
	public var songname:String;    //ByteArray; //[21]; /* Module name */
	public var trackername:String; //ByteArray;	//[20]; /* Tracker name */
	public var version:Int;        /* Version number */
	public var headersize:Int;     /* Header size */
	public var songlength:Int;     /* Song length (in patten order table) */
	public var restart:Int;        /* Restart position */
	public var numchn:Int;         /* Number of channels (2,4,6,8,10,...,32) */
	public var numpat:Int;         /* Number of patterns (max 256) */
	public var numins:Int;         /* Number of instruments (max 128) */
	public var flags:Int;
	public var tempo:Int;          /* Default tempo */
	public var bpm:Int;            /* Default BPM */
	public var orders:Array<Int>;  //[256];     /* Pattern order table  */
	
	public function new()
	{
		orders=new Array();
	}
}

class XMINSTHEADER
{
	public var size:Int;     /* Instrument size */
	public var name:String;  //[22]; /* Instrument name */
	public var type:Int;     /* Instrument type (always 0) */
	public var numsmp:Int;   /* Number of samples in instrument */
	public var ssize:Int;
	
	public function new()
	{
	}
}

class XMPATCHHEADER
{
	public var what:Array<Int>;     //[XMNOTECNT];  /*  Sample number for all notes */
	public var volenv:Array<Int>;   //[XMENVCNT]; /*  Points for volume envelope */
	public var panenv:Array<Int>;   //[XMENVCNT]; /*  Points for panning envelope */
	public var vol_env:Envelope;
	public var pan_env:Envelope;
	//public var volpts:UBYTE;      /*  Number of volume points */
	//public var panpts:UBYTE;      /*  Number of panning points */
	//public var volsus:UBYTE;      /*  Volume sustain point */
	//public var volbeg:UBYTE;      /*  Volume loop start point */
	//public var volend:UBYTE;      /*  Volume loop end point */
	//public var pansus:UBYTE;      /*  Panning sustain point */
	//public var panbeg:UBYTE;      /*  Panning loop start point */
	//public var panend:UBYTE;      /*  Panning loop end point */
	//public var volflg:UBYTE;      /*  Volume type: bit 0: On; 1: Sustain; 2: Loop */
	//public var panflg:UBYTE;      /*  Panning type: bit 0: On; 1: Sustain; 2: Loop */
	public var vibflg:Int;    /*  Vibrato type */
	public var vibsweep:Int;  /*  Vibrato sweep */
	public var vibdepth:Int;  /*  Vibrato depth */
	public var vibrate:Int;   /*  Vibrato rate */
	public var volfade:Int;   /*  Volume fadeout */
	
	public function new()
	{
		what=new Array();
		volenv=new Array();
		panenv=new Array();
		vol_env=new Envelope();
		pan_env=new Envelope();
	}
}

class XMWAVHEADER
{
	public var length:Int;     /* Sample length */
	public var loopstart:Int;  /* Sample loop start */
	public var looplength:Int; /* Sample loop length */
	public var volume:Int;     /* Volume  */
	public var finetune:Int;   /* Finetune (signed byte -128..+127) */
	public var type:Int;       /* Loop type */
	public var panning:Int;    /* Panning (0-255) */
	public var relnote:Int;    /* Relative note number (signed byte) */
	public var reserved:Int;
	public var samplename:String; //[22]; /* Sample name */
	public var vibtype:Int;    /* Vibrato type */
	public var vibsweep:Int;   /* Vibrato sweep */
	public var vibdepth:Int;   /* Vibrato depth */
	public var vibrate:Int;    /* Vibrato rate */
	
	public function new()
	{
	}
}

class XMPATHEADER
{
	public var size:Int;     /* Pattern header length  */
	public var packing:Int;  /* Packing type (always 0) */
	public var numrows:Int;  /* Number of rows in pattern (1..256) */
	public var packsize:Int; /* Packed patterndata size */
	
	public function new()
	{
	}
}

class XMNOTE
{
	public var note:Int;
	public var ins:Int;
	public var vol:Int;
	public var eff:Int;
	public var dat:Int;
	
	public function clear()
	{
		note=ins=vol=eff=dat=0;
	}

	public function new()
	{
	}
}

class XMLoader extends ModuleLoader
{
	public static var XMENVCNT=(12*2);
	public static var XMNOTECNT=(8*Defs.OCTAVE);
	
	/*========== Loader variables */
	static  var xmpat:Array<XMNOTE>=null;
	static  var mh:XMHEADER=null;
	
	/* increment unit for sample array reallocation */
	static var XM_SMPINCR=64;
	static var nextwav:Array<Int>;
	static var wh:Array<XMWAVHEADER>;
	//static var s:XMWAVHEADER=null;
	static var si:Int = 0;
	
	public function new()
	{
		type = "XM";
		version = "XM (FastTracker 2)";
	}
	
	/*========== Loader code */
	override public function test(reader:DataReader):Bool
	{
		var id:ByteArray;
		super.test(reader);
		// 38
		if((id=modreader._mm_read_ByteArray(38))==null) return false;
		var prevpos=id.position;
		if (id.readUTFBytes(17)!="Extended Module: ") return false;
		id.position=prevpos;
		if(id[37]==0x1a) return true;
		return false;
	}

	override public function init():Bool
	{
		mh=new XMHEADER();
		return (mh!=null);
	}

	override public function cleanup()
	{
		mh=null;
	}

	private function XM_ReadNote(n:XMNOTE):Int
	{
		var cmp:Int;
		var result:Int=1;
		n.clear();
		cmp=modreader._mm_read_UBYTE();
		if(cmp&0x80!=0)
		{
			if(cmp&1!=0)
			{
				result++;
				n.note = modreader._mm_read_UBYTE();
			}

			if(cmp&2!=0)
			{
				result++;
				n.ins  = modreader._mm_read_UBYTE();
			}

			if(cmp&4!=0)
			{
				result++;
				n.vol  = modreader._mm_read_UBYTE();
			}

			if(cmp&8!=0)
			{
				result++;
				n.eff  = modreader._mm_read_UBYTE();
			}

			if(cmp&16!=0)
			{
				result++;
				n.dat  = modreader._mm_read_UBYTE();
			}
		} else
		{
			n.note = cmp;
			n.ins  = modreader._mm_read_UBYTE();
			n.vol  = modreader._mm_read_UBYTE();
			n.eff  = modreader._mm_read_UBYTE();
			n.dat  = modreader._mm_read_UBYTE();
			result += 4;
		}

		return result;
	}

	private function XM_Convert(xmtracka:Array<XMNOTE>, xmtracki:Int, rows:Int):Int
	{
		var t:Int;
		var note:Int;
		var ins:Int;
		var vol:Int;
		var eff:Int;
		var dat:Int;
		MUnitrk.UniReset();
		for (t in 0 ... rows)
		{
			var xmtrack=xmtracka[xmtracki];
			note = xmtrack.note;
			ins  = xmtrack.ins;
			vol  = xmtrack.vol;
			eff  = xmtrack.eff;
			dat  = xmtrack.dat;
			if(note!=0)
			{
				if(note>XMNOTECNT)
					UniEffect(Defs.UNI_KEYFADE, 0);
				else
					UniNote(note-1);
			}

			if(ins!=0) UniInstrument(ins-1);
			switch(vol >> 4)
			{
				case 0x6:
					/* volslide down */
					if (vol & 0xf != 0)
						UniEffect(Defs.UNI_XMEFFECTA, vol & 0xf);
				case 0x7:
					/* volslide up */
					if (vol & 0xf != 0)
						UniEffect(Defs.UNI_XMEFFECTA, vol << 4);
				
					/* volume-row fine volume slide is compatible with protracker
					 * EBx and EAx effects i.e. a zero nibble means DO NOT SLIDE, as
					 * opposed to 'take the last sliding value'.
					 */
				case 0x8:
					/* finevol down */
					UniPTEffect(0xe, 0xb0 | (vol & 0xf));
				case 0x9:
					/* finevol up */
					UniPTEffect(0xe, 0xa0 | (vol & 0xf));
				case 0xa:
					/* set vibrato speed */
					UniEffect(Defs.UNI_XMEFFECT4, vol << 4);
				case 0xb:
					/* vibrato */
					UniEffect(Defs.UNI_XMEFFECT4, vol & 0xf);
				case 0xc:
					/* set panning */
					UniPTEffect(0x8, vol << 4);
				case 0xd:
					/* panning slide left (only slide when data not zero) */
					if (vol & 0xf != 0)
						UniEffect(Defs.UNI_XMEFFECTP, vol & 0xf);
				case 0xe:
					/* panning slide right (only slide when data not zero) */
					if (vol & 0xf != 0)
						UniEffect(Defs.UNI_XMEFFECTP, vol << 4);
				case 0xf:
					/* tone porta */
					UniPTEffect(0x3, vol << 4);
				default:
					if ((vol >= 0x10) && (vol <= 0x50))
						UniPTEffect(0xc, vol - 0x10);
			}

			switch(eff)
			{
				case 0x4:
					UniEffect(Defs.UNI_XMEFFECT4, dat);
				case 0x6:
					UniEffect(Defs.UNI_XMEFFECT6, dat);
				case 0xa:
					UniEffect(Defs.UNI_XMEFFECTA, dat);
				case 0xe:
					/* Extended effects */
					switch(dat >> 4)
					{
						case 0x1:
							/* XM fine porta up */
							UniEffect(Defs.UNI_XMEFFECTE1, dat & 0xf);
						case 0x2:
							/* XM fine porta down */
							UniEffect(Defs.UNI_XMEFFECTE2, dat & 0xf);
						case 0xa:
							/* XM fine volume up */
							UniEffect(Defs.UNI_XMEFFECTEA, dat & 0xf);
						case 0xb:
							/* XM fine volume down */
							UniEffect(Defs.UNI_XMEFFECTEB, dat & 0xf);
						default:
							UniPTEffect(eff, dat);
					}
				case 16: //'G'-55: /* G - set global volume */
					UniEffect(Defs.UNI_XMEFFECTG, (dat > 64) ? 128 : dat << 1);
				case 17: //'H'-55: /* H - global volume slide */
					UniEffect(Defs.UNI_XMEFFECTH, dat);
				case 20: //'K'-55: /* K - keyOff and KeyFade */
					UniEffect(Defs.UNI_KEYFADE, dat);
				case 21: //'L'-55: /* L - set envelope position */
					UniEffect(Defs.UNI_XMEFFECTL, dat);
				case 25: //'P'-55: /* P - panning slide */
					UniEffect(Defs.UNI_XMEFFECTP, dat);
				case 27: //'R'-55: /* R - multi retrig note */
					UniEffect(Defs.UNI_S3MEFFECTQ, dat);
				case 29: //'T'-55: /* T - Tremor */
					UniEffect(Defs.UNI_S3MEFFECTI, dat);
				case 33: // 'X'-55:
					switch(dat>>4)
					{
						case 1:
							/* X1 - Extra Fine Porta up */
							UniEffect(Defs.UNI_XMEFFECTX1, dat & 0xf);
						case 2:
							/* X2 - Extra Fine Porta down */
							UniEffect(Defs.UNI_XMEFFECTX2, dat & 0xf);
					}
				
				default:
					if (eff <= 0xf)
					{
						/* the pattern jump destination is written in decimal,
						 * but it seems some poor tracker software writes them
						 * in hexadecimal... (sigh)
						 */
						if (eff == 0xd)
						{
							/* don't change anything if we're sure it's in hexa */
							if ((((dat & 0xf0) >> 4) <= 9) && ((dat & 0xf) <= 9))
							{
								/* otherwise, convert from dec to hex */
								dat = (((dat & 0xf0) >> 4) * 10) + (dat & 0xf);
							}
						}
						UniPTEffect(eff, dat);
					}
			}

			MUnitrk.UniNewline();
			xmtracki++;
		}

		return MUnitrk.UniDup();
	}

	private function loadPatterns(dummypat:Bool):Bool
	{
		var t:Int;
		var u:Int;
		var v:Int;
		var numtrk:Int;
		if(!allocTracks()) return false;
		if(!allocPatterns()) return false;
		numtrk=0;
		for (t in 0 ... mh.numpat)
		{
			var ph=new XMPATHEADER();
			ph.size     =modreader._mm_read_I_ULONG();
			if (ph.size < (mh.version == 0x0102 ? 8 : 9))
			{
				modreader._mm_errno=Defs.MMERR_LOADING_PATTERN;
				return false;
			}

			ph.packing  =modreader._mm_read_UBYTE();
			if(ph.packing!=0)
			{
				modreader._mm_errno=Defs.MMERR_LOADING_PATTERN;
				return false;
			}

			if(mh.version==0x0102)
				ph.numrows = modreader._mm_read_UBYTE() + 1;
			else
				ph.numrows = modreader._mm_read_I_UWORD();
			ph.packsize =modreader._mm_read_I_UWORD();
			ph.size-=(mh.version==0x0102?8:9);
			if (ph.size != 0)
			{
				modreader._mm_fseek(ph.size,SEEK_CUR);
			}

			of.pattrows[t]=ph.numrows;
			if(ph.numrows!=0)
			{
				xmpat=new Array<XMNOTE>();
				for (pati in 0 ... ph.numrows*of.numchn) xmpat[pati]=new XMNOTE();
				if (xmpat==null) return false;
				//if(!(xmpat=(XMNOTE*)_mm_calloc(ph.numrows*of.numchn,sizeof(XMNOTE))))
				//        return 0;
				
				/* when packsize is 0, don't try to load a pattern.. it's empty. */
				if (ph.packsize != 0)
				{
					for (u in 0 ... ph.numrows)
					{
						for (v in 0 ... of.numchn)
						{
							if(ph.packsize==0) break;
							// ???
							ph.packsize-=XM_ReadNote(xmpat[(v*ph.numrows)+u]);
							if(ph.packsize<0)
							{
								xmpat=null;
								modreader._mm_errno=Defs.MMERR_LOADING_PATTERN;
								return false;
							}
						}
					}
				}

				if(ph.packsize != 0)
				{
					modreader._mm_fseek(ph.packsize, SEEK_CUR);
				}

				if(modreader.eof())
				{
					xmpat=null;
					modreader._mm_errno = Defs.MMERR_LOADING_PATTERN;
					return false;
				}

				for (v in 0 ... of.numchn)
				{
					of.tracks[numtrk++] = XM_Convert(xmpat, v * ph.numrows, ph.numrows);
				}
				xmpat=null;
			} else
			{
				for (v in 0 ... of.numchn)
				{
					of.tracks[numtrk++] = XM_Convert(null, 0, ph.numrows);
				}
			}
		}

		t=mh.numpat;
		if(dummypat)
		{
			of.pattrows[t]=64;
			xmpat=new Array<XMNOTE>();
			if (xmpat==null) return false;
			//if(!(xmpat=(XMNOTE*)_mm_calloc(64*of.numchn,sizeof(XMNOTE)))) return 0;
			for (v in 0 ... of.numchn)
						                        of.tracks[numtrk++]=XM_Convert(xmpat,v*64,64);
			xmpat=null;
		}

		return true;
	}

	private function fixEnvelope(e:Envelope)
	{
		var u:Int;
		var old:Int;
		var tmp:Int;
		//var prev:ENVPT;
		var cur=0;
		var prev:Int;
		var arr=e.env;
		var pts=e.pts;
		
		/* Some broken XM editing program will only save the low byte
                   of the position value. Try to compensate by adding the
                   missing high byte. */
		prev = cur++;
		old = arr[prev].pos;
		for (u in 1 ... pts)
		{
			// for: prev++, cur++
			if (arr[cur].pos < arr[prev].pos)
			{
				if (arr[cur].pos < 0x100)
				{
					if (arr[cur].pos > old)     
										
					/* same hex century */
					tmp = arr[cur].pos + (arr[prev].pos - old); else
										                                                        tmp = arr[cur].pos | ((arr[prev].pos + 0x100) & 0xff00);
					old = arr[cur].pos;
					arr[cur].pos = tmp;
				} else
				{
					old = arr[cur].pos;
				}
			} else
						                                old = arr[cur].pos;
			// for loop:
			prev++;
			cur++;
		}
	}

	private function XM_ProcessEnvelope(e:Envelope,pthe:Envelope,envarr:Array<Int>)
	{
		for (u in 0 ... (XMENVCNT >> 1))
		{
			e.env[u].pos = envarr[u << 1];
			e.env[u].val = envarr[(u << 1)+ 1];
			// ???
		}

		if (pthe.flg&1!=0) e.flg|=Defs.EF_ON;
		if (pthe.flg&2!=0) e.flg|=Defs.EF_SUSTAIN;
		if (pthe.flg&4!=0) e.flg|=Defs.EF_LOOP;
		//e.susbeg=e.susend=pthe.sus;	???
		e.beg=pthe.beg;
		e.end=pthe.end;
		e.pts=pthe.pts;
		
		/* scale envelope */
		for (p in 0 ... Std.int(XMENVCNT/2))
				                                        e.env[p].val<<=2;
		if ((e.flg&Defs.EF_ON)!=0&&(e.pts<2))
				                                        e.flg&=~Defs.EF_ON;
	}

	private function loadInstruments():Bool
	{
		var t:Int;
		var u:Int;
		//var d:INSTRUMENT;
		var next:Int=0;
		var wavcnt:Int=0;
		var di=0;
		if(!allocInstruments()) return false;
		//d=of.instruments;
		for (t in 0 ... of.numins)
		{
			// for: d++
			var ih=new XMINSTHEADER();
			var headend:Int;
			// long
			var d=of.instruments[di];
			//memset(d->samplenumber,0xff,INSTNOTES*sizeof(UWORD));
			for (di in 0 ... Defs.INSTNOTES) d.samplenumber[di]=0xffff;
			
			/* read instrument header */
			headend     = modreader._mm_ftell();
			ih.size     = modreader._mm_read_I_ULONG();
			headend    += ih.size;
			ih.name     = modreader._mm_read_string(22);
			ih.type     = modreader._mm_read_UBYTE();
			ih.numsmp   = modreader._mm_read_I_UWORD();
			d.insname   = DupStr(ih.name, 22, true);
			if(ih.size>29)
			{
				ih.ssize    = modreader._mm_read_I_ULONG();
				if((
								
				/*(SWORD)*/
				ih.numsmp>0)&&(ih.numsmp<=XMNOTECNT))
				{
					var pth=new XMPATCHHEADER();
					var p:Int;
					pth.what=modreader._mm_read_UBYTES(XMNOTECNT);
					pth.volenv=modreader._mm_read_I_UWORDS (XMENVCNT);
					pth.panenv=modreader._mm_read_I_UWORDS (XMENVCNT);
					pth.vol_env.pts      =  modreader._mm_read_UBYTE();
					pth.pan_env.pts      =  modreader._mm_read_UBYTE();
					pth.vol_env.susbeg=pth.vol_env.susend=modreader._mm_read_UBYTE();
					pth.vol_env.beg      =  modreader._mm_read_UBYTE();
					pth.vol_env.end      =  modreader._mm_read_UBYTE();
					pth.pan_env.susbeg=pth.pan_env.susend=modreader._mm_read_UBYTE();
					pth.pan_env.beg      =  modreader._mm_read_UBYTE();
					pth.pan_env.end      =  modreader._mm_read_UBYTE();
					pth.vol_env.flg      =  modreader._mm_read_UBYTE();
					pth.pan_env.flg      =  modreader._mm_read_UBYTE();
					pth.vibflg      =  modreader._mm_read_UBYTE();
					pth.vibsweep    =  modreader._mm_read_UBYTE();
					pth.vibdepth    =  modreader._mm_read_UBYTE();
					pth.vibrate     =  modreader._mm_read_UBYTE();
					pth.volfade     =  modreader._mm_read_I_UWORD();
					
					/* read the remainder of the header
                                   (2 bytes for 1.03, 22 for 1.04) */
					//for(u=headend-_mm_ftell();u;u--) _mm_read_UBYTE();
					u=headend-modreader._mm_ftell();
					while(u!=0)
					{
						modreader._mm_read_UBYTE();
						u--;
					}

					
					/* we can't trust the envelope point count here, as some
                                   modules have incorrect values (K_OSPACE.XM reports 32 volume
                                   points, for example). */
					if(pth.vol_env.pts>XMENVCNT/2) pth.vol_env.pts=Std.int(XMENVCNT/2);
					if(pth.pan_env.pts>XMENVCNT/2) pth.pan_env.pts=Std.int(XMENVCNT/2);
					if((modreader.eof())||(pth.vol_env.pts>XMENVCNT/2)||(pth.pan_env.pts>XMENVCNT/2))
					{
						nextwav=null;
						wh=null;
						modreader._mm_errno = Defs.MMERR_LOADING_SAMPLEINFO;
						return false;
					}

					for (u in 0 ... XMNOTECNT)
										                                        d.samplenumber[u]=pth.what[u]+of.numsmp;
					d.volfade = pth.volfade;
					XM_ProcessEnvelope(d.vol_env,pth.vol_env,pth.volenv);
					XM_ProcessEnvelope(d.pan_env,pth.pan_env,pth.panenv);
					if (d.vol_env.flg & Defs.EF_ON != 0)
						fixEnvelope(d.vol_env);
					if (d.pan_env.flg & Defs.EF_ON != 0)
						fixEnvelope(d.pan_env);
					
					/* Samples are stored outside the instrument struct now, so we
                                   have to load them all into a temp area, count the of.numsmp
                                   along the way and then do an AllocSamples() and move
                                   everything over */
					if(mh.version>0x0103) next = 0;
					for (u in 0 ... ih.numsmp)
					{
						// for: s++
						
						/* Allocate more room for sample information if necessary */
						if(of.numsmp+u==wavcnt)
						{
							wavcnt+=XM_SMPINCR;
							if (wh==null) wh=new Array();
							if (nextwav==null) nextwav=new Array();
							for (ri in 0 ... wavcnt)
																					if (wh[ri]==null) wh[ri]=new XMWAVHEADER();
							
							/*
                                                if(!(nextwav=realloc(nextwav,wavcnt*sizeof(ULONG)))){
                                                        if(wh) { free(wh);wh=NULL; }
                                                        _mm_errno = Defs.MMERR_OUT_OF_MEMORY;
                                                        return 0;
                                                }
                                                if(!(wh=realloc(wh,wavcnt*sizeof(XMWAVHEADER)))) {
                                                        free(nextwav);nextwav=NULL;
                                                        _mm_errno = Defs.MMERR_OUT_OF_MEMORY;
                                                        return 0;
                                                }
						*/
							//s=wh+(wavcnt-XM_SMPINCR);
							si=wavcnt-XM_SMPINCR;
						}

						var s=wh[si];
						s.length       = modreader._mm_read_I_ULONG ();
						s.loopstart    = modreader._mm_read_I_ULONG ();
						s.looplength   = modreader._mm_read_I_ULONG ();
						s.volume       = modreader._mm_read_UBYTE ();
						s.finetune     = modreader._mm_read_SBYTE ();
						s.type         = modreader._mm_read_UBYTE ();
						s.panning      = modreader._mm_read_UBYTE ();
						s.relnote      = modreader._mm_read_SBYTE ();
						s.vibtype      = pth.vibflg;
						s.vibsweep     = pth.vibsweep;
						s.vibdepth     = pth.vibdepth*4;
						s.vibrate      = pth.vibrate;
						s.reserved     = modreader._mm_read_UBYTE ();
						s.samplename   = modreader._mm_read_string(22);
						nextwav[of.numsmp+u]=next;
						next+=s.length;
						if(modreader.eof())
						{
							nextwav=null;
							wh=null;
							modreader._mm_errno = Defs.MMERR_LOADING_SAMPLEINFO;
							return false;
						}

						si++;
						// for loop
					}

					if(mh.version>0x0103)
					{
						for (u in 0 ... ih.numsmp)
						{
							nextwav[of.numsmp++] += modreader._mm_ftell();
						}

						modreader._mm_fseek(next,SEEK_CUR);
					} else
					{
						of.numsmp+=ih.numsmp;
					}
				} else
				{
					
					/* read the remainder of the header */
					u=headend-modreader._mm_ftell();
					while(u!=0)
					{
						modreader._mm_read_UBYTE();
						u--;
					}

					//for(... headend-_mm_ftell();u;u--) _mm_read_UBYTE();
					if(modreader.eof())
					{
						//free(nextwav);free(wh);
						nextwav=null;
						wh=null;
						modreader._mm_errno = Defs.MMERR_LOADING_SAMPLEINFO;
						return false;
					}
				}
			}

			di++;
			// for loop
		}

		
		/* sanity check */
		if(of.numsmp==0)
		{
			nextwav=null;
			wh=null;
			modreader._mm_errno = Defs.MMERR_LOADING_SAMPLEINFO;
			return false;
		}

		return true;
	}

	override public function load(curious:Bool):Bool
	{
		var d:Instrument;
		var q:Sample;
		var t:Int;
		var u:Int;
		var dummypat=false;
		var tracker:String;
		// 21
		var modtype:String;
		// 60
		
		/* try to read module header */
		mh.id          = modreader._mm_read_string(17);
		mh.songname    = modreader._mm_read_string(21);
		mh.trackername = modreader._mm_read_string(20);
		mh.version     = modreader._mm_read_I_UWORD();
		if((mh.version<0x102)||(mh.version>0x104))
		{
			modreader._mm_errno=Defs.MMERR_NOT_A_MODULE;
			return false;
		}

		mh.headersize  = modreader._mm_read_I_ULONG();
		mh.songlength  = modreader._mm_read_I_UWORD();
		mh.restart     = modreader._mm_read_I_UWORD();
		mh.numchn      = modreader._mm_read_I_UWORD();
		mh.numpat      = modreader._mm_read_I_UWORD();
		mh.numins      = modreader._mm_read_I_UWORD();
		mh.flags       = modreader._mm_read_I_UWORD();
		mh.tempo       = modreader._mm_read_I_UWORD();
		mh.bpm         = modreader._mm_read_I_UWORD();
		if(mh.bpm==0)
		{
			modreader._mm_errno=Defs.MMERR_NOT_A_MODULE;
			return false;
		}

		mh.orders = modreader._mm_read_UBYTES(256);
		if(modreader.eof())
		{
			modreader._mm_errno = Defs.MMERR_LOADING_HEADER;
			return false;
		}

		
		/* set module variables */
		of.initspeed = mh.tempo;
		of.inittempo = mh.bpm;
		//strncpy(tracker,mh->trackername,20);tracker[20]=0;
		//for(t=20;(tracker[t]<=' ')&&(t>=0);t--) tracker[t]=0;
		
		/* some modules have the tracker name empty */
		
		/*
        if (!tracker[0])
                strcpy(tracker,"Unknown tracker");

        snprintf(modtype,60,"%s (XM format %d.%02d)",
                            tracker,mh->version>>8,mh->version&0xff);
	*/
		of.modtype   = "XM";
		//strdup(modtype);
		of.numchn    = mh.numchn;
		of.numpat    = mh.numpat;
		of.numtrk    = of.numpat*of.numchn;
		
		/* get number of channels */
		of.songname  = DupStr(mh.songname,20,true);
		of.numpos    = mh.songlength;
		
		/* copy the songlength */
		of.reppos    = mh.restart<mh.songlength?mh.restart:0;
		of.numins    = mh.numins;
		of.flags    |= Defs.UF_XMPERIODS | Defs.UF_INST | Defs.UF_NOWRAP | Defs.UF_FT2QUIRKS |
				                                   Defs.UF_PANNING;
		if(mh.flags&1!=0) of.flags |= Defs.UF_LINEAR;
		of.bpmlimit  = 32;
		//memset(of.chanvol,64,of.numchn);             /* store channel volumes */
		for (vi in 0...of.numchn) of.chanvol[vi]=64;
		if(!allocPositions(of.numpos+1)) return false;
		for (t in 0 ... of.numpos)
				                of.positions[t]=mh.orders[t];
		
		/* We have to check for any pattern numbers in the order list greater than
           the number of patterns total. If one or more is found, we set it equal to
           the pattern total and make a dummy pattern to workaround the problem */
		for (t in 0 ... of.numpos)
		{
			if(of.positions[t]>=of.numpat)
			{
				of.positions[t]=of.numpat;
				dummypat=true;
			}
		}

		if(dummypat)
		{
			of.numpat++;
			of.numtrk+=of.numchn;
		}

		if(mh.version<0x0104)
		{
			if(!loadInstruments()) return false;
			if(!loadPatterns(dummypat)) return false;
			for (t in 0 ... of.numsmp)
						                        nextwav[t]+=modreader._mm_ftell();
		} else
		{
			if(!loadPatterns(dummypat)) return false;
			if(!loadInstruments()) return false;
		}

		if(!allocSamples())
		{
			nextwav=null;
			wh=null;
			return false;
		}

		//s = wh;
		si=0;
		var qi=0;
		for (u in 0 ... of.numsmp)
		{
			// for: q++,s++
			var q = of.samples[qi];
			var s=wh[si];
			q.samplename   = DupStr(s.samplename,22,true);
			q.length       = s.length;
			q.loopstart    = s.loopstart;
			q.loopend      = s.loopstart+s.looplength;
			q.volume       = s.volume;
			q.speed        = s.finetune+128;
			q.panning      = s.panning;
			q.seekpos      = nextwav[u];
			q.vibtype      = s.vibtype;
			q.vibsweep     = s.vibsweep;
			q.vibdepth     = s.vibdepth;
			q.vibrate      = s.vibrate;
			if(s.type & 0x10!=0)
			{
				q.length    >>= 1;
				q.loopstart >>= 1;
				q.loopend   >>= 1;
			}

			q.flags|=Defs.SF_OWNPAN|Defs.SF_DELTA|Defs.SF_SIGNED;
			if(s.type&0x3!=0) q.flags|=Defs.SF_LOOP;
			if(s.type&0x2!=0) q.flags|=Defs.SF_BIDI;
			if(s.type&0x10!=0) q.flags|=Defs.SF_16BITS;
			qi++;
			si++;
			// for loop
		}

		si=0;
		var di=0;
		var s=wh;
		for (u in 0 ... of.numins)
		{
			// for: d++
			var d=of.instruments[di];
			for (t in 0 ... XMNOTECNT)
			{
				if (d.samplenumber[t]>=of.numsmp)
								                                d.samplenote[t]=255; else
				{
					var note=t+s[d.samplenumber[t]].relnote;
					d.samplenote[t]=(note<0)?0:note;
				}
			}

			di++;
			// for loop
		}

		wh=null;
		nextwav=null;
		return true;
	}

	override public function loadTitle():String
	{
		var s:String;
		modreader._mm_fseek(17,SEEK_SET);
		s=modreader._mm_read_string(21);
		if (s==null) return null;
		return(DupStr(s,21,true));
	}
	
}