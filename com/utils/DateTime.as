package com.utils {
	
	//時間関連の処理を行うクラス
	
	//import flash.data.EncryptedLocalStore;		//暗号化されたローカルストア
	//import flash.desktop.*;
	//import flash.display.*;
	//import flash.events.*;
	//import flash.filesystem.*;
	//import flash.html.*;
	//import flash.net.*;
	//import flash.system.System;
	//import flash.text.*;
	import flash.utils.*;
	//import flash.ui.*;
	
	
	public class DateTime{
		
		private var _userID:String = "";
		
		
		public function DateTime():void {
			
		}
		
		
		//--------------------------------
		//現在時間を文字列で返す
		//--------------------------------
		//入力値 ： inType
		// ・Time: 0000/00/00 00:00:00の形式で返す
		// ・Date: 0000/00/00の形式で返す
		public function nowTimeStr(inType:String):String {
			var now:Date 		= new Date();
			var monStr:String 	= now.month + 1 < 10 ? "0" + String(now.month + 1) : String(now.month + 1);
			var dateStr:String 	= now.date < 10 ? "0" + String(now.date) : String(now.date);
			var hourStr:String 	= now.hours < 10 ? "0" + String(now.hours) : String(now.hours);
			var minStr:String 	= now.minutes < 10 ? "0" + String(now.minutes) : String(now.minutes);
			var secStr:String 	= now.seconds < 10 ? "0" + String(now.seconds) : String(now.seconds);
			
			if(inType == "Time"){
				return String(now.fullYear) + "/" + monStr + "/" + dateStr + " " + hourStr + ":" + minStr + ":" + secStr;
			}else if(inType == "Date"){
				return String(now.fullYear) + "/" + monStr + "/" + dateStr;
			}
			
			return String(now.fullYear) + "/" + monStr + "/" + dateStr + " " + hourStr + ":" + minStr + ":" + secStr;
		}
		
		
		//--------------------------------
		//現在時間をString形式でオブジェクトを返す
		//--------------------------------
		//入力値 ： inType
		// ・Time: 0000/00/00 00:00:00の形式で返す
		// ・Date: 0000/00/00の形式で返す
		public function nowTimeObj():Object {
			
			var now:Date 		= new Date();
			var monStr:String 	= now.month + 1 < 10 ? "0" + String(now.month + 1) : String(now.month + 1);
			var dateStr:String 	= now.date < 10 ? "0" + String(now.date) : String(now.date);
			var hourStr:String 	= now.hours < 10 ? "0" + String(now.hours) : String(now.hours);
			var minStr:String 	= now.minutes < 10 ? "0" + String(now.minutes) : String(now.minutes);
			var secStr:String 	= now.seconds < 10 ? "0" + String(now.seconds) : String(now.seconds);
						
			return { fullYear:String(now.fullYear),
						month:monStr,
						date:dateStr,
						hours:hourStr,
						minutes:minStr,
						seconds:secStr};
		}
		
		//--------------------------------
		//入力日時から何日経過しているかを返す
		//--------------------------------
		//入力値 ： inDateStr
		// ・00:00 → 0		(0日の値が返る)
		//　・00/00 → 0 ～ 	(0日以上の値が返る)
		public function dateLength(inDateStr:String):uint{
			if (inDateStr.indexOf(":") != -1) return 0;
			
			var splTopicsDateArr:Array = new Array();
			splTopicsDateArr = inDateStr.split("月");
			
			var monthStr:String = splTopicsDateArr[0];
			var dayStr:String = String(splTopicsDateArr[1]).replace("日","");
			
			var nowDate_n:Date = new Date();
			var nowDate:Date;
			var startDate:Date;
			if (monthStr != "" && dayStr != "") {
				nowDate = new Date(nowDate_n.fullYear, nowDate_n.month, nowDate_n.date, 0, 0, 0, 0);
				startDate = new Date(nowDate_n.fullYear, uint(monthStr) - 1, uint(dayStr), 0, 0, 0, 0);
				return Math.floor((nowDate.getTime()-startDate.getTime())/1000/60/60/24);
			}else {
				return 0;
			}
		}
		
		//---------------------------------------
		//指定された時間よりも先の時間をString形式で返す
		//---------------------------------------
		//taslWorkerThread getIntervalDateString
		//入力値 ： inHour
		// ・x →　0000/00/00 00:00:00 (現在時間からx時間経過した日時)
		public function afterDateStr(inHour:uint):String {
			
			var nowDate:Date = new Date();
			nowDate.setTime(nowDate.getTime() + inHour * 60 * 60 * 1000);
			
			var Y:uint = nowDate.fullYear;
			var M:uint = nowDate.month + 1;
			var D:uint = nowDate.date;
			var h:uint = nowDate.hours;
			var m:uint = nowDate.minutes;
			var s:uint = nowDate.seconds;
			
			var Y_str:String = String(Y);
			var M_str:String = String(M < 10 ? "0"+String(M) : M);
			var D_str:String = String(D < 10 ? "0"+String(D) : D);
			var h_str:String = String(h < 10 ? "0"+String(h) : h);
			var m_str:String = String(m < 10 ? "0"+String(m) : m);
			var s_str:String = String(s < 10 ? "0"+String(s) : s);
			
			return Y_str+"-"+M_str+"-"+D_str+" "+h_str+":"+m_str+":"+s_str;
		}
		
		//---------------------------------------
		//入力された日時と現在時間との時間差を返す
		//---------------------------------------
		//入力値 ： inDateStr
		//　・2013年01月01日 12:00 → 2 (現在時間：2013/01/03 12:00の場合)
		public function intervalHour(inDateStr:String):int{
			var test:String = inDateStr;
			
			var dateTimeSplArr:Array = test.split(" ");
			
			var yearStr:String 	= dateTimeSplArr[0].split("年")[0];
			var monthStr:String = dateTimeSplArr[0].split("年")[1].split("月")[0];
			var dayStr:String 	= dateTimeSplArr[0].split("月")[1].split("日")[0];
			
			var timeArr:Array 	= dateTimeSplArr[1].split(":");
			
			var nowDate:Date 	= new Date();
			var startDate:Date;
			if (yearStr != "" && monthStr != "" && dayStr != "" && timeArr.length == 2) {
				startDate = new Date(uint(yearStr),uint(monthStr)-1,uint(dayStr),uint(timeArr[0]),uint(timeArr[1]),0,0);
			}
			
			return Math.floor((nowDate.getTime()-startDate.getTime())/1000/60);
		}
		
		//---------------------------------------
		//入力された日付をDBで管理する形式に変換し返す
		//---------------------------------------
		//入力値 ： inDateStr
		//　・2013年01月01日 12:00 → 2013/01/01 12:00:00
		public function replaceDateTimeStr(inDateStr:String):String{
			var test:String = inDateStr;
			
			var dateTimeSplArr:Array = test.split(" ");
			
			var yearStr:String 	= dateTimeSplArr[0].split("年")[0];
			var monthStr:String = dateTimeSplArr[0].split("年")[1].split("月")[0];
			var dayStr:String 	= dateTimeSplArr[0].split("月")[1].split("日")[0];
			
			var timeArr:Array 	= dateTimeSplArr[1].split(":");
			
			var startDate:Date;
			if (yearStr != "" && monthStr != "" && dayStr != "" && timeArr.length == 2) {
				return yearStr+"/"+monthStr+"/"+dayStr+" "+timeArr[0]+":"+timeArr[1]+":"+"00";
			}else {
				return "0000/00/00 00:00:00";
			}
		}
		
	}
}