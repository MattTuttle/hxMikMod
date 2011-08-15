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

import hxmikmod.Mem;

class MUnitrk
{
	
	/* Unibuffer chunk size */
	/* Allocate so much that realloc() is never needed, because it won't work with hxmikmod.Mem */

	inline public static var BUFPAGE = 8192;

	public static var unioperands=[
		0, /* not used */
		1, /* UNI_NOTE */
		1, /* UNI_INSTRUMENT */
		1, /* UNI_PTEFFECT0 */
		1, /* UNI_PTEFFECT1 */
		1, /* UNI_PTEFFECT2 */
		1, /* UNI_PTEFFECT3 */
		1, /* UNI_PTEFFECT4 */
		1, /* UNI_PTEFFECT5 */
		1, /* UNI_PTEFFECT6 */
		1, /* UNI_PTEFFECT7 */
		1, /* UNI_PTEFFECT8 */
		1, /* UNI_PTEFFECT9 */
		1, /* UNI_PTEFFECTA */
		1, /* UNI_PTEFFECTB */
		1, /* UNI_PTEFFECTC */
		1, /* UNI_PTEFFECTD */
		1, /* UNI_PTEFFECTE */
		1, /* UNI_PTEFFECTF */
		1, /* UNI_S3MEFFECTA */
		1, /* UNI_S3MEFFECTD */
		1, /* UNI_S3MEFFECTE */
		1, /* UNI_S3MEFFECTF */
		1, /* UNI_S3MEFFECTI */
		1, /* UNI_S3MEFFECTQ */
		1, /* UNI_S3MEFFECTR */
		1, /* UNI_S3MEFFECTT */
		1, /* UNI_S3MEFFECTU */
		0, /* UNI_KEYOFF */
		1, /* UNI_KEYFADE */
		2, /* UNI_VOLEFFECTS */
		1, /* UNI_XMEFFECT4 */
		1, /* UNI_XMEFFECT6 */
		1, /* UNI_XMEFFECTA */
		1, /* UNI_XMEFFECTE1 */
		1, /* UNI_XMEFFECTE2 */
		1, /* UNI_XMEFFECTEA */
		1, /* UNI_XMEFFECTEB */
		1, /* UNI_XMEFFECTG */
		1, /* UNI_XMEFFECTH */
		1, /* UNI_XMEFFECTL */
		1, /* UNI_XMEFFECTP */
		1, /* UNI_XMEFFECTX1 */
		1, /* UNI_XMEFFECTX2 */
		1, /* UNI_ITEFFECTG */
		1, /* UNI_ITEFFECTH */
		1, /* UNI_ITEFFECTI */
		1, /* UNI_ITEFFECTM */
		1, /* UNI_ITEFFECTN */
		1, /* UNI_ITEFFECTP */
		1, /* UNI_ITEFFECTT */
		1, /* UNI_ITEFFECTU */
		1, /* UNI_ITEFFECTW */
		1, /* UNI_ITEFFECTY */
		2, /* UNI_ITEFFECTZ */
		1, /* UNI_ITEFFECTS0 */
		2, /* UNI_ULTEFFECT9 */
		2, /* UNI_MEDSPEED */
		0, /* UNI_MEDEFFECTF1 */
		0, /* UNI_MEDEFFECTF2 */
		0, /* UNI_MEDEFFECTF3 */
		2, /* UNI_OKTARP */
	];



/*========== Reading routines */

   public static var rowstart:Int;
   public static var rowend:Int;
   public static var rowpc:Int;
   public static var lastbyte:Int;


	public static function UniSetRow(t:Int)
	{
		rowstart = t;
		rowpc    = rowstart;
		if (t == 0) 
		{
			rowend=0;
		}
		else
		{
			rowend = rowstart+(Mem.getByte(rowpc)&0x1f);
			rowpc++;
		}	
	}

	public static function UniGetByte():Int
	{
		lastbyte = ((rowpc<rowend)?Mem.getByte(rowpc):0)&255;
		if (rowpc < rowend)
			rowpc++;
		return lastbyte;
	}

	public static function UniGetWord():Int
	{
		if (rowpc < rowend)
			return 0;
		var ret = Mem.getShort(rowpc) & 0xffff;
		rowpc += 2;
		return ret;
	}


	public static function UniSkipOpcode()
	{
		if (lastbyte < Defs.UNI_LAST)
		{
			var t = unioperands[lastbyte];
			while (t-- != 0)
			{
				UniGetByte();
			}
		}
	}



