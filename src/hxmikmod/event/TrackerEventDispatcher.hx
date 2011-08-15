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

import hxmikmod.event.TrackerEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.Timer;
import flash.events.TimerEvent;

class TrackerEventDispatcher extends EventDispatcher
{
	
	private static var d:TrackerEventDispatcher = new TrackerEventDispatcher();
	private inline static var MIN_EVENT_DELAY:Int = 50;
	private static var latency:Float = 0.0;
	
	public function new()
	{
		super();
	}

	public static function setLatency(lat:Float)
	{
		latency=lat;
	}

	public static function addEventListener(type:String, handler:Dynamic)
	{
		d.addEventListener(type,handler);
	}

	public static function removeEventListener(type:String, handler:Dynamic)
	{
		d.removeEventListener(type,handler);
	}

	public static function dispatchEvent(e:Event)
	{
		d.dispatchEvent(e);
	}

	// dispatch the tracker event after a specific delay
	// if it's close enough, do it immediately
	// update: it doubles the CPU usage so forget it for now, at least for SamplePos events
	static var maxprint = 0;
	public static function dispatchEventDelay(e:Event,delay:Float)
	{
		//delay+=latency;
		//if (delay<MIN_EVENT_DELAY) dispatchEvent(e);
		//else new TrackerEventTimer(delay,e).start();
		dispatchEvent(e);
		// actually, it takes too much CPU for the little accuracy gain
	}
}

class TrackerEventTimer extends Timer
{
	var tevent:Event;
	
	public function new(delay:Float, event:Event)
	{
		super(delay,1);
		this.tevent=event;
		addEventListener(TimerEvent.TIMER_COMPLETE, completeHandler);
	}

	function completeHandler(e:TimerEvent)
	{
		TrackerEventDispatcher.dispatchEvent(tevent);
	}
}