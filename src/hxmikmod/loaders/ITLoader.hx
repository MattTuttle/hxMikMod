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
import hxmikmod.INSTRUMENT;
import hxmikmod.DataReader;
import hxmikmod.MUnitrk;
import hxmikmod.MLutils;
import hxmikmod.Defs;
import hxmikmod.SAMPLE;
import hxmikmod.MODULE;
import hxmikmod.Mem;


/*========== Module structure */

/* header */
class ITHEADER {
	public var songname:String; 		//26
	public var blank01:Array<Int>; 	// 2
	public var ordnum:Int;
	public var insnum:Int;
	public var smpnum:Int;
	public var patnum:Int;
	public var cwt:Int;	
	public var cmwt:Int;	
	public var flags:Int;	
	public var special:Int;	
	public var globvol:Int;
	public var mixvol:Int;
	public var initspeed:Int;
	public var inittempo:Int;
	public var pansep:Int;
	public var zerobyte:Int;
	public var msglength:Int;
	public var msgoffset:Int;
	public var blank02:Array<Int>;		// 4
	public var pantable:Array<Int>;		// 64
	public var voltable:Array<Int>;		// 64

	public function new() {
	   //pantable=new Array();
	   //voltable=new Array();
	}
}



/* sample information */
class ITSAMPLE {
	public var filename:String;	// 12
	public var zerobyte:Int;
	public var globvol:Int;
	public var flag:Int;
	public var volume:Int;
	public var panning:Int;
	public var sampname:String;	// 28
	public var convert:Int;	/* sample conversion flag */
	public var length:Int;
	public var loopbeg:Int;
	public var loopend:Int;
	public var c5spd:Int;
	public var susbegin:Int;
	public var susend:Int;
	public var sampoffset:Int;
	public var vibspeed:Int;
	public var vibdepth:Int;
	public var vibrate:Int;
	public var vibwave:Int;	/* 0=sine, 1=rampdown, 2=square, 3=random (speed ignored) */

	public function new() {
	
	}
}

/* instrument information */

class ITINSTHEADER {
        public var size:Int;                   /* (dword) Instrument size */
        public var filename:String;	//[12];   /* (char) Instrument filename */
        public var zerobyte:Int;               /* (byte) Instrument type (always 0) */
        //public var volflg:UBYTE;
        //public var volpts:UBYTE;   
        //public var volbeg:UBYTE;                 /* (byte) Volume loop start (node) */
        //public var volend:UBYTE;                 /* (byte) Volume loop end (node) */
        //public var volsusbeg:UBYTE;              /* (byte) Volume sustain begin (node) */
        //public var volsusend:UBYTE;              /* (byte) Volume Sustain end (node) */
        //public var panflg:UBYTE;
        //public var panpts:UBYTE;  
        //public var panbeg:UBYTE;                 /* (byte) channel loop start (node) */
        //public var panend:UBYTE;                 /* (byte) channel loop end (node) */
        //public var pansusbeg:UBYTE;              /* (byte) channel sustain begin (node) */
        //public var pansusend:UBYTE;              /* (byte) channel Sustain end (node) */
        //public var pitflg:UBYTE;
        //public var pitpts:UBYTE;   
        //public var pitbeg:UBYTE;                 /* (byte) pitch loop start (node) */
        //public var pitend:UBYTE;                 /* (byte) pitch loop end (node) */
        //public var pitsusbeg:UBYTE;              /* (byte) pitch sustain begin (node) */
        //public var pitsusend:UBYTE;              /* (byte) pitch Sustain end (node) */
        public var blank:Int;
        public var globvol:Int;
        public var chanpan:Int;
        public var fadeout:Int;                /* Envelope end / NNA volume fadeout */
        public var dnc:Int;                    /* Duplicate note check */
        public var dca:Int;                    /* Duplicate check action */
        public var dct:Int;                    /* Duplicate check type */
        public var nna:Int;                    /* New Note Action [0,1,2,3] */
        public var trkvers:Int;                /* tracker version used to save [files only] */
        public var ppsep:Int;                  /* Pitch-pan Separation */
        public var ppcenter:Int;               /* Pitch-pan Center */
        public var rvolvar:Int;                /* random volume varations */
        public var rpanvar:Int;                /* random panning varations */
        public var numsmp:Int;                 /* Number of samples in instrument [files only] */
        public var name:String;			//[26];               /* Instrument name */
        public var blank01:Array<Int>;	//[6];
        public var samptable:Array<Int>;	//[ITNOTECNT];/* sample for each note [note / samp pairs] */
        public var volenv:Array<Int>;		//[200];         /* volume envelope (IT 1.x stuff) */
        public var oldvoltick:Array<Int>;	//[ITENVCNT];/* volume tick position (IT 1.x stuff) */
        //public var volnode:Array<UBYTE>;	//[ITENVCNT];   /* amplitude of volume nodes */
        //public var voltick:Array<UWORD>;	//[ITENVCNT];   /* tick value of volume nodes */
        //public var pannode:Array<SBYTE>;	//[ITENVCNT];   /* panenv - node points */
        //public var pantick:Array<UWORD>;	//[ITENVCNT];   /* tick value of panning nodes */
        //public var pitnode:Array<SBYTE>;	//[ITENVCNT];   /* pitchenv - node points */
        //public var pittick:Array<UWORD>;	//[ITENVCNT];   /* tick value of pitch nodes */
	public var vol_env:ItEnvelope;
	public var pan_env:ItEnvelope;
	public var pit_env:ItEnvelope;

	public function new() {
	   vol_env=new ItEnvelope();
	   pan_env=new ItEnvelope();
	   pit_env=new ItEnvelope();
	   oldvoltick=new Array();
	}
}

