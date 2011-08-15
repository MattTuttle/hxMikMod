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

package hxmikmod;

import hxmikmod.structure.Sample;
import hxmikmod.Defs;
import hxmikmod.DataReader;
import flash.utils.ByteArray;
import hxmikmod.event.TrackerEvent;
import hxmikmod.event.TrackerEventDispatcher;
import hxmikmod.Mem;

/* IT-Compressed status structure */
class ITPACK
{
	public var bits:Int;
	
	/* current number of bits */
	public var bufbits:Int;
	
	/* bits in buffer */
	public var last:Int;
	
	/* last output */
	public var buf:Int;
	
	/* bit buffer */
	public function new()
	{
	}
}

class SLoader
{
	static var musiclist:Array<SampleLoad>;
	static var sndfxlist:Array<SampleLoad>;
	static var sl_rlength:Int;
	static var sl_old:Int;
	static var sl_buffer:Array<Int>;
	
	/* size of the loader buffer in words */
	inline static var SLBUFSIZE=16384;
	public static function reset()
	{
		// new song
		stage_LoadSamples=0;
		stage_DitherSamples2=0;
		MDriver._mm_reset();
	}

	public static function SL_Init(s:SampleLoad):Bool
	{
		var i:Int;
		if(sl_buffer==null)
		{
			sl_buffer=new Array<Int>();
		}

		sl_rlength = s.length;
		if (s.infmt & Defs.SF_16BITS!=0) sl_rlength>>=1;
		sl_old = 0;
		return true;
	}

	public static function SL_Exit(s:SampleLoad)
	{
		if(sl_rlength>0) s.reader._mm_fseek(sl_rlength,SEEK_CUR);
		if(sl_buffer!=null)
		{
			sl_buffer=null;
		}
	}

	static function FreeSampleList(s:Array<SampleLoad>)
	{
		var i:Int;
		for (i in 0 ... s.length) s[i]=null;
	}

	static function RealSpeed(s:SampleLoad):Int
	{
		return Std.int(s.sample.speed/(s.scalefactor!=0?s.scalefactor:1));
	}

	static function SL_Sample16to8(s:SampleLoad)
	{
		s.outfmt &= ~Defs.SF_16BITS;
		s.sample.flags = (s.sample.flags&~Defs.SF_FORMATMASK) | s.outfmt;
	}

	public static function SL_Sample8to16(s:SampleLoad)
	{
		s.outfmt |= Defs.SF_16BITS;
		s.sample.flags = (s.sample.flags&~Defs.SF_FORMATMASK) | s.outfmt;
	}

	public static function SL_SampleSigned(s:SampleLoad)
	{
		s.outfmt |= Defs.SF_SIGNED;
		s.sample.flags = (s.sample.flags&~Defs.SF_FORMATMASK) | s.outfmt;
	}

	static function SL_SampleUnsigned(s:SampleLoad)
	{
		s.outfmt &= ~Defs.SF_SIGNED;
		s.sample.flags = (s.sample.flags&~Defs.SF_FORMATMASK) | s.outfmt;
	}

	// LoadSamples task split to smaller parts so that this method
	// is called repeatedly.
	// return values: 0=no error, not complete, 1=complete ok, -1=error
	static var stage_LoadSamples:Int;
	public static function SL_LoadSamples():Int
	{
		var prog:Int;
		switch(stage_LoadSamples)
		{
			case 0:
				if ((musiclist == null) && (sndfxlist == null))
					return 1;
					
				prog = DitherSamples(musiclist, Defs.MD_MUSIC);
				if (prog == -1) return -1;
				prog = DitherSamples(sndfxlist, Defs.MD_SNDFX);
				if (prog == -1) return -1;
				
				stage_LoadSamples++;
				return 0;
			case 1:
				prog = DitherSamples2(musiclist, Defs.MD_MUSIC);
				if (prog <= 0)
					return prog;
			case 2:
				prog = DitherSamples2(sndfxlist, Defs.MD_SNDFX);
				if (prog <= 0) return prog;
				stage_LoadSamples++;
				return 0;
		}
		
		musiclist = sndfxlist = null;
		return 1;
	}

