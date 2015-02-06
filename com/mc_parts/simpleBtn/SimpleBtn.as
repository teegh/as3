package com.mc_parts.simpleBtn {
			
	//import flash.desktop.*;
	import flash.display.*;
	import flash.events.*;
	import flash.ui.Mouse;
	//import flash.filesystem.*;
	//import flash.html.*;
	//import flash.net.*;
	//import flash.system.System;
	//import flash.text.*;
	//import flash.utils.*;
	//import flash.ui.*;
	
	import com.mc_parts.simpleBtn.SimpleBtnEvent;
	
	//mcの構造
	// mc(本体)	--- _enabledMC (MovieClip) 有効(2) 無効(1)のイメージフレームが含まれている。フレームアクションにstop();記述あり。
	//		    --- _btn	   (SimpleButton) 通常のボタンインスタンス
	
	/**
	 * シンプルなボタン。選択状態の表示あり
	 */
	public class SimpleBtn extends MovieClip {
		
		private var _enabled:Boolean = true;
		
		public function SimpleBtn():void {
			stop();
			init();
		}
		
		private function init():void {
			_enabledMC.gotoAndStop(2);
			_enabledMC.mouseEnabled = false;
			_btn.addEventListener(MouseEvent.CLICK, onMouseDonw_Btn);
			function onMouseDonw_Btn(e:MouseEvent):void {
				enabledBtn_call(false);
				dispatchEvent(new SimpleBtnEvent( SimpleBtnEvent.SELECTED));	//イベント発行
			}
		}
		
		private function enabledBtn_call(isEnabled:Boolean):void {
			this.enabledBtn = isEnabled;
		}
		public function get enabledBtn():Boolean {
			return _enabled;
		}
		public function set enabledBtn(inEnabled:Boolean):void {
			_enabled = inEnabled;
			if (!_enabled) {
				_btn.enabled 		= false;
				_btn.mouseEnabled 	= false;
				_btn.tabEnabled 	= false;
				_enabledMC.gotoAndStop(1);
			}else {
				_btn.enabled 		= true;
				_btn.mouseEnabled 	= true;
				_btn.tabEnabled 	= true;
				_enabledMC.gotoAndStop(2);
			}
		}
	}
}