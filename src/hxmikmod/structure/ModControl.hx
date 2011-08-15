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

class ModControl
{
	public var main:ModChannel;
	public var slave:ModVoice;

	public var slavechn:Int;
	public var muted:Bool;
	public var ultoffset:Int;
	public var anote:Int;
	public var oldnote:Int;
	public var ownper:Int;
	public var ownvol:Int;
	public var dca:Int;
	public var dct:Int;
	public var row:Int;
	public var retrig:Int;
	public var speed:Int;
	public var volume:Int;

	public var tmpvolume:Int;
	public var tmpperiod:Int;
	public var wantedperiod:Int;

	public var arpmem:Int;
	public var pansspd:Int;
	public var slidespeed:Int;
	public var portspeed:Int;

	public var s3mtremor:Int;
	public var s3mtronof:Int;
	public var s3mvolslide:Int;
	public var sliding:Bool;
	public var s3mrtgspeed:Int;
	public var s3mrtgslide:Int;

	public var glissando:Int;
	public var wavecontrol:Int;

	public var vibpos:Int;
	public var vibspd:Int;
	public var vibdepth:Int;

	public var trmpos:Int;
	public var trmspd:Int;
	public var trmdepth:Int;

	public var fslideupspd:Int;
	public var fslidednspd:Int;
	public var fportupspd:Int;
	public var fportdnspd:Int;
	public var ffportupspd:Int;
	public var ffportdnspd:Int;	

	public var hioffset:Int;
	public var soffset:Int;

	public var sseffect:Int;
	public var ssdata:Int;
	public var chanvolslide:Int;

	public var panbwave:Int;
	public var panbpos:Int;
	public var panbspd:Int;
	public var panbdepth:Int;

	public var newsamp:Int;
	public var voleffect:Int;
	public var voldata:Int;

	public var pat_reppos:Int;
	public var pat_repcnt:Int;

	public function new()
	{
		main = new ModChannel();
	}

}

