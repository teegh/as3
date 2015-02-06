package com.mp3.ByteArrayAudio {
	
	//import adobe.utils.CustomActions;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;

	import flash.display.MovieClip;
	import flash.display.Loader;
	//import flash.display.BlendMode;
	//import flash.display.BitmapData;
	//import flash.display.Bitmap;
	//import flash.net.URLRequest;
	import flash.events.Event;
	//import flash.geom.Rectangle;
	//import flash.geom.Matrix;
	//import flash.geom.ColorTransform;
	import flash.system.LoaderContext;
	import flash.filesystem.*;
	import flash.utils.ByteArray;
	import flash.media.Sound;
	
	import com.mp3.ByteArrayAudio.Sys.MP3ToSound;
	
	
	/*
	 * mp3データを含むByteArrayオブジェクトをSoundオブジェクトに変換する。 
	 * 変換処理自体はMP3ToSoundで行っている。
	 */
	public class ByteArrayToSound extends EventDispatcher{
		
		public static const HAS_LOADED:String 	= "hasLoaded";
		private var _mp3ToSound:MP3ToSound 		= new MP3ToSound();
		
		
		public function ByteArrayToSound() :void {			
			
		}
		
		
		
		//ファイルの読み込み。
		//ByteArrayをSoundに変換する処理へ渡す
		public function loadAudioFile(filePath:String):void {
			var file:File = new File(filePath);
			var stream:FileStream 	= new FileStream();
			var byteArr:ByteArray 	= new ByteArray();
			
			stream.open(file, FileMode.READ);
			stream.readBytes(byteArr, 0, stream.bytesAvailable);
			loadSoundData_atByteArray(byteArr);
			
			//解放
			file 			= null;
			stream 			= null;
			byteArr.length 	= 0;
			byteArr 		= null;
		}
		
		//入力されたByteArrayをSoundオブジェクトに変換
		public function loadSoundData_atByteArray(inByteArray:ByteArray):void {
			_mp3ToSound.addEventListener(Event.COMPLETE, onComplete_loadSuccess);
			_mp3ToSound.convert(inByteArray);
		}
		
		
		
		//ByteArrayからsoundオブジェクトを作成したら、処理完了のイベント発行を行う。
		private function onComplete_loadSuccess(evt:Event):void {
			_mp3ToSound.removeEventListener(Event.COMPLETE, onComplete_loadSuccess);
			this.dispatchEvent(new Event(HAS_LOADED));
		}
		
		//変換されたSoundオブジェクトを返す。
		public function get sound():Sound{
			return _mp3ToSound.sound;
		}		
	}
}