class ItEnvelope {
	public var node:Array<Int>;
	public var tick:Array<Int>;
        public var flg:Int;
        public var pts:Int;   
        public var beg:Int;
        public var end:Int;
        public var susbeg:Int;
        public var susend:Int;

	public function new() {
	   node=new Array();
	   tick=new Array();
	}
}


/* unpacked note */

class ITNOTE {
	public var note:Int;
	public var ins:Int;
	public var volpan:Int;
	public var cmd:Int;
	public var inf:Int;

	public function new() {
	   note=ins=volpan=cmd=inf=255;
	}
}


class ITLoader extends ModuleLoader {

   inline static var ITENVCNT=25;
   inline static var ITNOTECNT=120;


   /*========== Loader data */

   static var paraptr:Array<Int>=null;	/* parapointer array (see IT docs) */
   static var mh:ITHEADER=null;
   static var itpat:Array<ITNOTE>=null;		/* allocate to space for one full pattern */
   static var mask:Array<Int>=null;		/* arrays allocated to 64 elements and used for */
   static var last:Array<ITNOTE>=null;		/* uncompressing IT's pattern information */
   static var numtrk=0;
   static var old_effect:Int;  // unsigned	/* if set, use S3M old-effects stuffs */

   static var IT_Version=[
        "ImpulseTracker x.xx",
        "Compressed ImpulseTracker x.xx",
        "ImpulseTracker 2.14p3",
        "Compressed ImpulseTracker 2.14p3",
        "ImpulseTracker 2.14p4",
        "Compressed ImpulseTracker 2.14p4",
   ];


   /* table for porta-to-note command within volume/panning column */
   static var portatable = [0,1,4,8,16,32,64,96,128,255];

   /*========== Loader code */

   override public function Test():Bool {
        var id:String=MLoader.modreader._mm_read_string(4);
	if (id==null) return false;
	return (id=="IMPM");
   }

   override public function Init():Bool {
	if ((mh=new ITHEADER())==null) return false;
	if ((MLutils.poslookup=new Array())==null) return false;
	if ((itpat=new Array())==null) return false;
	if ((mask=new Array())==null) return false;
	if ((last=new Array())==null) return false;
	for (i in 0 ... 64) last[i]=new ITNOTE();
        //if(!(mh=(ITHEADER*)_mm_malloc(sizeof(ITHEADER)))) return 0;
        //if(!(poslookup=(UBYTE*)_mm_malloc(256*sizeof(UBYTE)))) return 0;
        //if(!(itpat=(ITNOTE*)_mm_malloc(200*64*sizeof(ITNOTE)))) return 0;
        //if(!(mask=(UBYTE*)_mm_malloc(64*sizeof(UBYTE)))) return 0;
        //if(!(last=(ITNOTE*)_mm_malloc(64*sizeof(ITNOTE)))) return 0;
        return true;
   }


   override public function Cleanup() {
        MLutils.FreeLinear();
	mh=null;
	MLutils.poslookup=null;
	itpat=null;
	mask=null;
	last=null;
	paraptr=null;
	MLutils.origpositions=null;
   }


/* Because so many IT files have 64 channels as the set number used, but really
   only use far less (usually from 8 to 24 still), I had to make this function,
   which determines the number of channels that are actually USED by a pattern.
 
   NOTE: You must first seek to the file location of the pattern before calling
         this procedure.

   Returns 1 on error
*/

   static function IT_GetNumChannels(patrows:Int):Bool {
	var row=0;
	var flag:Int;
	var ch:Int;

        do {
                if((flag=MLoader.modreader._mm_read_UBYTE())==-1) {	// EOF?
                        MLoader.modreader._mm_errno = Defs.MMERR_LOADING_PATTERN;
                        return true;
                }
                if(flag==0)
                        row++;
                else {
                        ch=(flag-1)&63;
                        MLutils.remap[ch]=0;
                        if(flag & 128!=0) mask[ch]=MLoader.modreader._mm_read_UBYTE();
                        if(mask[ch]&1!=0)   MLoader.modreader._mm_read_UBYTE();
                        if(mask[ch]&2!=0)   MLoader.modreader._mm_read_UBYTE();
                        if(mask[ch]&4!=0)   MLoader.modreader._mm_read_UBYTE();
                        if(mask[ch]&8!=0) { MLoader.modreader._mm_read_UBYTE(); MLoader.modreader._mm_read_UBYTE(); }
                }
        } while(row<patrows);

        return false;
   }



