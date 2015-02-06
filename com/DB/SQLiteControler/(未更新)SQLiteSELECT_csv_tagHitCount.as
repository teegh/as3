package com.org.sqlControl
{
	import flash.filesystem.File;
	import flash.display.MovieClip;
	import flash.utils.getTimer;
	import flash.data.*;
	import flash.events.*;
	import flash.filesystem.*;
	import com.org.sqlControl.SafeRepStr;
	
	//Excelデータから曲名・アーティスト・アルバムをそれぞれ抽出条件に、COUNTする（1トランザクション処理）　クラス。
	
	public class SQLiteSELECT_csv_tagHitCount
	{
		private var _conn:SQLConnection;	
		private var _sql:SQLStatement;												//
		private var _dat:Array;														//
		private var _activeDBtable:String="";										//操作DBテーブル
		private var _activeDBname:String="";										//操作DB
		private var _sqlOutput:Object=new Object;									//返り値
		private var _searchTag:String ="";											//検索するタグ
		

		//コンストラクタ
		public function SQLiteSELECT_csv_tagHitCount(inActiveDBtable , inActiveDBname , inSearchTag) {
			_searchTag = inSearchTag;
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
			//WHERE artist =@artist AND titles =@titles AND album=@album
			_sql.text = "SELECT count(*) AS count FROM "+ _activeDBtable +" WHERE "+_searchTag+" =@"+_searchTag ;		//指定タグの検索
			_sql.addEventListener(SQLEvent.RESULT, insertResultHandler);
			_sql.addEventListener(SQLErrorEvent.ERROR, insertErrorHandler);
			//trace("[DB SELECT] transaction begin");
		}
		public function select_csv_tagHitCount(inWord:String):void {
			//SQLクエリでエラー回避するためのエラー文字変換を行う。
			var RepStr:SafeRepStr= new SafeRepStr();
			var tagArr:Array=RepStr.safeRepStr(_searchTag, inWord);
			
			_sql.parameters["@"+_searchTag] = tagArr[0];
			_sql.execute();
		}
		private function insertResultHandler(e:SQLEvent):void {
			//成功
			var res:SQLResult=_sql.getResult();
			if(res.data != null){
				_sqlOutput=res.data;
			}
			else if(res.data ==null){
				_sqlOutput=new Object();
			}
		}
		private function insertErrorHandler(e:SQLErrorEvent):void {
			rollbackConn();
		}
		private function commitHandler(e:SQLEvent):void {
			//trace("[DB SELECT] commit complete!");
			closeConn();
		}
		private function rollbackHandler(e:SQLEvent):void {
			//trace("[DB SELECT] rollback complete!");
			closeConn();
		}
		private function compactCP(e:SQLEvent):void{
			_conn.removeEventListener(SQLEvent.COMPACT, compactCP);
			//trace("[DB INSERT] compact complete!");
		}
		private function errorHandler(e:SQLErrorEvent):void {
			trace("エラー："+e.error.message);
		}
		private function closeConn():void{
			_conn.addEventListener(SQLEvent.COMPACT, compactCP);
			//_conn.compact();				//DBの構造をクリーンアップ
			_conn.close();					//DB接続を閉じます。
			_sql.removeEventListener(SQLEvent.RESULT, insertResultHandler);
			_sql.removeEventListener(SQLErrorEvent.ERROR, insertErrorHandler);
			_conn.removeEventListener(SQLEvent.BEGIN, beginHandler);
			_conn.removeEventListener(SQLEvent.COMMIT, commitHandler);
			_conn.removeEventListener(SQLEvent.ROLLBACK, rollbackHandler);
			_conn.removeEventListener(SQLErrorEvent.ERROR, errorHandler);
			//trace("[DB SELECT] close!");
		}
		public function rollbackConn():void{
			_conn.rollback();
			//trace("[DB SELECT] rollback!");
		}
		public function commit():void{
			_conn.commit();
		}
		public function get result():uint {
			if (_sqlOutput[0] != null) {
				return _sqlOutput[0].count;
			}else {
				return 0;
			}
		}
	}
}