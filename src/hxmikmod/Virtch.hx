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

import hxmikmod.Defs;
import hxmikmod.structure.Sample;
import hxmikmod.structure.VInfo;
import hxmikmod.event.TrackerEvent;
import hxmikmod.event.TrackerEventDispatcher;
import hxmikmod.Mem;
import flash.utils.Endian;
import flash.utils.ByteArray;
import flash.Memory;

class Virtch
{
	
	private static inline var MAXVOL_FACTOR = (1 << 9);
	private static inline var REVERBERATION = 11000;
	private static inline var FRACBITS = 12;
	public static inline var TICKLSIZE = 8192;
	
	// If Int=Float, set this to 0. Otherwise 12..13
	// e.g. Yuki Satellites won't work with 13 because of long samples
	public var buffer_size:Int;
	// No unsigned type in haXe so...
	// returns true if (unsigned)a > (unsigned)b.
	// Using this for sample index comparison allows us one
	// additional FRACBIT which means better accuracy.
	
	public function new (bufferSize:Int)
	{
		buffer_size = bufferSize;
	}
	
	private function greaterOrEqual(a:Int, b:Int):Bool
	{
		var result:Bool;
		if (a == b)
		{
			result = true;
		}
		else
		{
			result = (a > b);
			if (a < 0 || b < 0)
			{
				if (a < 0 && b < 0) result = !result;
				// both negative, invert result else result=(a<0);
				// one of them is negative, actually that's the greater one
			}
		}

		return result;
	}

	
	/*  

  // use this version if Int=Float

  inline static function greaterOrEqual(a:Float, b:Float):Bool {
	return (a>=b);
  }
  
*/
	// These convert between fractional sample index and
	// an integer. If Int=Float, it's just a matter of
	// Float->Int casting. For FFP it's a bit shift operation.
	private static inline function indexToSample(si:Int):Int
	{
		return FRACBITS == 0 ? si << 2 : (si >> (FRACBITS - 2)) & 0xfffffffc;
		// FRACBITS-2 because it's a byte index to a Float buf
	}

	public static inline function indexToSampleF(si:Int):Float
	{
		return FRACBITS == 0 ? si : si / (1 << FRACBITS);
	}

	public static inline function sampleToIndex(ti:Int):Int
	{
		return (ti << FRACBITS);
	}

	public static inline var MAXSAMPLEHANDLES = 384;
	private static inline var samplesthatfit=TICKLSIZE;
	
	private var vinf:Array<VInfo>;
	private var vnf:VInfo;
	private var tickleft:Int;
	private var vc_memory:Int;
	private var vc_softchn:Int;
	private var idxsize:Int;
	private var idxlpos:Int;
	private var idxlend:Int;
	private var vc_tickbuf:Int;
	// tickbuf always at the beginning of Mem.buf, size (TICKLSIZE+32)<<3
	private var vc_mode:Int;
	public var Samples:Array<Int>;
	// membuf index of sampledata start
	public var SampleNames:Array<String>;
	// jouko debug addition
	private var hqmix:Bool;
	
	// clickbuf, rampvol ... not really used at the moment
	public function VC_Init():Bool
	{
		Samples = new Array();
		for (i in 0 ... MAXSAMPLEHANDLES) Samples[i]=-1;
		SampleNames=new Array();
		//vc_memory=0; ???
		MDriver.md_mode |= Defs.DMODE_INTERP;
		vc_mode = MDriver.md_mode;
		return false;
	}

	// before loading a new song, free sample handles and memory
	public function VC_Reset()
	{
		for (i in 0 ... MAXSAMPLEHANDLES) Samples[i]=-1;
	}

