package com.ms3.php {
	
	//phpクラス
	
	//import flash.data.EncryptedLocalStore;		//暗号化されたローカルストア
	//import flash.desktop.*;
	//import flash.display.*;
	import adobe.utils.CustomActions;
	import flash.events.*;
	//import flash.filesystem.*;
	//import flash.html.*;
	import flash.net.*;
	import flash.system.System;
	//import flash.text.*;
	import flash.utils.*;
	//import flash.ui.*;
	//import com.org.utils.DateTime;
	import com.ms3.php.ms3phpEvent;
	
	
	public class ms3php extends EventDispatcher{
		
		private var _php_init:Boolean 		= false;	//初期化および当クラスの処理を有効にするか？
		private var _sendCmdTimer:Timer;
		private var _tempWriteCommuId_Arr:Array = new Array();
		private var _userId:String 				= "";
		private var _this:webKitTest;
		
		private var _chkListKekkaArr:Array 		= new Array();
		
		
		public function ms3php():void {
			
		}
		
		public function init(inUserId:String,inThis:webKitTest,init:Boolean):void {
			_userId = inUserId;
			_this = inThis;
			_php_init = init;	//クラスの利用を有効にする
		}		
		
		public function get initialized():Boolean {
			return _php_init;
		}
		
		//********************************************
		//結果の記録と、一定時間間隔の送信
		//********************************************
		public function storeLog(inID:String, inName:String, inState:String, inCommuName:String, inURL:String, inFindTime:uint):Boolean {
			
			if (!_php_init) return false;   //クラスを無効にするか否か
			
			var isAddStore:Boolean = false;														//記録にカウントするか否か
			var commuIdStr:String = inURL.split("view_community.pl?id=")[1].split("&")[0];		//コミュidの抽出
			
			//コミュの出入りにより、同じコミュを行き来しているものは記録しない。
			if (_tempWriteCommuId_Arr.indexOf(commuIdStr) == -1) {
				_tempWriteCommuId_Arr.push(commuIdStr);
				
				//あまりにも格納数が多ければ1件削除
				if (_tempWriteCommuId_Arr.length == 10)_tempWriteCommuId_Arr.shift();
				
				isAddStore = true;
			}
			//一定時間経過後の処理
			sendTimerReStart();
			
			return isAddStore;
		}
		public function sendTimerReStart():void {
			if (!_php_init) return;   //クラスを無効にするか否か
			sendTimerStop();
			if (!_sendCmdTimer) {
				_sendCmdTimer = new Timer(1000, 30*60);
				_sendCmdTimer.addEventListener(TimerEvent.TIMER_COMPLETE , onTimerComp_sendTimer);
				_sendCmdTimer.addEventListener(TimerEvent.TIMER , onTimer_sendTimer);
				_sendCmdTimer.start();
			}
		}
		private function sendTimerStop():void {
			if (!_php_init) return;   //クラスを無効にするか否か
			if (_sendCmdTimer) {
				_sendCmdTimer.stop();
				_sendCmdTimer.removeEventListener(TimerEvent.TIMER_COMPLETE , onTimerComp_sendTimer);
				_sendCmdTimer.removeEventListener(TimerEvent.TIMER , onTimer_sendTimer);
				_sendCmdTimer = null;
			}
		}
		private function onTimerComp_sendTimer(e:TimerEvent):void {
			if (!_php_init) return;   //クラスを無効にするか否か
			sendTimerStop();
			_tempWriteCommuId_Arr = null;
			_tempWriteCommuId_Arr = new Array();
		}
		private function onTimer_sendTimer(e:TimerEvent):void {
			//trace(String(Timer(e.target).currentCount) + " / " +String(Timer(e.target).repeatCount));
		}
		
		
		
		
		
		private var _task_twMes_Arr:Array 		= new Array();	//twitter送信すべき内容が複数ある場合は、この配列に格納される。
		private var _task_twMes_else_Arr:Array 	= new Array();
		private var _tw_loader:URLLoader;
		private var _isTwSending:Boolean 		= false;
		private var _sendWaitTimer:Timer 		= new Timer(1500, 1);
		public function sendTwitterPHP_AddTask(inMes:String,
										inMixiName:String,
										inMixiId:String,
										inCommuName:String,
										inCommuId:String,
										inObserver:String,
										inObserverId:String,
										inFindTime:String):void {
			if (!_php_init) return;   //クラスを無効にするか否か
			if(_this.isTestMode) return;
			//既に同じ送信メッセージが送られる場合
			if (_task_twMes_Arr.indexOf(inMes) != -1) return;
			
			//送信中の場合、送信タスク配列に追加する
			if (_isTwSending) {
				//タスク配列に追加
				_task_twMes_Arr.push(inMes);
				_task_twMes_else_Arr.push({mesW:inMes,mixiName:inMixiName,mixiId:inMixiId,commuName:inCommuName,commuId:inCommuId,observer:inObserver,observerId:inObserverId,findTime:inFindTime});
				return;
			}
			_isTwSending = true;
			
			//送信処理
			sendTwitterPHP(inMes,inMixiName,inMixiId,inCommuName,inCommuId,inObserver,inObserverId,inFindTime);
		}
		private function sendTwitterPHP(inMes:String,
										inMixiName:String,
										inMixiId:String,
										inCommuName:String,
										inCommuId:String,
										inObserver:String,
										inObserverId:String,
										inFindTime:String):void {

			if (!_php_init) return;   //クラスを無効にするか否か
			System.useCodePage = false;			//↓文字コードをutf-8に
			var url:URLRequest = new URLRequest("http://ms3.sub.jp/app-cgi/appCallFunc/tw/send.php");
			url.method = URLRequestMethod.POST;//PHPへPOST送信
			
			//キャッシュを無効に
			url.cacheResponse = false;
			var header:URLRequestHeader = new URLRequestHeader("pragma", "no-cache");
			url.requestHeaders.push(header);
			
			//送る変数
			var variables:URLVariables = new URLVariables();
			variables.mes 			= escapeMultiByte(inMes);
			variables.mixiName 		= escapeMultiByte(inMixiName);
			variables.mixiId 		= escapeMultiByte(inMixiId);
			variables.commuName 	= escapeMultiByte(inCommuName);
			variables.commuId 		= escapeMultiByte(inCommuId);
			variables.observer 		= escapeMultiByte(inObserver);
			variables.observerId 	= escapeMultiByte(inObserverId);
			variables.findTime 		= escapeMultiByte(inFindTime);
			
			url.data = variables;
			
			_tw_loader = new URLLoader (url);
			if(!_tw_loader.hasEventListener(Event.COMPLETE))_tw_loader.addEventListener(Event.COMPLETE , onLoadComplete);
			_tw_loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			_tw_loader.load(url);
			
			url = null;
		}
		private function onLoadComplete(e:Event):void {
			if (!_php_init) return;   //クラスを無効にするか否か
			if (_task_twMes_Arr.length > 0) {
				//一定秒数後に実行する
				if(!_sendWaitTimer.hasEventListener(TimerEvent.TIMER_COMPLETE))_sendWaitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComp_sendTw);
				_sendWaitTimer.start();
			}else {
				//全て送信完了
				_isTwSending = false;
			}
		}
		private function onTimerComp_sendTw(e:TimerEvent):void {
			if (!_php_init) return;   //クラスを無効にするか否か
			//タイマーをリセット
			_sendWaitTimer.stop();
			_sendWaitTimer.reset();
			
			//他に送信すべき内容があれば送る。
			var stockObj:Object =  Object(_task_twMes_else_Arr.shift());
			sendTwitterPHP( String(_task_twMes_Arr.shift()) ,
							String(stockObj["mixiName"]) ,
							String(stockObj["mixiId"]) ,
							String(stockObj["commuName"]) ,
							String(stockObj["commuId"]) ,
							String(stockObj["observer"]) ,
							String(stockObj["observerId"]),
							String(stockObj["findTime"]));
			stockObj = null;
		}
		
		
		
		
		
		
		//********************************************
		//利用情報の送信
		//********************************************
		//解析をスタートさせる時、phpに以下を送信する。
		public function sendAppUseInfo(inSettingObj:Object, inSerachMode:String,inTargetId:String):void {
			
			if (!_php_init) return;   //クラスを無効にするか否か
			
			var userName:String = inSettingObj["name"];	//利用ユーザー名
			var serachmode:String = inSerachMode;		//解析モード
			
			
			
			//送信するメッセージを生成
			var sendMes:String = "";
			
			if(inTargetId != ""){
				sendMes += '<?xml version="1.0" encoding="UTF-8"?><deta>';
				sendMes += '<userID>';
				sendMes += _userId;
				sendMes += '</userID>';
				
				sendMes += '<userName>';
				sendMes += safeReplaceXML(userName);
				sendMes += '</userName>';
				
				sendMes += '<serachmode>';
				sendMes += serachmode;
				sendMes += '</serachmode>';
				
				sendMes += '<searchID>';
				sendMes += inTargetId;
				sendMes += '</searchID>';
				
				sendMes += '</deta>';
				
				trace("sendAppUseInfo 送信： \n"+sendMes);
				sendAppUseInfo_cmd(sendMes);
			}else {
				//trace("sendAppUseInfo リスト無し");
			}
			
			function safeReplaceXML(inStr:String):String {
				var retStr:String = inStr;
				retStr = retStr.replace(/"/g,'”').replace(/</g,"＜").replace(/>/g,"＞").replace(/\//g,"／").replace(/=/g,"＝");
				return retStr;
			}
		}
		//利用情報を送る
		private function sendAppUseInfo_cmd(inStr:String):void {
			if (!_php_init) return;   //クラスを無効にするか否か
			System.useCodePage = false;		//↓文字コードをutf-8に
			var url:URLRequest = new URLRequest("http://ms3.sub.jp/app-cgi/appCallFunc/setUserInfo.php");
			url.method = URLRequestMethod.POST;//PHPへPOST送信
			
			//キャッシュを無効に
			url.cacheResponse = false;
			var header:URLRequestHeader = new URLRequestHeader("pragma", "no-cache");
			url.requestHeaders.push(header);
			
			//送る変数
			var variables:URLVariables 	= new URLVariables();
			variables.userInfo 			= escapeMultiByte(inStr);
			
			url.data = variables;
			
			var testloader = new URLLoader (url);
			if(!testloader.hasEventListener(Event.COMPLETE))testloader.addEventListener(Event.COMPLETE , onSendAppUseInfo_cmdComplete);
			testloader.dataFormat = URLLoaderDataFormat.VARIABLES;
			testloader.load(url);
			
			url = null;
		}
		//送信完了したら
		private function onSendAppUseInfo_cmdComplete(e:Event):void {
			if (!_php_init) return;   //クラスを無効にするか否か
			var vars:URLVariables = new URLVariables( e.target.data );		//↓戻り値を変数に格納
			var outString:String = unescapeMultiByte(String(vars.out).replace(/^out=/, ""));
			trace(outString);
		}
		
		
		
		
		
		
		
		//********************************************
		//利用の停止
		//********************************************
		//解析を停止させる時、phpに以下を送信する。
		public function sendAppUseInfo_End():void {
			
			if (!_php_init) {
				_this.isAppSafeEnd = true;
				return;   //クラスを無効にするか否か
			}
			
			//送信するメッセージを生成
			var sendMes:String = "";
			
			if(_userId != ""){
				sendMes += '<?xml version="1.0" encoding="UTF-8"?><endDeta>';
				sendMes += '<userID>';
				sendMes += _userId;
				sendMes += '</userID>';
				
				sendMes += '</endDeta>';
				
				//trace("sendAppUseInfo_End 送信： \n"+sendMes);
				sendAppUseInfo_End_cmd(sendMes);
			}else {
				//trace("sendAppUseInfo_End リスト無し");
			}
		}
		//利用情報を送る
		private function sendAppUseInfo_End_cmd(inStr:String):void {
			
			if (!_php_init)return;   //クラスを無効にするか否か
			
			System.useCodePage = false;		//↓文字コードをutf-8に
			var url:URLRequest = new URLRequest("http://ms3.sub.jp/app-cgi/appCallFunc/setUserInfo.php");
			url.method = URLRequestMethod.POST;//PHPへPOST送信
			
			//キャッシュを無効に
			url.cacheResponse = false;
			var header:URLRequestHeader = new URLRequestHeader("pragma", "no-cache");
			url.requestHeaders.push(header);
			
			//送る変数
			var variables:URLVariables 	= new URLVariables();
			variables.userInfo 			= escapeMultiByte(inStr);
			
			url.data = variables;
			
			var testloader = new URLLoader (url);
			if (!testloader.hasEventListener(Event.COMPLETE)) testloader.addEventListener(Event.COMPLETE , onSendAppUseInfo_End_cmdComplete);
			if (!testloader.hasEventListener(SecurityErrorEvent.SECURITY_ERROR)) testloader.addEventListener(SecurityErrorEvent.SECURITY_ERROR , onSendAppUseInfo_End_cmdSecurityError);
			if (!testloader.hasEventListener(IOErrorEvent.IO_ERROR)) testloader.addEventListener(IOErrorEvent.IO_ERROR, onSendAppUseInfo_End_cmdIOError);			
			
			testloader.dataFormat = URLLoaderDataFormat.VARIABLES;
			testloader.load(url);
			
			url = null;
		}
		//送信完了したら
		private function onSendAppUseInfo_End_cmdComplete(e:Event):void {
			
			if (!_php_init) return;   //クラスを無効にするか否か
			
			var vars:URLVariables = new URLVariables( e.target.data );		//↓戻り値を変数に格納
			var outString:String = unescapeMultiByte(String(vars.out).replace(/^out=/, ""));
			//trace(outString);
			//アプリの終了フラグを立てる
			if (outString == "ok") {
				_this.isAppSafeEnd = true;
			}
		}
		//接続のエラーでも終了する。
		private function onSendAppUseInfo_End_cmdSecurityError(e:SecurityErrorEvent):void {
			if (!_php_init) return;   //クラスを無効にするか否か
			_this.isAppSafeEnd = true;
		}
		private function onSendAppUseInfo_End_cmdIOError(e:IOErrorEvent):void {
			if (!_php_init) return;   //クラスを無効にするか否か
			_this.isAppSafeEnd = true;
		}
		
		
		
		
		
		//********************************************
		//利用許可を得る
		//********************************************
		public function getUserAuth_cmd():Boolean {
			if (!_php_init) return false;   //クラスを無効にするか否か
			System.useCodePage = false;		//↓文字コードをutf-8に
			var url:URLRequest = new URLRequest("http://ms3.sub.jp/app-cgi/appCallFunc/getUserBan.php");
			url.method = URLRequestMethod.POST;//PHPへPOST送信
			
			//キャッシュを無効に
			url.cacheResponse = false;
			var header:URLRequestHeader = new URLRequestHeader("pragma", "no-cache");
			url.requestHeaders.push(header);
			
			//送る変数
			var variables:URLVariables 	= new URLVariables();
			variables.userId 			= escapeMultiByte(_userId);
			
			url.data = variables;
			
			var testloader = new URLLoader (url);
			if (!testloader.hasEventListener(Event.COMPLETE)) testloader.addEventListener(Event.COMPLETE , onGetUserAuth_cmdComplete);
			if (!testloader.hasEventListener(SecurityErrorEvent.SECURITY_ERROR)) testloader.addEventListener(SecurityErrorEvent.SECURITY_ERROR , onGetUserAuth_cmdSecurityError);
			if (!testloader.hasEventListener(IOErrorEvent.IO_ERROR)) testloader.addEventListener(IOErrorEvent.IO_ERROR, onGetUserAuth_cmdIOError);		
			testloader.dataFormat = URLLoaderDataFormat.VARIABLES;
			testloader.load(url);
			
			url = null;
			return true;
		}
		//送信完了したら
		private function onGetUserAuth_cmdComplete(e:Event):void {
			if (!_php_init) return;   //クラスを無効にするか否か
			var vars:URLVariables = new URLVariables( e.target.data );		//↓戻り値を変数に格納
			var outString:String = unescapeMultiByte(String(vars.out).replace(/^out=/, ""));
			
			//アプリの終了フラグを立てる
			if (outString == "1") {
				_this.appUseAuthAndProcessCmd(true);	//利用許可
			}else {
				_this.appUseAuthAndProcessCmd(false);	//利用禁止・アプリ終了
			}
		}
		//接続のエラーの場合は利用禁止とする。
		private function onGetUserAuth_cmdSecurityError(e:SecurityErrorEvent):void {
			if (!_php_init) return;   //クラスを無効にするか否か
			_this.appUseAuthAndProcessCmd(false);	//利用禁止・アプリ終了
		}
		private function onGetUserAuth_cmdIOError(e:IOErrorEvent):void {
			if (!_php_init) return;   //クラスを無効にするか否か
			_this.appUseAuthAndProcessCmd(false);	//利用禁止・アプリ終了
		}
		
		
		
		
		
		//**********************
		//SGリストの取得
		//**********************
		//SGリスト取得、値はthis.sgListに格納されます。
		public function getSGList():void {
			if (!_php_init) return;   //クラスを無効にするか否か
			System.useCodePage = false;		//↓文字コードをutf-8に
			var url:URLRequest = new URLRequest("http://ms3.sub.jp/app-cgi/appCallFunc/getSGList.php");
			url.method = URLRequestMethod.POST;//PHPへPOST送信
			
			//キャッシュを無効に
			url.cacheResponse = false;
			var header:URLRequestHeader = new URLRequestHeader("pragma", "no-cache");
			url.requestHeaders.push(header);
			
			//送る変数
			var variables:URLVariables 	= new URLVariables();
			variables.userInfo 			= escapeMultiByte("a");
			
			url.data = variables;
			
			var testloader = new URLLoader (url);
			if (!testloader.hasEventListener(Event.COMPLETE)) testloader.addEventListener(Event.COMPLETE , onLoad_getSGList_cmdComplete);
			
			testloader.dataFormat = URLLoaderDataFormat.VARIABLES;
			testloader.load(url);
			
			url = null;
		}
		private function onLoad_getSGList_cmdComplete(e:Event):void {
			if (!_php_init) return;   //クラスを無効にするか否か
			var vars:URLVariables = new URLVariables( e.target.data );		//↓戻り値を変数に格納
			var outString:String = unescapeMultiByte(String(vars.out).replace(/^out=/, ""));
			var xml = new XML(outString);
			
			_this.sgList = null;
			_this.sgList = new Array();
			for each (var property_t:XML in xml.list) {
				_this.sgList.push(property_t.id);
			}
			
			if(_this.sgList.length > 0)trace("get SGList["+_this.sgList.length+"] Success");
		}
		
		
		
		
		
		
		
		
		//-----------------------------------------------------------
		//
		//	活性度
		//
		//-----------------------------------------------------------
		//活性度結果入力
		public function mp3_chkListKekkaArr_push(inObj:Object):void {
			if (!_php_init) return;   //クラスを無効にするか否か
			_chkListKekkaArr.push(inObj);
		}
		//調査対象を取得
		public function checkActivityGet():Boolean {
			if (!_php_init) return false;   //クラスを無効にするか否か
			System.useCodePage = false;		//↓文字コードをutf-8に
			var url:URLRequest = new URLRequest("http://ms3.sub.jp/app-cgi/appCallFunc/getChkList.php");
			url.method = URLRequestMethod.POST;//PHPへPOST送信
			
			//キャッシュ設定
			url.cacheResponse = false;
			var header:URLRequestHeader = new URLRequestHeader("pragma", "no-cache");
			url.requestHeaders.push(header);
			
			//送る変数
			var variables:URLVariables 	= new URLVariables();
			variables.mes 				= escapeMultiByte("a");
			
			url.data = variables;
			
			var testloader = new URLLoader (url);
			if(!testloader.hasEventListener(Event.COMPLETE))testloader.addEventListener(Event.COMPLETE , onChkACtivityGetComplete);
			testloader.dataFormat = URLLoaderDataFormat.VARIABLES;
			testloader.load(url);
			
			url = null;
			return true;
		}
		//調査対象を取得したら、処理リストを作成。１つ目の解析を開始
		private function onChkACtivityGetComplete(e:Event):void {
			if (!_php_init) return;   //クラスを無効にするか否か
			var vars:URLVariables = new URLVariables( e.target.data );		//↓戻り値を変数に格納
			var outString:String = unescapeMultiByte(String(vars.out).replace(/^out=/, ""));
			
			var xml = new XML(outString);									//読み込んだ内容を元に，XMLデータを作成
			//trace( "xml:" + xml.list.id[0]);
			//trace( "xml:" + xml.list.(@no==0).id);
			
			//for each (var property_t:XML in xml.list) {
			//	trace(property_t.id + " : " + property_t.name + " : " + property_t.activity + " : " + property_t.startDate);
			//}
			//trace("------------------------------------");
			
			var eventRetObj:Object		= new Object();
			var chkListArr:Array 		= new Array();
			var activitySearchID:Array 	= new Array();
			_chkListKekkaArr = null;
			_chkListKekkaArr = new Array();		//初期化する
			
			var i:uint = 0;
			var hakkenCnt_arr:Array = new Array();
			hakkenCnt_arr = String(xml.hakkenCnt).split(",");
			if(xml.list){
				for each (var property:XML in xml.list) {
					//trace(property.id + " : " + property.name + " : " + property.activity + " : " + property.startDate);
					chkListArr.push( { id:property.id,
									name:property.name,
									activity:property.activity,
									startDate:property.startDate,
									lastDate:property.lastDate,
									hakkenCnt:hakkenCnt_arr[i]} );
					activitySearchID.push(property.id);					
					i++;
				}
			}
			
			//イベント発行。値を渡す。
			eventRetObj = {chkListArr:chkListArr,activitySearchID:activitySearchID};
			dispatchEvent(new ms3phpEvent(ms3phpEvent.CHK_ACT_LIST_GET , eventRetObj));
			
			hakkenCnt_arr = null;
		}
		//調査した結果をXMLにする。
		public function sendActivity(inActivitySearchId:Array):void {
			if (!_php_init) return;   //クラスを無効にするか否か
			var sendMes:String = "";
			
			if(_chkListKekkaArr.length > 0){
				sendMes += '<?xml version="1.0" encoding="UTF-8"?><deta><activityID>';
				sendMes += inActivitySearchId.toString();
				sendMes += '</activityID>';
				sendMes += '<activityList>';
				
				var traceMes:String = "";
				for (var i:uint = 0; i < _chkListKekkaArr.length; i++ ) {
					
					traceMes += safeReplaceXML(_chkListKekkaArr[i]["name"]) + " (id=" + _chkListKekkaArr[i]["id"] + ")"+"\n";
					
					sendMes += '<list no="'+String(i)+'">';
					sendMes += '<id>'+ _chkListKekkaArr[i]["id"] + '</id>';
					sendMes += '<name>'+ safeReplaceXML(_chkListKekkaArr[i]["name"]) + '</name>';
					sendMes += '<activity>'+ _chkListKekkaArr[i]["activity"] + '</activity>';
					sendMes += '<startDate>'+ _chkListKekkaArr[i]["startDate"] + '</startDate>';
					sendMes += '<activityAvgMonth>'+ _chkListKekkaArr[i]["activityAvgMonth"] + '</activityAvgMonth>';
					sendMes += '<activityAvgWeek>'+ _chkListKekkaArr[i]["activityAvgWeek"] + '</activityAvgWeek>';
					sendMes += '<AccuracyMonth>'+ _chkListKekkaArr[i]["AccuracyMonth"] + '</AccuracyMonth>';
					sendMes += '<AccuracyWeek>'+ _chkListKekkaArr[i]["AccuracyWeek"] + '</AccuracyWeek>';
					sendMes += '<comuCnt>' + _chkListKekkaArr[i]["comuCnt"] + '</comuCnt>';
					sendMes += '<isBan>'+ _chkListKekkaArr[i]["isBan"] + '</isBan>';
					sendMes += '<nextDate>'+ _chkListKekkaArr[i]["nextDate"] + '</nextDate>';
					sendMes += '<targetPriority>'+ _chkListKekkaArr[i]["targetPriority"] + '</targetPriority>';
					sendMes += '</list>';
				}
				sendMes += '</activityList></deta>';
				//trace("結果：\n"+traceMes);
				//trace("結果：\n"+sendMes);
				sendActivity_cmd(sendMes);
			}else {
				//trace("リスト無し");
			}
			
			function safeReplaceXML(inStr:String):String {
				var retStr:String = inStr;
				retStr = retStr.replace(/"/g,'”').replace(/</g,"＜").replace(/>/g,"＞").replace(/\//g,"／").replace(/=/g,"＝");
				return retStr;
			}
		}
		//調査結果XMLを送信
		private function sendActivity_cmd(inStr:String):void {
			if (!_php_init) return;   //クラスを無効にするか否か
			System.useCodePage = false;			//↓文字コードをutf-8に
			var url:URLRequest = new URLRequest("http://ms3.sub.jp/app-cgi/appCallFunc/setChkList.php");
			url.method = URLRequestMethod.POST;//PHPへPOST送信
			
			//キャッシュ設定
			url.cacheResponse = false;
			var header:URLRequestHeader = new URLRequestHeader("pragma", "no-cache");
			url.requestHeaders.push(header);
			
			//送る変数
			var variables:URLVariables 	= new URLVariables();
			variables.chkDeta 			= escapeMultiByte(inStr);
			
			url.data = variables;
			
			var testloader = new URLLoader (url);
			if(!testloader.hasEventListener(Event.COMPLETE))testloader.addEventListener(Event.COMPLETE , onSendActivity_cmdComplete);
			testloader.dataFormat = URLLoaderDataFormat.VARIABLES;
			testloader.load(url);
			
			url = null;
		}
		//送信完了したら
		private function onSendActivity_cmdComplete(e:Event):void {
			if (!_php_init) return;   //クラスを無効にするか否か
			var vars:URLVariables = new URLVariables( e.target.data );		//↓戻り値を変数に格納
			var outString:String = unescapeMultiByte(String(vars.out).replace(/^out=/, ""));
		}
		
	}
}