	static function SL_HalveSample(s:SampleLoad,factor:Int)
	{
		s.scalefactor=factor>0?factor:2;
		s.sample.divfactor = s.scalefactor;
		s.sample.length    = Std.int(s.length / s.scalefactor);
		s.sample.loopstart = Std.int(s.loopstart / s.scalefactor);
		s.sample.loopend   = Std.int(s.loopend / s.scalefactor);
	}

	
	/* Returns the total amount of memory required by the samplelist queue. */
	static function SampleTotal(samplist:Array<SampleLoad>,type:Int):Int
	{
		var total = 0;
		var i:Int;
		for (i in 0 ... samplist.length)
		{
			samplist[i].sample.flags=
						                  (samplist[i].sample.flags&~Defs.SF_FORMATMASK)|samplist[i].outfmt;
			total += MDriver.MD_SampleLength(type,samplist[i].sample);
		}

		return total;
	}

	public static function SL_Load(buffer:Int,smp:SampleLoad,length:Int):Bool
	{
		return SL_LoadInternal(buffer, smp.infmt, smp.outfmt, smp.scalefactor, length, smp.reader, false);
	}

	// haXifying IT compression requires some signedness tricks, I'm not 100%
	// sure these work universally
	inline static function sword(x:Int)
	{
		x&=0xffff;
		if (x>=32768) x-=65536;
		return x;
	}

	inline static function sbyte(x:Int)
	{
		x&=0xff;
		if (x>=128) x-=256;
		return x;
	}