	static inline function MixStereoNormal(srci:Int, desti:Int, todo:Int, vnf:VInfo)
	{
		var lvolsel = vnf.lvolsel / MAXVOL_FACTOR;
		var rvolsel = vnf.rvolsel / MAXVOL_FACTOR;
		var sample;
		desti <<= 3;
		//desti+=vc_tickbuf;	// tickbuf=0
		for (i in 0 ... todo)
		{
			sample = Memory.getFloat(srci + indexToSample(vnf.current));
			vnf.current += vnf.increment;
			Memory.setFloat(desti, Memory.getFloat(desti) + lvolsel * sample);
			desti += 4;
			Memory.setFloat(desti, Memory.getFloat(desti) + rvolsel * sample);
			desti += 4;
		}
	}

	
	/*

   static function hqMixStereoNormal(srce:Array<Int>,dest:Array<Float>,desti:Int,index:Int,increment:Int,todo:Int):Int {
	Profiler.ENTER();		
	var sample=0;
	var desti2=desti<<1;
	for (i in 0 ... todo) {
		sample=srce[indexToSample(index)];
                index += increment;

                if(hqmix && vnf.rampvol!=0) {
                        dest[desti2++] += (
                          ( ( (vnf.oldlvol*vnf.rampvol) +
                              (vnf.lvolsel*(CLICK_BUFFER-vnf.rampvol))
                            ) * sample ) >> CLICK_SHIFT );
                        dest[desti2++] += (
                          ( ( (vnf.oldrvol*vnf.rampvol) +
                              (vnf.rvolsel*(CLICK_BUFFER-vnf.rampvol))
                            ) * sample ) >> CLICK_SHIFT );
                        vnf.rampvol--;
                } else
                  if (hqmix && vnf.click!=0) {
                        dest[desti2++] += (
                          ( ( (vnf.lvolsel*(CLICK_BUFFER-vnf.click)) *
                              sample ) + (vnf.lastvalL * vnf.click) )
                            >> CLICK_SHIFT );
                        dest[desti2++] += (
                          ( ( (vnf.rvolsel*(CLICK_BUFFER-vnf.click)) *
                              sample ) + (vnf.lastvalR * vnf.click) )
                            >> CLICK_SHIFT );
                        vnf.click--;
                } else { 
                        dest[desti2++] +=vnf.lvolsel*sample;
                        dest[desti2++] +=vnf.rvolsel*sample;
                }
        }
        vnf.lastvalL=vnf.lvolsel*sample;
        vnf.lastvalR=vnf.rvolsel*sample;
	Profiler.LEAVE();
        return index;
}


*/

	function AddChannel(todo:Int)
	{
		var end:Int;
		var done:Int;
		var s:Int;
		var ptri=0;
		var endpos:Int;
		
		if ((s = Samples[vnf.handle]) == -1)
		{
			vnf.current=0;
			vnf.active=false;
			vnf.lastvalL = vnf.lastvalR = 0;
			return;
		}

		var reverse=(vnf.flags & Defs.SF_REVERSE)!=0;
		var loop=(vnf.flags & Defs.SF_LOOP)!=0;
		var bidi=(vnf.flags & Defs.SF_BIDI)!=0;
		
		/* update the 'current' index so the sample loops, or stops playing if it
           reached the end of the sample */
		while(todo > 0)
		{
			if (reverse)
			{
				
				/* The sample is playing in reverse */
				if (loop && !greaterOrEqual(vnf.current,idxlpos))
				{
					
					/* the sample is looping and has reached the loopstart index */
					if(bidi)
					{
						
						/* sample is doing bidirectional loops, so 'bounce' the
                                           current index against the idxlpos */
						vnf.current = idxlpos+(idxlpos-vnf.current);
						//vnf.flags &= ~Defs.SF_REVERSE;
						reverse=false;
						vnf.increment = -vnf.increment;
					} else
					                                        
					/* normal backwards looping, so set the current position to
                                           loopend index */
					vnf.current=idxlend-(idxlpos-vnf.current);
				}
				else
				{
					
					/* the sample is not looping, so check if it reached index 0 */
					if(vnf.current <= 0 && vnf.current-vnf.increment>0)
					{
						// suspicious unsignedness fix
						
						/* playing index reached 0, so stop playing this sample */
						vnf.current=0;
						vnf.active=false;
						break;
					}
				}
			}
			else
			{
				
				/* The sample is playing forward */
				if (loop && (greaterOrEqual(vnf.current,idxlend)))
				{
					
					/* the sample is looping, check the loopend index */
					if (bidi)
					{
						
						/* sample is doing bidirectional loops, so 'bounce' the
                                           current index against the idxlend */
						//vnf.flags |= Defs.SF_REVERSE;
						reverse=true;
						vnf.increment = -vnf.increment;
						vnf.current = idxlend-(vnf.current-idxlend);
					} else
					                                        
					/* normal backwards looping, so set the current position
                                           to loopend index */
					vnf.current=idxlpos+(vnf.current-idxlend);
				}
				else
				{
					
					/* sample is not looping, so check if it reached the last
                                   position */
					if(greaterOrEqual(vnf.current,idxsize))
					{
						
						/* yes, so stop playing this sample */
						vnf.current=0;
						vnf.active=false;
						break;
					}
				}
			}

			end = reverse ? (loop ? idxlpos : 0) : (loop ? idxlend : idxsize);
			
			/* if the sample is not blocked... */
			if (end == vnf.current || vnf.increment == 0)
			{
				done = 0;
			}
			else
			{
				//done=Std.int(Math.min((end-vnf.current)/vnf.increment+1,todo));
				var a = Std.int((end - vnf.current) / vnf.increment + 1);
				//if (a<todo) done=a; else done=todo;
				if (greaterOrEqual(todo, a))
					done = a;
				else
					done = todo;
				// hmm ?
				if (done<0) done=0;
			}

			if (done==0)
			{
				vnf.active=false;
				break;
			}

			endpos = vnf.current + done * vnf.increment;
			if (vnf.vol != 0 || vnf.rampvol != 0)
			{
				MixStereoNormal(s, ptri, done, vnf);
			}
			else
			{
				vnf.lastvalL = vnf.lastvalR = 0;
				
				/* update sample position */
				vnf.current = endpos;
			}

			todo -= done;
			ptri += done;
		}

		if (reverse)
			vnf.flags |= Defs.SF_REVERSE;
		else
			vnf.flags &= ~Defs.SF_REVERSE;
	}

