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

import flash.net.URLRequest;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.net.URLLoaderDataFormat;
import hxmikmod.event.TrackerEvent;
import hxmikmod.event.TrackerEventDispatcher;


class URLLoader extends flash.net.URLLoader {

   public function new(url:String) {
        super(null);
        dataFormat = URLLoaderDataFormat.BINARY;
        addEventListener(Event.COMPLETE,onComplete);
        addEventListener(IOErrorEvent.IO_ERROR,onError);
	addEventListener(ProgressEvent.PROGRESS,onProgress);
	load(new URLRequest(url));
   }


   function onProgress(e:ProgressEvent) {
	TrackerEventDispatcher.dispatchEvent(new TrackerLoadingEvent(0,"reading file",e.bytesLoaded/e.bytesTotal));
   }


   function onComplete(event:Event) {
        removeEventListener(Event.COMPLETE,onComplete);
        var m=Player.LoadBytes(data,32,false);
   }

   function onError(event:IOErrorEvent) {
        trace(event);
        removeEventListener(IOErrorEvent.IO_ERROR,onError);
   }




}
