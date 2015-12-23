hxMikMod
========

This is a Haxe/Flash port of libmikmod, a music module playing library.

It should be considered work in progress, but the modules I have tried
so far sound ok. I've implemented the MOD, XM, S3M, and IT loaders but
the more exotic formats aren't supported yet.

This is a very direct port from the original ANSI C code, so there
is little object orientation. Therefore this project shouldn't be used as
an example of good coding practices.




Why?
====

At the moment of writing, there is apparently NO freely available
Flash library that could play these music file formats. There are
a couple of 4-channel MOD player projects, but there seem to be
some license and/or playback issues such as unimplemented effects.

Apparently the only Flash app that can play >4 channel module formats
produced by programs like FastTracker 2, Scream Tracker or Impulse
Tracker, is the Alchemy-based FlashModPlug by UnitZeroOne, which is
however still unreleased at the moment.

Why would someone want to play with these deprecated file formats?
Apart from nostalgy, tracker modules offer several advantages over
MP3's: small file size, vast amount of available music
(ModLand hosts over 400,000 music files), easy creation...




Authors
=======

This port is based on libmikmod-3.2.0-beta2 which was developed
by Jean-Paul Mikkers, Jake Stine, Miod Vallat, Raphael Assenat,
and others.

Information about the original MikMod is available at
http://mikmod.raphnet.net/

This haXe port was written by Jouko Pynnönen (jouko@iki.fi)




Usage
=====

	MikMod.Init(null);
        Player.LoadURL("my_song.xm");

	// in an event handler that is called
	// when the loading is finished:

	Player.Start(module);


Please refer to the source, the included examples and the original
libmikmod documentation for more information.

SimplePlayer.hx is a minimal example of how to load and play a music
module embedded in the .swf.

MultiPlayer.hx contains a list of demo tunes, which it loads via
a URLRequest. There are also some GUI elements I mainly used
for debugging.





Notes on porting
================

Firstly, I'm new with haXe and Flash so there is probably a lot of room
for improvement in this project. Any contributions such as bug reports and
fixes, functionality patches, additional module format support, etc.
are appreciated.

The files under hxmikmod/ roughly correspond to the original ANSI C
file names. Most numerical constants are in Defs.hx. Loader routines
are in the hxmikmod.loaders package. I've added the MikMod and
Player classes mainly for convenience, e.g. the C function
MikMod_Init() was renamed to MikMod.Init() and Player_Start() to
Player.Start().

The hxmikmod.events package contains some rought outlining of an event
system that doesn't exist in the original library. It provides some support
for GUI interaction. Refer to MultiPlayer.hx for an example.

Currently the only proper way to find out when the module is loaded, is to use
thes event interface:

        TrackerEventDispatcher.addEventListener(TrackerLoadingEvent.TYPE,onTrackerLoading);

You will receive events about the loading process to an event handler:

	public function onTrackerLoading(e:TrackerLoadingEvent) {
	   if (e.state==TrackerLoadingEvent.LOADED)
        	Player.Start(e.module);
	}


The file Types.hx contains typedefs of the numeric types used in original
libmikmod. Currently they all translate into the haXe Int type.

There are a few functions that haven't been implemented yet (they're in the source
as stubs with a trace() call). However all playback functionality of the currently
supported formats should be there.

There are almost certainly some bugs lurking around, e.g. in the various effect functions
I haven't been able to test. Please let me know if you spot one.

Impulse Tracker compressed sample loading is SLOW. I'm not sure if this is a bug.




Resources
=========

hxmikmod:                   http://code.google.com/p/hxmikmod/
The original MikMod site:   http://mikmod.raphnet.net/
The Mod Archive:            http://modarchive.org/
Modland:                    ftp://ftp.modland.com/
World of Game Mods:         http://www.mirsoft.info/gamemods.php




License
=======

hxMikMod sound library
Copyright (C) 2011 Jouko Pynnönen <jouko@iki.fi>

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA




Acknowledgements
================

Thanks and greets to the artists whose work I've used for demonstration, testing,
and enjoyment purposes, including: Firefox, Tor Gausen, Barry Leitch, Lizardking, Maktone,
Purple Motion, Quasian, Radix, Random Voice, Tip.
