﻿package com.org.sqlControl
{
	import flash.filesystem.File;
	import flash.display.MovieClip;
	import flash.utils.getTimer;
	import flash.data.*;
	import flash.events.*;
	import flash.filesystem.*;
	import com.org.sqlControl.SafeRepStr;
	
	//入力された配列(データグリッドのリスト配列)を全件削除する。
	//全件に対して再帰処理を行い、１トランザクションで完了する。
	
	public class SQLiteDELETE
	{
		private var _conn:SQLConnection;
		private var _sql:SQLStatement;												//
		private var _activeDBtable:String="";										//操作DBテーブル
		private var _activeDBname:String="";										//操作DB
		private var _loadMov:MovieClip;												//ロード画面
		private var _dat:Array = new Array();
		private var roopFlg:Boolean;												//再帰処理の処理許可(SQLエラー時にfalse)
		private var roopNum:uint;													//処理する配列件数

		//コンストラクタ
		public function SQLiteDELETE(inActiveDBtable:String , inActiveDBname:String , inDat:Array){
			_activeDBtable=inActiveDBtable;
			_activeDBname=inActiveDBname;
			_dat= inDat;
			roopFlg=true;
			roopNum=0;
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
			_sql.text = "DELETE FROM "+ _activeDBtable +" WHERE no = @no";
			_sql.addEventListener(SQLErrorEvent.ERROR, insertErrorHandler);
			_sql.addEventListener(SQLEvent.RESULT, insertResultHandler);
			//trace("[DB DELETE] transaction begin");
		}
		
		//選択したデータを削除
		public function deleteCol():void {
			if(_dat.length >0){
				roopNum=_dat.length;		//処理件数を取得。
				inDeleteCol();
			}
		}
		private function inDeleteCol():void {
			var item:Object = _dat.shift();
			_sql.parameters["@no"]=String(item.no);
			_sql.execute();
			
			if( ! _dat.length){
				return;						//全件処理が終了後、再帰処理終了
			}else{
				if(roopFlg==true){		//再帰処理を許可する場合。(SQLエラーなどで再帰処理を停止指示していればfalse)
					inDeleteCol();	//スタックオーバーフローを回避する為に末尾再帰を行っている。SQLEvent.RESULTイベントを設けず、処理(あまり好ましくない。)
				}else{
					return;					//エラーの場合、再帰処理終了
				}
			}
		}
		private function insertResultHandler(e:SQLEvent):void {
			roopNum--;
			//trace("処理件数残り："+roopNum);
			if(roopNum<=0){
				_conn.commit();
			}
		}
		private function insertErrorHandler(e:SQLErrorEvent):void {
			roopFlg=false;
			rollbackConn();
		}
		private function commitHandler(e:SQLEvent):void {
			//trace("[DB DELETE] commit complete!");
			closeConn();
		}
		private function rollbackHandler(e:SQLEvent):void {
			//trace("[DB DELETE] rollback complete!");
			closeConn();
		}
		private function compactCP(e:SQLEvent):void{
			_conn.removeEventListener(SQLEvent.COMPACT, compactCP);
			//trace("[DB DELETE] compact complete!");
		}
		private function errorHandler(e:SQLErrorEvent):void {
			trace("DB DELETE SQLErrorEventエラー："+e.error.message);
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
			//trace("[DB DELETE] close!");
			return;
		}
		private function rollbackConn():void{
			_conn.rollback();
			//trace("[DB DELETE] rollback!");
		}
		private function commit():void{
			_conn.commit();
		}
	}
}