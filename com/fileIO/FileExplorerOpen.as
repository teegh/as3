package com.fileIO{
	
	//import flash.desktop.*;
	//import flash.display.*;
	//import flash.data.*;
	//import flash.events.*;
	import flash.filesystem.*;
	//import flash.html.*;
	import flash.net.*;
	//import flash.system.System;
	//import flash.text.*;
	//import flash.utils.*;
	//import flash.ui.*;
	
	public class FileExplorerOpen{
		
		public function FileExplorerOpen():void {
			init();
		}
		
		private function init():void {
			
		}
		
		public function openFile(inFilePath:String):void {
			var file:File = new File(inFilePath);
			if(file.exists){
				var url:URLRequest = new URLRequest(inFilePath);
				navigateToURL(url, "_blank");
			}else {
				trace("[FileExplorerOpen > openFile]\nファイルは存在しません。");
			}
		}
	}
}