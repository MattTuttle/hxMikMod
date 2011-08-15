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

import flash.events.SampleDataEvent;
import flash.media.SoundChannel;
import flash.media.Sound;
import hxmikmod.structure.Sample;
import hxmikmod.event.TrackerEvent;
import hxmikmod.event.TrackerEventDispatcher;

class FlashDriver extends MDriver
{
	var sound:Sound;
	var channel:SoundChannel;
	
	public function new(params:Hash<Dynamic>)
	{
		name = "FlashDriver for hxMikMod (c) jouko@iki.fi";
		version = "1.0";
		hardVoiceLimit = 1;
		softVoiceLimit = 32;
		virtch = new Virtch(4096);
		if (params != null)
		{
			try
			{
				if (params.exists("buffer_size"))
				{
					virtch.buffer_size = cast(params.get("buffer_size"));
				}
			}
			catch (e:Dynamic)
			{
				trace(e);
			}
		}
	}

	private function onSampleData(event:SampleDataEvent)
	{
		//if (channel!=null)
		//   TrackerEventDispatcher.setLatency(event.position/44.1-channel.position);
		virtch.WriteSamples(event.data);
	}

	override public function IsPresent():Bool
	{
		return true;
	}

	override public function SampleLoad(s:SampleLoad,a:Int):Int
	{
		return virtch.VC_SampleLoad(s,a);
	}

	override public function FreeSampleSpace(a:Int):Int
	{
		return virtch.VC_SampleSpace(a);
	}

	override public function RealSampleLength(a:Int,s:Sample):Int
	{
		return virtch.VC_SampleLength(a,s);
	}

	override public function Init():Bool
	{
		return virtch.VC_Init();
	}

	override public function Exit()
	{
		trace("Exit");
	}

	override public function Reset():Bool
	{
		virtch.VC_Reset();
		return true;
	}

	override public function SetNumVoices():Bool
	{
		return virtch.VC_SetNumVoices();
	}

	override public function PlayStart():Bool
	{
		if (sound==null)
		{
			sound=new Sound();
			sound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			channel = sound.play();
		}

		return virtch.VC_PlayStart();
	}

	override public function PlayStop()
	{
		if (sound!=null)
		{
			sound.removeEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			sound = null;
			channel = null;
		}
	}

	override public function Pause()
	{
		trace("Pause");
	}

	override public function VoiceSetVolume(a:Int,b:Int)
	{
		virtch.VC_VoiceSetVolume(a,b);
	}

	override public function VoiceGetVolume(a:Int):Int
	{
		return virtch.VC_VoiceGetVolume(a);
	}

	override public function VoiceSetFrequency(a:Int,b:Int)
	{
		virtch.VC_VoiceSetFrequency(a,b);
	}

	override public function VoiceGetFrequency(a:Int):Int
	{
		trace("VoiceGetFrequency");
		return 0;
	}

	override public function VoiceSetPanning(a:Int,b:Int)
	{
		virtch.VC_VoiceSetPanning(a,b);
	}

	override public function VoiceGetPanning(a:Int):Int
	{
		trace("VoiceGetPanning");
		return 0;
	}

	override public function VoicePlay(a:Int, b:Int, c:Int, d:Int, e:Int, f:Int, g:Int)
	{
		virtch.VC_VoicePlay(a,b,c,d,e,f,g);
	}

	override public function VoiceStop(a:Int)
	{
		virtch.VC_VoiceStop(a);
	}

	override public function VoiceStopped(a:Int):Bool
	{
		return virtch.VC_VoiceStopped(a);
	}

	override public function VoiceGetPosition(a:Int):Int
	{
		return virtch.VC_VoiceGetPosition(a);
	}

	override public function VoiceRealVolume(a:Int):Int
	{
		trace("VoiceRealVolume");
		return 0;
	}
}