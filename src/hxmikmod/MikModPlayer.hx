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
import hxmikmod.event.TrackerEventDispatcher;
import hxmikmod.event.TrackerEvent;
import hxmikmod.loaders.ModuleLoader;
import hxmikmod.DataReader;
import hxmikmod.structure.ModControl;
import hxmikmod.structure.Module;
import hxmikmod.structure.ModVoice;

class MikModPlayer
{
	
	private var _playing:Bool;
	
	public function new()
	{
		var result:Bool = MDriver._mm_init(null);
		_playing = false;
	}

	public function start(mod:Module)
	{
		var t:Int;
		if (mod==null) return;

		MDriver.MikMod_EnableOutput_internal();

		mod.forbid=false;

		if (MPlayer.pf != mod)
		{
			/* new song is being started, so completely stop out the old one. */
			if (MPlayer.pf != null)
				MPlayer.pf.forbid = true;
			for (t in 0 ... MDriver.md_sngchn) MDriver.Voice_Stop_internal(t);
		}
		MPlayer.pf = mod;
		_playing = true;
	}
	
	public var isPlaying(get, null):Bool;
	private function get_isPlaying():Bool
	{
		return _playing;
	}
	
	private function onLoadComplete(e:TrackerLoadingEvent)
	{
		TrackerEventDispatcher.removeEventListener(TrackerLoadingEvent.COMPLETE, onLoadComplete);
		start(e.module);
	}

	public function stop()
	{
		MPlayer.Player_Stop_internal();
		_playing = false;
	}

	public function exit(mod:Module)
	{
		MDriver.MikMod_Exit_internal();
		MPlayer.Player_Exit_internal(mod);
		_playing = false;
	}

	public static function init(mod:Module):Bool
	{
		mod.extspd=true;
		mod.panflag=true;
		mod.wrap=true; //false;
		mod.loop=true;
		mod.fadeout=false;
		mod.relspd=0;

		/* make sure the player doesn't start with garbage */
		mod.control=new Array<ModControl>();
		for (i in 0 ... mod.numchn)
			mod.control[i] = new ModControl();
		
		mod.voice=new Array<ModVoice>();
		for (i in 0 ... MDriver.md_sngchn)
			mod.voice[i] = new ModVoice();

		//if (!(mod.control=(MP_CONTROL*)_mm_calloc(mod.numchn,sizeof(MP_CONTROL))))
		//        return 1;
		//if (!(mod.voice=(MP_VOICE*)_mm_calloc(md_sngchn,sizeof(MP_VOICE))))
		//        return 1;

		MPlayer.Player_Init_internal(mod);
		return false;
	}


	/* Loads a module given a file pointer.
	File is loaded from the current file seek position. */
	public function loadSong(data:ByteArray, maxchan:Int = 32, curious:Bool = false):Bool
	{
		var t:Int;
		var l:ModuleLoader = null;
		
		// set mod reader
		var reader = new DataReader(data);
		reader._mm_errno = 0;
		reader._mm_iobase_setcur();
		
		TrackerEventDispatcher.dispatchEvent(new TrackerLoadingEvent(TrackerLoadingEvent.PROGRESS, "initializing..."));
		Mem.freeAll();
		
		var loaders:Array<ModuleLoader> = new Array<ModuleLoader>();
//		loaders.push(new hxmikmod.loaders.MODLoader());
		loaders.push(new hxmikmod.loaders.XMLoader());
//		loaders.push(new hxmikmod.loaders.S3MLoader());
//		loaders.push(new hxmikmod.loaders.ITLoader());
		
		/* Try to find a loader that recognizes the module */
		for (tryloader in loaders)
		{
			// firstloader ...
			reader._mm_rewind();
			tryloader.modreader = reader;
			if (tryloader.test(reader))
			{
				l = tryloader;
				break;
			}
		}

		if (l == null)
		{
			reader._mm_errno = Defs.MMERR_NOT_A_MODULE;
			reader.rollback();
			return false;
			//null;
		}
		
		/* init unitrk routines */
		if(!MUnitrk.UniInit())
		{
			reader.rollback();
			return false;
			//null;
		}
		
		TrackerEventDispatcher.addEventListener(TrackerLoadingEvent.COMPLETE, onLoadComplete);

		return l.start(maxchan, curious);
	}

}
