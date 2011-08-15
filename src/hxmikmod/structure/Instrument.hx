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

typedef EnvelopePoint = {
	public var pos:Int;
	public var val:Int;
};

class Envelope
{
	public var flg:Int;           /* bit 0: on 1: sustain 2: loop */
	public var pts:Int;
	public var susbeg:Int;
	public var susend:Int;
	public var beg:Int;
	public var end:Int;
	public var env:Array<EnvelopePoint>;   // x ENVPOINTS
	public function new()
	{
	   env=new Array();
	   for (i in 0 ... Defs.ENVPOINTS)
		env[i] = { pos:0, val:0 };
	}
}

class Instrument
{
	public var insname:String;

	public var flags:Int;
	public var samplenumber:Array<Int>; // x INSTNOTES
	public var samplenote:Array<Int>;   // x INSTNOTES

	public var nnatype:Int;
	public var dca:Int;              /* duplicate check action */
	public var dct:Int;              /* duplicate check type */
	public var globvol:Int;
	public var volfade:Int;
	public var panning:Int;          /* instrument-based panning var */

	public var pitpansep:Int;        /* pitch pan separation (0 to 255) */
	public var pitpancenter:Int;     /* pitch pan center (0 to 119) */
	public var rvolvar:Int;          /* random volume varations (0 - 100%) */
	public var rpanvar:Int;          /* random panning varations (0 - 100%) */

	/* volume envelope */
	public var vol_env:Envelope;
	/* panning envelope */
	public var pan_env:Envelope;
	/* pitch envelope */
	public var pit_env:Envelope;

	public function new()
	{
	   vol_env = new Envelope();
	   pan_env = new Envelope();
	   pit_env = new Envelope();
	   samplenumber = new Array();
	   samplenote = new Array();
	}
}


