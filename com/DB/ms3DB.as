package com.ms3.DB {
	
	//ヘルプメッセージクラス
	
	//import flash.data.EncryptedLocalStore;		//暗号化されたローカルストア
	//import flash.desktop.*;
	//import flash.display.*;
	//import flash.events.*;
	//import flash.filesystem.*;
	//import flash.html.*;
	//import flash.net.*;
	//import flash.system.System;
	//import flash.text.*;
	//import flash.utils.*;
	//import flash.ui.*;
	import com.org.sqlControl.SQLiteGP;
	import com.org.sqlControl.SQLiteOptimize;
	import com.org.sqlControl.SQLiteGP_bbsReader;
	import com.org.utils.CSV;
	
	
	public class ms3DB {
		
		private const _maxViewCount:uint = 50;	//最大表示件数
		
		public function ms3DB():void {
			
		}
		
		
		//--------------------------------------------
		//DBの初期化
		//--------------------------------------------
		public function dbInit():void {
			var mySQLiteGP:SQLiteGP = new SQLiteGP("log","log.db");
			mySQLiteGP.commit();
			mySQLiteGP 	= null;
			var optimizeDB:SQLiteOptimize = new SQLiteOptimize();
			optimizeDB.optimizeDBtable("log.db","log");
			optimizeDB 	= null;
			
			var mySQLiteGP_bbsReader:SQLiteGP_bbsReader = new SQLiteGP_bbsReader("bbsReader" , "bbsReader.db");
			mySQLiteGP_bbsReader.commit();
			mySQLiteGP_bbsReader = null;
			optimizeDB = new SQLiteOptimize();
			optimizeDB.optimizeDBtable("bbsReader.db","bbsReader");
			optimizeDB = null;
		}
		
		//**********************
		//	DB :: IDトレース
		//**********************
		//--------------------------------------------
		//結果を記録
		//--------------------------------------------
		public function writeDB_idTraceMode(inDate:String,
								inChuuiFlg:Boolean,
								inName:String,
								inId:String,
								inCommuName:String,
								inCommuId:String,
								inBbsId:String,
								inBbsDate:String,
								inBbsNo:String,
								inFindTime:uint):void {
			//データベースの記録
			//[カラムの定義]
			//検出日時：				date TEXT
			//注意喚起したか？：			chuuiFlg BOOLEAN
			//ニックネーム：				name TEXT
			//ID：					id INTEGER
			//コミュ名：				commuName TEXT
			//コミュID:				commuId INTEGER
			//書き込みされたトピックid：	bbsId INTEGER
			//書き込みの日時			bbsDate TEXT
			//書き込み番号			bbsNo INTEGER
			
			//DBに記録させる。
			var mySQLiteGP:SQLiteGP;
			mySQLiteGP = new SQLiteGP("log" , "log.db");
			mySQLiteGP.setStmtText("INSERT" , "log" , "" , "" , "");
			
			//リストを挿入。
			mySQLiteGP.exec({date : inDate,
					chuuiFlg : 	inChuuiFlg,
					name : 		inName,
					id : 		uint(inId),
					commuName : inCommuName,
					commuId : 	uint(inCommuId),
					bbsId : 	uint(inBbsId),
					bbsDate : 	inBbsDate,
					bbsNo : 	uint(inBbsNo) } );
							
			//トランザクションをコミット
			mySQLiteGP.commit();
			mySQLiteGP = null;	
		}
		
		
		//--------------------------------------------
		//結果を削除
		//--------------------------------------------
		public function deleteDB_idTraceMode():void {
			var mySQLiteGP:SQLiteGP;
			mySQLiteGP = new SQLiteGP("log" , "log.db");
			mySQLiteGP.setStmtText("DELETE ALL" , "log" , "" , "" , "");
			mySQLiteGP.exec("");
			//トランザクションをコミット
			mySQLiteGP.commit();
			mySQLiteGP = null;
		}
		
		
		//--------------------------------------------
		//結果のページ総数を返す
		//--------------------------------------------
		public function totalPage_idTraceMode():uint{
			//DBの内容を出力する
			var mySQLiteGP:SQLiteGP;
			mySQLiteGP = new SQLiteGP("log" , "log.db");
			mySQLiteGP.setStmtText("COUNT", "log" , "" , "" , "");
			mySQLiteGP.exec("");
			var selObj_reqCount:Object 	= mySQLiteGP.result;
			var logCount:uint 			= selObj_reqCount[0]["COUNT(no)"];
			
			//解放
			selObj_reqCount = null;
			
			//トランザクションをコミット
			mySQLiteGP.commit();
			mySQLiteGP = null;
			
			return Math.floor(logCount / _maxViewCount)+((logCount / _maxViewCount - Math.floor(logCount / _maxViewCount)) > 0 ? 1 : 0);
		}
		
		//--------------------------------------------
		//結果をHTML形式で返す
		//--------------------------------------------
		public function getListHTML_idTraceMode(inPage:uint, inNowPage:int, inMikakuninCount:uint):String {
			
			var retStr:String = "";
			
			var mySQLiteGP:SQLiteGP;
			mySQLiteGP = new SQLiteGP("log" , "log.db");
			mySQLiteGP.setStmtText("SELECT LIMIT ORDER DATE" , "log" , String(inNowPage * _maxViewCount) , String(_maxViewCount) , "");
			mySQLiteGP.exec("");
			var selObj_reqAll:Object = mySQLiteGP.result;
			//トランザクションをコミット
			mySQLiteGP.commit();
			mySQLiteGP = null;
			
			//ダイナミックテキストに表示する内容を追記
			var kaigyo:String = "\n";
			var tab:String = "\t";
			
			//trace("DB.length: "+selObj_reqAll.length);
			var newInfoST:String = "";
			var newInfoET:String = "";
			if (selObj_reqAll != null) {
				for (var i:uint = 0; i < selObj_reqAll.length; i++ ) {
					
					//trace("DB -> date: " + selObj_reqAll[i]["date"]);
					//trace("DB -> chuuiFlg: " + selObj_reqAll[i]["chuuiFlg"]);
					//trace("DB -> name: " + selObj_reqAll[i]["name"]);
					//trace("DB -> id: " + selObj_reqAll[i]["id"]);
					//trace("DB -> commuName: " + selObj_reqAll[i]["commuName"]);
					//trace("DB -> commuId: " + selObj_reqAll[i]["commuId"]);
					//trace("DB -> bbsId: " + selObj_reqAll[i]["bbsId"]);
					//trace("DB -> bbsDate: " + selObj_reqAll[i]["bbsDate"]);
					//trace("DB -> bbsNo: " + selObj_reqAll[i]["bbsNo"]);
					//trace("---------------")
					
					if(i < inMikakuninCount-inNowPage*_maxViewCount){
						newInfoST = "<span class=\"newInfo\">";
						newInfoET = "</span>";
					}else {
						newInfoST = "";
						newInfoET = "";
					}
					
					var dateSplArr:Array = String(String(selObj_reqAll[i]["date"]).substr(0, -6) + "時").split("/");
					retStr += newInfoST + dateSplArr[0]+"年"+dateSplArr[1]+"月"+String(dateSplArr[2]).replace(" ","日 ") + newInfoET +kaigyo;
					retStr += newInfoST + "<a href=\""+ "http://mixi.jp/view_community.pl?id=" + selObj_reqAll[i]["commuId"] +"\">" + selObj_reqAll[i]["commuName"] +"</a>"+newInfoET+ kaigyo;
					retStr += newInfoST + "http://mixi.jp/view_community.pl?id=" + selObj_reqAll[i]["commuId"] + newInfoET + kaigyo;
					retStr += kaigyo;
				}
			}
			
			//解放
			selObj_reqAll 	= null;
			kaigyo 			= null;
			tab 			= null;
			newInfoST		= null;
			newInfoET		= null;
			dateSplArr		= null;
			
			return retStr;
		}
		
		
		
		
		//--------------------------------------------
		//結果をCSV出力
		//--------------------------------------------
		public function outDBtoCSV_idTraceMode():void {
			
			//DBの内容を出力する
			var mySQLiteGP:SQLiteGP;
			mySQLiteGP = new SQLiteGP("log" , "log.db");
			mySQLiteGP.setStmtText("SELECT ALL" , "log" , "" , "" , "");
			mySQLiteGP.exec("");
			var selObj_reqAll:Object = mySQLiteGP.result;
			
			//トランザクションをコミット
			mySQLiteGP.commit();
			mySQLiteGP = null;
			
			if (selObj_reqAll != null) {

				//trace("DB -> date: " + selObj_reqAll[i]["date"]);
				//trace("DB -> chuuiFlg: " + selObj_reqAll[i]["chuuiFlg"]);
				//trace("DB -> name: " + selObj_reqAll[i]["name"]);
				//trace("DB -> id: " + selObj_reqAll[i]["id"]);
				//trace("DB -> commuName: " + selObj_reqAll[i]["commuName"]);
				//trace("DB -> commuId: " + selObj_reqAll[i]["commuId"]);
				//trace("DB -> bbsId: " + selObj_reqAll[i]["bbsId"]);
				//trace("DB -> bbsDate: " + selObj_reqAll[i]["bbsDate"]);
				//trace("DB -> bbsNo: " + selObj_reqAll[i]["bbsNo"]);
				//trace("---------------")
				
				var csv:CSV = new CSV("検出した日時","mixiニックネーム","mixi ID","プロフィールURL","コミュニティ名","コミュニティID","コミュニティURL");
				
				for (var i:uint = 0; i < selObj_reqAll.length; i++ ) {
					csv.addCol(selObj_reqAll[i]["date"],
									selObj_reqAll[i]["name"],
									selObj_reqAll[i]["id"],
									"http://mixi.jp/show_profile.pl?id=" + selObj_reqAll[i]["id"],
									selObj_reqAll[i]["commuName"],
									selObj_reqAll[i]["commuId"],
									"http://mixi.jp/view_community.pl?id=" + selObj_reqAll[i]["commuId"]);
				}
				
				csv.exportFile("MS3 解析結果");
				csv = null;
			}
			selObj_reqAll = null;
		}
		
		
		
		
		
		//**********************
		//	DB :: コミュフィード抽出
		//**********************	
		
		//--------------------------------------------
		//結果の表示
		//--------------------------------------------
		public function viewDB_topicExtractionMode(inPage:int):Object {
			
			//返り値
			var retObject = new Object();
			var retTopicFeed_nowPage:int = 0;
			var retTotalPage:uint = 0;
			var retNowViewNo_bbsReader:String = "";
			var isImportantList:Boolean = false;
			var retMes:String = "";
			
			retTopicFeed_nowPage = inPage < 0 ? 0 : inPage;
			
			//件数取得
			var mySQLiteGP:SQLiteGP_bbsReader;
			mySQLiteGP = new SQLiteGP_bbsReader("bbsReader" , "bbsReader.db");
			mySQLiteGP.setStmtText("COUNT" , "bbsReader" , "" , "" , "");
			mySQLiteGP.exec("");
			var selObj_reqCount:Object = mySQLiteGP.result;
			retTotalPage = selObj_reqCount[0]["COUNT(no)"];
			
			retTopicFeed_nowPage = retTopicFeed_nowPage >= retTotalPage ? retTotalPage-1 : retTopicFeed_nowPage;
			
			if(retTotalPage > 0){
				//DBの内容を出力する
				var conditionStr:String = "* FROM bbsReader ORDER BY id DESC LIMIT "+String(retTopicFeed_nowPage)+",1";
				mySQLiteGP.setStmtText("SELECT ALL config" , "" , "" , "" , conditionStr);
				mySQLiteGP.exec("");
				var selObj_reqAll:Object = mySQLiteGP.result;
				//トランザクションをコミット
				mySQLiteGP.commit();
				mySQLiteGP = null;
				
				retMes = "";
				if (selObj_reqAll != null) {
					for (var i:uint = 0; i < selObj_reqAll.length; i++ ) {
						
						retNowViewNo_bbsReader = selObj_reqAll[i]["no"];
						retMes += "条件と一致したコメントを表示します (新ID順に表示)<br>";
						retMes += "<em>アカウント：</em>"+'<a href="http://mixi.jp/show_profile.pl?id='+selObj_reqAll[i]["id"]+'" target="_blank">'+selObj_reqAll[i]["name"] + "</a> (id=" + selObj_reqAll[i]["id"] + ")" + "<br>";
						retMes += "<em>日付：</em>" + selObj_reqAll[i]["date"] + "<br>";
						retMes += "<em>コミュ：</em>" + selObj_reqAll[i]["commuName"] + "<br>";
						retMes += "<em>タイトル：</em>"+selObj_reqAll[i]["title"] + "<br>";
						retMes += '<em>リンク：</em><a href="'+selObj_reqAll[i]["topicUrl"]+'" target="_blank">トピックを開く</a> | <a href="'+selObj_reqAll[i]["commentUrl"]+'" target="_blank">コメント['+selObj_reqAll[i]["topicNo"]+']を開く</a> | <a href="'+selObj_reqAll[i]["reportUrl"]+'" target="_blank">'+ "通報する</a>"+"<br>";
						
						retMes += "<em>コメント"+"["+selObj_reqAll[i]["topicNo"]+"]"+"：</em><br>";
						retMes += selObj_reqAll[i]["comment"] + "<br>";
						
						//保護されているか否か？
						isImportantList = selObj_reqAll[i]["isImportant"];
						
						/*
						trace("id: " + selObj_reqAll[i]["name"] + ")");
						trace("date: " + selObj_reqAll[i]["date"]);
						trace("url: " + selObj_reqAll[i]["topicUrl"]);
						trace("comment: " + selObj_reqAll[i]["comment"]);
						trace("---------------------------------------");
						trace("");
						trace("");
						*/
					}
				}
				selObj_reqAll = null;
			}else {
				retNowViewNo_bbsReader = "";
				retMes = "解析結果は0件です。";
			}
			
			//返り値の設定
			retObject = { topicFeed_nowPage:retTopicFeed_nowPage,
							totalPage:retTotalPage,
							nowViewNo_bbsReader:retNowViewNo_bbsReader,
							isImportantList:isImportantList,
							mes:retMes};
			
			//解放
			selObj_reqCount 		= null;
			retNowViewNo_bbsReader 	= null;
			retMes 					= null;
			
			return retObject;
		}
		
		//--------------------------------------------
		//結果を削除
		//--------------------------------------------
		public function deleteDB_topicExtractionMode():void {
			var mySQLiteGP_bbs:SQLiteGP_bbsReader = new SQLiteGP_bbsReader("bbsReader" , "bbsReader.db");
			mySQLiteGP_bbs.setStmtText("DELETE isImportant" , "bbsReader" , "" , "" , "");
			mySQLiteGP_bbs.exec("");			
			//トランザクションをコミット
			mySQLiteGP_bbs.commit();
			mySQLiteGP_bbs = null;
		}
		
		//--------------------------------------------
		//結果が重要項目であるか否かの設定 (isImportant：trueで削除されない)
		//--------------------------------------------
		public function importedFlg_topicExtractionMode(inImportant:Boolean,inNowViewNo:String):void {			
			var mySQLiteGP_bbs:SQLiteGP_bbsReader = new SQLiteGP_bbsReader("bbsReader" , "bbsReader.db");
			mySQLiteGP_bbs.setStmtText("UPDATE isImportant" , "bbsReader" , "" , "" , inNowViewNo);
			mySQLiteGP_bbs.exec( { isImportant:inImportant});
			//トランザクションをコミット
			mySQLiteGP_bbs.commit();
			mySQLiteGP_bbs = null;
		}
		
		//--------------------------------------------
		//isSendPhpを変更
		//--------------------------------------------
		public function sendPhpFlg_topicExtractionMode(isSendPhp:Boolean, inNoArr:Array):void {
			var whereStr:String = "";
			var mySQLiteGP_bbs:SQLiteGP_bbsReader = new SQLiteGP_bbsReader("bbsReader" , "bbsReader.db");
			mySQLiteGP_bbs.setStmtText("UPDATE isSendPhp" , "bbsReader" , "" , "" , whereStr);
			mySQLiteGP_bbs.exec( { isSendPhp:isSendPhp});
			//トランザクションをコミット
			mySQLiteGP_bbs.commit();
			mySQLiteGP_bbs = null;
			//解放
			whereStr = null;
		}
		
		
		
		//**********************
		//	DB :: 共通
		//**********************	
		
		//--------------------------------------------
		//記録数を取得する
		//--------------------------------------------
		public function dbListCount(inSearchMode:String):uint {
			var retCount:uint = 0;
			if (inSearchMode == "search") {
				var mySQLiteGP_bbs:SQLiteGP_bbsReader;
				mySQLiteGP_bbs = new SQLiteGP_bbsReader("bbsReader" , "bbsReader.db");
				mySQLiteGP_bbs.setStmtText("COUNT", "bbsReader" , "" , "" , "");
				mySQLiteGP_bbs.exec("");
				
				var selObj_reqCount_bbs:Object = mySQLiteGP_bbs.result;
				retCount = selObj_reqCount_bbs[0]["COUNT(no)"];
				
				//トランザクションをコミット
				mySQLiteGP_bbs.commit();
				mySQLiteGP_bbs = null;
				
				//解放
				selObj_reqCount_bbs = null;
			}else{
				//DBの内容を出力する
				var mySQLiteGP:SQLiteGP;
				mySQLiteGP = new SQLiteGP("log" , "log.db");
				mySQLiteGP.setStmtText("COUNT", "log" , "" , "" , "");
				mySQLiteGP.exec("");
				
				var selObj_reqCount:Object = mySQLiteGP.result;
				retCount = selObj_reqCount[0]["COUNT(no)"];
								
				//トランザクションをコミット
				mySQLiteGP.commit();
				mySQLiteGP = null;
				
				//解放
				selObj_reqCount = null;
			}
			return retCount;
		}
	}
}