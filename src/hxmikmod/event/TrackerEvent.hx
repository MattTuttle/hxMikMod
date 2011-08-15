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

package hxmikmod.event;

import hxmikmod.structure.Module;
import hxmikmod.structure.ModChannel;

import flash.events.Event;
import flash.utils.ByteArray;

class TrackerVoiceEvent extends Event
{
	public var voice:Int;
	public var handle:Int;
	public var start:Int;
	public var size:Int;
	public var reppos:Int;
	public var repend:Int;
	public var flags:Int;
	inline public static var TYPE="TrackerVoiceEvent";
	public function new(voice:Int,handle:Int,start:Int,size:Int,reppos:Int,repend:Int,flags:Int)
	{
		super(TYPE);
		this.voice=voice;
		this.handle=handle;
		this.start=start;
		this.size=size;
		this.reppos=reppos;
		this.repend=repend;
		this.flags=flags;
	}
}

class TrackerSamplePosEvent extends Event
{
	public var voice:Int;
	public var pos:Float;
	public var increment:Float;
	inline public static var TYPE="TrackerSamplePosEvent";
	public function new(voice:Int, pos:Float, increment:Float)
	{
		super(TYPE);
		this.voice=voice;
		this.pos=pos;
		this.increment=increment;
	}
}

class TrackerLoadingEvent extends Event
{
	public var state:Int;
	public var message:String;
	public var progress:Float;
	public var module:Module;
	
	inline public static var PROGRESS = "TrackerLoadingProgress";
	inline public static var COMPLETE = "TrackerLoadingComplete";
	inline public static var FAILED = "TrackerLoadingFailed";
	
	public function new(state:String, message:String = "loading...", progress:Float = 1, ?module:Module)
	{
		super(state);
		this.message=message;
		this.progress=progress;
		this.module=module;
	}
}

class TrackerNoteEvent extends Event
{
	inline public static var TYPE="TrackerNoteEvent";
	public var channel:ModChannel;
	public function new(channel:ModChannel)
	{
		super(TYPE);
		this.channel=channel;
	}
}

// This is called when a block of data is sent to the audio output device.
// It is not guaranteed to be size complete SampleEvent buffer.
// "addr" is a byte index to the Mem.buf bytebuffer,
// "samples" is the count of stereo samples (dual-Floats) written,
// "pos" is how many stereo samples was written before this block
// "audiobufsize" is the total size of the SampleEvent.data buffer (constant)
class TrackerAudioBufferEvent extends Event
{
	inline public static var TYPE="TrackerAudioBufferEvent";
	public var addr:ByteArray;
	public var startpos:Int;
	public var endpos:Int;
	public var audiobufsize:Int;
	public function new(addr:ByteArray,startpos:Int,endpos:Int,audiobufsize:Int)
	{
		super(TYPE);
		this.addr=addr;
		this.startpos=startpos;
		this.endpos=endpos;
		this.audiobufsize=audiobufsize;
	}
}

class TrackerPlayPosEvent extends Event
{
	inline public static var TYPE="TrackerPlayPosEvent";
	public var pos:Int;
	public var max:Int;
	public var finished:Bool;
	public function new(pos:Int,max:Int,finished:Bool)
	{
		super(TYPE);
		this.pos=pos;
		this.max=max;
		this.finished=finished;
	}
}