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

package hxmikmod.structure;

import hxmikmod.DataReader;

class Sample
{
	public var panning:Int;
	
	/* panning (0-255 or PAN_SURROUND) */
	public var speed:Int;
	
	/* Base playing speed/frequency of note */
	public var volume:Int;
	
	/* volume 0-64 */
	public var inflags:Int;
	
	/* sample format on disk */
	public var flags:Int;
	
	/* sample format in memory */
	public var length:Int;
	
	/* length of sample (in samples!) */
	public var loopstart:Int;
	
	/* repeat position (relative to start, in samples) */
	public var loopend:Int;
	
	/* repeat end */
	public var susbegin:Int;
	
	/* sustain loop begin (in samples) \  Not Supported */
	public var susend:Int;
	
	/* sustain loop end                /      Yet! */
	
	/* Variables used by the module player only! (ignored for sound effects) */
	public var globvol:Int;
	
	/* global volume */
	public var vibflags:Int;
	
	/* autovibrato flag stuffs */
	public var vibtype:Int;
	
	/* Vibratos moved from INSTRUMENT to SAMPLE */
	public var vibsweep:Int;
	public var vibdepth:Int;
	public var vibrate:Int;
	public var samplename:String;
	
	/* name of the sample */
	
	/* Values used internally only */
	public var avibpos:Int;
	
	/* autovibrato pos [player use] */
	public var divfactor:Int;
	
	/* for sample scaling, maintains proper period slides */
	public var seekpos:Int;
	
	/* seek position in file */
	public var handle:Int;
	
	/* sample handle used by individual drivers */
	public function new()
	{
	}
}


/*========== Samples */

/* This is a handle of sorts attached to any sample registered with
   SL_RegisterSample.  Generally, this only need be used or changed by the
   loaders and drivers of mikmod. */
class SampleLoad
{
	public var next:SampleLoad;
	public var length:Int;    /* length of sample (in samples!) */
	public var loopstart:Int; /* repeat position (relative to start, in samples) */
	public var loopend:Int;   /* repeat end */
	public var infmt:Int;
	public var outfmt:Int;
	public var scalefactor:Int;
	public var sample:Sample; // ptr
	public var reader:DataReader; // ptr
	
	public function new()
	{
	}
}