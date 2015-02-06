package com.DB.SQLiteControler
{
	
	//import flash.filesystem.File;
	//import flash.display.MovieClip;
	//import flash.utils.getTimer;
	import flash.data.*;
	import flash.events.*;
	//import flash.filesystem.*;
	import com.utils.SafeStrReplace;
	import com.DB.SQLiteControler.SQLiteBase;
	
	
	/**
	 * SQL処理の汎用操作をまとめたクラス。トランザクション開始から、数種類の命令から選択し、実行、コミットまで、一つのDBファイルに対してトランザクション処理を行える。
	 */
	public class SQLiteGP extends SQLiteBase
	{
		private var _comdType:String;											//ＳＱＬコマンドを保持する
		private var _isCompactCommand:Boolean 	= false;						//処理後にSQLの最適化を行うか否か
		private var _sqlOutput:Object 			= new Object();					//返り値
		private var _safeRep:SafeStrReplace		= new SafeStrReplace();			//
		
		
		//コンストラクタ
		public function SQLiteGP(inDB_fileName:String,inDB_tableName:String) {
			super(inDB_fileName , inDB_tableName);
		}
		
		//ゲッターメソッド
		//SQLクエリの結果を取得
		public function get result():Object{
			return  _sqlOutput;
		}
		
		//クエリをセット
		public function setStmtText(comdType:String , inLIMIT1:String , inLIMIT2:String , condition:String):void{
			//_sql = new SQLStatement();
			//_sql.sqlConnection = _conn;
			
			//処理タイプに応じて実行命令textを変更する。
			_comdType = comdType;	//保持
			
			switch(comdType){
				case "COUNT":
					_sql.text = "SELECT COUNT(no) FROM " + _DB_tableName;		//指定したテーブルの合計数を得る
					_isCompactCommand = false;
					break;
				case "SELECT LIMIT":		//指定したテーブルに対して、指定件数取得する。
					_sql.text = "SELECT * FROM " + _DB_tableName + " LIMIT " + inLIMIT1 + "," + inLIMIT2;
					_isCompactCommand = false;
					break;
				case "SELECT LIMIT ORDER DATE":		//指定したテーブルに対して、指定件数取得する。
					_sql.text = "SELECT * FROM " + _DB_tableName + " ORDER BY date DESC" +" LIMIT " + inLIMIT1 + "," + inLIMIT2;
					_isCompactCommand = false;
					break;
				case "SELECT WHERE":		//指定したテーブルに対して、条件に一致するデータを抽出。
					_sql.text = "SELECT * FROM " + _DB_tableName + " WHERE no = " + condition;
					_isCompactCommand = false;
					break;
				case "SELECT WHERE SEARCH":	//指定したテーブルに対して、任意の条件に一致するデータを抽出
					_sql.text = "SELECT * FROM " + _DB_tableName + " WHERE " + condition;
					_isCompactCommand = false;
					break;
				case "SELECT WHERE @":	//指定したテーブルに対して、条件に一致するデータを抽出。条件はプレースホルダ使用。
					_sql.text = "SELECT * FROM " + _DB_tableName + " WHERE no = " + "@condition";
					_isCompactCommand = false;
					break;
				case "SELECT ALL":	//指定したテーブルに対して、データを取得
					_sql.text = "SELECT * FROM " + _DB_tableName;
					_isCompactCommand = false;
					break;
				case "SELECT RANDOM":	//指定したテーブルに対して、データを取得
					_sql.text = "SELECT * FROM " + _DB_tableName + " ORDER BY RANDOM()";
					_isCompactCommand = false;
					break;
				case "SELECT GROUP ID":	//指定したテーブルに対して、IDごとにまとめたリストを取得
					_sql.text = "SELECT id ,count(id) FROM " + _DB_tableName + " GROUP BY id";
					_isCompactCommand = false;
					break;
				case "INSERT":	//指定したテーブルに配列を挿入する。
					_sql.text ="INSERT INTO "+_DB_tableName+ "(no, date, chuuiFlg, name, id, commuName, commuId, bbsId, bbsDate, bbsNo)"
								+ "VALUES (Null, @date, @chuuiFlg, @name, @id, @commuName, @commuId, @bbsId, @bbsDate, @bbsNo)";
					_isCompactCommand = true;
					break;
				case "DELETE":	//不要な空間を削除する。
					//_sql.sqlConnection.compact();						
					_sql.text = "DELETE FROM " + _DB_tableName + " WHERE no=" + condition;
					_isCompactCommand = true;
					break;
				case "DELETE @":	//不要な空間を削除する。条件はプレースホルダーを使用。
					//_sql.sqlConnection.compact();						
					_sql.text = "DELETE FROM " + _DB_tableName + " WHERE no=" + "@condition";
					_isCompactCommand = true;
					break;
				case "DELETE ALL":	//不要な空間を削除する。
					//_sql.sqlConnection.compact();						
					_sql.text = "DELETE FROM " + _DB_tableName;
					_isCompactCommand = true;
					break;
				case "DELETE TABLE":	//不要な空間を削除する。
					//_sql.sqlConnection.compact();						
					_sql.text = "DROP TABLE " + _DB_tableName;
					_isCompactCommand = true;
					break;
			}
		}
		
		public function exec(inputData:Object):void {
			//INSERTを実行する場合、inputDataをパラメータに入力する。
			if( inputData != "" ){
				switch(_comdType){	//配列行数１個に対して行われる。
					case "INSERT":
						_sql.parameters["@date"] 		= inputData["date"];
						_sql.parameters["@chuuiFlg"] 	= inputData["chuuiFlg"];
						_sql.parameters["@name"] 		= _safeRep.Rep_sql("",inputData["name"])[0];
						_sql.parameters["@id"] 			= inputData["id"];
						_sql.parameters["@commuName"] 	= _safeRep.Rep_sql("",inputData["commuName"])[0];
						_sql.parameters["@commuId"] 	= inputData["commuId"];
						_sql.parameters["@bbsId"] 		= inputData["bbsId"];
						_sql.parameters["@bbsDate"] 	= inputData["bbsDate"];
						_sql.parameters["@bbsNo"] 		= inputData["bbsNo"];
						break;
					case "SELECT WHERE @":
						_sql.parameters["@condition"] 	= _safeRep.Rep_sql("",inputData["condition"])[0]; 
						break;
					case "DELETE @":
						_sql.parameters["@condition"] 	= _safeRep.Rep_sql("",inputData["condition"])[0]; 
						break;
				}
			}
			_sql.execute();
		}
		
		//結果を取得。　_sql.execute();が成功した際
		override protected function insertResultHandler(e:SQLEvent):void {
			if(_comdType != "INSERT" && _comdType != "DELETE"  && _comdType != "UPDATE TANAAGE"){
				var res:SQLResult = _sql.getResult();
				if(res.data != null){
					_sqlOutput = res.data;
				}
				else if(res.data == null){
					_sqlOutput = new Array();
				}
			}
		}
		
		//DBの構造をクリーンアップ
		override protected function connCompact():void {
			if (_isCompactCommand)_conn.compact();				//INSERT,DELETEの場合はDBの構造をクリーンアップ
			//dispose();
		}
		
		//解放
		/*
		private function dispose():void {
			_sqlOutput = null;				//メモリ解放
		}
		*/
		
	}
}