package com.utils {
	
	import flash.data.EncryptedLocalStore;		//暗号化されたローカルストア
	//import flash.desktop.*;
	//import flash.display.*;
	//import flash.events.*;
	//import flash.filesystem.*;
	//import flash.html.*;
	//import flash.net.*;
	//import flash.system.System;
	//import flash.text.*;
	import flash.utils.*;
	//import flash.ui.*;
	
	/**
	 * 設定を保存、出力するクラス
	 */
	public class AppSetting{
		
		private var _settingObj:Object;
		private var _parName:Array;
		
		//保存する値の名前を配列として入力
		public function AppSetting(... inPar_Arr):void {
			_parName = inPar_Arr;
		}
		
		//設定取得
		public function get settingObj():Object {
			return _settingObj;
		}
		
		
		//入力されるObjectの値をローカルストアに保存する
		public function saveSetting(inObj:Object):void {
			
			var bytes:ByteArray;
			
			for (var i:uint = 0; i < _parName.length; i++ ) {
				bytes = null;
				bytes = new ByteArray();
				
				if(inObj[_parName[i]] != null){
					bytes.writeUTFBytes(inObj[_parName[i]] != "" ? inObj[_parName[i]] : " ");	//その他 (通常処理)
					EncryptedLocalStore.setItem( _parName[i] , bytes );
				}
			}
			bytes = null;
			_settingObj = loadSetting();	//アプリ内で保持している値に反映
		}
		
		
		
		
		
		
		//設定の読み込み
		public function loadSetting():Object {
			
			var retObj:Object = new Object();
			
			//保存されている音量、チャンネルを取得。
			try{
				//アクセスキーを暗号化されたローカルストアから取得
				var bytes:ByteArray;
				
				for (var i:uint = 0; i < _parName.length; i++) {
					bytes = null;
					bytes = new ByteArray();
					bytes = EncryptedLocalStore.getItem( _parName[i] );
					retObj[_parName[i]] = bytes.readUTFBytes( bytes.length );
				}
				bytes = null;
				
			}catch (e:TypeError) {
				retObj = null;
			}catch (e:Error) {
				retObj = null;
			}
			
			_settingObj = retObj;
			return retObj;
		}
		
		
		public function deleteSetting():void {
			for (var i:uint = 0; i < _parName.length; i++ ) {
				EncryptedLocalStore.removeItem( _parName[i]);
			}
		}
	}
}