   static function IT_ConvertTrack(tr:Array<ITNOTE>,tri:Int,numrows:Int):Int {
	//var t:Int;
	var note:Int;
	var ins:Int;
	var volpan:Int;

        MUnitrk.UniReset();

        for(t in 0 ... numrows) {
                note=tr[tri+t*MLoader.of.numchn].note;
                ins=tr[tri+t*MLoader.of.numchn].ins;
                volpan=tr[tri+t*MLoader.of.numchn].volpan;

                if(note!=255) {
                        if(note==253)
                                MUnitrk.UniWriteByte(Defs.UNI_KEYOFF);
                        else if(note==254) {
                                MLutils.UniPTEffect(0xc,-1);    /* note cut command */
                                volpan=255;
                        } else
                                MLutils.UniNote(note);
                }

                if((ins!=0)&&(ins<100))
                        MLutils.UniInstrument(ins-1);
                else if(ins==253)
                        MUnitrk.UniWriteByte(Defs.UNI_KEYOFF);
                else if(ins!=255) { /* crap */
                        MLoader.modreader._mm_errno=Defs.MMERR_LOADING_PATTERN;
                        return 0;
                }

                /* process volume / panning column
                   volume / panning effects do NOT all share the same memory address
                   yet. */
                if(volpan<=64) 
                        MLutils.UniVolEffect(Defs.VOL_VOLUME,volpan);
                else if(volpan==65) /* fine volume slide up (65-74) - A0 case */
                        MLutils.UniVolEffect(Defs.VOL_VOLSLIDE,0);
                else if(volpan<=74)     { /* fine volume slide up (65-74) - general case */
                        MLutils.UniVolEffect(Defs.VOL_VOLSLIDE,0x0f+((volpan-65)<<4));
                } else if(volpan==75)   /* fine volume slide down (75-84) - B0 case */
                        MLutils.UniVolEffect(Defs.VOL_VOLSLIDE,0);
                else if(volpan<=84) {   /* fine volume slide down (75-84) - general case*/
                        MLutils.UniVolEffect(Defs.VOL_VOLSLIDE,0xf0+(volpan-75));
                } else if(volpan<=94)   /* volume slide up (85-94) */
                        MLutils.UniVolEffect(Defs.VOL_VOLSLIDE,((volpan-85)<<4));
                else if(volpan<=104)/* volume slide down (95-104) */
                        MLutils.UniVolEffect(Defs.VOL_VOLSLIDE,(volpan-95));
                else if(volpan<=114)/* pitch slide down (105-114) */
                        MLutils.UniVolEffect(Defs.VOL_PITCHSLIDEDN,(volpan-105));
                else if(volpan<=124)/* pitch slide up (115-124) */
                        MLutils.UniVolEffect(Defs.VOL_PITCHSLIDEUP,(volpan-115));
                else if(volpan<=127) { /* crap */
                        MLoader.modreader._mm_errno=Defs.MMERR_LOADING_PATTERN;
                        return 0;
                } else if(volpan<=192)
                        MLutils.UniVolEffect(Defs.VOL_PANNING,((volpan-128)==64)?255:((volpan-128)<<2));
                else if(volpan<=202)/* portamento to note */
                        MLutils.UniVolEffect(Defs.VOL_PORTAMENTO,portatable[volpan-193]);
                else if(volpan<=212)/* vibrato */
                        MLutils.UniVolEffect(Defs.VOL_VIBRATO,(volpan-203));
                else if((volpan!=239)&&(volpan!=255)) { /* crap */
                        MLoader.modreader._mm_errno=Defs.MMERR_LOADING_PATTERN;
                        return 0;
                }

                MLutils.S3MIT_ProcessCmd(tr[tri+t*MLoader.of.numchn].cmd,tr[tri+t*MLoader.of.numchn].inf,
                    old_effect|Defs.S3MIT_IT);

                MUnitrk.UniNewline();
        }
        return MUnitrk.UniDup();
   }



   static function IT_ReadPattern(patrows:Int):Bool {
	var row=0;
	var flag:Int;
	var ch:Int;
	var blah:Int;
	var itt=itpat;  // ptr
	var dummy=new ITNOTE();
	var n:ITNOTE; // ptr
	var l:ITNOTE; // ptr
	var itti=0;

	for (i in 0 ... 200*64) itt[itti+i]=new ITNOTE();	//memset(itt,255,200*64*sizeof(ITNOTE));

        do {
                if((flag=MLoader.modreader._mm_read_UBYTE())==-1) {	// EOF?
                        MLoader.modreader._mm_errno = Defs.MMERR_LOADING_PATTERN;
                        return false;
                }
                if(flag==0) {
                        //itt=itt[MLoader.of.numchn];	//&
			itti+=MLoader.of.numchn;
                        row++;
                } else {
                        ch=MLutils.remap[(flag-1)&63];
                        if(ch!=-1) {
                                n=itt[itti+ch];	//&
                                l=last[ch];	//&
                        } else 
                                n=l=dummy;	//&

                        if(flag&128!=0) mask[ch]=MLoader.modreader._mm_read_UBYTE();
                        if(mask[ch]&1!=0)
                                /* convert IT note off to internal note off */
                                if((l.note=n.note=MLoader.modreader._mm_read_UBYTE())==255) 
                                        l.note=n.note=253;
                        if(mask[ch]&2!=0)
                                l.ins=n.ins=MLoader.modreader._mm_read_UBYTE();
                        if(mask[ch]&4!=0)
                                l.volpan=n.volpan=MLoader.modreader._mm_read_UBYTE();
                        if(mask[ch]&8!=0) {
                                l.cmd=n.cmd=MLoader.modreader._mm_read_UBYTE();
                                l.inf=n.inf=MLoader.modreader._mm_read_UBYTE();
                        }
                        if(mask[ch]&16!=0)
                                n.note=l.note;
                        if(mask[ch]&32!=0)
                                n.ins=l.ins;
                        if(mask[ch]&64!=0)
                                n.volpan=l.volpan;
                        if(mask[ch]&128!=0) {
                                n.cmd=l.cmd;
                                n.inf=l.inf;
                        }
                }
        } while(row<patrows);

        for(blah in 0 ... MLoader.of.numchn) {
                if(0==(MLoader.of.tracks[numtrk++]=IT_ConvertTrack(itpat,blah,patrows)))
                        return false;
        }

        return true;
   }


   static function LoadMidiString(modreader:DataReader):String {
        var s = modreader._mm_read_string(32);
        /* remove blanks and uppercase all */
	return s=~/[^0-9A-Za-z]/g.replace(s,"").toUpperCase();
        //while(*last) {
        //        if(isalnum((int)*last)) *(cur++)=toupper((int)*last);
        //        last++;
        //}
        //*cur=0;
   }


