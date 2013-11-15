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

package ;

import flash.Lib;
import flash.text.TextField;
import haxe.PosInfos;



// This class can be used to approximate how much time
// different parts of the code use.
//
// Insert Profiler.ENTER(); in the beginning of the method you want to
// examine and Profiler.LEAVE(); in the end.
//
// The Summary() method will dump the calculations in a textfield.
//
// Note: you must call Profiler.LEAVE() before every return statement,
// otherwise the calculation will be wrong. There's no error checking.
// Note2: measuring time of recursive methods won't work, i.e. if
// Profiler.ENTER() is called twice without a LEAVE(), the first enter
// timestamp is lost.

class Profiler
{
	static var entertime:Map<String, Int> = new Map();
	static var totaltime:Map<String, Int> = new Map();
	static var called:Map<String, Int> = new Map();
	static var profiling_started = 0;

	inline static var UNPROFILED = "(unprofiled time) ";
	inline static var PROFILER_ENABLED = true;

	public static function reset()
	{
		totaltime = new Map();
		entertime = new Map();
		called = new Map();
		profiling_started = Lib.getTimer();
	}

	inline public static function ENTER(?pos:PosInfos)
	{
		if (PROFILER_ENABLED)
		{
			var m = pos.className + "." + pos.methodName;
			var t = Lib.getTimer();
			entertime.set(m, t);
			called.set(m, called.get(m) + 1);
		}
	}

	inline public static function LEAVE(?pos:PosInfos)
	{
		if (PROFILER_ENABLED)
		{
			var t = Lib.getTimer();
			var m = pos.className + "." + pos.methodName;
			var d = t - entertime.get(m);
			totaltime.set(m, totaltime.get(m) + d);
		}
	}

	public static function Summary():String
	{
		var alltime:Float = Lib.getTimer() - profiling_started;	// total real time passed ms
		var t:String = "<font face=\"consolas,courier\" size=\"14\">";
		var text:String;
		var totalms:Int = 0; // time spent inside profiled code
		var nameSize:Int = 50, timeSize:Int = 8, percentSize:Int = 4;
		var sorted:Array<String> = new Array<String>();
		
		for (method in totaltime.keys())
		{
			var time = totaltime.get(method);
			totalms += time;
			var i:Int = 0;
			while (i < sorted.length)
			{
				if (totaltime.get(sorted[i]) < time)
					break;
				i++;
			}
			sorted.insert(i, method);
		}
		if (totalms == 0)
			return "not enough data";
		for (method in sorted)
		{
			var ms = totaltime.get(method);
			t += method;
			for (i in method.length ... nameSize) t += " ";
			
			text = ms + "ms";
			t += text;
			for (i in text.length ... timeSize) t += " ";
			
			text = Math.round(100 * ms / totalms) + "%";
			t += text;
			for (i in text.length ... percentSize) t += " ";
			
			t += called.get(method) + "\n";
		}
		var unprofiled = alltime - totalms;
		t += "\n" + UNPROFILED + "                                " +
			unprofiled + "ms  " + Math.round(100 * unprofiled / alltime) + "% \n" + 
			"\n\n<b>hxMikMod v0.8\nheardtheword@gmail.com</b></font>";
		return t;
	}

}
