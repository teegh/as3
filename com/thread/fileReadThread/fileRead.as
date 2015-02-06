package com.thread.fileReadThread {
	
	//import flash.data.EncryptedLocalStore;		//暗号化されたローカルストア
	//import flash.desktop.*;
	//import flash.display.*;
	//import flash.events.*;
	import adobe.utils.ProductManager;
	import flash.filesystem.*;
	//import flash.html.*;
	//import flash.net.*;
	//import flash.system.System;
	//import flash.text.*;
	//import flash.utils.*;
	//import flash.ui.*;
	
	import com.utils.SafeStrReplace;
	import com.DB.SQLiteControler.SQLiteINSERT;

	
	//メモリ使用量計測目的
	//import flash.system.System;
	//import com.thread.fileReadThread.ThreadProcessCounter;
	
	
	/**
	 * ファイルを読み込み、ファイルに対する処理を行うクラス。
	 */
	public class fileRead{
		
		
		private var _safeRep:SafeStrReplace = new SafeStrReplace();
		
		public function fileRead():void {
			
		}
		
		//ファイルを読み込んだ時の処理。
		public function read(inFile:File , inSQLiteInsert:SQLiteINSERT , inThCnt:ThreadProcessCounter):void {
			//trace("[fileRead] "+inFile.nativePath);
			var tempArr:Array = new Array();
			
			//**********************************
			//	ファイル名
			//**********************************
			//ファイル名の抽出
			var fileName:String = _safeRep.Rep_FileName(inFile.nativePath);
			//trace("[com.thread.fileReadThread fileRead] \nファイル名：" + fileName);
			
			//全角半角変換
			//fileName = _safeRep.Rep_Kana(fileName);
			
			//SQLに入力する為に文字列を変換
			//tempArr = _safeRep.Rep_sql("fileName", fileName);
			//fileName = tempArr[0] + tempArr[1];
			//trace("[com.thread.fileReadThread fileRead] \nファイル名 (各種変換後)：" + fileName);
		
			
			//**********************************
			//	ファイルパス取得
			//**********************************
			var filePath:String = inFile.nativePath;
			
			//SQLに入力する為に文字列を変換
			//tempArr = _safeRep.Rep_sql("filePath", filePath);
			//filePath = tempArr[0] + tempArr[1];
			//trace("[com.thread.fileReadThread fileRead] \nファイルパス (各種変換後)：" + filePath);
			//trace("[com.thread.fileReadThread fileRead] \nファイルパス：" + filePath);
			
			
			//**********************************
			//	ＤＢの入力処理
			//**********************************
			//DB処理
			trace("[fileRead] " + filePath);
			inSQLiteInsert.insert(fileName, filePath);
			
			//**********************************
			//	使用メモリ　モニタリング （デバッグ用）
			//**********************************
			//使用メモリを出力する。
			//trace( inThCnt.commitedCnt + "\t" + String(System.totalMemory / 1024) + "\t" + filePath);
		}
	}
}