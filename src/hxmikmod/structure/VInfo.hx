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

import hxmikmod.Virtch;

class VInfo
{
	public var kick:Int;
	public var active:Bool;
	public var flags:Int;
	public var handle:Int;
	public var start:Int;
	public var size:Int;
	public var reppos:Int;
	public var repend:Int;
	public var frq:Int;
	public var vol:Int;
	public var pan:Int;
	public var click:Int;
	public var rampvol:Int;
	public var lastvalL:Int;
	public var lastvalR:Int;
	public var lvolsel:Int;
	public var rvolsel:Int;
	public var oldlvol:Int;
	public var oldrvol:Int;
	public var current:Int;
	public var increment:Int;

	public function new() {
	}
}

