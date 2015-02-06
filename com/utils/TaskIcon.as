package com.utils {
	
	//タスクアイコンの処理
	
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
	
	public class TaskIcon{
		
		private var _stage:Stage;
		
		public function TaskIcon():void {
			
		}
		
		//最小化
		public function init(inStage:Stage):void{
			
			_stage = inStage;
			
			//読み込んだアイコンの設定
			var images:Array = [];
			var icon:File = File.applicationDirectory.resolvePath("_iconTask" + "\\16.png");
			var ldr:Loader = new Loader();
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaded);
			ldr.load(new URLRequest(icon.url));
			function onLoaded(event:Event):void
			{
				var bit:BitmapData = new BitmapData(16,16,true,0xFFFFFF);
				bit.draw(ldr);
				images.push(bit);
				NativeApplication.nativeApplication.icon.bitmaps = images;
			}
			
			// アイコンの設定
			//var imgArray:Array = new Array();
			//imgArray.push(new BitmapData(16, 16, true, 0xCCCCCC ));
			//imgArray.push(new BitmapData(128, 128, true, 0xCCCCCC ));
			//NativeApplication.nativeApplication.icon.bitmaps = imgArray;
			
			// メニューの設定
			var menu:NativeMenu = new NativeMenu();
       		var exitMenu = menu.addItem(new NativeMenuItem("Exit"));
			exitMenu.addEventListener(Event.SELECT, function(evt:Event) {
				_stage.nativeWindow.close();
			});
			
			
			var viewMenu = menu.addItem(new NativeMenuItem("view"));
			viewMenu.addEventListener(Event.SELECT, function(evt:Event) {
				restore_cmd();
			});
			
			
			if (NativeApplication.supportsDockIcon) {
				// Mac の場合
				var dockIcon:DockIcon
					= NativeApplication.nativeApplication.icon as DockIcon;
				dockIcon.menu = menu;
			} else if (NativeApplication.supportsSystemTrayIcon) { 
				// Windows の場合
				// ToolTip の設定。
				var trayIcon:SystemTrayIcon
					= NativeApplication.nativeApplication.icon as SystemTrayIcon;
				trayIcon.menu = menu;
				
				//trayIcon.tooltip = "最小化時にクリックすると表示されます";
				//trayIcon.addEventListener(MouseEvent.CLICK, restore);
			}
			
			//_closeBtn.addEventListener(MouseEvent.CLICK, onMouse_miniWindow);
		}
		
		private function restore(event:MouseEvent):void {
			restore_cmd();
		}
		private function restore_cmd():void {
			_stage.nativeWindow.restore();
			_stage.nativeWindow.visible = true;
		}
		
		private function onMouse_miniWindow(event:MouseEvent):void {
			miniWindow();
		}
		public function miniWindow():void{
			_stage.nativeWindow.minimize();
			_stage.nativeWindow.visible = false;
			setTimeout(notice, 3000);
		}
		
		private function notice():void{
			if (!_stage.nativeWindow.active) {
				if (NativeWindow.supportsNotification) {
					// Windows の場合
					_stage.nativeWindow.notifyUser(NotificationType.INFORMATIONAL);
				} else if (NativeApplication.supportsDockIcon) {
					var dockIcon:DockIcon
						= NativeApplication.nativeApplication.icon as DockIcon;
					dockIcon.bounce(NotificationType.INFORMATIONAL);
				}
			}
		}
		
	}
}