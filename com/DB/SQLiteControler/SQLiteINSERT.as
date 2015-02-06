package com.DB.SQLiteControler
{
	//import flash.filesystem.File;
	//import flash.utils.getTimer;
	import flash.data.*;
	//import flash.events.*;
	//import flash.filesystem.*;
	import com.utils.SafeStrReplace;
	import com.DB.SQLiteControler.SQLiteBase;
	
	/**
	 * SQLiteにデーターを追加するクラス。(トランザクション)
	 */
	public class SQLiteINSERT extends SQLiteBase
	{
		
		var RepStr:SafeStrReplace 	= new SafeStrReplace();
		var fileNameArr:Array;
		var filePathArr:Array;
		var escapeSeq:String;
		
		//コンストラクタ
		public function SQLiteINSERT(inDB_fileName:String,inDB_tableName:String) {
			super(inDB_fileName , inDB_tableName);
		}
		
		override protected function inputStatement():void {
			_sql = new SQLStatement();
			_sql.sqlConnection = _conn;
			_sql.text = "INSERT INTO " + _DB_tableName +" (fileName, filePath, escapeSeq) VALUES ( @fileName, @filePath, @escapeSeq )";
		}
		
		public function insert(inFileName:String , inFilePath:String):void {
			//入力値の文字をＳＱＬ入力にエラー回避する文字へ変換(SQLの区切り文字を変換)
			fileNameArr 	= RepStr.Rep_sql("fileName", inFileName);		//エスケープシーケンスが含まれる場合はタイトル中の文字を置き換え、エスケープ文字と位置をescapeSeqに格納
			filePathArr 	= RepStr.Rep_sql("filePath",inFilePath);		//エスケープシーケンスが含まれる場合はタイトル中の文字を置き換え、エスケープ文字と位置をescapeSeqに格納
			
			//エスケープシーケンスの位置を保存する変数
			escapeSeq = fileNameArr[1] + filePathArr[1];
			
			_sql.parameters["@fileName"] 	=	fileNameArr[0];
			_sql.parameters["@filePath"] 	=	filePathArr[0];
			_sql.parameters["@escapeSeq"] 	=	escapeSeq;
			_sql.execute();
		}
		
		
	}
}