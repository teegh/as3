package com.org.utils {
	
	import flash.filesystem.*;
	import com.org.utils.SafeStrReplace;
	
	//CSVの処理をまとめたクラス
	
	public class CSV{
		
		private var _csvTitleCol:Array = new Array();	//ｃｓｖの見出しとなる行
		private var writeStringCol:String = "";
		private var writeStringTitleCol:String = "";
		private var repCSV:SafeStrReplace = new SafeStrReplace();
		
		public function CSV(... inCSV_Title_Col):void{
			titleCol(inCSV_Title_Col);
		}
		
		public function titleCol(inCSV_Title_Col:Array):void {
			writeStringCol = "";
			_csvTitleCol = inCSV_Title_Col;
			for (var i:uint = 0; i < _csvTitleCol.length; i++ ) {
				if (writeStringTitleCol != "") writeStringTitleCol += ",";
				writeStringTitleCol += repCSV.Rep_Encode_csvExportUseString(_csvTitleCol[i]);
			}
			writeStringCol += "\r\n";
		}
		
		public function addCol(... inCol):void{
			if (_csvTitleCol.length != inCol.length) return;
			for (var i:uint = 0; i < inCol.length; i++ ) {
				if (i != 0) writeStringCol += ",";
				writeStringCol += repCSV.Rep_Encode_csvExportUseString(inCol[i]).replace(/\r/g,"").replace(/\n/g,"");
			}
			writeStringCol += "\r\n";
		}
		
		public function exportFile(inFileName:String):void {
			if (writeStringCol == "") return
			var desktop_file : File = File.desktopDirectory;								// デスクトップのファイルパスを取得する
			var now:Date=new Date();														//現在の日付を取得
			var new_file : File = desktop_file.resolvePath( inFileName +"(" + String(now.month + 1) + "月" + String(now.date) + "日 " + String(now.hours) + "時" + String(now.minutes) + "分)" + ".csv");		// デスクトップから相対パスを指定して新しいファイルパスを取得する
			
			var stream : FileStream = new FileStream();										//ファイルストリームオブジェクト作成
			stream.open (new_file, FileMode.WRITE);											//オープン。ファイル名はnew_file
			stream.writeMultiByte(writeStringTitleCol + writeStringCol, "shift_jis");		//ストリングオブジェクトをshift_jisで書き出す
			stream.close();
		}
	}
	
}