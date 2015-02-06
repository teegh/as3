package com.utils {
	
	//文字変換メソッド集
	
	import com.googlecode.kanaxs.Kana;	//半角全角・かなカナ変換  ※com\_swc\kana-1.0.4.swcをライブラリパスに通す必要あり
	import flash.filesystem.*;

	
	//------------
	// 目次
	//------------
	//Stringをnew RegExp(String)にして使用させる為のStringスケープメソッド
	//CSV出力時に半角記号を""でエスケープした文字列を返す。
	//SQL入力時エラー回避する文字列に変換。　返り値は変換した文字、変換した文字の位置を示す文字
	//変換したSQL入力時エラー回避する文字列を復元する。
	//HTML出力時に影響の出る文字をエスケープします。
	//XML出力時に影響の出る文字をエスケープします。
	//一定の基準で、全角半角変換する
	//ファイルパスから、ファイル名の抽出
	//ファイルパスから、含んでいるディレクトリのファイルパスを返す。
		
		
	
	public class SafeStrReplace {
		
		public function SafeStrReplace():void{
			
		}
		
		//Stringをnew RegExp(String)にして使用させる為のStringスケープメソッド
		public function Rep_Encode_RegExpUseString(inString:String):String {
			
			var retStr:String = inString;
			
			//(変換処理)正規表現で用いるメタキャラクタをエスケープさせる
			// ￥()+[]'.^$?*{}|
			retStr = retStr.replace(/\\/g, "\\\\").replace(/\(/g, "\\(").replace(/\)/g, "\\)").replace(/\+/g, "\\+").replace(/\[/g, "\\[").replace(/\]/g, "\\]").replace(/\'/g, "\\'").replace(/\./g, "\\.").replace(/\^/g, "\\^").replace(/\$/g, "\\$").replace(/\?/g, "\\?").replace(/\*/g, "\\*").replace(/\{/g, "\\{").replace(/\}/g, "\\}").replace(/\|/g, "\\|");
			
			return retStr;
		}
		
		
		//CSV出力時に半角記号を""でエスケープした文字列を返す。
		public function Rep_Encode_csvExportUseString(inString:String):String {
			
			var retStr:String = inString;
			
			if( retStr.indexOf(",") != -1 || retStr.indexOf("\"") != -1 ){			
				//エスケープさせる。
				retStr = retStr.replace(/"/g, "\"\"");
				retStr = "\"" + retStr + "\"";
			}
			
			return retStr;
		}
		
		
		//SQL入力時エラー回避する文字列に変換。　返り値は変換した文字、変換した文字の位置を示す文字
		//「ファイル名@ESCAPEWORD_targetCol=n,n1,n2...」という形式で出力される。
		//,./~^|-=%$&#!*_][}{<>"\/;'\+ は入力できる。入力動作確認済み。
		public function Rep_sql(targetCol:String, repStrIN:String):Array{
			var repStr:String=repStrIN;												//[返り値]変換後の文字列
			var repPosStr:String = "";												//上記２値が格納される配列
			var returnArr:Array = new Array();
			
			var reg1:RegExp = /"/g;
			var reg2:RegExp = /'/g;
			var reg3:RegExp = /%/g;
			
			var regArr:Array=[ reg1 , reg2 , reg3];		//正規表現の文字を配列に格納
			var repArr:Array=["”", "’", "％"];											//変換後の文字を格納
			var result:Object;															//マッチングメソッドexceの返り値
			
			for(var i:uint=0; i<regArr.length; i++){
				var myPatternLp:RegExp=regArr[i];									//マッチングする値(gオプション：一致する回数まで繰り返しチェック)
				while( (result=regArr[i].exec(repStrIN)) != null){					//マッチングのする回数分、繰り返し処理
					if(repPosStr.indexOf("@ESCAPEWORD_"+targetCol+"=")==-1){		//escapeSeqに＠～を含まない場合、＠～を挿入。(＠～は区切り文字)
						repPosStr+="@ESCAPEWORD_"+targetCol+"=";
					}else{
						repPosStr+=",";												//区切り文字を挿入。
					}
					repPosStr+=String(result.index);								//マッチングする文字の位置を格納
				}
				repStr=repStr.replace(regArr[i], repArr[i]);						//文字の変換
			}
			returnArr = [repStr , repPosStr ];										//返り値の配列に格納
			return returnArr;
		}
		
		
		//半角スペースを%(SQLのワイルドカード)に変換
		public function Rep_spaceToPar(inString:String):String {
			var repStr:String = inString;
			repStr = repStr.replace(/ /g, "%");
			return repStr;
		}
		//変換したSQL入力時エラー回避する文字列を復元する。
		public function Rep_sql_Fukugen(targetCol:String, inRepStr:String, inEscapeStr:String):String {
			var returnStr:String = inRepStr;
			var repStrArr:Array = inEscapeStr.split("@ESCAPEWORD_" + targetCol + "=");
			if (repStrArr.length == 2) {
				repStrArr = repStrArr[1].split("@");
				repStrArr = repStrArr[0].split(",");
				
				var beforeStr:String 	= "";
				var repStr:String 		= "";
				var afterStr:String 	= "";
				var repPos:uint = 0;
				
				//変換した文字の位置をもとに、その位置の文字列を半角に変換する。
				for (var i:uint = 0; i < repStrArr.length; i++ ) {
					repPos = uint(repStrArr[i]);
					beforeStr 	= ""; 
					repStr 		= "";
					afterStr 	= "";
					
					if (repPos != 0) beforeStr = returnStr.substr(0, repPos);									//変換する文字の手前にある文字列を取り出す
					repStr = returnStr.substr(repPos,1).replace("”","\"").replace("’","'").replace("％","%");	//文字の変換 (復元)
					if (repPos != returnStr.length-1) afterStr = returnStr.substring(repPos+1);					//後半を取り出す
					
					returnStr = beforeStr + repStr + afterStr;
				}
				
				//解放
				beforeStr = null;
				repStr = null;
				afterStr = null;
				repPos = 0;
			}
			repStrArr.length = 0;
			
			return returnStr;
		}
		
		
		
		
		//HTML出力時に影響の出る文字をエスケープします。
		/*
			  	<　（右大なり） &lt; 
				>　（左大なり） &gt; 
				&　（アンパーサント） &amp; 
				"　（ダブルクォーテーション） &quot; 
		*/
		//http://ja.wikipedia.org/wiki/%E6%96%87%E5%AD%97%E5%8F%82%E7%85%A7
		public function Rep_Encode_htmlExportUseString(inString):String {
			
			var retStr:String = inString;
			
			//(変換処理)正規表現で用いるメタキャラクタをエスケープさせる
			retStr = retStr.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
			
			return retStr;
		}
		
		
		//XML出力時に影響の出る文字をエスケープします。
		/*
			  	<　（右大なり） &lt; 
				>　（左大なり） &gt; 
				&　（アンパーサント） &amp; 
				"　（ダブルクォーテーション） &quot; 
				'　 （シングルクォーテーション） &apos; 
		*/
		//http://ja.wikipedia.org/wiki/%E6%96%87%E5%AD%97%E5%8F%82%E7%85%A7
		public function Rep_Encode_xmlExportUseString(inString):String {
			
			var retStr:String = inString;
			
			//(変換処理)正規表現で用いるメタキャラクタをエスケープさせる
			retStr = retStr.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/\'/g, "&apos;");
			
			return retStr;
		}
		
		//一定の基準で、全角半角変換する
		public function Rep_Kana(inString:String):String {
			//曲の検索などの都合上、すべて一定の基準で全角半角変換する
			//全角→半角英数、半角カナ→全角カナ　に変換
			
			//①全角→半角英数
			var kana:Kana = new Kana(inString);		//com.googlecode.kanaxs.Kana(swcファイル)　の Kanaオブジェクト
			kana.toHankakuCase();
			//②半角カナ→全角カナ変換
			kana = new Kana(kana.toString());
			kana.toZenkanaCase();
			//③は゛→ば変換
			kana = new Kana(kana.toString());
			kana.toPaddingCase();
			
			return kana.toString();
		}
		
		
		//ファイルパスから、ファイル名の抽出
		public function Rep_FileName(inNativePath:String):String {
			//[参考 ファイル番号の除去]　.replace(/^[0-9][0-9] - /, "")
			var retStr:String			= "";
			var filePathSplArr:Array 	= inNativePath.split("\\");
			//var fileName:String 		= fileNameSplArr[fileNameSplArr.length -1].replace(/\..+$/, "");
			
			var fileName:String			= filePathSplArr[filePathSplArr.length -1];
			var fileNameSplArr:Array 	= fileName.split(".");
			for (var i:uint = 0; i < fileNameSplArr.length - 1; i++ ) {
				if (retStr != "") retStr += ".";
				retStr += fileNameSplArr[i];
			}
			
			if (retStr == "") {
				retStr = fileName;
			}
			
			return retStr;
		}
		
		
		//ファイルパスから、拡張子の抽出
		public function Rep_FileKind(inNativePath:String):String {
			//[参考 ファイル番号の除去]　.replace(/^[0-9][0-9] - /, "")
			var retStr:String			= "";
			var filePathSplArr:Array 	= inNativePath.split("\\");
			//var fileName:String 		= fileNameSplArr[fileNameSplArr.length -1].replace(/\..+$/, "");
			
			var fileName:String			= filePathSplArr[filePathSplArr.length -1];
			var fileNameSplArr:Array 	= fileName.split(".");
			
			if (fileNameSplArr.length > 0) {
				retStr = fileNameSplArr[fileNameSplArr.length - 1];
			}
			
			return retStr;
		}
		
		
		//ファイルパスから、含んでいるディレクトリのファイルパスを返す。 例： c:\else\file.txt -> c:\else
		public function Rep_FilePath_ContainingFolderPath(inNativePath:String):String {
			
			var readFile:File = new File(inNativePath);
			var retStr:String			= inNativePath;
			
			if(readFile.exists){
				if (!readFile.isDirectory) {
					var filePathSplArr:Array 	= inNativePath.split("\\");
					var fileName:String			= filePathSplArr[filePathSplArr.length -1];
					retStr = retStr.replace(fileName,"");
				}
			}
			
			return retStr;
		}
	}
	
}