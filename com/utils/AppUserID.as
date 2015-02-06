package com.org.utils {
	
	//ユーザーIDを発行するクラス
	
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
	
	
	public class AppUserID{
		
		private var _userID:String = "";
		
		public function AppUserID():void {
			
		}
		
		//ID取得
		public function get userID():String {
			return _userID;
		}
		
		//ID生成
		public function createUserId():void {
			if (loadSetting_userID()) return;
			//設定値をバイナリ変換し、ローカルストアへ保管する。
			
			var userID_Str:String = "";
			var bytes:ByteArray = new ByteArray();
			
			userID_Str = alphab3()+"-"+ratStr8() + "-" + getNowTime("Date").replace(/\//g,"");
			
			//trace("作成："+userID_Str);
			_userID = userID_Str;
			
			bytes.writeUTFBytes(userID_Str);
			EncryptedLocalStore.setItem( "userID" , bytes );
			bytes = null;
			userID_Str = null;
			
			function ratStr8():String {
				var retStr:String = "";
				for (var i:uint = 0; i < 8; i++ ) {
					var r:uint = Math.floor(Math.random() * 10);
					retStr += String(r);
				}
				return retStr;
			}
			function alphab3():String {
				var alphaArr:Array = new Array();
				alphaArr = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P","Q"];
				
				var retStr:String = "";
				for (var i:uint = 0; i < 3; i++ ) {
					var r:uint = Math.floor(Math.random() * 16);
					retStr += alphaArr[r];
				}
				
				alphaArr = null;
				return retStr;
			}
		}
		
		//ローカルストアからの読み込み
		private function loadSetting_userID():Object {
			var retObj:Object = new Object();
			//保存されている音量、チャンネルを取得。
			try{
				//アクセスキーを暗号化されたローカルストアから取得
				var bytes:ByteArray = EncryptedLocalStore.getItem( "userID" );
				var userID:String = bytes.readUTFBytes( bytes.length );
				bytes = null;
				
				retObj = { userID:userID };
				_userID = userID;
				
				//trace("AppUser:"+userID);
				
				bytes = null;
				userID = null;
			}catch(e:TypeError){
				trace("設定が保存されていません。");
				retObj = null;
			}catch (e:Error) {
				trace("設定が保存されていません。");
				retObj = null;
			}
			return retObj;
		}
		
		private function getNowTime(inType:String):String {
			var now:Date = new Date();
			var monStr:String = now.month + 1 < 10 ? "0" + String(now.month + 1) : String(now.month + 1);
			var dateStr:String = now.date < 10 ? "0" + String(now.date) : String(now.date);
			var hourStr:String = now.hours < 10 ? "0" + String(now.hours) : String(now.hours);
			var minStr:String = now.minutes < 10 ? "0" + String(now.minutes) : String(now.minutes);
			var secStr:String = now.seconds < 10 ? "0" + String(now.seconds) : String(now.seconds);
			if(inType == "Time"){
				return String(now.fullYear) + "/" + monStr + "/" + dateStr + " " + hourStr + ":" + minStr + ":" + secStr;
			}else if(inType == "Date"){
				return String(now.fullYear) + "/" + monStr + "/" + dateStr;
			}
			return String(now.fullYear) + "/" + monStr + "/" + dateStr + " " + hourStr + ":" + minStr + ":" + secStr;
		}
	}
}