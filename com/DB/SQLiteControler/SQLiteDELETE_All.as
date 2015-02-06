package com.DB.SQLiteControler
{
	//import flash.filesystem.File;
	//import flash.utils.getTimer;
	import flash.data.*;
	//import flash.events.*;
	//import flash.filesystem.*;
	import com.DB.SQLiteControler.SQLiteBase;
	
	
	/**
	 * 指定したＤＢテーブルの内容を全件削除する。
	 */
	public class SQLiteDELETE_All extends SQLiteBase
	{
		//コンストラクタ
		public function SQLiteDELETE_All(inDB_fileName:String,inDB_tableName:String) {
			super(inDB_fileName , inDB_tableName);
		}
		
		override protected function inputStatement():void {
			_sql = new SQLStatement();
			_sql.sqlConnection = _conn;
			_sql.text = "DELETE FROM "+ _DB_tableName;
		}
		
		//選択したデータを削除
		public function deleteAll():void {
			_sql.execute();
		}
	}
}