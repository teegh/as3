package com.print 
{ 
    import flash.printing.*;
    import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
 
    public class ImgPrint extends EventDispatcher 
    {
		private var _file:File;
		private var _stream:FileStream;
		private var _ldr:Loader;
		private var _thumb:Sprite;
		private var _prevStage:MovieClip;
		private var _H:uint = 0;		//ステージの幅
		private var _W:uint = 0;
		
        public function ImgPrint(inPrintImgFilePath:String , inPreviewStage:MovieClip):void {
			
			//プレビューの画面サイズを取得
			_W = inPreviewStage.width;
			_H = inPreviewStage.height;
			
			//ファイルパスから印刷
			fileReadImg(inPrintImgFilePath);
		}
		
		// (ファイルをブラウザで開く)
		private function openfile():void{
			_file = new File();
			_file.addEventListener(Event.SELECT , onSelected);
			_file.addEventListener(Event.CANCEL , onCancel);
			var filter = new FileFilter("画像ファイル(*.jpg)", "*.jpg;");
			try {
				_file.browseForOpen("ファイルの選択",[filter]);
			}catch (e:Error) {
				trace(e.message);
			}
		}
		
		// (ファイルをブラウザで開く場合)
		private function onSelected(e:Event):void {
			_stream = new FileStream();
			_stream.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_stream.addEventListener(Event.COMPLETE , onStreamComplete);
			_stream.openAsync(_file , FileMode.READ);
		}
		
		
		//ファイルパスから開く場合
		private function fileReadImg(inFilePath:String):void {
			var file:File = newe File(inFilePath);
			if(file.exists && checkKind(inFilePath)){
				_stream = new FileStream();
				_stream.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				_stream.addEventListener(Event.COMPLETE , onStreamComplete);
				_stream.openAsync(inFile , FileMode.READ);
			}
		}
		
		private function onStreamComplete(event:Event):void {
			var byteArr:ByteArray = new ByteArray();
			_ldr = new Loader();
			_ldr.contentLoaderInfo.addEventListener(Event.COMPLETE , onLoadComplete );
			
			try {
				_stream.readBytes(byteArr , 0 , _stream.bytesAvailable );
				_ldr.loadBytes(byteArr);
				
			}catch (error:Error) {
				quit();
			}finally {
				_stream.close();
			}
		}
		
		private function onLoadComplete(event:Event):void {
			
			_thumb = new Sprite();
			
			_thumb.addChild(_ldr);			//画像のLoaderオブジェクトを_thumbにaddchildする。
			_prevStage.addChild(_thumb);	//ステージに表示
			
			print();
		}	

        //印刷
        private function print():void {
            var pj:PrintJob	=	new PrintJob();
            var width:uint;
            var height:uint;
			
            if (pj.start()) {
				
				var isLandSCAPE:Boolean = false;
				
                //ランドスケープであるか確認
                if (pj.orientation == PrintJobOrientation.LANDSCAPE) {
                    isLandSCAPE = true;
                }
                
                try {
                    //印刷するSpriteのサイズを保持
                    width =_thumb.width;
                    height = _thumb.height;
					
					//印刷する向きに合わせてSpriteを回転
					var isRotate:Boolean = false;
					if ( ((width >= height) && !isLandSCAPE) || ((width <= height) && isLandSCAPE)) {
						isRotate = true;
						_thumb.rotation = 90;
						_thumb.x = height;
					}
					
					//印刷サイズに合わせる。
                    var w:Number = pj.pageWidth / _thumb.width;
                    var h:Number = pj.pageHeight / _thumb.height;
					var raito:Number = (w > h) ? w : h;
					_thumb.scaleX = _thumb.scaleY = w;
					_thumb.x = 0;
					
                    //印刷の実行
                    pj.addPage(_thumb);
                    pj.send();
                    
                    //サイズ・回転を戻す(表示向け)
                    _thumb.width 	= width;
                    _thumb.height 	= height;
					_thumb.rotation = 0;
					
                } catch (e:Error) {
					trace("エラーが発生しました。"+e.message);
                }
            }
        } 
		
		private function quit():void {
			trace("エラーが発生したため、アプリを終了します");
		}
		
		private function onCancel(event:Event):void {
			//quit();
		}
		
		private function onIOError(event:Error):void {
			//quit();
		}
		
		
		//拡張子チェック (＠dragEnterHandler)
		private function checkKind(filePath:String):Boolean{
			var kinds:Array=[".jpg", ".JPG"];																		//可能のある拡張子を登録
			var chkKind:String;
			var pattern:RegExp;
			var chkStr:String;
			for (var i:int=0; i<kinds.length; i++){
				chkKind	= kinds[i];
				pattern	= new RegExp(chkKind,"i");																//指定した拡張子の大文字・小文字の区分をなくす
				chkStr	= filePath.substr(filePath.length-chkKind.length,filePath.length);			//取得したファイル名から拡張子部分を抜き出す
				if(pattern.exec(chkStr) != null){
					kinds 		= null;
					chkKind 	= null;
					pattern 		= null;
					chkStr 		= null;
					return true;													//検索メソッドの実行(正規表現)。指定拡張子と一致するならtrueを返す。
				}
			}
			kinds 		= null;
			chkKind 	= null;
			pattern 	= null;
			chkStr 		= null;
			return false;																									//指定拡張子と不一致ならfalseを返す。
		}
    } 
}