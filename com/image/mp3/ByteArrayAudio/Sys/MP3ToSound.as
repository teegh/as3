package com.mp3.ByteArrayAudio.Sys
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	
	/*
	 * ByteArrayをSoundオブジェクトに変換し、Soundオブジェクトを返す。
	 */ 
	public class MP3ToSound extends EventDispatcher
	{
		
		private var _sound:Sound;
		private var mp3Parser:MP3Parser;
		
		public function get sound():Sound{
			return _sound;
		}
		
		
		
		public function MP3ToSound(){
			mp3Parser = new MP3Parser();
		}
		
		public function convert(byteArray:ByteArray):void{
			mp3Parser.setMp3Data(byteArray);
			generateSound(mp3Parser);
		}
		
		
		//リトル円ディアンのbytearrayを返す。
		private function generateSound(mp3Source:MP3Parser):Boolean{
			var swfBytes:ByteArray = new ByteArray();
			swfBytes.endian = Endian.LITTLE_ENDIAN;
			for(var i:uint=0; i < SoundClassSwfByteCode.soundClassSwfBytes1.length; ++i){
				swfBytes.writeByte(SoundClassSwfByteCode.soundClassSwfBytes1[i]);
			}
			var swfSizePosition:uint=swfBytes.position;
			swfBytes.writeInt(0); //swf size will go here
			for(i=0;i<SoundClassSwfByteCode.soundClassSwfBytes2.length;++i){
				swfBytes.writeByte(SoundClassSwfByteCode.soundClassSwfBytes2[i]);
			}
			var audioSizePosition:uint=swfBytes.position;
			swfBytes.writeInt(0); //audiodatasize+7 to go here
			swfBytes.writeByte(1);
			swfBytes.writeByte(0);
			
			mp3Source.writeSwfFormatByte(swfBytes);
			
			var sampleSizePosition:uint=swfBytes.position;
			swfBytes.writeInt(0); //number of samples goes here
			
			swfBytes.writeByte(0); //seeksamples
			swfBytes.writeByte(0);
			
			var frameCount:uint	 = 0;
			var byteCount:uint	 = 0; 	//this includes the seeksamples written earlier
			
			for(;;){
				var seg:ByteArraySegment=mp3Source.getNextFrame();
				if(seg==null)break;
				swfBytes.writeBytes(seg.byteArray,seg.start,seg.length);
				byteCount+=seg.length;
				frameCount++;
			}
			
			if(byteCount==0){
				return false;
			}
			byteCount += 2;
			
			
			var currentPos:uint=swfBytes.position;
			swfBytes.position=audioSizePosition;
			swfBytes.writeInt(byteCount+7);
			swfBytes.position=sampleSizePosition;
			swfBytes.writeInt(frameCount*1152);
			swfBytes.position=currentPos;
			for(i=0;i<SoundClassSwfByteCode.soundClassSwfBytes3.length;++i)	{
				swfBytes.writeByte(SoundClassSwfByteCode.soundClassSwfBytes3[i]);
			}
			swfBytes.position=swfSizePosition;
			swfBytes.writeInt(swfBytes.length);
			swfBytes.position = 0;
			
			var context:LoaderContext = new LoaderContext();
			context.allowLoadBytesCodeExecution = true;
			
			var swfBytesLoader:Loader=new Loader();
			swfBytesLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,swfCreated);
			swfBytesLoader.loadBytes(swfBytes,context);
			return true;
		}
		
		
		private function swfCreated(ev:Event):void{
			mp3Parser.kill();
			mp3Parser = null;
			
			var loaderInfo:LoaderInfo=ev.currentTarget as LoaderInfo;
			var soundClass:Class=loaderInfo.applicationDomain.getDefinition("SoundClass") as Class;
			_sound = new soundClass();
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}