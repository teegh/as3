package com.thread.fileReadThread.FileReadThController
{
	
	
	import flash.events.Event;
	
	
	/**
	 * スレッドコントローラーに関するイベント
	 */
	public class FileReadThControllerEvent extends Event{
	
		
		//イベント
		public static const FileRead_Complete:String = "FileRead_Complete";			//スレッドの処理終了
		
		
		
		public var m:String;								//エラー・イベントメッセージ
		//public var waitThreadArr:Array = new Array();		//イベントで渡すObject
		
		
		
		
		public function FileReadThControllerEvent(type:String){	//,inWaitThreadArr:Array){
			super(type);
			//this.waitThreadArr = inWaitThreadArr;			//渡す値をおさめたObject
		}
		
		public override function clone():Event{
			return new FileReadThControllerEvent(type);			// , waitThreadArr);
		}
		
		public override function toString():String{
			return formatToString("FileReadThControllerEvent");	// , "waitThreadArr");
		}
	
		/*
		//ゲッターメソッド
		public function get waitThread():Array {
			return waitThreadArr;
		}
		*/
	}
	
}