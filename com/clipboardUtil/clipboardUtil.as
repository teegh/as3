package com.clipboardUtil{
	
	//クリップボードに関する処理
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.filesystem.*;
	
	public class clipboardUtil{
		
		public function clipboardUtil():void {
			init();
		}
		
		private function init():void {
			
		}
		
		
		//オペレイティングシステムクリップボードの内容にアクセスし、テキストが存在すれば返す。
		public function getClipBoad_Str():String {
			var clipboard : Clipboard = Clipboard.generalClipboard;						// OS のクリップボードを取得
			var str:String = clipboard.getData(ClipboardFormats.TEXT_FORMAT) as String;	// クリップボードからテキストデータを取得
			if(str){
				//trace("Clipboad TXET : " + str);
				return str;
			}else {
				return "";
			}
		}
		
		
		//ファイルパスを、ファイルとしてオペレイティングシステムクリップボードに格納する。
		//(利用例) 右クリック　＞　ペーストなど命令でクリップボードのファイルリストを使用できる。
		public function writeClipBoad_file(inNativePath:String):void{
			var clipboard:Clipboard = Clipboard.generalClipboard;						// OS のクリップボードを取得
			var setFile:File = new File(inNativePath);
			if (setFile.exists) {
				clipboard.setData(ClipboardFormats.FILE_LIST_FORMAT , [setFile]);
			}
		}
		
		//ファイルパスを、ファイルとしてクリップボードに格納し、それを返す。
		//(利用例) ドラッグなど操作で、指定されたファイルをドロップする。
		public function setClipBoad_file(inNativePath:String):Clipboard{
			var clipboard:Clipboard = new Clipboard();						// OS のクリップボードを取得
			var setFile:File = new File(inNativePath);
			if (setFile.exists) {
				clipboard.setData(ClipboardFormats.FILE_LIST_FORMAT , [setFile]);
				return clipboard;
			}else {
				return null;
			}
		}
	}
}