	static function read_itcompr8(status:ITPACK, reader:DataReader, sl_buffer:Array<Int>, count:Int, incnt:Array<Int>):Int
	{
		//Int *dest=sl_buffer,*end=sl_buffer+count;
		var desti=0;
		var x:Int;
		var y:Int;
		var needbits:Int;
		var havebits:Int;
		var new_count=false;
		var bits = status.bits;
		var bufbits = status.bufbits;
		var last = status.last;
		var buf = status.buf;
		while (desti<count)
		{
			needbits=new_count?3:bits;
			x=havebits=0;
			while (needbits!=0)
			{
				
				/* feed buffer */
				if (bufbits==0)
				{
					if(incnt[0]--!=0)
						buf = reader._mm_read_UBYTE();
					else
						buf = 0;
					bufbits = 8;
				}

				
				/* get as many bits as necessary */
				y = needbits<bufbits?needbits:bufbits;
				if (y<=0)
				{
					trace("y="+y);
					return 0;
				}

				x|= (buf & ((1<<y)- 1))<<havebits;
				buf>>=y;
				bufbits-=y;
				needbits-=y;
				havebits+=y;
			}

			if (new_count)
			{
				new_count = false;
				if (++x >= bits)
					x++;
				bits = x&0xffff;
				continue;
			}

			if (bits<7)
			{
				if (x==(1<<(bits-1)))
				{
					new_count=true;
					continue;
				}
			} else if (bits<9)
			{
				y = (0xff >> (9-bits)) - 4;
				if ((x>y)&&(x<=y+8))
				{
					if ((x -= y) >= bits)
						x++;
					bits = x&0xfff;
					continue;
				}
			} else if (bits<10)
			{
				if (x>=0x100)
				{
					bits=(x-0x100+1)&0xffff;
					continue;
				}
			} else
			{
				
				/* error in compressed data... */
				trace("it compr8 err desti="+desti+" bits="+bits+" bufbits="+bufbits);
				reader._mm_errno = Defs.MMERR_ITPACK_INVALID_DATA;
				return 0;
			}

			if (bits<8) 
						
			/* extend sign */
			x = (sbyte(x <<(8-bits))) >> (8-bits);
			//*(dest++)= (last+=x) << 8; /* convert to 16 bit */
			sl_buffer[desti++]=(last+=x)<<8;
			while (sl_buffer[desti-1]>=32768) sl_buffer[desti-1]-=65536;
		}

		status.bits = bits;
		status.bufbits = bufbits;
		status.last = last;
		status.buf = buf;
		return desti;
	}

	
	/* unpack a 16bit IT packed sample */
	static function read_itcompr16(status:ITPACK, reader:DataReader, sl_buffer:Array<Int>, count:Int, incnt:Array<Int>):Int
	{
		//Int *dest=sl_buffer,*end=sl_buffer+count;
		var desti=0;
		var x:Int;
		var y:Int;
		var needbits:Int;
		var havebits:Int;
		var new_count=false;
		var bits=status.bits&0xffff;
		var bufbits=status.bufbits;
		var last=status.last;
		var buf=status.buf;
		while (desti<count)
		{
			needbits=new_count?4:bits;
			x=havebits=0;
			while (needbits!=0)
			{
				
				/* feed buffer */
				if (bufbits==0)
				{
					if(incnt[0]--!=0)
										                                        buf=reader._mm_read_UBYTE(); else
										                                        buf=0;
					bufbits=8;
				}

				
				/* get as many bits as necessary */
				y=needbits<bufbits?needbits:bufbits;
				if (y<=0)
				{
					trace("needbits="+y);
					return 0;
				}

				x|=(buf&((1<<y)-1))<<havebits;
				buf>>=y;
				bufbits-=y;
				needbits-=y;
				havebits+=y;
			}

			if (new_count)
			{
				new_count = false;
				if (++x >= bits)
								                                x++;
				bits=x&0xffff;
				continue;
			}

			if (bits<7)
			{
				if (x==(1<<(bits-1)))
				{
					new_count=true;
					continue;
				}
			} else if (bits<17)
			{
				y=(0xffff>>(17-bits))-8;
				if ((x>y)&&(x<=y+16))
				{
					if ((x-=y)>=bits)
										                                        x++;
					bits = x&0xffff;
					continue;
				}
			} else if (bits<18)
			{
				if (x>=0x10000)
				{
					bits=(x-0x10000+1)&0xffff;
					continue;
				}
			} else
			{
				
				/* error in compressed data... */
				reader._mm_errno=Defs.MMERR_ITPACK_INVALID_DATA;
				trace("it compr16 err desti="+desti+" bits="+bits+" bufbits="+bufbits);
				return 0;
			}

			if (bits<16) 
						
			/* extend sign */
			{
				x = (sword(x<<(16-bits)))>>(16-bits);
			}

			sl_buffer[desti++]=(last+=x);
			while (sl_buffer[desti-1]>=32768) sl_buffer[desti-1]-=65536;
		}

		status.bits = bits;
		status.bufbits = bufbits;
		status.last = last;
		status.buf = buf;
		return desti;
	}

