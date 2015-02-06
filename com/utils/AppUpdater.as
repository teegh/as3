package com.utils {	
	
	//アップデートを確認するクラス
	
	//import flash.data.EncryptedLocalStore;		//暗号化されたローカルストア
	import flash.desktop.*;
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	//import flash.html.*;
	import flash.net.*;
	//import flash.system.System;
	//import flash.text.*;
	import flash.utils.*;
	//import flash.ui.*;
	import air.update.events.*;							//アップデートクラス
	import air.update.ApplicationUpdater;				//事前にapplicationupdater_ui.swcへのライブラリパスを通す必要あり。
	
	
	public class AppUpdater{
		
		private var _this:webKitTest;
		private const _xmlFilePath:String = "app:/config/updaterConfig.xml";
		private const _exeFilePath:String = "ms3.sub.jp/appFile/webKitTest.exe";
		private var _updateDisp:MovieClip;
		private var stage:Stage;
		private var _updater:ApplicationUpdater = new ApplicationUpdater();
		
		public function AppUpdater():void {
			
		}
		
		public function init_update(inThis:webKitTest, inStage:Stage , inUpdateDisp:MovieClip):void {
			
			_this = inThis;
			stage = inStage;
			_updateDisp = inUpdateDisp;
			
			//アプリケーションのアップデート情報を記載したXML
			_updater.configurationFile = new File(_xmlFilePath);
			
			//初期化した後の処理
			_updater.addEventListener(UpdateEvent.INITIALIZED , onUpdaterInti);	
			_updater.addEventListener(StatusUpdateEvent.UPDATE_STATUS, onUpdateStatus);
			//_updater.addEventListener(UpdateEvent.BEFORE_INSTALL, onBeforeInstall );
			//_updater.addEventListener(UpdateEvent.CHECK_FOR_UPDATE , onCheckForUpdate );
			//_updater.addEventListener(UpdateEvent.DOWNLOAD_COMPLETE, onDownloadComp );
			//_updater.addEventListener(UpdateEvent.DOWNLOAD_START , onDownloadStart);
			//_updater.addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR , onDownloadError);
			
			_updater.initialize();
		}
		
		private function onUpdaterInti(e:UpdateEvent):void {
			_updater.checkNow();																	//アップデートの確認を行う
		}
		private function onUpdateStatus(event:StatusUpdateEvent):void{
			//アプリケーションの更新が必要である場合
			if( event.available){
				//var _updateDisp:UpdateDisp = new UpdateDisp();
				_updateDisp.x = _updateDisp.y = 0.0;
				_updateDisp._white.alpha = 0.0;
				_updateDisp._back.width = stage.stageWidth;
				_updateDisp._back.height = stage.stageHeight;
				_updateDisp._white.width = stage.stageWidth;
				_updateDisp._white.height = stage.stageHeight;
				_updateDisp._mes.text = event.details.toString();
				_updateDisp._btn.addEventListener(MouseEvent.CLICK, openUpdateFile);
				_updateDisp._btn.addEventListener(MouseEvent.MOUSE_OVER, whiteIn);
				_updateDisp._btn.addEventListener(MouseEvent.MOUSE_OUT, whiteOut);
				_updateDisp._btn.addEventListener(MouseEvent.ROLL_OUT, whiteOut);
				
				_this.addChild(_updateDisp);
				
				var _exitTimer:Timer = new Timer(15* 1000, 1);
				_exitTimer.addEventListener(TimerEvent.TIMER_COMPLETE , exitCmd);
				
				function whiteIn(e:MouseEvent):void {
					_updateDisp._white.alpha = 0.5;
				}
				function whiteOut(e:MouseEvent):void {
					_updateDisp._white.alpha = 0.0;
				}
				function openUpdateFile(e:MouseEvent):void{
					var urlReq:URLRequest = new URLRequest("http://"+_exeFilePath);
					
					urlReq.cacheResponse = false;
					var header:URLRequestHeader = new URLRequestHeader("pragma", "no-cache");
					urlReq.requestHeaders.push(header);
					//urlReq.manageCookies = false;
					
					navigateToURL(urlReq);
					_exitTimer.start();
				}
				function exitCmd(e:TimerEvent):void {
					stage.nativeWindow.close();
				}
			}
		}
		
	}
}