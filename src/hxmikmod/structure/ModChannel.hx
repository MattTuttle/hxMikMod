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

class ModChannel
{
	public var i:Instrument;
	public var s:Sample;

	public var sample:Int;
	public var note:Int;
	public var outvolume:Int;
	public var chanvol:Int;
	public var fadevol:Int;
	public var panning:Int;
	public var kick:Int;
	public var kick_flag:Bool;
	public var period:Int;
	public var nna:Int;

	public var volflg:Int;
	public var panflg:Int;
	public var pitflg:Int;

	public var keyoff:Int;
	public var handle:Int;
	public var notedelay:Int;
	public var start:Int;
	
	public function new()
	{
	}

	public function clone(ret:ModChannel) 
	{
		ret.i = i; ret.s = s; ret.sample = sample; ret.note = note; ret.outvolume = outvolume; ret.chanvol = chanvol;
		ret.fadevol = fadevol; ret.panning = panning; ret.kick = kick; ret.kick_flag = kick_flag;
		ret.period = period; ret.nna = nna; ret.volflg = volflg; ret.panflg = panflg; ret.pitflg = pitflg;
		ret.keyoff = keyoff; ret.handle = handle; ret.notedelay = notedelay; ret.start = start;
	}

}