	public static function SL_LoadInternal(buffer:Int, infmt:Int, outfmt:Int, scalefactor:Int, length:Int, reader:DataReader, dither:Bool):Bool
	{
		var ptr=buffer;
		var stodo:Int;
		var u:Int;
		var ptri=buffer;
		var result:Int;
		var c_block=0;
		
		/* compression bytes until next block */
		var status:ITPACK=new ITPACK();
		var incnt=new Array<Int>();
		while(length!=0)
		{
			stodo=(length<SLBUFSIZE)?length:SLBUFSIZE;
			if(infmt&Defs.SF_ITPACKED!=0)
			{
				sl_rlength=0;
				if (c_block==0)
				{
					status.bits = (infmt & Defs.SF_16BITS!=0) ? 17 : 9;
					status.last = status.bufbits = 0;
					incnt[0]=reader._mm_read_I_UWORD();
					c_block = (infmt & Defs.SF_16BITS!=0) ? 0x4000 : 0x8000;
					if(infmt&Defs.SF_DELTA!=0) sl_old=0;
				}

				if (infmt & Defs.SF_16BITS!=0)
				{
					if((result=read_itcompr16(status,reader,sl_buffer,stodo,incnt))==0)
										                                        return true;
				} else
				{
					if((result=read_itcompr8(status,reader,sl_buffer,stodo,incnt))==0)
										                                        return true;
				}

				if(result!=stodo)
				{
					reader._mm_errno=Defs.MMERR_ITPACK_INVALID_DATA;
					return true;
				}

				c_block -= stodo;
			} else
			{
				if(infmt&Defs.SF_16BITS!=0)
				{
					//trace("in 16-bit");
					if(infmt&Defs.SF_BIG_ENDIAN!=0)
					{
						//trace("big endian");
						sl_buffer = reader._mm_read_M_SWORDS(stodo);
					} 
					else
					{
						//trace("little endian");
						sl_buffer=reader._mm_read_I_SWORDS(stodo);
					}
				} else
				{
					//trace("in 8-bit");
					var ba = new ByteArray();
					ba = reader._mm_read_ByteArray(stodo);
					for (t in 0...stodo)
					{
						sl_buffer[t]=ba.readByte();
						//signed
					}

					for (t in 0 ... stodo)
					{
						sl_buffer[t]<<=8;
					}
				}

				sl_rlength-=stodo;
			}

			if(infmt & Defs.SF_DELTA!=0)
			{
				//trace("delta");
				for (t in 0 ... stodo)
				{
					sl_buffer[t] += sl_old;
					if (sl_buffer[t]<-32768) sl_buffer[t]+=65536; else if (sl_buffer[t]>32767) sl_buffer[t]-=65536;
					sl_old = sl_buffer[t];
				}
			}

			if((infmt^outfmt) & Defs.SF_SIGNED!=0)
			{
				//trace("flip signedness, in signed="+(infmt&Defs.SF_SIGNED!=0));
				for (t in 0 ... stodo)
				{
					//sl_buffer[t]^= 0x8000;
					sl_buffer[t]=(sl_buffer[t]&0xffff)-0x8000;
					// will this work in all cases?
				}
			}

			if(scalefactor!=0)
			{
				var idx=0;
				var scaleval:Int;
				//trace("scalefactor "+scalefactor);
				
				/* Sample Scaling... average values for better results. */
				var y=0;
				while(y<stodo && length!=0)
				{
					scaleval = 0;
					//for(u=scalefactor;u && t<stodo;u--,t++)
					u=scalefactor;
					while(u!=0 && y<stodo)
					{
						scaleval+=sl_buffer[y];
						u--;
						y++;
					}

					sl_buffer[idx++]=Std.int(scaleval/(scalefactor-u));
					length--;
				}

				stodo = idx;
			} else
						                        length -= stodo;
			if (dither)
			{
				//trace("dither");
				if((infmt & Defs.SF_STEREO)!=0 && (outfmt & Defs.SF_STEREO)==0)
				{
					
					/* dither stereo to mono, average together every two samples */
					var avgval:Int;
					var idx=0;
					var t=0;
					while(t<stodo && length!=0)
					{
						avgval=sl_buffer[t++];
						avgval+=sl_buffer[t++];
						sl_buffer[idx++]=avgval>>1;
						length-=2;
					}

					stodo = idx;
				}
			}

			if(outfmt & Defs.SF_16BITS!=0)
			{
				//trace("out 16-bit");
				for (t in 0 ... stodo)
				{
					var tmp:Float;
					Mem.setFloat(ptri,tmp=sl_buffer[t]/32768.0);
					ptri+=4;
				}
			} else
			{
				trace("out 8-bit??? untested");
				for (t in 0 ... stodo)
				{
					Mem.setFloat(ptri,sl_buffer[t]/128.0);
					ptri+=4;
				}
			}
		}

		return false;
	}

