package com.utils {
	
	//*********************************
	//アプリケーションのウインドウ動作を決めるクラス
	//*********************************
	
	//オリジナルの閉じるボタン
	//「閉じるボタン」のデフォルト処理を無効にし、自作の処理を割り込ませるクラス。
			
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
	 * アプリケーションのウインドウ動作を決めるクラス
	 */
	public class AppWindowBtn{
		
		protected var _stage:Stage;
		protected var _window:MovieClip;
		
		public function AppWindowBtn():void {
			
		}
		
		public function init(inStage:Stage , inWindow:MovieClip):void{
			_stage 		= inStage;
			_window 	= inWindow;	//制御するアプリのウインドウとするムービークリップ
			
			init_setting();
		}
		
		private function init_setting():void {
			//イベントの設定
			//必要に応じてコメントアウト
			setWindowEvent();				//ウインドウのボタンやヘッダー部分の動作を設定。
			setWindowEvent_custom();		//上記の処理に加え、付け加えたいもの。(継承する際に使用)
			//init_originalClose();			//「閉じるボタン」のデフォルト処理を無効にし、自作の処理を割り込ませるクラス。
		}
		
		//ウインドウのボタンやヘッダー部分の動作を設定。
		//_window._closeBtn	ウインドウの閉じるボタン (ボタン)
		//_window._header		ウインドウのヘッダー部分 (ムービークリップ)
		private function setWindowEvent():void {
			_window.gotoAndStop(1);	//ムービークリップの再生を停止する。
			
			_window._closeBtn.addEventListener(MouseEvent.CLICK , closeApp);
			_window._header.addEventListener(MouseEvent.MOUSE_DOWN , moveApp);
			_window._header.gotoAndStop(1);	//ムービークリップの再生を停止する。
			
			//ウインドウの閉じるボタンを押すと、アプリを閉じる
			function closeApp(e:MouseEvent):void {
				_stage.nativeWindow.close();
			}
			//ウインドウのヘッダー部分をドラッグすると、アプリの移動を行う。
			function moveApp(e:MouseEvent):void {
				_stage.nativeWindow.startMove();
			}
		}
		
		//継承クラスで追加処理を記述
		protected function setWindowEvent_custom():void { }
		
		
		//「閉じるボタン」のデフォルト処理を無効にし、自作の処理を割り込ませるクラス。
		private function init_originalClose():void {
			
			//使い方
			//自前の終了処理を割り込ませる前に、同メソッドを実行すること。
			//自前の処理のイベントリスナー
			/*stage.nativeWindow.addEventListener(Event.CLOSING , function (e:Event):void {
				Function();					//オリジナル処理
				stage.nativeWindow.close();	//アプリの終了
			});
			*/
			
			_stage.nativeWindow.addEventListener(Event.CLOSING , closeApp);
			function closeApp(e:Event):void {
				_stage.nativeWindow.removeEventListener(Event.CLOSING , closeApp);
				e.preventDefault();	// 閉じられるデフォルト処理を無効にする
			}
		}
	}
}