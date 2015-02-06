package com.utils {
	
	//キーが押されているかチェックするクラス
	
	//import flash.data.EncryptedLocalStore;		//暗号化されたローカルストア
	//import flash.desktop.*;
	import flash.display.*;
	import flash.events.*;
	//import flash.filesystem.*;
	//import flash.html.*;
	//import flash.net.*;
	//import flash.system.System;
	//import flash.text.*;
	//import flash.utils.*;
	//import flash.ui.*;
	
	
	/**
	 * キーが押されているかチェックするクラス
	 */
	public class KeyDownCheck{
		
		//※他のウインドウをアクティブ中に、このウインドウをアクティブにすると、キーダウンイベントが取得できない。
		//アクティブ時に、キーボードイベントの監視のオンオフ
		//キーの判定がわからない間は、「不明」である値を示す
		
		private var _stage:Stage;
		private var key_code:uint;
		private var key_location:uint;
		private var ctrl_key:Boolean;
		private var shift_key:Boolean;
		private var alt_key:Boolean;
		private var isPress:Boolean;
		
		public function KeyDownCheck(inStage:Stage):void {
			_stage = inStage;
			startChk();
		}
		
		
		private function startChk():void{
			// キーボードを押したときに実行される関数
			function KeyDownFunc(e:KeyboardEvent):void{
				
				//キーを押しているか
				isPress = true;
				//trace("押している");
				
				// キーコード
				key_code = e.keyCode;
				//trace("code:" + key_code);

				// Shiftキーなど 左側=1 か 右側=2 か
				key_location = e.keyLocation;
				//trace("location:" + key_location);

				// Ctrlキーの押下状態
				ctrl_key = e.ctrlKey;
				//trace("ctrl:" + ctrl_key);

				// Shiftキーの押下状態
				shift_key = e.shiftKey;
				//trace("shift:" + shift_key);

				// Altキーの押下状態
				alt_key = e.altKey;
				//trace("alt:" + alt_key);
			}

			function KeyUpFunc(e:KeyboardEvent):void {
				//trace("離している");
				isPress			= false;
				key_code 		= 0;
				key_location 	= 0;
				ctrl_key 		= false;
				shift_key 		= false;
				alt_key 		= false;
			}
			
			// イベントを登録
			_stage.addEventListener(KeyboardEvent.KEY_DOWN , KeyDownFunc);
			_stage.addEventListener(KeyboardEvent.KEY_UP , KeyUpFunc);
		}
		
		
		//ゲッターメソッド
		public function get press():Boolean {
			return isPress;
		}
		public function get code():uint {
			return key_code;
		}
		public function get location():uint {
			return key_location;
		}
		public function get ctrl():Boolean {
			return ctrl_key;
		}
		public function get shift():Boolean {
			return shift_key;
		}
		public function get alt():Boolean {
			return alt_key;
		}
		
	}
}