	private function clearTickBuf(len:Int)
	{
		Mem.clearFloat(vc_tickbuf,len<<3);
	}

	public function VC_SampleLoad(sload:SampleLoad,type:Int):Int
	{
		var s = sload.sample;
		var handle:Int;
		var t:Int;
		var length:Int;
		var loopstart:Int;
		var loopend:Int;
		if(type==Defs.MD_HARDWARE) return -1;
		
		/* Find empty slot to put sample address in */
		t=MAXSAMPLEHANDLES;
		for (handle in 0 ... MAXSAMPLEHANDLES)
		                if(Samples[handle]==-1)
		{
			t=handle;
			break;
		}

		handle=t;
		if(handle==MAXSAMPLEHANDLES)
		{
			sload.reader._mm_errno = Defs.MMERR_OUT_OF_HANDLES;
			return -1;
		}

		
		/* Reality check for loop settings */
		if (s.loopend > s.length)
		                s.loopend = s.length;
		if (s.loopstart >= s.loopend)
		                s.flags &= ~Defs.SF_LOOP;
		length    = s.length;
		loopstart = s.loopstart;
		loopend   = s.loopend;
		SLoader.SL_SampleSigned(sload);
		SLoader.SL_Sample8to16(sload);
		
		/*
        if(!(Samples[handle]=(Int*)_mm_malloc((length+20)<<1))) {
                _mm_errno = MMERR_SAMPLE_TOO_BIG;
                return -1;
        }
	*/
		Samples[handle]=Mem.alloc((length+20)<<2);
		SampleNames[handle]=s.samplename;
		
		/* read sample into buffer */
		if (SLoader.SL_Load(Samples[handle],sload,length))
		                return -1;
		
		/* Unclick sample */
		if(s.flags & Defs.SF_LOOP!=0)
		{
			if(s.flags & Defs.SF_BIDI!=0)
			                        for (t in 0 ... 16)
							Mem.setFloat(Samples[handle]+((loopend+t)<<2),
								Mem.getFloat(Samples[handle]+((loopend-t-1)<<2))); else
			                        for (t in 0 ... 16)
			{
				Mem.setFloat(Samples[handle]+((loopend+t)<<2),
									Mem.getFloat(Samples[handle]+((loopstart+t)<<2)));
			}
		} else
		                for (t in 0 ... 16)
					Mem.setFloat(Samples[handle]+((t+length)<<2),0);
		return handle;
	}

