package com.fileCtrl {
	
	//スレッド上の進捗情報を格納するクラス
	
	//import flash.data.EncryptedLocalStore;		//暗号化されたローカルストア
	//import flash.desktop.*;
	import flash.desktop.Clipboard;
	import flash.desktop.NativeDragOptions;
	import flash.desktop.NativeDragManager;
	import flash.display.MovieClip;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.geom.Point;
	//import flash.display.*;
	//import flash.events.*;
	//import adobe.utils.ProductManager;
	import flash.filesystem.*;
	//import flash.html.*;
	//import flash.net.*;
	//import flash.system.System;
	//import flash.text.*;
	//import flash.utils.*;
	//import flash.ui.*;
	//import com.utils.StopWatch;
	//import caurina.transitions.Tweener;
	import com.utils.SafeStrReplace;
	import com.clipboardUtil.clipboardUtil;
	
	/**
	 * ファイルに関する処理をまとめたクラス
	 */
	public class fileCtrl{
		
		private var _safeRep:SafeStrReplace = new SafeStrReplace();
		
		public function fileCtrl():void {
			
		}
		
		//入力されたファイルパスを、デフォルトアプリケーションで開く。AIR2.0以上必須
		public function openFile(inFilePath:String):Boolean {
			var readFile:File = new File(inFilePath);
			
			if (readFile.exists) {
				//trace(readFile.nativePath);
				readFile.openWithDefaultApplication();
				return true;
			}else {
				trace("[com.fileCtrl.fileCtrl] openFile() ファイルが存在しません。");
				return false;
			}
			
			readFile.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		
		//入力されたファイルパスのを含むディレクトリを、デフォルトアプリケーションで開く。AIR2.0以上必須
		//例： C:\test\test.txt -> C:\testを開く。
		public function openFile_containingFolder(inFilePath:String):Boolean {
			var readFile:File = new File(_safeRep.Rep_FilePath_ContainingFolderPath(inFilePath));
			if (readFile.exists) {
				trace(readFile.nativePath);
				readFile.openWithDefaultApplication();
				return true;
			}else {
				trace("[com.fileCtrl.fileCtrl] openFile_containingFolder() ファイルが存在しません。");
				return false;
			}
		}
		
		//ファイルをクリップボードに渡す。ファイルのドラッグを行う。
		//(使用方法)　private function dragSt(e:MouseEvent):void {fileCtrl.setClipBoard_file(inFile_NativePath);}
		public function setClipBoard_file_doDrag(inNativePath:String,dragTarget_interactiveObject:MovieClip):void {
			
			//ファイルをクリップボードに渡す
			var _clipboardUtil:clipboardUtil = new clipboardUtil();
			var _clipboard:Clipboard 		 = _clipboardUtil.setClipBoad_file(inNativePath);
			
			if(_clipboard){
				var offset:Point 			= new Point(0,0);
				var opt:NativeDragOptions 	= new NativeDragOptions();
				opt.allowCopy 				= true;
				opt.allowMove 				= false;
				opt.allowLink 				= true;
				//NativeDragManager.doDrag(_testIcon , _clipboard , null , offset , opt);
				NativeDragManager.doDrag(dragTarget_interactiveObject , _clipboard , null , offset , opt);
			}
		}
	}
}