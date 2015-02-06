package com.utils {
	
	//import adobe.utils.CustomActions;
	import comApp.ByteArrayToSound;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;

	import flash.display.MovieClip;
	//import flash.display.Loader;
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
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	
	import com.utils.StopWatch;
	
	
	/*
	 * ファイルや展開されたByteArrayオブジェクトを、プロテクトする。
	 * また、プロテクトされたデータを復元する。
	 */
	public class ProtectData extends EventDispatcher{
		
		//public static const HAS_LOADED:String 	= "hasEncode";	//プロテクトデータが生成されたとき
		//public static const HAS_LOADED:String 	= "hasDecode";	//プロテクトデータが読み取られたとき
		
		
		public function ProtectData() :void {			
			
		}
		
		
		//********************************************************************************************************
		// エンコード、デコード メソッド
		//********************************************************************************************************
		
		//ファイルの読み込み、エンコード(プロテクト)
		public function encodeProtectFile(filePath:String):ByteArray {
			var byteArr:ByteArray 	= getFile_ByteData(filePath);
			byteArr = encodeProtect(byteArr);
			return byteArr;
		}
		
		
		//入力されたByteArrayをエンコード(プロテクト)する。
		public function encodeProtect(inByteArray:ByteArray):ByteArray {
			
			//stw.startTime();
			var byte:ByteArray 						= inByteArray;			
			var firstSeparationLength:uint 			= 5 + Math.floor(Math.random() * 3);
			var secondSeperationLength:uint			= 3 + Math.floor(Math.random() * 3);
			var inverceBlock:uint 					= (2 + Math.floor(Math.random() * 6))*2 + 1;			
			var shuffleInfoPosition:uint			= 128 + (Math.floor(Math.random() * 127));
			
			/*
			trace("---------------------------------------------------");
			trace("firstSeparationLength: " + firstSeparationLength);
			trace("secondSeperationLength: " + secondSeperationLength);
			trace("inverceBlock: " + inverceBlock);
			trace("(shuffleInfoPosition: "+shuffleInfoPosition+")");
			trace("---------------------------------------------------");
			*/
			
			var stw:StopWatch = new StopWatch();
			
			
			//バイナリーデーターをシャッフルして、ファイルに書き出す。
			byte = encode_separattionByteShuffle(byte, firstSeparationLength);			
			byte = encode_separattionByteShuffle(byte, secondSeperationLength);
			byte = encode_inverceByteShuffle(byte, inverceBlock);
			byte = encode_addInfo(byte, shuffleInfoPosition,[firstSeparationLength,secondSeperationLength,inverceBlock]);
			//writeFile_ByteArray(byte, File.desktopDirectory.nativePath + "/out.ra");
			
			//stw.stopTime();
			return byte;
		}
		
		
		//ファイルの読み込み、デコード(復元)
		public function decodeProtectFile(filePath:String):ByteArray {
			var byteArr:ByteArray 	= getFile_ByteData(filePath);
			byteArr = decodeProtect(byteArr);
			return byteArr;
		}
		
		
		//入力されたByteArrayをデコード(復元)する。
		public function decodeProtect(inByteArray:ByteArray):ByteArray {
			
			//stw.startTime();
			var byte:ByteArray = inByteArray;
			
			//シャッフルしたバイナリーデータを復元する。
			byte.position = 0
			var shuffleInfoArr:Array = decode_info(byte);
			byte = shuffleInfoArr[1];
			
			byte = decode_inverceByteShuffle(byte, shuffleInfoArr[0][2]);
			byte = decode_separattionByteShuffle(byte, shuffleInfoArr[0][1]);
			byte = decode_separattionByteShuffle(byte, shuffleInfoArr[0][0]);
			
			//writeFile_ByteArray(byte, File.desktopDirectory.nativePath + "/decode.mp3");
			
			/*
			trace("＜デコード結果＞");
			trace("シャッフル情報：");
			for (var i:uint = 0; i < shuffleInfoArr[0].length; i++ ) {
				trace("-> " + shuffleInfoArr[0][i]);
			}
			trace("バイナリー情報：");
			var traceStr:String = "";
			for (i = 0; i < byte.length; i++ ) {
				traceStr += byte[i] + " ";
				if (uint(byte[i]) % 10 == 0) {
					traceStr += "\n";
				}
			}
			trace(traceStr);
			*/
			
			//stw.stopTime();
			return byte;
		}
		
		
		
		
		
		
		//********************************************************************************************************
		// ファイル入出力
		//********************************************************************************************************
		
		//ファイルのバイナリーデータを取得する。
		private function getFile_ByteData(filePath:String):ByteArray{
			var file:File 			= new File(filePath);
			var stream:FileStream 	= new FileStream();
			var retByte:ByteArray 	= new ByteArray();
			
			stream.open(file, FileMode.READ);
			stream.readBytes(retByte, 0, stream.bytesAvailable);
			stream.close();
			
			//解放
			file 			= null;
			stream 			= null;
			
			return retByte;
		}
		
		
		//バイナリファイルを書き出し
		public function writeFile_ByteArray(inByte:ByteArray, inFilePath:String):void {
			var file:File 				= new File(inFilePath);		// 出力ファイルを作る
			var stream_out:FileStream 	= new FileStream();			// ファイルストリームオブジェクトを作成する
			var byte:ByteArray			= inByte;
			
			stream_out.open(file , FileMode.WRITE);			// 書き込みモードで開く
			stream_out.position = 0;						// アクセス開始位置を 0 へ
			stream_out.writeBytes(byte, 0 , byte.length);	// ByteArray オブジェクトから、総サイズ分読み込んで、ファイルに書き込む
			stream_out.close ();							// ファイルストリームを閉じる
			
			byte 		= null;
			stream_out 	= null;
			file 		= null;
		}
		
		
		
		
		
		
		//********************************************************************************************************
		// エンコード(プロテクト)とデコード(復元)
		//********************************************************************************************************
		
		//シャッフルした設定情報値をデータの末尾からinSufflePositionの位置に追加する。末尾には追記した位置を追記する。
		private function encode_addInfo(inByte:ByteArray, inSufflePosition:uint, inOptionPar:Array):ByteArray {
			var byte:ByteArray					= inByte;
			var sepByteVec:Vector.<ByteArray> 	= new Vector.<ByteArray>();
			
			//追記する位置でバイナリーファイルを分ける。
			byte.position = 0
			sepByteVec[0] = new ByteArray();
			byte.readBytes(sepByteVec[0], 0, byte.length - inSufflePosition);
			
			byte.position = byte.length - inSufflePosition;
			sepByteVec[1] = new ByteArray();
			byte.readBytes(sepByteVec[1], 0, inSufflePosition);
			
			byte.length = 0;
			byte = null;
			byte = new ByteArray();
			
			
			//追記する(前半のバイナリーデータ)
			sepByteVec[0].position = 0;
			sepByteVec[0].readBytes(byte, byte.length, sepByteVec[0].bytesAvailable);
			
			//追記する(シャッフル情報のバイナリーデータ)
			sepByteVec[2] = new ByteArray();
			sepByteVec[2].position = 0;
			for (var i:uint = 0; i < inOptionPar.length; i++ ) {
				sepByteVec[2][i]=uint(inOptionPar[i]);
			}
			sepByteVec[2].position = 0;
			sepByteVec[2].readBytes(byte, byte.length, sepByteVec[2].bytesAvailable);
			
			//追記する(後半のバイナリーデータ)
			sepByteVec[1].position = 0;
			sepByteVec[1].readBytes(byte, byte.length, sepByteVec[1].bytesAvailable);
			
			//追記する(位置情報を示すバイナリーデータ)
			sepByteVec[3] = new ByteArray();
			sepByteVec[3][0] = inSufflePosition;
			sepByteVec[3].position = 0;
			sepByteVec[3].readBytes(byte, byte.bytesAvailable, sepByteVec[3].bytesAvailable);
			
			
			//解放
			for (i = 0; i < sepByteVec.length; i++) {
				sepByteVec[i].length = 0;
				sepByteVec[i] = null;
			}
			sepByteVec.length = 0;
			sepByteVec = null;
			
			
			byte.position = 0;
			return byte;
		}
		
		//シャッフルした設定情報値を読み取る。
		private function decode_info(inByte:ByteArray):Array {
			var infoSize:uint = 3;
			
			var retArr:Array 					= new Array();
			var retByte:ByteArray 				= new ByteArray();
			var sepByteVec:Vector.<ByteArray> 	= new Vector.<ByteArray>();
			
			//設定値を読み取る
			var byte:ByteArray = inByte;
			var byteSize:uint = byte.length;
			var infoPosition:uint = uint(byte[byteSize -1]) + 1;
			for (var i:uint = 0; i < infoSize; i++ ) {
				retArr[i] = byte[byteSize -1 -infoPosition - (infoSize - i-1)];
			}
			
			//設定値を除いたバイナリーデータを読み込む。
			sepByteVec[0] = new ByteArray();
			byte.position = 0;
			byte.readBytes(sepByteVec[0], sepByteVec[0].length, byteSize -infoPosition - infoSize);
			
			byte.position += infoSize;
			byte.readBytes(sepByteVec[0], sepByteVec[0].length, byte.bytesAvailable-1);
			
			retByte = sepByteVec[0];
			
			/*
			//設定値読み込み結果
			trace("w-> "+byte[byteSize -infoPosition - infoSize]);
			trace("w-> " + byte[byteSize -infoPosition - infoSize +1]);
			trace("w-> "+byte[byteSize -infoPosition - infoSize+2]);
			*/
			
			return [retArr,retByte];
		}
		
		
		
		
		
		
		
		//入力されたバイナリーデータを指定バイトずつ反転させる
		// (例) 1 2 3 4 5 6 7 8 9 <3>
		// (結果) 789 456 123
		private function encode_inverceByteShuffle(inByte:ByteArray, inverceBlock:uint):ByteArray {
			
			var retByte:ByteArray 	= new ByteArray();
			var byteLangth:uint 	= inByte.length;
			var loopLength:uint 	= Math.ceil(byteLangth / inverceBlock);
			var readPosition:int	= byteLangth;
			
			for (var i:int = 1; i < loopLength + 1; i++) {
				readPosition = readPosition - inverceBlock;
				if (readPosition > 0) {
					inByte.position = readPosition;
					inByte.readBytes(retByte, retByte.bytesAvailable , inverceBlock);
				}else {
					inByte.position = 0;
					inByte.readBytes(retByte, retByte.bytesAvailable , readPosition + inverceBlock);
					break;
				}
			}
			return retByte;
		}
		
		//反転されたバイナリーデータを復元する。
		private function decode_inverceByteShuffle(inByte:ByteArray, inverceBlock:uint):ByteArray {
			
			var byte:ByteArray					= inByte;
			var retByte:ByteArray 				= new ByteArray();
			var sepByteVec:Vector.<ByteArray> 	= new Vector.<ByteArray>();
			var byteLangth:uint 				= inByte.length;
			var loopLength:uint 				= Math.floor(byteLangth / inverceBlock);
			var invercedByteSize:uint 			= inverceBlock * loopLength;
			var lessByteSizse:uint 				= byteLangth - invercedByteSize;
			
			
			sepByteVec[0] = new ByteArray();
			
			byte.position = invercedByteSize;
			byte.readBytes(sepByteVec[0], sepByteVec[0].length, lessByteSizse);
			
			var j:uint = 0;
			for (var i:uint = 0; i < loopLength; i++ ) {
				for (j = 0; j < inverceBlock; j++ ) {		
					byte.position = (loopLength - 1- i) * inverceBlock + j;
					byte.readBytes(sepByteVec[0], sepByteVec[0].length, 1);
				}
			}
			
			retByte = sepByteVec[0];
			return retByte;
		}
		
		
		
		
		
		
		
		
		
		//指定された数でバイナリーデータを分割後、1バイトずつ一つに纏めていく。 
		// (例) 1 2 3 4 5 6 7 8 9  10 11 <3>
		// (結果) 147 258 369 10 11
		private function encode_separattionByteShuffle(inByte:ByteArray , seperationLength:uint):ByteArray {
			
			var sepByteVec:Vector.<ByteArray> 	= new Vector.<ByteArray>();
			var byte:ByteArray 					= inByte;
			var byteLength:uint 				= inByte.length;
			var separationBlock:uint			= Math.floor( byteLength / seperationLength );
			
			for (var i:uint = 0; i < seperationLength; i++ ) {
				sepByteVec[i] = new ByteArray();
				byte.position = i * separationBlock;
				byte.readBytes(sepByteVec[i], sepByteVec[i].bytesAvailable , separationBlock);
			}
			if (byteLength != separationBlock * seperationLength) {
				sepByteVec[seperationLength] = new ByteArray();
				byte.position = separationBlock * seperationLength;
				byte.readBytes(sepByteVec[seperationLength], sepByteVec[seperationLength].bytesAvailable , byteLength - separationBlock * seperationLength);
			}
			
			//解放・初期化
			byte.length = 0;
			byte = null;
			byte = new ByteArray();
			
			//-------------------------------------------
			//分離させたものを結合させる。
			//-------------------------------------------
			for (var j:uint = 0; j < separationBlock; j++ ) {
				for (i = 0; i < seperationLength; i++ ) {
					sepByteVec[i].position = j;
					sepByteVec[i].readBytes(byte, byte.bytesAvailable, 1);
				}
			}
			if (byteLength != separationBlock * seperationLength) {
				sepByteVec[seperationLength].position = 0;
				sepByteVec[seperationLength].readBytes(byte, byte.bytesAvailable, sepByteVec[seperationLength].bytesAvailable);
			}
			byte.position = 0;
			
			
			return byte;
		}
		
		//分割され、1バイトずつ一つに纏められたバイトデータを復元する。 
		//(例) 147 258 369 10 11
		//(結果) 1 2 3 4 5 6 7 8 9  10 11 <3>

		//(例2) 1 4 7 10 13 | 2 5 8 11 14 | 3 6 9 12 15 | 16
		//(結果2) 1 2 3 4 5 6 7 8 9  10 11 12 13 14 15 16 <5>
		
		private function decode_separattionByteShuffle(inByte:ByteArray , inverceBlock:uint):ByteArray {
			
			var byte:ByteArray					= inByte;
			var retByte:ByteArray 				= new ByteArray();
			var sepByteVec:Vector.<ByteArray> 	= new Vector.<ByteArray>();
			var byteLangth:uint 				= inByte.length;
			var loopLength:uint 				= Math.floor(byteLangth / inverceBlock);
			var invercedByteSize:uint 			= inverceBlock * loopLength;
			var lessByteSizse:uint 				= byteLangth - invercedByteSize;
			
			
			sepByteVec[0] = new ByteArray();
			
			var j:uint = 0;
			var i:uint = 0;
			for (i = 0; i < inverceBlock; i++ ) {
				for (j = 0; j < loopLength; j++ ) {		
					byte.position = j * inverceBlock + i;
					byte.readBytes(sepByteVec[0], sepByteVec[0].length, 1);
				}
			}
			
			byte.position = invercedByteSize;
			byte.readBytes(sepByteVec[0], sepByteVec[0].length, lessByteSizse);
			
			retByte = sepByteVec[0];
			return retByte;
		}
	}
}