	// divided DitherSamples to 2 parts...
	static function DitherSamples(samplist:Array<SampleLoad>,type:Int):Int
	{
		var c2smp:SampleLoad;
		var maxsize:Int;
		var speed:Int;
		var si:Int;
		c2smp=null;
		if(samplist==null) return 1;
		Profiler.ENTER();
		if((maxsize=MDriver.MD_SampleSpace(type)*1024)!=0) 
				                while(SampleTotal(samplist,type)>maxsize)
		{
			
			/* First Pass - check for any 16 bit samples */
			si=0;
			//s = samplist;
			while(samplist[si]!=null)
			{
				var s=samplist[si];
				if(s.outfmt & Defs.SF_16BITS!=0)
				{
					SL_Sample16to8(s);
					break;
				}

				si++;
			}

			
			/* Second pass (if no 16bits found above) is to take the sample with
                           the highest speed and dither it by half. */
			if(samplist[si]==null)
			{
				//s = samplist;
				si=0;
				speed = 0;
				while(samplist[si]!=null)
				{
					var s=samplist[si];
					if((s.sample.length!=0) && (RealSpeed(s)>speed))
					{
						speed=RealSpeed(s);
						c2smp=s;
					}

					si++;
				}

				if (c2smp!=null)
								                                        SL_HalveSample(c2smp,2);
			}
		}

		Profiler.LEAVE();
		return 1;
	}

	static var stage_DitherSamples2:Int;
	static var sample_count:Int;
	static function DitherSamples2(samplist:Array<SampleLoad>,type:Int):Int
	{
		var si;
		Profiler.ENTER();
		
		/* Samples dithered, now load them ! */
		if (stage_DitherSamples2==0)
		{
			var si=0;
			while(samplist[si]!=null) si++;
			sample_count=si;
			si=0;
		}

		si=stage_DitherSamples2;
		if (samplist[si]!=null)
		{
			// while ...
			var s=samplist[si];
			var ns=samplist[si+1];
			if (ns!=null)
			{
				// the event will fire AFTER we return from this, so announce the NEXT sample
				var n = ns.sample.samplename;
				if (n == null || n == "") n = "processing samples";
				TrackerEventDispatcher.dispatchEvent(new TrackerLoadingEvent(TrackerLoadingEvent.PROGRESS, n, si/sample_count));
			}

			
			/* sample has to be loaded ? -> increase number of samples, allocate
                   memory and load sample. */
			if(s.sample.length!=0)
			{
				if (s.sample.seekpos != 0)
					s.reader._mm_fseek(s.sample.seekpos, SEEK_SET);
				
				/* Call the sample load routine of the driver module. It has to
                           return a 'handle' (>=0) that identifies the sample. */
				s.sample.handle = MDriver.MD_SampleLoad(s, type);
				s.sample.flags  = (s.sample.flags & ~Defs.SF_FORMATMASK) | s.outfmt;
				if(s.sample.handle<0)
				{
					FreeSampleList(samplist);
					s.reader.rollback();
					Profiler.LEAVE();
					return -1;
				}
			}

			stage_DitherSamples2++;
			Profiler.LEAVE();
			return 0;
			// means "more to do here"
			//si++;
		}

		FreeSampleList(samplist);
		Profiler.LEAVE();
		return 1;
	}

	
	/* Registers a sample for loading when SL_LoadSamples() is called. */
	public static function SL_RegisterSample(s:Sample, type:Int, reader:DataReader):SampleLoad
	{
		var samplist:Array<SampleLoad>;
		var news:SampleLoad;
		if(type==Defs.MD_MUSIC)
		{
			if (musiclist==null) musiclist=new Array();
			samplist = musiclist;
		} else
				          if (type==Defs.MD_SNDFX)
		{
			if (sndfxlist==null) sndfxlist=new Array();
			samplist = sndfxlist;
		} else
				                return null;
		
		/* Allocate and add structure to the END of the list */
		news=new SampleLoad();
		samplist.push(news);
		news.infmt     = s.flags & Defs.SF_FORMATMASK;
		news.outfmt    = news.infmt;
		news.reader    = reader;
		news.sample    = s;
		news.length    = s.length;
		news.loopstart = s.loopstart;
		news.loopend   = s.loopend;
		return news;
	}
}