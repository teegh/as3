package com.thread.fileReadThread
{
	
	
	import flash.events.Event;
	
	
	/**
	 * スレッドの状態に関するイベント
	 */
	public class fileReadThreadEvent extends Event{
	
		
		//イベント
		public static const Thread_Complete:String = "Thread_Complete";			//スレッドの処理終了
		
		
		
		public var m:String;								//エラー・イベントメッセージ
		public var waitThreadArr:Array = new Array();		//イベントで渡すObject
		
		
		
		
		public function fileReadThreadEvent(type:String , inWaitThreadArr:Array){
			super(type);
			this.waitThreadArr = inWaitThreadArr;	//渡す値をおさめたObject
		}
		
		public override function clone():Event{
			return new fileReadThreadEvent(type , waitThreadArr);
		}
		
		public override function toString():String{
			return formatToString("fileReadThreadEvent" ,"waitThreadArr");
		}
	
		
		//ゲッターメソッド
		public function get waitThread():Array {
			return waitThreadArr;
		}
	}
	
}