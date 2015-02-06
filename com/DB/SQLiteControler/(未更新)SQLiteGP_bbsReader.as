package com.org.sqlControl
{
	import flash.filesystem.File;
	import flash.display.MovieClip;
	import flash.utils.getTimer;
	import flash.data.*;
	import flash.events.*;
	import flash.filesystem.*;
	import com.org.sqlControl.SafeRepStr;
	
	//2010.04.026
	//SQL処理の汎用操作をまとめたクラス。
	//トランザクション開始から、数種類の命令から選択し、実行、コミットまで、
	//一つのDBファイルに対してトランザクション処理を行える。
	
	public class SQLiteGP_bbsReader
	{
		private var _conn:SQLConnection;	
		private var _sql:SQLStatement;											//
		private var _activeDBtable:String="";									//操作DBテーブル
		private var _activeDBname:String="";									//操作DB
		private var _comdType:String;											//ＳＱＬコマンドを保持する
		private var _isCompactCommand:Boolean = false;							//処理後にSQLの最適化を行うか否か
		private var _sqlOutput:Object = new Object();							//返り値
		private var _safeRep:SafeRepStr = new SafeRepStr();
		
		//コンストラクタ
		public function SQLiteGP_bbsReader(inActiveDBtable , inActiveDBname){
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
			_conn.open(file,SQLMode.CREATE);											//同期モードでDBを開く。
		}
		// DB コネクションオープン
		private function connectionOpenHandler(evt:Event):void {
			_conn.removeEventListener(SQLEvent.OPEN, connectionOpenHandler);
			_conn.removeEventListener(SQLErrorEvent.ERROR, dbErrorHandler);
			createTable();
		}
		
		//[カラムの定義]
		//トピックの書き込み番号		topicNo INTEGER
		//書き込み日時			date TEXT
		//判定ポイント				point INTEGER	
		//ネーム					name TEXT
		//ID					id INTEGER
		//コミュ名					commuName TEXT
		//コミュID					commuID TEXT
		//タイトル					title TEXT
		//コメント					comment TEXT
		//トピックURL				topicUrl TEXT
		//コメント直リンクURL			commentUrl TEXT
		//レポートURL				reportUrl TEXT
		//重要フラグ				isImportant BOOLEAN
		//ブラックリスト入りのIDか？		isBlackListMached BOOLEAN
		
		
		//DBテーブルの作成
		public function createTable():void {
			_sql = new SQLStatement();
			_sql.sqlConnection = _conn;
			_sql.text=
				"CREATE TABLE IF NOT EXISTS "+_activeDBtable +" ("+
				" no INTEGER PRIMARY KEY," +
				" topicNo INTEGER," +
				" date TEXT," +
				" point INTEGER," +				
				" name TEXT,"+
				" id INTEGER," +
				" commuName TEXT," +
				" commuID TEXT,"+
				" title TEXT,"+
				" comment TEXT," +
				" topicUrl TEXT," +
				" commentUrl TEXT," +
				" reportUrl TEXT," +
				" isImportant BOOLEAN," +
				" isBlackListMached BOOLEAN," +
				" isSendPhp BOOLEAN" +
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
		//クエリをセット
		public function setStmtText(comdType:String , inDBTable:String , inLIMIT1:String , inLIMIT2:String , condition:String):void{
			_sql = new SQLStatement();
			_sql.sqlConnection = _conn;
			//処理タイプに応じて実行命令textを変更する。
			_comdType=comdType;	//保持
			switch(comdType){
				case "COUNT":
					_sql.text = "SELECT COUNT(no) FROM " + inDBTable;		//指定したテーブルの合計数を得る
					_isCompactCommand = false;
					break;
				case "SELECT LIMIT":		//指定したテーブルに対して、指定件数取得する。
					_sql.text = "SELECT * FROM " + inDBTable + " LIMIT " + inLIMIT1 + "," + inLIMIT2;
					_isCompactCommand = false;
					break;
				case "SELECT LIMIT ORDER DATE":		//指定したテーブルに対して、指定件数取得する。
					_sql.text = "SELECT * FROM " + inDBTable + " ORDER BY date DESC" +" LIMIT " + inLIMIT1 + "," + inLIMIT2;
					_isCompactCommand = false;
					break;
				case "SELECT WHERE":		//指定したテーブルに対して、条件に一致するデータを抽出。
					_sql.text = "SELECT * FROM " + inDBTable + " WHERE no = " + condition;
					_isCompactCommand = false;
					break;
				case "SELECT WHERE SEARCH":	//指定したテーブルに対して、任意の条件に一致するデータを抽出
					_sql.text = "SELECT * FROM " + inDBTable + " WHERE " + condition;
					_isCompactCommand = false;
					break;
				case "SELECT WHERE @":	//指定したテーブルに対して、条件に一致するデータを抽出。条件はプレースホルダ使用。
					_sql.text = "SELECT * FROM " + inDBTable + " WHERE no = " + "@condition";
					_isCompactCommand = false;
					break;
				case "SELECT ALL":	//指定したテーブルに対して、データを取得
					_sql.text = "SELECT * FROM " + inDBTable;
					_isCompactCommand = false;
					break;
				case "SELECT ALL config":	//指定したテーブルに対して、データを取得
					_sql.text = "SELECT "+condition;
					_isCompactCommand = false;
					break;
				case "SELECT RANDOM":	//指定したテーブルに対して、データを取得
					_sql.text = "SELECT * FROM " + inDBTable + " ORDER BY RANDOM()";
					_isCompactCommand = false;
					break;
				case "SELECT GROUP ID":	//指定したテーブルに対して、IDごとにまとめたリストを取得
					_sql.text = "SELECT id ,count(id) FROM " + inDBTable + " GROUP BY id ORDER BY count(id)";
					_isCompactCommand = false;
					break;
				case "INSERT":	//指定したテーブルに配列を挿入する。
					_sql.text ="INSERT INTO "+inDBTable+ "(no, topicNo, date, point, name, id, commuName, commuId, title, comment, topicUrl, commentUrl, reportUrl, isImportant, isBlackListMached, isSendPhp)"
								+ "VALUES (Null, @topicNo, @date, @point, @name, @id, @commuName, @commuId, @title, @comment, @topicUrl, @commentUrl, @reportUrl, @isImportant, @isBlackListMached, @isSendPhp)";
					
					_isCompactCommand = true;
					break;
				case "UPDATE isImportant":	//情報を更新します。
					//_sql.sqlConnection.compact();						
					_sql.text = "UPDATE " + inDBTable + " set isImportant = @isImportant WHERE no = " + condition;
					_isCompactCommand = true;
					break;
				case "UPDATE isSendPhp":	//情報を更新します。
					//_sql.sqlConnection.compact();						
					_sql.text = "UPDATE " + inDBTable + " set isSendPhp = @isSendPhp WHERE no = " + condition;
					_isCompactCommand = true;
					break;
				case "DELETE":	//不要な空間を削除する。
					//_sql.sqlConnection.compact();						
					_sql.text = "DELETE FROM " + inDBTable + " WHERE no=" + condition;
					_isCompactCommand = true;
					break;
				case "DELETE isImportant":	//不要な空間を削除する。
					//_sql.sqlConnection.compact();						
					_sql.text = "DELETE FROM " + inDBTable + " WHERE isImportant = FALSE";
					_isCompactCommand = true;
					break;
				case "DELETE @":	//不要な空間を削除する。条件はプレースホルダーを使用。
					//_sql.sqlConnection.compact();						
					_sql.text = "DELETE FROM " + inDBTable + " WHERE no=" + "@condition";
					_isCompactCommand = true;
					break;
				case "DELETE ALL":	//不要な空間を削除する。
					//_sql.sqlConnection.compact();						
					_sql.text = "DELETE FROM " + inDBTable;
					_isCompactCommand = true;
					break;
				case "DELETE TABLE":	//不要な空間を削除する。
					//_sql.sqlConnection.compact();						
					_sql.text = "DROP TABLE " + inDBTable;
					_isCompactCommand = true;
					break;
			}
			_sql.addEventListener(SQLEvent.RESULT, insertResultHandler);
			_sql.addEventListener(SQLErrorEvent.ERROR, insertErrorHandler);
		}
		public function exec(inputData:Object):void {
			//INSERTを実行する場合、inputDataをパラメータに入力する。
			if( inputData != "" ){
				switch(_comdType) {	//配列行数１個に対して行われる。
					
					case "INSERT":
						_sql.parameters["@topicNo"] = 			inputData["topicNo"];
						_sql.parameters["@date"] = 				inputData["date"];
						_sql.parameters["@point"] = 			inputData["point"];
						_sql.parameters["@name"] = 				_safeRep.safeRepStr("", inputData["name"])[0];
						_sql.parameters["@id"] = 				inputData["id"];
						
						_sql.parameters["@commuName"] = 		_safeRep.safeRepStr("",inputData["commuName"])[0];
						_sql.parameters["@commuId"] = 			inputData["commuId"];
						
						_sql.parameters["@title"] = 			_safeRep.safeRepStr("",inputData["title"])[0];
						_sql.parameters["@comment"] = 			_safeRep.safeRepStr("",inputData["comment"])[0];
						_sql.parameters["@topicUrl"] = 			inputData["topicUrl"];
						_sql.parameters["@reportUrl"] = 		inputData["reportUrl"];
						_sql.parameters["@commentUrl"] = 		inputData["commentUrl"]
						_sql.parameters["@isImportant"] = 		inputData["isImportant"];
						_sql.parameters["@isBlackListMached"] = inputData["isBlackListMached"];
						_sql.parameters["@isSendPhp"] = 		inputData["isSendPhp"];
						
						break;
					case "SELECT WHERE @":
						_sql.parameters["@condition"] = 	_safeRep.safeRepStr("",inputData["condition"])[0]; 
						break;
					case "DELETE @":
						_sql.parameters["@condition"] = 	_safeRep.safeRepStr("",inputData["condition"])[0]; 
						break;
					case "UPDATE isImportant":
						_sql.parameters["@isImportant"] = 	inputData["isImportant"];
						break;
					case "UPDATE isSendPhp":
						_sql.parameters["@isSendPhp"] = 	inputData["isSendPhp"];
						break;
				}
			}
			_sql.execute();
		}
		private function insertResultHandler(e:SQLEvent):void {
			//成功
			if(_comdType != "INSERT" && _comdType != "DELETE"  && _comdType != "UPDATE isImportant" && _comdType != "UPDATE isSendPhp"){
				var res:SQLResult=_sql.getResult();
				if(res.data != null){
					_sqlOutput=res.data;
				}
				else if(res.data ==null){
					_sqlOutput=new Array();
				}
			}
		}
		private function insertErrorHandler(e:SQLErrorEvent):void {
			rollbackConn();
		}
		private function beginHandler(e:SQLEvent):void {
			//trace("[DB GP] transaction begin");
		}
		private function commitHandler(e:SQLEvent):void {
			//trace("[DB GP] commit complete!");
			closeConn();
		}
		private function rollbackHandler(e:SQLEvent):void {
			//trace("[DB GP] rollback complete!");
			closeConn();
		}
		private function compactCP(e:SQLEvent):void{
			_conn.removeEventListener(SQLEvent.COMPACT, compactCP);
			//trace("[DB GP] compact complete!");
		}
		private function errorHandler(e:SQLErrorEvent):void {
			trace("エラー："+e.error.message);
		}
		private function dbErrorHandler(evt:Event):void {
			trace("DB INSERT エラーハンドラー (dbErrorHandler(evt:Event) ) :: " + evt);
		}
		
		//DBを閉じる
		private function closeConn():void{
			_conn.addEventListener(SQLEvent.COMPACT, compactCP);
			if (_isCompactCommand)_conn.compact();				//INSERT,DELETEの場合はDBの構造をクリーンアップ
			_conn.close();										//DB接続を閉じます。	
			_sql.removeEventListener(SQLEvent.RESULT, insertResultHandler);
			_sql.removeEventListener(SQLErrorEvent.ERROR, insertErrorHandler);
			
			_conn.removeEventListener(SQLEvent.BEGIN, beginHandler);
			_conn.removeEventListener(SQLEvent.COMMIT, commitHandler);
			_conn.removeEventListener(SQLEvent.ROLLBACK, rollbackHandler);
			_conn.removeEventListener(SQLErrorEvent.ERROR, errorHandler);
			
			_sqlOutput=null				//メモリ解放
			//trace("[DB GP] close!");
		}
		public function rollbackConn():void{
			_conn.rollback();
			//trace("[DB GP] rollback!");
		}
		public function commit():void{
			_conn.commit();
		}
		public function get result():Object{
			return  _sqlOutput;
		}
	}
}