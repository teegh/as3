package com.DB.SQLiteControler
{
	import flash.filesystem.File;
	import flash.utils.getTimer;
	import flash.data.*;
	import flash.events.*;
	import flash.filesystem.*;
	import com.utils.SafeStrReplace;
	
	/**
	 * SQLiteのファイルオープンやトランザクションに関する処理をまとめたクラス
	 */
	public class SQLiteBase
	{
		protected 	var _sql:SQLStatement;
		protected 	var _conn:SQLConnection;
		private 	var _dat:Array;														//
		
		private 	var _DB_fileName:String	 	= "";									//操作・作成するデータベースのファイル名
		protected 	var _DB_tableName:String	= "";									//操作・作成するデータベースのテーブル名

		//コンストラクタ
		public function SQLiteBase(inDB_fileName:String,inDB_tableName:String) {
			_DB_fileName = inDB_fileName+".db";
			_DB_tableName = inDB_tableName;
			initDB(_DB_fileName);
		}
		
		
		
		
		//***********************************
		//サブクラスでオーバーライド、追加するメソッド
		//***********************************
		protected function inputStatement():void {
			//サブクラスで記述。
			/*
			_sql = new SQLStatement();
			_sql.sqlConnection = _conn;
			_sql.text = "INSERT INTO " + _DB_tableName +" (fileName, filePath, escapeSeq) VALUES ( @fileName, @filePath, @escapeSeq )";
			//trace("[com.DB.SQLiteControler] transaction begin");
			*/
		}
		
		/*
		public function insert(inFileName:String , inFilePath:String):void {
			//入力値の文字をＳＱＬ入力にエラー回避する文字へ変換(SQLの区切り文字を変換)
			var RepStr:SafeStrReplace 	= new SafeStrReplace();
			var fileNameArr:Array 	= RepStr.Rep_sql("fileName", inFileName);		//エスケープシーケンスが含まれる場合はタイトル中の文字を置き換え、エスケープ文字と位置をescapeSeqに格納
			var filePathArr:Array 	= RepStr.Rep_sql("filePath",inFileName);		//エスケープシーケンスが含まれる場合はタイトル中の文字を置き換え、エスケープ文字と位置をescapeSeqに格納
			
			//エスケープシーケンスの位置を保存する変数
			var escapeSeq:String = fileNameArr[1] + filePathArr[1];
			
			_sql.parameters["@fileName"] 	=	fileNameArr[0];
			_sql.parameters["@filePath"] 	=	filePathArr[0]
			_sql.parameters["@escapeSeq"] 	=	escapeSeq;
			_sql.execute();
		}*/
		//***********************************
		
		
		
		
		
		//***********************************
		//BDの新規作成、初期化
		//***********************************
		public function initDB(inDB_fileName:String){								//DBname：作成するDBの名前、TableName：作成するテーブルの名前
			//trace("DB作成先dir : " + File.applicationStorageDirectory.nativePath);
			var file:File = File.applicationStorageDirectory.resolvePath(inDB_fileName);
			_conn = new SQLConnection();
			_conn.addEventListener(SQLEvent.OPEN, connectionOpenHandler);
			_conn.addEventListener(SQLErrorEvent.ERROR, dbErrorHandler);
			_conn.open(file,SQLMode.CREATE);													//同期モードでDBを開く。
		}
		// DB コネクションオープン
		private function connectionOpenHandler(evt:Event):void {
			_conn.removeEventListener(SQLEvent.OPEN, connectionOpenHandler);
			_conn.removeEventListener(SQLErrorEvent.ERROR, dbErrorHandler);
			createTable();
			//biginTr();
		}
		// DB エラーハンドラー
		private function dbErrorHandler(evt:Event):void {
			trace("[com.DB.SQLiteControler.SQLiteBase] エラーハンドラー (dbErrorHandler(evt:Event) ) :: " + evt);
		}
		
		// DBテーブルの作成
		public function createTable():void {
			_sql = new SQLStatement();
			_sql.sqlConnection = _conn;
			_sql.text = 
				"CREATE TABLE IF NOT EXISTS "+_DB_tableName +" ("+
				" no INTEGER PRIMARY KEY,"+
				" fileName TEXT ,"+
				" filePath TEXT ," +
				" escapeSeq TEXT " +
			")";
			_sql.addEventListener(SQLEvent.RESULT, stmtCreateResult);
			_sql.addEventListener(SQLErrorEvent.ERROR, dbErrorHandler);
			_sql.execute();
		}
		
		// SQL 実行完了
		private function stmtCreateResult(evt:Event):void {
			_sql.removeEventListener(SQLEvent.RESULT, stmtCreateResult);
			_sql.removeEventListener(SQLErrorEvent.ERROR, dbErrorHandler);
			biginTr();			//トランザクション開始
		}



		
		//トランザクション処理
		private function biginTr():void {
			_conn.addEventListener(SQLEvent.BEGIN, beginHandler);
			_conn.addEventListener(SQLEvent.COMMIT, commitHandler);
			_conn.addEventListener(SQLEvent.ROLLBACK, rollbackHandler);
			_conn.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			_conn.begin();
			//trace("[com.DB.SQLiteControler.SQLiteBase] トランザクション開始");
		}
		
		private function beginHandler(e:SQLEvent):void {
			inputStatement();
			_sql.addEventListener(SQLEvent.RESULT, insertResultHandler);
			_sql.addEventListener(SQLErrorEvent.ERROR, insertErrorHandler);
		}
		
		
		
		
		
		protected function insertResultHandler(e:SQLEvent):void {
			//_conn.commit();
		}
		private function insertErrorHandler(e:SQLErrorEvent):void {
			rollbackConn();
		}
		private function commitHandler(e:SQLEvent):void {
			//trace("[com.DB.SQLiteControler.SQLiteBase] commit complete!");
			closeConn();
		}
		private function rollbackHandler(e:SQLEvent):void {
			//trace("[com.DB.SQLiteControler.SQLiteBase] rollback complete!");
			closeConn();
		}
		private function compactCP(e:SQLEvent):void{
			_conn.removeEventListener(SQLEvent.COMPACT, compactCP);
			//trace("[com.DB.SQLiteControler.SQLiteBase] compact complete!");
		}
		private function errorHandler(e:SQLErrorEvent):void {
			trace("[com.DB.SQLiteControler]エラー発生："+e.error.message);
		}
		private function closeConn():void{
			_conn.addEventListener(SQLEvent.COMPACT, compactCP);
			connCompact();					//DBの構造をクリーンアップ
			_conn.close();					//DB接続を閉じます。
			_sql.removeEventListener(SQLEvent.RESULT, insertResultHandler);
			_sql.removeEventListener(SQLErrorEvent.ERROR, insertErrorHandler);
			_conn.removeEventListener(SQLEvent.BEGIN, beginHandler);
			_conn.removeEventListener(SQLEvent.COMMIT, commitHandler);
			_conn.removeEventListener(SQLEvent.ROLLBACK, rollbackHandler);
			_conn.removeEventListener(SQLErrorEvent.ERROR, errorHandler);
			//trace("[com.DB.SQLiteControler.SQLiteBase] close!");
		}
		protected function connCompact():void {
			_conn.compact();				//DBの構造をクリーンアップ
		}
		
		public function rollbackConn():void{
			_conn.rollback();
			//trace("[com.DB.SQLiteControler.SQLiteBase] rollback!");
		}
		public function commit():void {
			_conn.commit();
			trace("[com.DB.SQLiteControler.SQLiteBase] commit();");
		}
	}
}