package com.mp3.ByteArrayAudio.Sys
{
	//import deng.fzip.FZip;
	//import deng.fzip.FZipFile;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.net.URLRequest;
	
	public class ZipMp3 extends EventDispatcher
	{
		public static const COMPLETE:String = "complete";
		
		public function ZipMp3():void {
			
		}
		
		private function convert():void{
			if(files.length > 0){
				var file:FZipFile = files.shift();
				var mp3ToSound:MP3ToSound = new MP3ToSound();
				mp3ToSound.addEventListener(Event.COMPLETE, mp3ToSoundItem_complete);
				mp3ToSound.convert(file.content);	//byteArray
			}
			else{
//				trace("finish");
				dispatchEvent(new Event(COMPLETE));
			}
		}
		
		private function mp3ToSoundItem_complete(e:Event):void {
			
			var mp3ToSound:MP3ToSound = e.target as MP3ToSound;
			trace("mp3ToSound_complete:" + mp3ToSound.filename);
			
			_sounds.push(mp3ToSound.sound);
			_filenames.push(mp3ToSound.filename);
			
			convert();
		}
	}
}