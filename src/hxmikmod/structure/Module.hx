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

import hxmikmod.Mem;

class Module
{

	/* general module information */
	public var songname:String;
	public var modtype:String;
	public var comment:String;

	public var flags:Int;
	public var numchn:Int;
	public var numvoices:Int;
	public var numpos:Int;
	public var numpat:Int;
	public var numins:Int;
	public var numsmp:Int;
	public var instruments:Array<Instrument>;
	public var samples:Array<Sample>;
	public var realchn:Int;
	public var totalchn:Int;

        /* playback settings */
	public var reppos:Int;
	public var initspeed:Int;
	public var inittempo:Int;
	public var initvolume:Int;
	public var panning:Array<Int>;
	public var chanvol:Array<Int>;
	public var bpm:Int;
	public var sngspd:Int;
	public var volume:Int;

	public var extspd:Bool;
	public var panflag:Bool;
	public var wrap:Bool;
	public var loop:Bool;
	public var fadeout:Bool;

	public var patpos:Int;
	public var sngpos:Int;
	public var sngtime:Int;
	public var audiobufferstart:Int;

	public var relspd:Int;


        /* internal module representation */
	public var numtrk:Int;
	public var tracks:Array<Int>;
	public var patterns:Array<Int>;
	public var pattrows:Array<Int>;
	public var positions:Array<Int>;

	public var forbid:Bool;
	public var numrow:Int;
	public var vbtick:Int;
	public var sngremainder:Int;

	public var control:Array<ModControl>;
	public var voice:Array<ModVoice>;

	public var globalslide:Int;
	public var pat_repcrazy:Int;
	public var patbrk:Int;
	public var patdly:Int;
	public var patdly2:Int;
	public var posjmp:Int;
	public var bpmlimit:Int;

	public function new() {
	   chanvol = new Array<Int>();
	   panning = new Array<Int>();
	}

}

