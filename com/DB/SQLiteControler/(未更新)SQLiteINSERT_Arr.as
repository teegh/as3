package com.org.sqlControl
{
	import flash.filesystem.File;
	import flash.display.MovieClip;
	import flash.utils.getTimer;
	import flash.data.*;
	import flash.events.*;
	import flash.filesystem.*;
	import com.org.sqlControl.SafeRepStr;
	
	//入力された配列(データグリッドのリスト配列やmp3のID3タグ情報)を全件追加する。
	//全件に対して再帰処理を行い、１トランザクションで完了する。
	
	public class SQLiteINSERT_Arr
	{
		private var _conn:SQLConnection;	
		private var _sql:SQLStatement;													//
		private var _activeDBtable:String="";											//操作DBテーブル
		private var _activeDBname:String="";										//操作DB
		private var _loadMov:MovieClip;													//ロード画面
		private var _dat:Array=new Array();
		private var roopFlg:Boolean;														//再帰処理の処理許可(SQLエラー時にfalse)
		private var roopNum:uint;															//処理する配列件数
	
		//コンストラクタ
		public function SQLiteINSERT_Arr(inActiveDBtable:String , inActiveDBname:String , inArr:Array){
			_activeDBtable=inActiveDBtable;
			_activeDBname=inActiveDBname;
			_dat=inArr;
			initDB(_activeDBname , _activeDBtable);
			roopFlg=true;
			roopNum=0;
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
			trace("DB INSERT_Arr エラーハンドラー (dbErrorHandler(evt:Event) ) :: " + evt);
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
			_sql.text = "INSERT INTO "+ _activeDBtable +" (tanaNo , cdNo, titles, titlesKana, playTime, artist, artistKana, album, track, year, genre, comment, filePath, picFlg, picFileSize, picFilePos , kashiFlg, kashiFileSize, kashiFilePos, escapeSeq, requestFlg, requestTime ) VALUES ( @tanaNo , @cdNo, @titles, @titlesKana, @playTime, @artist, @artistKana, @album, @track, @year, @genre, @comment, @filePath, @picFlg, @picFrameSize, @picFilePos , @kashiFlg, @kashiFrameSize, @kashiFilePos, @escapeSeq, @requestFlg, @requestTime )";
			_sql.addEventListener(SQLEvent.RESULT, insertResultHandler);
			_sql.addEventListener(SQLErrorEvent.ERROR, insertErrorHandler);
			trace("[DB INSERT_Arr] transaction begin");
		}
		
		//コンストラクタ入力Arrayを全件 DBへ入力
		public function insert():void {
			if(_dat.length >0){
				roopNum=_dat.length;		//処理件数を取得。
				insertDo();
			}
		}
		private function insertDo():void {
			var item:Object=_dat.shift();																	//配列の最初の要素を削除し、その要素を取得する。
			
			//カナ、棚番号、ＣＤ番号については ' 文字を削除する。
			item.tanaNo=item.tanaNo.replace(/'/g , "");											//変換した文字を返す。
			item.cdNo=item.cdNo.replace(/'/g , "");													//変換した文字を返す。
			item.artistKana=item.artistKana.replace(/'/g , "");									//変換した文字を返す。
			item.titlesKana=item.titlesKana.replace(/'/g , "");									//変換した文字を返す。
			
			//入力値の文字をＳＱＬ入力にエラー回避する文字へ変換(SQLの区切り文字を変換)
			var RepStr:SafeRepStr = new SafeRepStr();
			var titlesArr:Array =		RepStr.safeRepStr("titles",item.titles);							//エスケープシーケンスが含まれる場合はタイトル中の文字を置き換え、エスケープ文字と位置をescapeSeqに格納
			var artistArr:Array=			RepStr.safeRepStr("artist",item.artist);						//													アーティスト
			var albumArr:Array=			RepStr.safeRepStr("album",item.album);						//													アルバム
			var genreArr:Array=			RepStr.safeRepStr("genre",item.genre);						//													ジャンル
			var commentArr:Array=	RepStr.safeRepStr("comment",item.comment);				//													コメント
			var filePathArr:Array=		RepStr.safeRepStr("filePath",item.filePath);					//													ファイル場所
			
			//エスケープシーケンスの位置を保存する変数
			var escapeSeq:String=titlesArr[1]+artistArr[1]+albumArr[1]+genreArr[1]+commentArr[1]+filePathArr[1];
			
			_sql.parameters["@tanaNo"] = 		item.tanaNo  ;
			_sql.parameters["@cdNo"] = 			item.cdNo  ;
			_sql.parameters["@titles"] = 		titlesArr[0]  ;
			_sql.parameters["@titlesKana"] = 	item.titlesKana  ;
			_sql.parameters["@playTime"] = 	item.playTime  ;
			_sql.parameters["@artist"] = 		artistArr[0]  ;
			_sql.parameters["@artistKana"] = 	item.artistKana  ;
			_sql.parameters["@album"] = 		albumArr[0]  ;
			_sql.parameters["@track"] = 		item.track  ;
			_sql.parameters["@year"] = 			item.year  ;
			_sql.parameters["@genre"] = 		genreArr[0]  ;
			_sql.parameters["@comment"] = 	commentArr[0]  ;
			_sql.parameters["@filePath"] = 		filePathArr[0]  ;
			_sql.parameters["@picFlg"] = 		item.picFlg ;
			_sql.parameters["@picFrameSize"] = 	item.picFrameSize  ;
			_sql.parameters["@picFilePos"] = 		item.picFilePos  ;
			_sql.parameters["@kashiFlg"] = 			item.kashiFlg  ;
			_sql.parameters["@kashiFrameSize"] = 	item.kashiFrameSize  ;
			_sql.parameters["@kashiFilePos"] = 	item.kashiFilePos  ;
			_sql.parameters["@escapeSeq"] = 		item.escapeSeq  ;
			_sql.parameters["@requestFlg"] = 		item.requestFlg  ;
			_sql.parameters["@requestTime"] = 	item.requestTime  ; 
			_sql.execute();
			
			if( ! _dat.length){
				return;						//全件処理が終了後、再帰処理終了
			}else{
				if(roopFlg==true){		//再帰処理を許可する場合。(SQLエラーなどで再帰処理を停止指示していればfalse)
					insertDo();				//スタックオーバーフローを回避する為に末尾再帰を行っている。SQLEvent.RESULTイベントを設けず、処理(あまり好ましくない。)
				}else{
					return;					//エラーの場合、再帰処理終了
				}
			}
		}
		
		//insert成功
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
			trace("[DB INSERT_Arr] commit complete!");
			closeConn();
		}
		private function rollbackHandler(e:SQLEvent):void {
			trace("[DB INSERT_Arr] rollback complete!");
			closeConn();
		}
		private function compactCP(e:SQLEvent):void{
			_conn.removeEventListener(SQLEvent.COMPACT, compactCP);
			trace("[DB INSET Arr] compact complete!");
		}
		private function errorHandler(e:SQLErrorEvent):void {
			trace("エラー："+e.error.message);
		}
		private function closeConn():void{
			_conn.addEventListener(SQLEvent.COMPACT, compactCP);
			_conn.compact();				//DBの構造をクリーンアップ
			_conn.close();					//DB接続を閉じます。
			_sql.removeEventListener(SQLEvent.RESULT, insertResultHandler);
			_sql.removeEventListener(SQLErrorEvent.ERROR, insertErrorHandler);
			_conn.removeEventListener(SQLEvent.BEGIN, beginHandler);
			_conn.removeEventListener(SQLEvent.COMMIT, commitHandler);
			_conn.removeEventListener(SQLEvent.ROLLBACK, rollbackHandler);
			_conn.removeEventListener(SQLErrorEvent.ERROR, errorHandler);
			trace("[DB INSERT_Arr] close!");
		}
		public function rollbackConn():void{
			_conn.rollback();
			trace("[DB INSERT_Arr] rollback!");
		}
		public function commit():void{
			_conn.commit();
		}
	}
}