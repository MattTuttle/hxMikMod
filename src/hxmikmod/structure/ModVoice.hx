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

import hxmikmod.structure.Instrument;

class ModVoice
{
	public var main:ModChannel;

	public var venv:ENVPR;
	public var penv:ENVPR;
	public var cenv:ENVPR;

	public var avibpos:Int;
	public var aswppos:Int;

	public var totalvol:Int;

	public var mflag:Bool;
	public var masterchn:Int;
	public var masterperiod:Int;

	public var master:ModControl;	// ptr

	public function new() {
		main = new ModChannel();
		venv = new ENVPR();
		penv = new ENVPR();
		cenv = new ENVPR();
	}
}


class ENVPR
{
	public var flg:Int;          /* envelope flag */
	public var pts:Int;          /* number of envelope points */
	public var susbeg:Int;       /* envelope sustain index begin */
	public var susend:Int;       /* envelope sustain index end */
	public var beg:Int;          /* envelope loop begin */
	public var end:Int;          /* envelope loop end */
	public var p:Int;            /* current envelope counter */
	public var a:Int;            /* envelope index a */
	public var b:Int;            /* envelope index b */
	public var env:Array<EnvelopePoint>;          /* envelope points */

	public function new()
	{
	}
}


