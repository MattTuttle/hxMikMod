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

import flash.utils.ByteArray;
import flash.utils.Endian;

enum SeekMode
{
	SEEK_SET;
	SEEK_CUR;
}

class DataReader
{
	public var _mm_errno:Int;
	private var _mm_errorhandler:Void->Void;
	private var _mm_iobase:Int;
	private var temp_iobase:Int;
	
	public var data:ByteArray;
	
	public function new(i:ByteArray)
	{
		data = i;
		data.endian = Endian.LITTLE_ENDIAN;
		_mm_errno = 0;
		_mm_iobase = 0;
		temp_iobase = 0;
	}
	
	public function rollback()
	{
		if (_mm_errorhandler != null)
		{
			_mm_errorhandler();
		}
		_mm_rewind();
		_mm_iobase_revert();
	}
	
	function BigEndian()
	{
		data.endian = Endian.BIG_ENDIAN;
	}

	function LittleEndian()
	{
		data.endian = Endian.LITTLE_ENDIAN;
	}

	
	/* Sets the current file-position as the new _mm_iobase */
	public function _mm_iobase_setcur()
	{
		temp_iobase = _mm_iobase;
		
		/* store old value in case of revert */
		_mm_iobase = tell();
	}

	
	/* Reverts to the last known _mm_iobase value. */
	public function _mm_iobase_revert()
	{
		_mm_iobase = temp_iobase;
	}

	public function _mm_rewind()
	{
		_mm_fseek(0, SEEK_SET);
	}

	public function _mm_fseek(pos:Int,whence:SeekMode)
	{
		seek(pos, whence);
	}

	public function _mm_ftell()
	{
		return data.position;
	}

	public function _mm_read_string(number:Int):String
	{
		return data.readUTFBytes(number);
	}

	public function _mm_read_M_UWORD():Int
	{
		data.endian = Endian.BIG_ENDIAN;
		var result = data.readUnsignedShort();
		data.endian = Endian.LITTLE_ENDIAN;
		return result;
	}

	public function _mm_read_I_UWORD():Int
	{
		return data.readUnsignedShort();
	}

	public function _mm_read_M_ULONG():Int
	{
		data.endian = Endian.BIG_ENDIAN;
		var result = data.readUnsignedInt();
		data.endian = Endian.LITTLE_ENDIAN;
		return result;
	}

	public function _mm_read_I_ULONG():Int
	{
		return data.readUnsignedInt();
	}

	public function _mm_read_M_SWORD():Int
	{
		data.endian = Endian.BIG_ENDIAN;
		var result = data.readShort();
		data.endian = Endian.LITTLE_ENDIAN;
		return result;
	}

	public function _mm_read_I_SWORD():Int
	{
		return data.readShort();
	}

	public function _mm_read_M_SLONG():Int
	{
		data.endian = Endian.BIG_ENDIAN;
		var result = data.readInt();
		data.endian = Endian.LITTLE_ENDIAN;
		return result;
	}

	public function _mm_read_I_SLONG():Int
	{
		return data.readInt();
	}

	public function _mm_read_UBYTE()
	{
		return data.readUnsignedByte();
	}

	public function _mm_read_SBYTE()
	{
		return data.readByte();
	}

	public function _mm_read_UBYTES(len:Int):Array<Int>
	{
		var ret = new Array<Int>();
		if (data.bytesAvailable < len) return null;
		for (a in 0 ... len)
		{
			ret[a] = data.readUnsignedByte();
		}

		return ret;
	}

	public function _mm_read_ByteArray(len:Int):ByteArray
	{
		var ret=new ByteArray();
		data.readBytes(ret, 0, len);
		if (ret.bytesAvailable != len) return null;
		return ret;
	}

	public function _mm_read_I_UWORDS(number:Int):Array<Int>
	{
		var ret = new Array<Int>();
		for (i in 0 ... number)
		{
			ret[i] = data.readUnsignedShort();
		}

		if (eof()) return null;
		return ret;
	}

	public function _mm_read_I_SWORDS(number:Int):Array<Int>
	{
		var ret = new Array<Int>();
		for (i in 0 ... number)
		{
			ret[i] = data.readShort();
		}

		if (eof()) return null;
		return ret;
	}

	public function _mm_read_M_SWORDS(number:Int):Array<Int>
	{
		data.endian = Endian.BIG_ENDIAN;
		var result = _mm_read_I_SWORDS(number);
		data.endian = Endian.LITTLE_ENDIAN;
		return result;
	}

	public function _mm_read_I_ULONGS(number:Int):Array<Int>
	{
		var ret=new Array<Int>();
		for (i in 0 ... number)
		{
			ret[i] = data.readUnsignedInt();
		}

		if (eof()) return null;
		return ret;
	}
	
	public function seek(offset:Int, whence:SeekMode):Bool
	{
		switch (whence)
		{
			case SEEK_SET:
				data.position = offset;
			case SEEK_CUR:
				data.position += offset;
			/*default:
				trace("Seek: bad whence=" + whence);
				return false;*/
		}
		
		return true;
	}

	public function tell():Int
	{
		return data.position;
	}

	public function eof():Bool
	{
		//return (i.bytesAvailable<=0);	// wrong
		return false;
		// Flash will throw EOFError anyway
	}
	
}
