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

import flash.Memory;
import flash.utils.ByteArray;
import flash.utils.Endian;

// This class implements sample memory acess and management in
// a haXe/Flash optimized way.
// All buffers and mixing data are stored in one big chunk.
// This allows us to access them with the fast flash.Memory methods, doing
// only one Memory.select().

class Mem
{

	public static var buf:ByteArray = init();
	public static var zeroes:ByteArray;
	static var last_alloc:Int;
	
	private inline static var RESERVED_SIZE=(Virtch.TICKLSIZE+32)<<3;

	static function init()
	{
		var ret = new ByteArray();
		ret.length = RESERVED_SIZE;	// Virtch tickbuf hardwired to buffer start
		Memory.select(ret);
		zeroes = new ByteArray();
		for (i in 0 ... 16384>>2) zeroes.writeFloat(0);
		return ret;
	}


	public static function freeAll()
	{
		buf.length = RESERVED_SIZE;
	}

	// allocates a new area at the end of the data buffer,
	// returns the byte index to the beginning of it
	public static function alloc(len:Int, ?pos:haxe.PosInfos):Int
	{
		var ret = buf.length;
		buf.length += len;
		last_alloc = ret;
		return ret;
	}

	public static function free(ptr:Int)
	{
		if (last_alloc==ptr) {
			buf.length=last_alloc;
			last_alloc=0;
		} //else trace("can't free");
	}

	public static function realloc(ptr:Int, len:Int):Bool
	{
		if (last_alloc != ptr)
		{
			trace("can't realloc " + ptr + ", last_alloc=" + last_alloc);
			setByte(-1,-1);		// throw an error for debugging
			return false;
		}
		buf.length+=len;
		return true;
	}

	// note that you have to pass a byte index (4*float index)
	inline public static function setFloat(i:Int, f:Float)
	{
		Memory.setFloat(i, f);
	}

	inline public static function getFloat(i:Int):Float
	{
		return Memory.getFloat(i);
	}

	inline public static function setShort(i:Int, s:Int)
	{
		Memory.setI16(i,s);
	}

	inline public static function getShort(i:Int):Int
	{
		return Memory.signExtend16(Memory.getUI16(i));
	}

	inline public static function getByte(i:Int):Int
	{
		return Memory.getByte(i);
	}

	inline public static function setByte(i:Int, b:Int)
	{
		Memory.setByte(i, b);
	}

	inline public static function clearFloat(i:Int, len:Int)
	{
		buf.position = i;
		buf.writeBytes(zeroes, 0, len);
	}

}