	public function WriteSamples(buf:ByteArray)
	{
		var left:Int;
		var portion=0;
		var pan:Int;
		var vol:Int;
		var todo = buffer_size;
		var written = 0;
		
		Profiler.ENTER();
		while (todo > 0)
		{
			if (tickleft==0)
			{
				MPlayer.Player_HandleTick();
				tickleft = Std.int((MDriver.md_mixfreq * 125) / (MDriver.md_bpm * 50));
			}

			left = Std.int(Math.min(tickleft, todo));
			tickleft -= left;
			todo     -= left;
			while(left > 0)
			{
				portion = Std.int(Math.min(left, samplesthatfit));
				if (portion <= 0)
				{
					return;
				}

				// ?
				clearTickBuf(portion);
				for (t in 0 ... vc_softchn)
				{
					vnf=vinf[t];
					if (vnf.kick!=0)
					{
						vnf.current=sampleToIndex(vnf.start);
						vnf.kick=0;
						vnf.active=true;
						//vnf.click=CLICK_BUFFER;
						vnf.rampvol=0;
					}

					if (vnf.frq==0) vnf.active=false;
					if (vnf.active)
					{
						vnf.increment=cast((sampleToIndex(vnf.frq)/MDriver.md_mixfreq));
						if ((vnf.flags&Defs.SF_REVERSE)!=0) vnf.increment=-vnf.increment;
						vol=vnf.vol;
						pan=vnf.pan;
						vnf.oldlvol=vnf.lvolsel;
						vnf.oldrvol=vnf.rvolsel;
						if (vc_mode & Defs.DMODE_STEREO!=0)
						{
							if (pan!=Defs.PAN_SURROUND)
							{
								vnf.lvolsel=(vol*(Defs.PAN_RIGHT-pan))>>8;
								vnf.rvolsel=(vol*pan)>>8;
							} else
							{
								vnf.lvolsel=vnf.rvolsel=Std.int((vol * 256) / 480);
							}
						} else vnf.lvolsel=vol;
						idxsize=(vnf.size!=0)?sampleToIndex(vnf.size):0;
						idxlend=(vnf.repend!=0)?sampleToIndex(vnf.repend):0;
						if (FRACBITS!=0)
						{
							if (vnf.size!=0) idxsize--;
							if (vnf.repend!=0) idxlend--;
						}

						idxlpos=sampleToIndex(vnf.reppos);
						AddChannel(portion);
					}
				}

				var startpos=buf.position;
				
				// Mix32toFP
				buf.endian = Endian.LITTLE_ENDIAN;
				buf.writeBytes(Mem.buf, vc_tickbuf, portion << 3);
				
				var endpos=buf.position;
				//TrackerEventDispatcher.dispatchEvent(new TrackerAudioBufferEvent(buf,startpos,endpos,buffer_size));
				TrackerEventDispatcher.dispatchEvent(new TrackerAudioBufferEvent(buf,startpos,endpos,buffer_size));
				written+=portion;
				left-=portion;
			}
		}

		for (i in 0 ... vc_softchn)
		{
			vnf=vinf[i];
			if (!vnf.active) continue;
			TrackerEventDispatcher.dispatchEvent(new hxmikmod.event.TrackerSamplePosEvent(i,indexToSampleF(vnf.current),indexToSampleF(vnf.increment)));
		}
		Profiler.LEAVE();
	}

	public function VC_PlayStart():Bool
	{
		MDriver.md_mode |= Defs.DMODE_INTERP;
		tickleft=0;
		return false;
	}

	public function VC_VoicePlay(voice:Int,handle:Int,start:Int,size:Int,reppos:Int,repend:Int,flags:Int)
	{
		vinf[voice].flags    = flags;
		vinf[voice].handle   = handle;
		vinf[voice].start    = start;
		vinf[voice].size     = size;
		vinf[voice].reppos   = reppos;
		vinf[voice].repend   = repend;
		vinf[voice].kick     = 1;
	}

	public function VC_VoiceSetPanning(voice:Int,pan:Int)
	{
		
		/* protect against clicks if panning variation is too high */
		//if(Math.abs(vinf[voice].pan-pan)>48)
		//        vinf[voice].rampvol=CLICK_BUFFER;
		vinf[voice].pan=pan;
	}

	public function VC_SetNumVoices():Bool
	{
		var t:Int;
		MDriver.md_mode|=Defs.DMODE_INTERP;
		if ((vc_softchn = MDriver.md_softchn) == 0)
			return false;
		//if(vinf) free(vinf);
		
		vinf=new Array<VInfo>();
		hqmix = (vc_softchn <= 8);
		for (t in 0 ... vc_softchn)
		{
			vinf[t]=new VInfo();
			vinf[t].frq=10000;
			vinf[t].pan = (t & 1 != 0) ? Defs.PAN_LEFT : Defs.PAN_RIGHT;
		}

		return false;
	}

	public function VC_VoiceSetFrequency(voice:Int,frq:Int)
	{
		vinf[voice].frq=frq;
	}

	public function VC_VoiceSetVolume(voice:Int,vol:Int)
	{
		
		/* protect against clicks if volume variation is too high */
		//if(Math.abs(vinf[voice].vol-vol)>32)
		//        vinf[voice].rampvol=CLICK_BUFFER;
		vinf[voice].vol=vol;
	}

	public function VC_SampleLength(type:Int,s:Sample):Int
	{
		if (s==null) return 0;
		return (s.length*((s.flags&Defs.SF_16BITS)!=0?2:1))+16;
	}

	public function VC_SampleSpace(type:Int):Int
	{
		return vc_memory;
	}

	public function VC_VoiceStop(voice:Int)
	{
		vinf[voice].active = false;
	}

	public function VC_VoiceStopped(voice:Int):Bool
	{
		return(vinf[voice].active==false);
	}

	public function VC_VoiceGetPosition(voice:Int):Int
	{
		return(Std.int(vinf[voice].current));
	}

	public function VC_VoiceGetVolume(voice:Int):Int
	{
		return vinf[voice].vol;
	}
}