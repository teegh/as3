package com.org.sqlControl
{
	import flash.filesystem.File;
	import flash.display.MovieClip;
	import flash.utils.getTimer;
	import flash.data.*;
	import flash.events.*;
	import flash.filesystem.*;
	import com.org.sqlControl.SafeRepStr;
	
	//2011.11.01
	//DBの最適化(compact,REINDEX)を行い,ＤＢアクセスに関するパフォーマンスを調整する
	
	public class SQLiteOptimize
	{
		private var _conn:SQLConnection;				//
		private var _sql:SQLStatement;					//
		private var _activeDBtable:String="";			//操作DBテーブル
		private var _activeDBname:String="";			//操作DB

		//コンストラクタ
		public function SQLiteOptimize(){
			
		}
		
		//***********************************
		//BDの新規作成、初期化
		//***********************************
		public function optimizeDBtable(DBname:String, TableName:String){						//DBname：作成するDBの名前、TableName：作成するテーブルの名前
			//trace("DB作成先dir : " + File.applicationStorageDirectory.nativePath);
			var file:File = File.applicationStorageDirectory.resolvePath(DBname);
			if(file.exists){
				_conn = new SQLConnection();
				_conn.addEventListener(SQLEvent.OPEN, connectionOpenHandler);
				_conn.addEventListener(SQLErrorEvent.ERROR, dbErrorHandler);
				_conn.open(file, SQLMode.CREATE);													//同期モードでDBを開く。
			}else {
				trace("DB Optimize ファイルが開けませんでした "+DBname);
			}
		}
		
		// DB コネクションオープン
		private function connectionOpenHandler(evt:Event):void {
			_conn.removeEventListener(SQLEvent.OPEN, connectionOpenHandler);
			_conn.removeEventListener(SQLErrorEvent.ERROR, dbErrorHandler);
			optimizeTable();
			//biginTr();
		}
		
		// DB エラーハンドラー
		private function dbErrorHandler(evt:Event):void {
			trace("DB Optimize エラーハンドラー (dbErrorHandler(evt:Event) ) :: " + evt);
		}
		
		// DBテーブルの作成
		public function optimizeTable():void {
			_sql = new SQLStatement();
			_sql.sqlConnection = _conn;
			_sql.text = "REINDEX "+_activeDBtable;
			_sql.addEventListener(SQLEvent.RESULT, stmtCreateResult);
			_sql.addEventListener(SQLErrorEvent.ERROR, dbErrorHandler);
			_sql.execute();
		}
		
		// SQL 実行完了
		private function stmtCreateResult(evt:Event):void {
			_sql.removeEventListener(SQLEvent.RESULT, stmtCreateResult);
			_sql.removeEventListener(SQLErrorEvent.ERROR, dbErrorHandler);
			//biginTr();			//トランザクション開始
			closeConn();
		}

		private function closeConn():void{
			_conn.addEventListener(SQLEvent.COMPACT, compactCP);
			_conn.compact();				//DBの構造をクリーンアップ
			_conn.close();					//DB接続を閉じます。
			_conn = null;
		}
		private function compactCP(e:SQLEvent):void{
			_conn.removeEventListener(SQLEvent.COMPACT, compactCP);
			//trace("[DB INSERT] compact complete!");
		}
	}
}