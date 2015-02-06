package com.utils {
	
	//import flash.data.EncryptedLocalStore;		//暗号化されたローカルストア
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
	 * 経過時間を計算。結果を取得するクラス
	 */
	public class StopWatch{
		
		private var timer:int 	= 0;
		private var _h:uint 	= 0;
		private var _m:uint 	= 0;
		private var _s:uint 	= 0;
		private var _ms:uint 	= 0;
		private var _isStart:Boolean 		= false;	//計測中であるか否か
		private var _instruTime:Boolean 	= false;	//計測結果が計算済みであるか否か
		
		public function StopWatch():void {
			
		}
		
		//計測開始
		public function startTime():void {
			timer = getTimer();	//現在の時間を取得
			_isStart = true;
			_instruTime = false;
			trace("[StopWatch] 経過時間 計測を開始します");
		}
		
		//計測停止
		public function stopTime():void {
			if (!_isStart) return;
			_isStart = false;
			_instruTime = true;
			
			timer = getTimer() - timer;
			
			var secondsTime:uint = Math.floor(timer/1000);
			_h = Math.floor(secondsTime/60/60);
			_m = Math.floor((secondsTime - _h*60*60)/60);
			_s = Math.floor(secondsTime - _h * 60 * 60 - _m * 60);
			_ms = Math.floor(timer - ((_h * 60 + _m) * 60 + _s)*1000 );
			trace("[StopWatch] 経過時間　計測を停止しました。　 -> " + String(_h) + "時間" + String(_m) + "分" + String(_s) + "秒 " + String(_ms) + "ミリ秒");
		}
		
		//時間、分、秒、ミリ秒の取得
		public function get h():uint {
			return _h;
		}
		public function get m():uint {
			return _m;
		}
		public function get s():uint {
			return _s;
		}
		public function get ms():uint {
			return _ms;
		}
		public function get timeString():String {
			if(!_isStart){
				return String(_h) + "時間" + String(_m) + "分" + String(_s) + "秒 " + String(_ms) + "ミリ秒";
			}else {
				return "";
			}
		}
		
		//時間が測定済であるか否か。
		public function get instruTime():Boolean {
			return _instruTime;
		}
	}
}