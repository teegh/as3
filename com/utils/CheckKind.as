package com.utils {
	
	//拡張子を確認するクラス
	
	//import flash.data.EncryptedLocalStore;		//暗号化されたローカルストア
	//import flash.desktop.*;
	//import flash.display.*;
	//import flash.events.*;
	//import flash.filesystem.*;
	//import flash.html.*;
	//import flash.net.*;
	//import flash.system.System;
	//import flash.text.*;
	//import flash.utils.*;
	//import flash.ui.*;
	
	
	/**
	 * ファイルパス(String)から、ファイル拡張子を合致判定する。
	 */
	public class CheckKind{
		
		private var kinds:Array = new Array();
		private var chkKind:String;
		private var pattern:RegExp;
		private var chkStr:String;
		private var kindsLength:uint = 0;
		
		
		//チェックする拡張子
		//入力例　settingCheckKind(".MP3",".mp3", ".mpeg3");
		//指定がなければ、check()は常にtrueを返す。
		public function CheckKind(...inKakutyoushi):void {
			kinds = inKakutyoushi;
			kindsLength = kinds.length;
			//if(inKakutyoushi != null && inKakutyoushi.length > 0)trace("[com.utils.CheckKind] チェックする拡張子 : "+inKakutyoushi.length.toString());
		}
		
		//拡張子チェック。一致する拡張子であれば、trueを返す。
		public function check(filePath:String):Boolean{
			if (kinds.length == 0) return true;
			for (var i:int = 0; i < kindsLength; i++){
				chkKind	= kinds[i];
				pattern	= new RegExp(chkKind,"i");													//指定した拡張子の大文字・小文字の区分をなくす
				chkStr	= filePath.substr(filePath.length - chkKind.length, filePath.length);			//取得したファイル名から拡張子部分を抜き出す
				if(pattern.exec(chkStr) != null){
					return true;		//検索メソッドの実行(正規表現)。指定拡張子と一致するならtrueを返す。
				}
			}
			return false;				//指定拡張子と不一致ならfalseを返す。
		}
		
	}
}