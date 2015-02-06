package com.thread.fileReadThread.FileReadThController {

	import flash.display.MovieClip;
	//import flash.data.EncryptedLocalStore;		//暗号化されたローカルストア
	//import flash.desktop.*;
	//import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	//import flash.html.*;
	//import flash.net.*;
	//import flash.system.System;
	//import flash.text.*;
	//import flash.utils.*;
	//import flash.ui.*;

	//ファイル読み込みスレッド
	import org.libspark.thread.Thread;
	import org.libspark.thread.IntervalThreadExecutor;
	import com.thread.fileReadThread.fileReadThread;
	import com.thread.fileReadThread.fileReadThreadEvent;
	import com.thread.fileReadThread.FileReadThController.FileReadThControllerEvent;

	/**
	 * ファイルをスレッドで読み込む処理。
	 */
	/*
	//使い方の例。
	var fileReadThCtrl:FileReadThController = new FileReadThController("C:\\Users\\Desktop\\mp3", _main);
	fileReadThCtrl.addEventListener(FileReadThControllerEvent.FileRead_Complete , onComplete_readFileTh);
	fileReadThCtrl.start();
	*/
	public class FileReadThController extends EventDispatcher{

		private var _importFile:String = "";
		private var _loadingBarDisp:MovieClip;
		private var _fileReadTh:fileReadThread;

		public function FileReadThController(importFilePath:String, loadingBarDisp:MovieClip):void {
			Thread.initialize(new IntervalThreadExecutor(2));
			_importFile = importFilePath;
			_loadingBarDisp = loadingBarDisp;
		}

		public function start():void {
			var readFile:File = new File(_importFile);
			_fileReadTh = new fileReadThread([[readFile]], _loadingBarDisp);	//Fileは２次元配列で入力すること。
			_fileReadTh.addEventListener(fileReadThreadEvent.Thread_Complete , onThreadComplete);
			_fileReadTh.start();
		}




		//スレッドの処理が一旦完了したら
		private function onThreadComplete(e:fileReadThreadEvent):void {
			//trace("[FileReadThController] スレッドの処理が一旦完了");
			_fileReadTh.removeEventListener(fileReadThreadEvent.Thread_Complete , onThreadComplete);
			_fileReadTh = null;

			if (e.waitThread.length > 0) {
				waitThread(e.waitThread);
			}else{
				processComplete();
			}
		}

		//待機スレッドがあれば、引き続き読み込み処理を実行する。
		private function waitThread(inArr:Array):void {
			_fileReadTh = new fileReadThread(inArr, _loadingBarDisp);
			_fileReadTh.addEventListener(fileReadThreadEvent.Thread_Complete , onThreadComplete);
			_fileReadTh.start();
		}

		//処理が完了したらイベントを発行する。
		private function processComplete():void {
			//trace("[FileReadThController] スレッドの処理完了");
			dispatchEvent(new FileReadThControllerEvent(FileReadThControllerEvent.FileRead_Complete));
		}
	}
}