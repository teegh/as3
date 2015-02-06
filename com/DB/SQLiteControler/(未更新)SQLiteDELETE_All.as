package com.org.sqlControl
{
	import flash.filesystem.File;
	import flash.utils.getTimer;
	import flash.data.*;
	import flash.events.*;
	import flash.filesystem.*;
	
	//指定したＤＢテーブルの内容を全件削除する。
	
	public class SQLiteDELETE_All
	{
		private var _conn:SQLConnection;	
		private var _sql:SQLStatement;													//
		private var _activeDBtable:String="";											//操作DBテーブル
		private var _activeDBname:String="";										//操作DB
		//コンストラクタ
		public function SQLiteDELETE_All(inActiveDBtable:String , inActiveDBname:String){
			_activeDBtable=inActiveDBtable;
			_activeDBname=inActiveDBname;
			initDB(_activeDBname , _activeDBtable);
		}
		
		//***********************************
		//BDの新規作成、初期化
		//***********************************
		public function initDB(DBname:String, TableName:String){						//DBname：作成するDBの名前、TableName：作成するテーブルの名前
			//trace("DB作成先dir : " + File.applicationStorageDirectory.nativePath);
			var file:File = File.applicationStorageDirectory.resolvePath(DBname);
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
		}
		// DB エラーハンドラー
		private function dbErrorHandler(evt:Event):void {
			trace("DB エラーハンドラー (dbErrorHandler(evt:Event) ) :: " + evt);
		}
		
		// DBテーブルの作成
		public function createTable():void {
			_sql = new SQLStatement();
			_sql.sqlConnection = _conn;
			_sql.text=
				"CREATE TABLE IF NOT EXISTS "+_activeDBtable +" ("+
				" no INTEGER PRIMARY KEY,"+
				" tanaNo TEXT,"+
				" cdNo TEXT,"+
				" titles TEXT,"+
				" titlesKana TEXT,"+
				" playTime TEXT,"+
				" artist TEXT,"+
				" artistKana TEXT,"+
				" album TEXT,"+
				" track INTEGER,"+
				" year TEXT,"+
				" genre TEXT,"+
				" comment TEXT,"+
				" filePath TEXT,"+
				" picFlg BOOLEAN,"+
				" picFileSize INTEGER,"+
				" picFilePos INTEGER,"+
				" kashiFlg BOOLEAN,"+
				" kashiFileSize INTEGER,"+
				" kashiFilePos INTEGER,"+
				" escapeSeq TEXT,"+
				" requestFlg TEXT,"+
				" requestTime TEXT"+
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
		}
		private function beginHandler(e:SQLEvent):void {
			_sql = new SQLStatement();
			_sql.sqlConnection = _conn;
			_sql.text = "DELETE FROM "+ _activeDBtable;
			_sql.addEventListener(SQLErrorEvent.ERROR, insertErrorHandler);
			_sql.addEventListener(SQLEvent.RESULT, insertResultHandler);
			//trace("[DB DELETE All] transaction begin");
		}
		
		//選択したデータを削除
		public function deleteAll():void {
			_sql.execute();
		}
		private function insertResultHandler(e:SQLEvent):void {
			_conn.commit();
		}
		private function insertErrorHandler(e:SQLErrorEvent):void {
			rollbackConn();
		}
		private function commitHandler(e:SQLEvent):void {
			//trace("[DB DELETE All] commit complete!");
			closeConn();
		}
		private function rollbackHandler(e:SQLEvent):void {
			//trace("[DB DELETE All] rollback complete!");
			closeConn();
		}
		private function compactCP(e:SQLEvent):void{
			_conn.removeEventListener(SQLEvent.COMPACT, compactCP);
			//trace("[DB DELETE All] compact complete!");
		}
		private function errorHandler(e:SQLErrorEvent):void {
			//trace("DB DELETE SQLErrorEventエラー："+e.error.message);
		}
		private function closeConn():void{
			_conn.addEventListener(SQLEvent.COMPACT, compactCP);
			_conn.compact();				//DBの構造をクリーンアップ
			_conn.close();					//DB接続を閉じます。
			_sql.removeEventListener(SQLErrorEvent.ERROR, insertErrorHandler);
			_sql.removeEventListener(SQLEvent.RESULT, insertResultHandler);
			_conn.removeEventListener(SQLEvent.BEGIN, beginHandler);
			_conn.removeEventListener(SQLEvent.COMMIT, commitHandler);
			_conn.removeEventListener(SQLEvent.ROLLBACK, rollbackHandler);
			_conn.removeEventListener(SQLErrorEvent.ERROR, errorHandler);
			//trace("[DB DELETE All] close!");
			return;
		}
		private function rollbackConn():void{
			_conn.rollback();
			//trace("[DB DELETE All] rollback!");
		}
		private function commit():void{
			_conn.commit();
		}
	}
}