   /* Load embedded midi information for resonant filters */
   static function IT_LoadMidiConfiguration(modreader:DataReader) {
	MLutils.filtermacros=new Array();
	MLutils.filtersettings=new Array();
        //memset(filtermacros,0,sizeof(filtermacros));
        //memset(filtersettings,0,sizeof(filtersettings));

        if (modreader!=null) { /* information is embedded in file */
		var dat:Int;
		var midiline:String;	//33

                dat=modreader._mm_read_I_UWORD();
                modreader._mm_fseek(8*dat+0x120,SEEK_CUR);

                /* read midi macros */
                for(i in 0 ... Defs.UF_MAXMACRO) {
                        midiline=LoadMidiString(modreader);
			if (~/^F0F00/.match(midiline) &&		//if((!strncmp(midiline,"F0F00",5))&&
                           ((midiline.charAt(5)=="0")||(midiline.charAt(5)=="1")))
                                        MLutils.filtermacros[i]=(midiline.charCodeAt(5)-48 /*'0'*/)|0x80;
                }

                /* read standalone filters */
                for(i in 0x80 ... 0x100) {
                        midiline=LoadMidiString(modreader);
                        if(~/^F0F00/.match(midiline)&&
                           ((midiline.charAt(5)=="0")||(midiline.charAt(5)=="1"))) {
                                MLutils.filtersettings[i].filter=(midiline.charCodeAt(5)-48)|0x80;
				var six=midiline.charCodeAt(6);
                                dat=(six!=0 && six!=null)?(six-48):0;
				var seven=midiline.charCodeAt(7);
                                if(seven!=0)dat=(dat<<4)|(seven-48);
                                MLutils.filtersettings[i].inf=dat;
                        }
                }
        } else { /* use default information */
                MLutils.filtermacros[0]=Defs.FILT_CUT;
                for(i in 0x80 ... 0x90) {
                        MLutils.filtersettings[i].filter=Defs.FILT_RESONANT;
                        MLutils.filtersettings[i].inf=(i&0x7f)<<3;
                }
        }
        MLutils.activemacro=0;
        for(i in 0 ... 0x80) {
                MLutils.filtersettings[i].filter=MLutils.filtermacros[0];
                MLutils.filtersettings[i].inf=i;
        }
   }


   static function IT_LoadEnvelope(e:ItEnvelope,signed:Bool) {
   	e.flg=MLoader.modreader._mm_read_UBYTE();
	e.pts=MLoader.modreader._mm_read_UBYTE();
        e.beg=MLoader.modreader._mm_read_UBYTE();
        e.end=MLoader.modreader._mm_read_UBYTE();
        e.susbeg=MLoader.modreader._mm_read_UBYTE();
        e.susend=MLoader.modreader._mm_read_UBYTE();
        for(lp in 0 ... ITENVCNT) {
        	e.node[lp]=signed ? MLoader.modreader._mm_read_SBYTE() : MLoader.modreader._mm_read_UBYTE();
                e.tick[lp]=MLoader.modreader._mm_read_I_UWORD();
        }
        MLoader.modreader._mm_read_UBYTE();
   }



   static function IT_ProcessEnvelope(e:ItEnvelope,d:Envelope) {
      if(e.flg&1!=0) d.flg|=Defs.EF_ON;
      if(e.flg&2!=0) d.flg|=Defs.EF_LOOP;
      if(e.flg&4!=0) d.flg|=Defs.EF_SUSTAIN;
      d.pts=e.pts;
      d.beg=e.beg;
      d.end=e.end;
      d.susbeg=e.susbeg;
      d.susend=e.susend;
      for(u in 0 ... e.pts) d.env[u].pos=e.tick[u];
      if((d.flg&Defs.EF_ON)!=0&&(d.pts<2))
		d.flg&=~Defs.EF_ON;
   }





