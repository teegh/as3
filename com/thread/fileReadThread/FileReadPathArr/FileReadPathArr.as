package com.thread.fileReadThread.FileReadPathArr {
	
	//入力されたファイルディレクトリと読み込み画面から、ファイルをすべて読み込み、
	//読み込んだファイルパスを配列(Vector.<String>)として出力するクラス。
	
	import flash.events.EventDispatcher;
	import flash.display.MovieClip;
	import com.thread.fileReadThread.FileReadThController.FileReadThController;
	import com.thread.fileReadThread.FileReadThController.FileReadThControllerEvent;
    import comApp.DBController.DBController;
	import com.thread.fileReadThread.FileReadPathArr.FileReadPathArrEvent;
	import com.utils.SafeStrReplace;

    public class FileReadPathArr extends EventDispatcher{

		private var _db_controller:DBController = new DBController("fileName", "fileName" );
		private var _loadDir:String = "";
		private var _disp:MovieClip;
		private var _pathArr:Vector.<String> = new Vector.<String>();
		private var _safeRep:SafeStrReplace = new SafeStrReplace();
		
        public function FileReadPathArr(inLoadDirectory:String, inLoadDisp:MovieClip) {
			_loadDir 	= inLoadDirectory;
			_disp		= inLoadDisp;
        }
		
		
		public function startLoad():void {
			//ファイルの読み込みのテスト
			var fileReadThCtrl:FileReadThController = new FileReadThController(_loadDir, _disp);
			fileReadThCtrl.addEventListener(FileReadThControllerEvent.FileRead_Complete , onComplete_readFileTh);
			fileReadThCtrl.start();
		}
		
		private function onComplete_readFileTh(e:FileReadThControllerEvent):void {
			e.target.removeEventListener(FileReadThControllerEvent.FileRead_Complete , onComplete_readFileTh);
			loadSQL();
		}
		
		private function loadSQL():void {
			var selObj:Object = _db_controller.selectAll();
			//trace("現在のDB件数： " + selObj.length);
			for (var i:uint = 0; i < selObj.length; i++ ) {
				_pathArr[i] = _safeRep.Rep_sql_Fukugen("filePath", selObj[i]["filePath"], selObj[i]["escapeSeq"]);
			}
			_db_controller.deleteAll();
			
			//イベント発行
			dispatchEvent(new FileReadPathArrEvent( FileReadPathArrEvent.FILE_LOAD_COMPLETE, _pathArr));
		}
		
		/*
		public function get loadfilePathArr():Array {
			return _pathArr;
		}
		*/
    }
}