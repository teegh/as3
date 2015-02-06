package com.mp3.MP3Encode {
	
	//import flash.data.EncryptedLocalStore;		//暗号化されたローカルストア
	import flash.desktop.*;
	//import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	//import flash.html.*;
	//import flash.net.*;
	//import flash.system.System;
	//import flash.text.*;
	import flash.utils.*;
	//import flash.ui.*;
	
	
	/**
	 * mp3にエンコードするクラス。
	 * 
	 * (できること)
	 * エンコード前に含まれていたreplay gainの情報を、出力ファイルに自動追加。ただしmp3Gain 93db以外の適用値だった場合は追加されない。
	 * エンコード後のデータはmp3ByteDataで取得できる。
	 * mp3ByteDataをwriteFile_ByteArrayすれば、ファイルを書き出すこともできる。
	 */
	public class MP3Encode extends EventDispatcher{
		
		private var _outFilePath:String;			//出力先のファイルパスを保持する。
		private var _replayGainFrame:ByteArray;		//Replay Gainバイナリーデータ
		private var _encode_mp3ByteData:ByteArray;	//エンコードしたmp3のバイナリーデータ
		
		public function MP3Encode():void {
			
		}
		
		//エンコードしたmp3のバイナリーデータを返す。
		public function get mp3Data():ByteArray {
			return _encode_mp3ByteData;
		}
		
		//mp3を指定ビットレートに書き出し
		public function mp3Encode(inFilePath:String, inOutTempFilePath:String, bitrate:uint):void {
			
			_outFilePath 	= inOutTempFilePath;			//出力先のファイルパスを保持する。
			_replayGainFrame = getReplayGain(inFilePath);	//Replay Gainバイナリーデータを取得。
			
			//NativeProcessStartupInfoを作成し起動したexeを指定します。
			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			var file:File = File.applicationDirectory.resolvePath("bin/lame/lame.exe");
			
			if(file.exists){			
				info.executable = file;
				//exeの呼び出し引数をVector.<String>で作成し、NativeProcessStartupInfoに設定します。
				var processArgs:Vector.<String> = new Vector.<String>();
				processArgs[0] = "--abr";				//--abr平均ビットレート -b固定ビットレート
				processArgs[1] = String(bitrate);
				processArgs[2] = inFilePath;
				processArgs[3] = _outFilePath;
				info.arguments = processArgs;
				
				//NativeProcessを生成して、各種イベントハンドラを設定し、NativeProcessStartupInfo を引数にして、
				//NativeProcess .start関数に呼び出すことで、指定したexeを起動させます。
				var process:NativeProcess = new NativeProcess();
				//process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData);
				//process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onErrorData);
				process.addEventListener(NativeProcessExitEvent.EXIT, onExit);
				//process.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onIOError);
				//process.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onIOError);
				process.start(info);
			}
		}
		
		//エンコード完了。Replay Gainの情報を追加
		private function onExit(evt:NativeProcessExitEvent):void {
			
			//lame.exeで書き出されたファイルのバイナリーデータを取得
			_encode_mp3ByteData = getFile_ByteData(_outFilePath);
			
			//書き出したmp3ファイルにReplayGainのフレームを追加
			if (_replayGainFrame.length != 0) {
				_encode_mp3ByteData = addReplayGain(_encode_mp3ByteData, _replayGainFrame);
			}
			
			//処理完了のイベント
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		//ファイルのバイナリーデータを取得する。
		private function getFile_ByteData(inFilePath:String):ByteArray {
			var retByte:ByteArray 	= new ByteArray();
			var file:File 			= new File(inFilePath);
			var stream:FileStream 	= new FileStream();
			
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
			
			//解放
			file 		= null;
			stream_out 	= null;
			byte 		= null;
		}
		
		
		//リプレイゲインの情報があれば、取得する。
		//更にReplay Gainの設定値が適正であれば、そのデータを返す。
		private function getReplayGain(inFilePath:String):ByteArray {
			
			var retByte:ByteArray 			= new ByteArray();
			var byteArr:ByteArray 			= getFile_ByteData(inFilePath);
			var tempByte:ByteArray			= new ByteArray();
			var tempReplaceByte:ByteArray	= new ByteArray();
			var labelStr:String 			= "";
			var labelStr_s:String 			= "";
			var byteArrLength:uint 		= byteArr.length;
			var frameStartPosition:uint = 0;
			var frameLength:uint		= 0;
			var apeTagLength:uint		= 0;					//APEタグの長さ
			var apeTagNum:uint			= 0;					//APEタグの数
			var apeTagDataLength:uint 	= 0;
			var checkLoop:uint 			= 0;
			var replayTrackGain:Number	= 0;					//replay gainの値
			var gainError:Boolean 		= true;					//replay gainが適用されていない かどうかのフラグ
			
			
			
			//------------------------------
			//mp3Gainの適用有無を確認する
			//------------------------------
			byteArr.position 		= byteArrLength-160;		//MP3Gain APETAGフッターの先頭を指定。
			
			if (byteArr.readMultiByte(6, "shift_jis").match(/APETAG/i)) {
				//-----------------
				//APEタグの長さを取得。
				//-----------------
				byteArr.position += 6;
				tempByte.length 		= 4;
				tempReplaceByte.length 	= 4;
				tempByte.position 		= 0;
				byteArr.readBytes(tempByte,2,2);
				//trace(tempByte[0]+":"+tempByte[1]+":"+tempByte[2]+":"+tempByte[3]);
				tempByte.readBytes(tempReplaceByte,0,4);		//ひっくり返す
				tempByte[2] = tempReplaceByte[3];
				tempByte[3] = tempReplaceByte[2];
				tempByte.position = 0;
				//trace(tempByte[0]+":"+tempByte[1]+":"+tempByte[2]+":"+tempByte[3]);
				apeTagLength = tempByte.readInt();				//<4>取得したByteArrayオブジェクト32bit分をの32bit整数値に変換する。
				
				//-----------------
				//APEタグの数を取得。
				//-----------------
				byteArr.position += 2;
				tempByte 				= new ByteArray();
				tempReplaceByte			= new ByteArray();
				tempByte.length 		= 4;
				tempReplaceByte.length 	= 4;
				tempByte.position 		= 0;
				byteArr.readBytes(tempByte,2,2);
				tempByte.readBytes(tempReplaceByte,0,4);		//ひっくり返す
				tempByte[2] = tempReplaceByte[3];
				tempByte[3] = tempReplaceByte[2];
				tempByte.position 		= 0;
				apeTagNum = tempByte.readInt();					//<4>取得したByteArrayオブジェクト32bit分をの32bit整数値に変換する。
				
				//-----------------
				//MP3Gain APETAGの内容を指定。
				//-----------------
				byteArr.position 	= byteArrLength -160 - apeTagLength + 32;
				frameStartPosition 	= byteArrLength -160 - apeTagLength;
				frameLength			= 160 + apeTagLength;
				
				//trace("▼apeTagNum: "+apeTagNum);
				//trace("▼apeTagLength: "+apeTagLength);
				
				for(var i:uint=0; i<apeTagNum; i++){
					
					//-----------------
					//APEタグデータ長を取得
					//-----------------
					//apeTagDataLength = uint(byteArr.readMultiByte(1, "shift_jis"));
					tempByte 				= new ByteArray();
					tempReplaceByte			= new ByteArray();
					tempByte.length 		= 4;
					tempReplaceByte.length 	= 4;
					tempByte.position 		= 0;
					byteArr.readBytes(tempByte,2,2);
					tempByte.readBytes(tempReplaceByte,0,4);		//ひっくり返す
					tempByte[2] = tempReplaceByte[3];
					tempByte[3] = tempReplaceByte[2];
					tempByte.position 		= 0;
					apeTagDataLength 		= tempByte.readInt();	//<4>取得したByteArrayオブジェクト32bit分をの32bit整数値に変換する。
				
					byteArr.position += 6;
					
					//trace("▼apeTagDataLength["+i+"]: "+apeTagDataLength);
					
					//-----------------
					//APEタグのラベル名を取得
					//-----------------
					labelStr 	= "";
					labelStr_s 	= byteArr.readMultiByte(1, "shift_jis");
					checkLoop 	= 0;
					while( labelStr_s != "" ){
						//trace("▼ - checkLoop:"+checkLoop);
						labelStr 	= labelStr + labelStr_s;
						labelStr_s 	= byteArr.readMultiByte(1, "shift_jis");
					}
					//trace("▼labelStr["+i+"]: "+labelStr);
					
					
					if (labelStr.match(/REPLAYGAIN_TRACK_GAIN/i) || labelStr.match(/replaygain_track_gain/i) ){
						
						//MP3Gain REPLAYGAIN_TRACK_GAINの設定値の位置を指定。Gain設定値の計算方法：89(デフォルト) - MP3Gain REPLAYGAIN_TRACK_GAIN値
						replayTrackGain 	= 89.0 - Number(byteArr.readMultiByte(apeTagDataLength-3, "shift_jis"));
						byteArr.position 	+= 3;
						//trace("▼replayTrackGain["+i+"]: "+replayTrackGain);
						if ( replayTrackGain <= 92.200 || replayTrackGain >= 93.800) {	//93dB ±0.8
							//trace("replayTrackGainが93dB以外の設定値になっています");
							trace("ReplayGainの設定値が誤っている可能性があります。MP3Gain設定値："+replayTrackGain+"[dB]。[修正方法]MP3Gainを適用し直してください。");
							//fileErrorMessage		+= "▼異常：MP3Gainの設定値が誤っている可能性があります。MP3Gain設定値："+replayTrackGain+"[dB]。[修正方法]MP3Gainを適用し直してください。";		//異常内容
							//gainErrorMes 			+= "　　→MP3Gainの設定値が誤っている可能性があります。\n　　現在のMP3Gain設定値： "+replayTrackGain+"[dB]\n";
						}else{
							gainError 	= false;		//mp3Gain適正値
							trace("ReplayGainの設定値は適正値です。MP3Gain設定値："+replayTrackGain+"[dB]。");
						}
						break;
					}else{
						//APETAG ラベル名がREPLAYGAIN_TRACK_GAIN以外の場合
						byteArr.position += apeTagDataLength;
					}
				}
				if (gainError) {
					trace("ReplayGainの情報は見つかりましたが、正常に読み込めませんでした。");
					//fileErrorMessage		+= "▼異常：読み込んだmp3ファイルはMP3Gainを適用していますが、データが壊れている可能性があります。[修正方法]改めてMP3Gainを適用し直してください。";		//異常内容
					//gainErrorMes 			+= "　　→MP3Gainが適用されていません。\n";
				}
				
			}else {
				trace("ReplayGainの情報は見つかりません。");
				//fileErrorMessage		+= "▼異常：MP3Gainが適用されていない可能性があります。[修正方法]MP3Gainを適用してください。";		//異常内容
				//gainErrorMes 			+= "　　→MP3Gainが適用されていません。\n";
			}
			
			//Replay Gainの情報が見つかったとき。
			if (!gainError) {
				byteArr.position = frameStartPosition;
				byteArr.readBytes(retByte, 0, frameLength);
				//trace("取りだしたフレームの数："+frameLength);
			}
			
			//解放
			byteArr.length 			= 0;
			tempByte.length 		= 0;
			tempReplaceByte.length 	= 0;
			byteArr		 			= null;
			tempByte 				= null;
			tempReplaceByte 		= null;
			labelStr 				= null;
			labelStr_s 				= null;
			
			return retByte;
		}
		
		
		
		
		//リプレイゲインの情報を追記する。
		private function addReplayGain(inFileByteData:ByteArray, inReplayGainByteData:ByteArray):ByteArray {
			
			var replayGainByteData:ByteArray 	= inReplayGainByteData;
			var byteArr:ByteArray 				= inFileByteData;
			
			replayGainByteData.position = 0; 
			byteArr.position = 0;
			
			replayGainByteData.readBytes(byteArr, byteArr.length , replayGainByteData.length);
			
			return byteArr;
		}
		
		
	}
}