   override public function Load(curious:Bool):Bool {
	var t:Int;
	var u:Int;
	var lp:Int;
	//var d:INSTRUMENT;
	//var q:SAMPLE;
	var compressed=false;

        numtrk=0;
        MLutils.filters=false;

        /* try to read module header */
        MLoader.modreader._mm_read_I_ULONG();    /* kill the 4 byte header */
        mh.songname    = MLoader.modreader._mm_read_string(26);
        mh.blank01     = MLoader.modreader._mm_read_UBYTES(2);
        mh.ordnum      = MLoader.modreader._mm_read_I_UWORD();
        mh.insnum      = MLoader.modreader._mm_read_I_UWORD();
        mh.smpnum      = MLoader.modreader._mm_read_I_UWORD();
        mh.patnum      = MLoader.modreader._mm_read_I_UWORD();
        mh.cwt         = MLoader.modreader._mm_read_I_UWORD();
        mh.cmwt        = MLoader.modreader._mm_read_I_UWORD();
        mh.flags       = MLoader.modreader._mm_read_I_UWORD();
        mh.special     = MLoader.modreader._mm_read_I_UWORD();
        mh.globvol     = MLoader.modreader._mm_read_UBYTE();
        mh.mixvol      = MLoader.modreader._mm_read_UBYTE();
        mh.initspeed   = MLoader.modreader._mm_read_UBYTE();
        mh.inittempo   = MLoader.modreader._mm_read_UBYTE();
        mh.pansep      = MLoader.modreader._mm_read_UBYTE();
        mh.zerobyte    = MLoader.modreader._mm_read_UBYTE();
        mh.msglength   = MLoader.modreader._mm_read_I_UWORD();
        mh.msgoffset   = MLoader.modreader._mm_read_I_ULONG();
        mh.blank02     = MLoader.modreader._mm_read_UBYTES(4);
	
        mh.pantable=MLoader.modreader._mm_read_UBYTES(64);
        mh.voltable=MLoader.modreader._mm_read_UBYTES(64);

        if (MLoader.modreader.eof())
		{
			MLoader.modreader._mm_errno = Defs.MMERR_LOADING_HEADER;
			return false;
        }

        /* set module variables */
        MLoader.of.songname    = MLoader.DupStr(mh.songname,26,false); /* make a cstr of songname  */
        MLoader.of.reppos      = 0;
        MLoader.of.numpat      = mh.patnum;
        MLoader.of.numins      = mh.insnum;
        MLoader.of.numsmp      = mh.smpnum;
        MLoader.of.initspeed   = mh.initspeed;
        MLoader.of.inittempo   = mh.inittempo;
        MLoader.of.initvolume  = mh.globvol;
        MLoader.of.flags      |= Defs.UF_BGSLIDES | Defs.UF_ARPMEM;
        if ((mh.flags & 1)==0)
                        MLoader.of.flags |= Defs.UF_PANNING;
        MLoader.of.bpmlimit=32;

	var s25=mh.songname.charCodeAt(25);
        if(s25!=null && s25!=0) {
                MLoader.of.numvoices=1+s25;
                //fprintf(stderr,"Embedded IT limitation to %d voices\n",MLoader.of.numvoices);
        }

        /* set the module type */
        /* 2.17 : IT 2.14p4 */
        /* 2.16 : IT 2.14p3 with resonant filters */
        /* 2.15 : IT 2.14p3 (improved compression) */
        if((mh.cwt<=0x219)&&(mh.cwt>=0x217))
                MLoader.of.modtype=IT_Version[mh.cmwt<0x214?4:5];
        else if (mh.cwt>=0x215)
                MLoader.of.modtype=IT_Version[mh.cmwt<0x214?2:3];
        else {
                var mt=IT_Version[mh.cmwt<0x214?0:1];
		mt=~/x/.replace(mt,String.fromCharCode((mh.cwt>>8)+48));
		mt=~/x/.replace(mt,String.fromCharCode(((mh.cwt>>4)&0xf)+48));
		mt=~/x/.replace(mt,String.fromCharCode((mh.cwt&0xf)+48));
		MLoader.of.modtype=mt;
                //MLoader.of.modtype[mh.cmwt<0x214?15:26] = (mh.cwt>>8)+'0';
                //MLoader.of.modtype[mh.cmwt<0x214?17:28] = ((mh.cwt>>4)&0xf)+'0';
                //MLoader.of.modtype[mh.cmwt<0x214?18:29] = ((mh.cwt)&0xf)+'0';
        }

        if(mh.flags&8!=0)
                MLoader.of.flags |= Defs.UF_XMPERIODS | Defs.UF_LINEAR;

        if((mh.cwt>=0x106)&&(mh.flags&16)!=0)
                old_effect=Defs.S3MIT_OLDSTYLE;
        else
                old_effect=0;

        /* set panning positions */
        if (mh.flags&1!=0)
                for(t in 0 ... 64) {
                        mh.pantable[t]&=0x7f;
                        if(mh.pantable[t]<64)
                                MLoader.of.panning[t]=mh.pantable[t]<<2;
                        else if(mh.pantable[t]==64)
                                MLoader.of.panning[t]=255;
                        else if(mh.pantable[t]==100)
                                MLoader.of.panning[t]=Defs.PAN_SURROUND;
                        else if(mh.pantable[t]==127)
                                MLoader.of.panning[t]=Defs.PAN_CENTER;
                        else {
                                MLoader.modreader._mm_errno=Defs.MMERR_LOADING_HEADER;
                                return false;
                        }
                }
        else
                for (t in 0 ... 64)
					MLoader.of.panning[t]=Defs.PAN_CENTER;

        /* set channel volumes */
        //memcpy(MLoader.of.chanvol,mh->voltable,64);
	//MLoader.of.chanvol=mh.voltable;
	for (cpy in 0 ... 64) MLoader.of.chanvol[cpy]=mh.voltable[cpy];		// to be sure

        /* read the order data */
        if(!MLoader.AllocPositions(mh.ordnum)) return false;
        if(null==(MLutils.origpositions=new Array())) return false; // _mm_calloc(mh->ordnum,sizeof(UWORD)))) return 0;

        for(t in 0 ... mh.ordnum) {
			MLutils.origpositions[t] = MLoader.modreader._mm_read_UBYTE();
			if((MLutils.origpositions[t]>mh.patnum)&&(MLutils.origpositions[t]<254))
				MLutils.origpositions[t]=255;
        }

        if(MLoader.modreader.eof()) {
                MLoader.modreader._mm_errno = Defs.MMERR_LOADING_HEADER;
                return false;
        }

        MLutils.poslookupcnt=mh.ordnum;
        MLutils.S3MIT_CreateOrders(curious);

        //if(!(paraptr=(ULONG*)_mm_malloc((mh->insnum+mh->smpnum+MLoader.of.numpat)*
        //                               sizeof(ULONG)))) return 0;

        /* read the instrument, sample, and pattern parapointers */
        paraptr=MLoader.modreader._mm_read_I_ULONGS(mh.insnum+mh.smpnum+MLoader.of.numpat);

        if(MLoader.modreader.eof()) {
                MLoader.modreader._mm_errno = Defs.MMERR_LOADING_HEADER;
                return false;
        }

        /* Check for and load midi information for resonant filters */
        if(mh.cmwt>=0x216) {
                if(mh.special&8!=0) {
                        IT_LoadMidiConfiguration(MLoader.modreader);
                        if(MLoader.modreader.eof()) {
                                MLoader.modreader._mm_errno = Defs.MMERR_LOADING_HEADER;
                                return false;
                        }
                } else
                        IT_LoadMidiConfiguration(null);
                MLutils.filters=true;
        }

        /* Check for and load song comment */
        if((mh.special&1)!=0&&(mh.cwt>=0x104)&&(mh.msglength)!=0) {
                MLoader.modreader._mm_fseek(mh.msgoffset,SEEK_SET);
                if(!MLoader.ReadComment(mh.msglength)) return false;
        }

        if((mh.flags&4)==0) MLoader.of.numins=MLoader.of.numsmp;
        if(!MLoader.AllocSamples()) return false;

        if(MLutils.AllocLinear()==null) return false;

        /* Load all samples */
        //q = MLoader.of.samples;
	var qi=0;
        for(t in 0 ... mh.smpnum) {
                var s=new ITSAMPLE();
		var q=MLoader.of.samples[qi];

                /* seek to sample position */
                MLoader.modreader._mm_fseek(paraptr[mh.insnum+t]+4,SEEK_SET);

                /* load sample info */
                s.filename    = MLoader.modreader._mm_read_string(12);
                s.zerobyte    = MLoader.modreader._mm_read_UBYTE();
                s.globvol     = MLoader.modreader._mm_read_UBYTE();
                s.flag        = MLoader.modreader._mm_read_UBYTE();
                s.volume      = MLoader.modreader._mm_read_UBYTE();
                s.sampname    = MLoader.modreader._mm_read_string(26);
                s.convert     = MLoader.modreader._mm_read_UBYTE();
                s.panning     = MLoader.modreader._mm_read_UBYTE();
                s.length      = MLoader.modreader._mm_read_I_ULONG();
                s.loopbeg     = MLoader.modreader._mm_read_I_ULONG();
                s.loopend     = MLoader.modreader._mm_read_I_ULONG();
                s.c5spd       = MLoader.modreader._mm_read_I_ULONG();
                s.susbegin    = MLoader.modreader._mm_read_I_ULONG();
                s.susend      = MLoader.modreader._mm_read_I_ULONG();
                s.sampoffset  = MLoader.modreader._mm_read_I_ULONG();
                s.vibspeed    = MLoader.modreader._mm_read_UBYTE();
                s.vibdepth    = MLoader.modreader._mm_read_UBYTE();
                s.vibrate     = MLoader.modreader._mm_read_UBYTE();
                s.vibwave     = MLoader.modreader._mm_read_UBYTE();

                /* Generate an error if c5spd is > 512k, or samplelength > 256 megs
                   (nothing would EVER be that high) */

                if(MLoader.modreader.eof()||(s.c5spd>0x7ffff)/*||(s.length>0xfffffff)*/) {	// ???
                        MLoader.modreader._mm_errno = Defs.MMERR_LOADING_SAMPLEINFO;
                        return false;
                }

                /* Reality check for sample loop information */
		/*
                if((s.flag&16)!=0&&
                   ((s.loopbeg>0xfffffff)||(s.loopend>0xfffffff))) {
                        _mm_errno = MMERR_LOADING_SAMPLEINFO;
                        return 0;
                }
		*/

                q.samplename = MLoader.DupStr(s.sampname,26,false);
                q.speed      = Std.int(s.c5spd / 2);
                q.panning    = ((s.panning&127)==64)?255:(s.panning&127)<<2;
                q.length     = s.length;
                q.loopstart  = s.loopbeg;
                q.loopend    = s.loopend;
                q.volume     = s.volume;
                q.globvol    = s.globvol;
                q.seekpos    = s.sampoffset;

                /* Convert speed to XM linear finetune */
                if(MLoader.of.flags&Defs.UF_LINEAR!=0)
                        q.speed=MLutils.speed_to_finetune(s.c5spd,t);

                if(s.panning&128!=0) q.flags|=Defs.SF_OWNPAN;

                if(s.vibrate!=0) {
                        q.vibflags |= Defs.AV_IT;
                        q.vibtype   = s.vibwave;
                        q.vibsweep  = s.vibrate * 2;
                        q.vibdepth  = s.vibdepth;
                        q.vibrate   = s.vibspeed;
                }

                if(s.flag&2!=0) q.flags|=Defs.SF_16BITS;
                if((s.flag&8)!=0&&(mh.cwt>=0x214)) {
                        q.flags|=Defs.SF_ITPACKED;
                        compressed=true;
                }
                if(s.flag&16!=0) q.flags|=Defs.SF_LOOP;
                if(s.flag&64!=0) q.flags|=Defs.SF_BIDI;

                if(mh.cwt>=0x200) {
                        if(s.convert&1!=0) q.flags|=Defs.SF_SIGNED;
                        if(s.convert&4!=0) q.flags|=Defs.SF_DELTA;   
                }
                qi++;
        }

        /* Load instruments if instrument mode flag enabled */
	var di=0;
        if(mh.flags&4!=0) {
                if(!MLoader.AllocInstruments()) return false;
                //d=MLoader.of.instruments;
                MLoader.of.flags|=Defs.UF_NNA|Defs.UF_INST;

                for(t in 0 ... mh.insnum) {
                        var ih=new ITINSTHEADER();

			var d=MLoader.of.instruments[di];
                        /* seek to instrument position */
                        MLoader.modreader._mm_fseek(paraptr[t]+4,SEEK_SET);

                        /* load instrument info */
                        ih.filename  = MLoader.modreader._mm_read_string(12);
                        ih.zerobyte  = MLoader.modreader._mm_read_UBYTE();
                        if(mh.cwt<0x200) {
                                /* load IT 1.xx inst header */
                                ih.vol_env.flg    = MLoader.modreader._mm_read_UBYTE();
                                ih.vol_env.beg    = MLoader.modreader._mm_read_UBYTE();
                                ih.vol_env.end    = MLoader.modreader._mm_read_UBYTE();
                                ih.vol_env.susbeg = MLoader.modreader._mm_read_UBYTE();
                                ih.vol_env.susend = MLoader.modreader._mm_read_UBYTE();
													MLoader.modreader._mm_read_I_UWORD();
                                ih.fadeout   = MLoader.modreader._mm_read_I_UWORD();
                                ih.nna       = MLoader.modreader._mm_read_UBYTE();
                                ih.dnc       = MLoader.modreader._mm_read_UBYTE();
                        } else {
                                /* Read IT200+ header */
                                ih.nna       = MLoader.modreader._mm_read_UBYTE();
                                ih.dct       = MLoader.modreader._mm_read_UBYTE();
                                ih.dca       = MLoader.modreader._mm_read_UBYTE();
                                ih.fadeout   = MLoader.modreader._mm_read_I_UWORD();
                                ih.ppsep     = MLoader.modreader._mm_read_UBYTE();
                                ih.ppcenter  = MLoader.modreader._mm_read_UBYTE();
                                ih.globvol   = MLoader.modreader._mm_read_UBYTE();
                                ih.chanpan   = MLoader.modreader._mm_read_UBYTE();
                                ih.rvolvar   = MLoader.modreader._mm_read_UBYTE();
                                ih.rpanvar   = MLoader.modreader._mm_read_UBYTE();
                        }

                        ih.trkvers   = MLoader.modreader._mm_read_I_UWORD();
                        ih.numsmp    = MLoader.modreader._mm_read_UBYTE();
                        MLoader.modreader._mm_read_UBYTE();
                        ih.name=MLoader.modreader._mm_read_string(26);
                        ih.blank01=MLoader.modreader._mm_read_UBYTES(6);
                        ih.samptable=MLoader.modreader._mm_read_I_UWORDS(ITNOTECNT);
                        if(mh.cwt<0x200) {
                                /* load IT 1xx volume envelope */
                                ih.volenv=MLoader.modreader._mm_read_UBYTES(200);
                                for(lp in 0 ... ITENVCNT) {
                                        ih.oldvoltick[lp] = MLoader.modreader._mm_read_UBYTE();
                                        ih.vol_env.node[lp]    = MLoader.modreader._mm_read_UBYTE();
                                } 
                        } else {
                                /* load IT 2xx volume, pan and pitch envelopes */

                                IT_LoadEnvelope(ih.vol_env,false);
                                IT_LoadEnvelope(ih.pan_env,true);
                                IT_LoadEnvelope(ih.pit_env,true);
                        }
 
                        if(MLoader.modreader.eof()) {
                                MLoader.modreader._mm_errno = Defs.MMERR_LOADING_SAMPLEINFO;
                                return false;
                        }

                        d.vol_env.flg|=Defs.EF_VOLENV;
                        d.insname = MLoader.DupStr(ih.name,26,false);
                        d.nnatype = ih.nna & Defs.NNA_MASK;

                        if(mh.cwt<0x200) {
                                d.volfade=ih.fadeout<< 6;
                                if(ih.dnc!=0) {
                                        d.dct=Defs.DCT_NOTE;
                                        d.dca=Defs.DCA_CUT;
                                }

                                if(ih.vol_env.flg&1!=0) d.vol_env.flg|=Defs.EF_ON;
                                if(ih.vol_env.flg&2!=0) d.vol_env.flg|=Defs.EF_LOOP;
                                if(ih.vol_env.flg&4!=0) d.vol_env.flg|=Defs.EF_SUSTAIN;      

                                /* XM conversion of IT envelope Array */
                                d.vol_env.beg    = ih.vol_env.beg;   
                                d.vol_env.end    = ih.vol_env.end;
                                d.vol_env.susbeg = ih.vol_env.susbeg;
                                d.vol_env.susend = ih.vol_env.susend;

                                if(ih.vol_env.flg&1!=0) {
                                        for(u in 0 ... ITENVCNT)
                                                if(ih.oldvoltick[d.vol_env.pts]!=0xff) {
                                                        d.vol_env.env[d.vol_env.pts].val=(ih.vol_env.node[d.vol_env.pts]<<2);
                                                        d.vol_env.env[d.vol_env.pts].pos=ih.oldvoltick[d.vol_env.pts];
                                                        d.vol_env.pts++;
                                                } else
                                                        break;
                                }  
                        } else {
                                d.panning=((ih.chanpan&127)==64)?255:(ih.chanpan&127)<<2;
                                if((ih.chanpan&128)==0) d.flags|=Defs.IF_OWNPAN;

                                if((ih.ppsep & 128)==0) {
                                        d.pitpansep=ih.ppsep<<2;
                                        d.pitpancenter=ih.ppcenter;
                                        d.flags|=Defs.IF_PITCHPAN;
                                }
                                d.globvol=ih.globvol>>1;
                                d.volfade=ih.fadeout<<5;
                                d.dct    =ih.dct;
                                d.dca    =ih.dca;

                                if(mh.cwt>=0x204) {
                                        d.rvolvar = ih.rvolvar;
                                        d.rpanvar = ih.rpanvar;
                                }


                                IT_ProcessEnvelope(ih.vol_env,d.vol_env);
                                for(u in 0 ... ih.vol_env.pts)
                                        d.vol_env.env[u].val=(ih.vol_env.node[u]<<2);

                                IT_ProcessEnvelope(ih.pan_env,d.pan_env);
                                for(u in 0 ... ih.pan_env.pts)
                                        d.pan_env.env[u].val=
                                          ih.pan_env.node[u]==32?255:(ih.pan_env.node[u]+32)<<2;

                                IT_ProcessEnvelope(ih.pit_env,d.pit_env);
                                for(u in 0 ... ih.pit_env.pts)
                                        d.pit_env.env[u].val=ih.pit_env.node[u]+32;

                                if(ih.pit_env.flg&0x80!=0) {
                                        /* filter envelopes not supported yet */
                                        d.pit_env.flg&=~Defs.EF_ON;
                                        ih.pit_env.pts=ih.pit_env.beg=ih.pit_env.end=0;
					// warning "Filter envelopes not supported yet"
                                }
                        }

                        for(u in 0 ... ITNOTECNT) {
                                d.samplenote[u]=(ih.samptable[u]&255);
                                d.samplenumber[u]=
                                  (ih.samptable[u]>>8)!=0?((ih.samptable[u]>>8)-1):0xffff;
                                if(d.samplenumber[u]>=MLoader.of.numsmp)
                                        d.samplenote[u]=255;
                                else if (MLoader.of.flags&Defs.UF_LINEAR!=0) {
                                        var note=d.samplenote[u]+MLutils.noteindex[d.samplenumber[u]];
                                        d.samplenote[u]=(note<0)?0:(note>255?255:note);
                                }
                        }

                        di++;                  
                }
        } else if(MLoader.of.flags & Defs.UF_LINEAR!=0) {
                if(!MLoader.AllocInstruments()) return false;
                var d=MLoader.of.instruments[di];
                MLoader.of.flags|=Defs.UF_INST;

                for(t in 0 ... mh.smpnum) { // d++
                        for(u in 0 ... ITNOTECNT) {
                                if(d.samplenumber[u]>=MLoader.of.numsmp)
                                        d.samplenote[u]=255;
                                else {
                                        var note=d.samplenote[u]+MLutils.noteindex[d.samplenumber[u]];
                                        d.samplenote[u]=(note<0)?0:(note>255?255:note);
                                }
                        }
		di++;	// for loop
		}
        }

        /* Figure out how many channels this song actually uses */
        MLoader.of.numchn=0;
        //memset(remap,-1,UF_MAXCHAN*sizeof(UBYTE));
	for (t in 0 ... Defs.UF_MAXCHAN) MLutils.remap[t]=-1;
        for(t in 0 ... MLoader.of.numpat) {
                var packlen:Int;

                /* seek to pattern position */
                if(paraptr[mh.insnum+mh.smpnum+t]!=0) { /* 0 -> empty 64 row pattern */
                        MLoader.modreader._mm_fseek(paraptr[mh.insnum+mh.smpnum+t],SEEK_SET);
                        MLoader.modreader._mm_read_I_UWORD();
                        /* read pattern length (# of rows)
                           Impulse Tracker never creates patterns with less than 32 rows,
                           but some other trackers do, so we only check for more than 256
                           rows */
                        packlen=MLoader.modreader._mm_read_I_UWORD();
                        if(packlen>256) {
                                MLoader.modreader._mm_errno=Defs.MMERR_LOADING_PATTERN;
                                return false;
                        }
                        MLoader.modreader._mm_read_I_ULONG();
                        if(IT_GetNumChannels(packlen)) return false;
                }
        }

        /* give each of them a different number */
        for(t in 0 ... Defs.UF_MAXCHAN) 
                if(MLutils.remap[t]==0)
                        MLutils.remap[t]=MLoader.of.numchn++;

        MLoader.of.numtrk = MLoader.of.numpat*MLoader.of.numchn;
        if(MLoader.of.numvoices!=0)
                if (MLoader.of.numvoices<MLoader.of.numchn) MLoader.of.numvoices=MLoader.of.numchn;

        if(!MLoader.AllocPatterns()) return false;
        if(!MLoader.AllocTracks()) return false;

        for(t in 0 ... MLoader.of.numpat) {
                var packlen:Int;

                /* seek to pattern position */
                if(paraptr[mh.insnum+mh.smpnum+t]==0) { /* 0 -> empty 64 row pattern */
                        MLoader.of.pattrows[t]=64;
                        for(u in 0 ... MLoader.of.numchn) {
                                MUnitrk.UniReset();
                                for(k in 0 ... 64) MUnitrk.UniNewline();
                                MLoader.of.tracks[numtrk++]=MUnitrk.UniDup();
                        }
                } else {
                        MLoader.modreader._mm_fseek(paraptr[mh.insnum + mh.smpnum + t], SEEK_SET);
                        packlen = MLoader.modreader._mm_read_I_UWORD();
                        MLoader.of.pattrows[t] = MLoader.modreader._mm_read_I_UWORD();
                        MLoader.modreader._mm_read_I_ULONG();
                        if(!IT_ReadPattern(MLoader.of.pattrows[t])) return false;
                }
        }

        return true;
   }



   override public function LoadTitle():String {
        MLoader.modreader._mm_fseek(4,SEEK_SET);
	var s=MLoader.modreader._mm_read_string(26);
	if (s==null) return null;
        return(MLoader.DupStr(s,26,false));
   }

   /*========== Loader information */

   public function new() {
	type="IT";
	version="IT (Impulse Tracker)";
   }



}
