package com.thread.fileReadThread {
	
	//スレッド上の進捗情報を格納するクラス
	
	//import flash.data.EncryptedLocalStore;		//暗号化されたローカルストア
	//import flash.desktop.*;
	//import flash.display.*;
	//import flash.events.*;
	//import adobe.utils.ProductManager;
	//import flash.filesystem.*;
	//import flash.html.*;
	//import flash.net.*;
	//import flash.system.System;
	//import flash.text.*;
	import flash.utils.*;
	//import flash.ui.*;
	import com.utils.StopWatch;
	
	public class ThreadProcessCounter{
		
		//スレッドの進捗を管理する値
		private var _thread:Number 			= 0;			//スレッドの実行数
		private var _readFile:Number 		= 0;			//読み込んだファイルの数 (処理する)
		private var _notReadFile:Number 	= 0;			//読み込んでいないファイルの数 (処理対象としなかったファイル)
		private var _folder:Number 			= 0;			//展開したフォルダーの数
		private var _message:String 		= "";			//処理の状況を示すメッセージ
		private var _openFilePath:String	= "";			//現在開いているファイルのファイルパス
		private var _stopWatch:StopWatch 					//処理時間計測クラス
		
		//スレッドの分散処理など利用する値
		private var _commitedCnt:uint				= 0;	//SQLの処理において、コミットを行った回数
		private var _beforeCommitedTime:int 		= 0;	//SQLの処理において、スレッドを開始してコミットするまでのを行ったときのgetTimer()値
		private var _clusterThreadCnt:Number		= 0;	//分散スレッドを実行した回数
		private var _directryDepthAtOpenFile:uint	= 0;	//開いたファイルのディレクトリ深度
		
		
		public function ThreadProcessCounter():void {
			_beforeCommitedTime = getTimer();
			_stopWatch			= new StopWatch();
		}
		
		//method
		public function startStopWatch():void {		//処理時間計測開始
			_stopWatch.startTime();
		}
		public function stopStopWatch():void {		//処理時間計測停止
			_stopWatch.stopTime();
		}
		
		//get
		public function get thread():Number {		//スレッド処理を行った回数
			return _thread;
		}
		public function get readFile():Number {		//読み込んだファイル (処理対象とするファイルの読み込み数)
			return _readFile;
		}
		public function get notReadFile():Number {	//読み込みしなかったファイル (処理対象外であり、ファイルの処理を行わなかったファイル数)
			return _notReadFile;
		}
		public function get folder():Number {		//展開したファイル数
			return _folder;
		}
		public function get message():String {		//読み込みに関する諸情報を収める変数
			return _message;
		}
		public function get commitedCnt():uint {		//スレッド中で、SQLトランザクション処理をコミットした回数
			return _commitedCnt;
		}
		public function get beforeCommitedTime():int {	//コミットした直後から、次にコミットする間に経過した時間
			return _beforeCommitedTime;
		}
		public function get clusterThreadCnt():Number {	//分散スレッドを実行した回数
			return _clusterThreadCnt;
		}
		public function get directryDepthAtOpenFile():uint {	//スレッドで読み込んだファイルのパス深度
			return _directryDepthAtOpenFile;
		}
		public function get openFilePath():String {		//スレッドで読み込んだファイルのファイルパス
			return _openFilePath;
		}
		public function get thCompleteTime():String {	//スレッドの処理に要した時間 (stopStopWatch()で処理時間停止を行った後で取得できる)
			return _stopWatch.timeString;
		}
		public function get thInstruComplete():Boolean {	//スレッドの処理にようした時間を取得できるか？ (処理時間計測済みか)
			return _stopWatch.instruTime;
		}
		
		//set
		public function set thread(inCnt:Number):void{
			_thread = inCnt;
		}
		public function set readFile(inCnt:Number):void {
			_readFile = inCnt;
		}
		public function set notReadFile(inCnt:Number):void {
			_notReadFile = inCnt;
		}
		public function set folder(inCnt:Number):void {
			_folder = inCnt;
		}
		public function set message(inStr:String):void {
			_message = inStr;
		}
		public function set commitedCnt(inCnt:uint):void {
			_commitedCnt = inCnt;
		}
		public function set beforeCommitedTime(inGetTime:int):void {
			_beforeCommitedTime = inGetTime;
		}
		public function set clusterThreadCnt(inCnt:Number):void {
			_clusterThreadCnt = inCnt;
		}
		public function set directryDepthAtOpenFile(inCnt:uint):void {
			_directryDepthAtOpenFile = inCnt;
		}
		public function set openFilePath(inStr:String):void {
			_openFilePath = inStr;
		}
	}
}