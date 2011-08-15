import flash.events.SampleDataEvent;
import flash.Lib;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;
import flash.media.Sound;
import flash.text.TextField;
import flash.utils.ByteArray;

import hxmikmod.MikModPlayer;

class Test
{
	
	private var player:MikModPlayer;
	private var tf:TextField;
	
	public static function main()
	{
		new Test();
	}
	
	public function new()
	{
		player = new MikModPlayer();
		player.loadSong(new XMTest());
		
		// Profiling info
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		tf = new TextField();
		tf.width = 640;
		tf.height = 480;
		Lib.current.addChild(tf);
	}
	
	public function onEnterFrame(e:Event)
	{
		tf.htmlText = Profiler.Summary();
	}
	
}