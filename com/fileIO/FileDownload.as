package com.fileIO {
	
    import flash.events.*;
    import flash.net.FileReference;
    import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import com.fileIO.FileDownloadEvent;
	import flash.utils.ByteArray;
	import flash.filesystem.*;

    public class FileDownload extends EventDispatcher{
		
		private var theUrl:URLRequest;
		private var loader:URLLoader;
		private var saveFilePath:String = "";

        public function FileDownload() {
			
        }
		
        public function startDownload(inUrl:String, inSavePath:String):void {
			
			theUrl = new URLRequest(inUrl);		//ダウンロードURL
			saveFilePath = inSavePath;				//保存先ファイルパス(絶対パス)
			
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE , onComplete );
			
			//loader.addEventListener(Event.OPEN, openHandler);
            //loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			//loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);

			loader.load(theUrl);
        }

		private function onComplete(e:Event):void{
			
			if(saveFilePath != null && saveFilePath != ""){
				//ファイルを保存
				var settingFile:File = new File( saveFilePath );						//保存するファイルディレクトリを元にファイルを作成
				var stream : FileStream = new FileStream();						//ファイルストリームオブジェクト作成
				stream.open (settingFile, FileMode.WRITE);							//オープン。ファイル名はnew_file, ファイルモードは「追記」
				stream.writeBytes(loader.data, 0, loader.data.bytesAvailable);				//ストリングオブジェクトをshift-jisで書き出す
				stream.close();
				stream = null;
			}
			//イベント発行
			dispatchEvent(new FileDownloadEvent( FileDownloadEvent.FILEDOWNLOAD_COMPLETE, loader.data));
			
			//解放
			loader.removeEventListener(Event.COMPLETE , onComplete );
			releaseObj();
		}
		
		/*
		private function openHandler(e:Event):void{
			e.target.removeEventListener(Event.OPEN, openHandler);
			trace("openHandler");
		}
        private function progressHandler(e:ProgressEvent):void{
			e.target.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
			trace("progressHandler");
		}
		private function httpStatusHandler(e:HTTPStatusEvent):void{
			e.target.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			trace("httpStatusHandler");
		}
		*/
		
		private function securityErrorHandler(e:SecurityErrorEvent):void{
			e.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			releaseObj();
			
			//イベント発行
			dispatchEvent(new FileDownloadEvent( FileDownloadEvent.FILEDOWNLOAD_FAILED, null));
			
			trace("securityErrorHandler");
		}
		
		private function ioErrorHandler(e:IOErrorEvent):void{
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			releaseObj();
			
			//イベント発行
			dispatchEvent(new FileDownloadEvent( FileDownloadEvent.FILEDOWNLOAD_FAILED, null));
			
			trace("ioErrorHandler");
		}
		
		
		private function releaseObj():void{
			loader = null;
			theUrl = null;
			saveFilePath = null;
		}
    }
}