	/* Finds the address of row number 'row' in the UniMod(tm) stream 't' returns
		NULL if the row can't be found. */

	public static function UniFindRow(t:Int, row:Int):Int
	{
		var c:Int;
		var l:Int;
		
		if (t != 0)
		{
			while (true)
			{
				c = Mem.getByte(t) & 0xff;             /* get rep/len byte */
				if (c == 0)
				{
					/* zero ? -> end of track.. */
					trace("UniFindRow failed");
					return 0;
				}
				l = (c >> 5) + 1;    /* extract repeat value */
				if (l > row) break;  /* reached wanted row? -> return pointer */
				row -= l;            /* haven't reached row yet.. update row */
				t += (c & 0x1f);     /* point t to the next row */
			}
		}
		return t;
	}



	/*========== Writing routines */

	public static var unibuf:Int;  /* pointer to the temporary unitrk buffer */
	public static var unimax:Int;  /* buffer size */

	public static var unipc:Int;   /* buffer cursor */
	public static var unitt:Int;   /* current row index */
	public static var lastp:Int;   /* previous row index */

	/* Resets index-pointers to create a new track. */
	public static function UniReset()
	{
		unitt     = 0;   /* reset index to rep/len byte */
		unipc     = 1;   /* first opcode will be written to index 1 */
		lastp     = 0;   /* no previous row yet */
		Mem.setByte(unibuf,0);	/* clear rep/len byte */
	}



	/* Expands the buffer */
	public static function UniExpand(wanted:Int):Bool
	{
		if ((unipc + wanted) >= unimax)
		{
			// Expand the buffer by BUFPAGE bytes
			if (Mem.realloc(unibuf, (unimax + BUFPAGE)))
			{
				// Check if realloc succeeded
				unimax+=BUFPAGE;
				return true;
			}
			else
			{
				return false;
			}
		}
		return true;
	}


	/* Appends one byte of data to the current row of a track. */
	public static function UniWriteByte(data:Int)
	{
		if (UniExpand(1))
		{
			Mem.setByte(unibuf + unipc, data);
			unipc++;
		}
	}


	public static function UniWriteWord(data:Int)
	{
		if (UniExpand(2))
		{
			Mem.setShort(unibuf+unipc,data);
			unipc+=2;
		}
	}


	public static function MyCmp(a:Int, b:Int, len:Int):Bool
	{
		for (t in 0 ... len)
		{
			if (Mem.getByte(a + t) != Mem.getByte(b + t))
			{
				return false;
			}
		}
		return true;
	}


	/* Closes the current row of a unitrk stream (updates the rep/len byte) and sets
		pointers to start a new row. */
	public static function UniNewline()
	{
		var n:Int;
		var l:Int;
		var len:Int;

		var b=Mem.getByte(unibuf+lastp);
		n = (b>>5)+1;     /* repeat of previous row */
		l = (b&0x1f);     /* length of previous row */

		len = unipc-unitt;            /* length of current row */

		/* Now, check if the previous and the current row are identical.. when they
		are, just increase the repeat field of the previous row */
		if (n < 8 && len == l && MyCmp(unibuf + lastp + 1, unibuf + unitt + 1, len - 1))
		{
			Mem.setByte(unibuf+lastp,Mem.getByte(unibuf+lastp)+0x20);
			unipc = unitt+1;
		}
		else
		{
			if (UniExpand(unitt - unipc))
			{
				/* current and previous row aren't equal... update the pointers */
				Mem.setByte(unibuf + unitt, len);
				lastp = unitt;
				unitt = unipc++;
			}
		}
	}

	static function memcpy(dst:Int, src:Int, len:Int)
	{
		// could use writeBytes for a marginal gain
		for (i in 0 ... len)
			Mem.setByte(dst + i, Mem.getByte(src + i));
	}


	/* Terminates the current unitrk stream and returns a pointer to a copy of the stream. */
	public static function UniDup():Int
	{
		var d:Int;

		if (!UniExpand(unitt - unipc))
			return 0;
		Mem.setByte(unibuf+unitt,0);

		if ((d = Mem.alloc(unipc)) == 0)
			return 0;
		memcpy(d, unibuf, unipc);
		return d;
	}

	public static function UniInit():Bool
	{
		unimax = BUFPAGE;
		unibuf = Mem.alloc(unimax);
		return (unibuf != 0);
	}

	public static function UniCleanup()
	{
		if (unibuf != 0)
			Mem.free(unibuf);
		unibuf = 0;
	}

}
