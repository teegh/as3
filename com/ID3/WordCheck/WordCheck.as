//入力された情報が適切な文字であるか判定するクラス
package com.ID3.WordCheck
{
	import com.googlecode.kanaxs.Kana;	//半角全角・かなカナ変換
	import com.gusen.utils.SafeStrReplace;	//安全文字変換クラス
	
	public class WordCheck
	{
		
		private var kana:Kana;
		private const unicodeSpaceReg:RegExp = new RegExp("[" 
		+ String.fromCharCode(0x2002)
		+ String.fromCharCode(0x2003)
		+ String.fromCharCode(0x2004)
		+ String.fromCharCode(0x2005)
		+ String.fromCharCode(0x2009)
		+ String.fromCharCode(0x2006)
		+ String.fromCharCode(0x2007)
		+ String.fromCharCode(0x2008)
		+ String.fromCharCode(0x200A)
		+ String.fromCharCode(0x200B)
		+ String.fromCharCode(0x3000)
		+ String.fromCharCode(0xFEFF)
		+ String.fromCharCode(0x0009)
		+ "]", "g");
		//↑特殊なスペース(http://ja.wikipedia.org/wiki/%E3%82%B9%E3%83%9A%E3%83%BC%E3%82%B9)
		
		public function WordCheck():void
		{
			
		}
		
		//mp3タグの情報が空欄であるかチェックする。	
		public function check_id3Tag_nullStr(inString:String):String {
			//空欄チェック
			if (inString == "") {
				return "<div class=\"errorMes\"><div class=\"errorMes_info\">　　→空欄です。内容を入力して下さい。</div></div>\n";
			}else {
				return "";
			}
		}
		
		//mp3タグの情報が正しい入力値であるかチェックする。	
		public function check_id3Tag(inString:String , isChkNullStr:Boolean):String{
			
			//空欄チェック
			if (isChkNullStr && inString == "") {
				return "<div class=\"errorMes\"><div class=\"errorMes_info\">　　→空欄です。曲情報を入力して下さい。</div></div>\n";
			}
			
			var errorMesStr:String = "";
			
			//チェックする文字パターン
			var patternArr:Array = new Array();
			
			//除外記号：ⅰⅱⅲⅳⅴⅵⅶⅷⅸⅹⅠⅡⅢⅣⅤⅥⅦⅧⅨⅩ
			patternArr.push(/[)(=･"!#$%\\*+\/:;<>?@[\]^_`{|}~｡｢｣､]/g);		//半角記号。チェック除外文字：',.&-
			patternArr.push(/[１２３４５６７８９ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ]/g);
			patternArr.push(/^[0-9][0-9] - /g);
			patternArr.push(/…/g);
			patternArr.push(/[＆‐―－’，．]/g);			//全角記号
			patternArr.push(/(^[ 　])|([ 　]$)/g);	//前後の空白
			patternArr.push(unicodeSpaceReg);		//unicodeの幅なしスペース(U+200B)などの特殊スペース
			patternArr.push(/[①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳㍉㌔㌢㍍㌘㌧㌃㌶㍑㍗㌍㌦㌣㌫㍊㌻㎜㎝㎞㎎㎏㏄㎡㍻〝〟№㏍℡㊤㊥㊦㊧㊨㈱㈲㈹㍾㍽㍼≒≡∫∮∑√⊥∠∟⊿∵∩∪]/g);
			patternArr.push(/[纊褜鍈銈蓜俉炻昱棈鋹曻彅丨仡仼伀伃伹佖侒侊侚侔俍偀倢俿倞偆偰偂傔僴僘兊兤冝冾凬刕劜劦勀勛匀匇匤卲厓厲叝﨎咜咊咩哿喆坙坥垬埈埇﨏塚增墲夋奓奛奝奣妤妺孖寀甯寘寬尞岦岺峵崧嵓﨑嵂嵭嶸嶹巐弡弴彧德忞恝悅悊惞惕愠惲愑愷愰憘戓抦揵摠撝擎敎昀昕昻昉昮昞昤晥晗晙]/g);
			patternArr.push(/[晴晳暙暠暲暿曺朎朗杦枻桒柀栁桄棏﨓楨﨔榘槢樰橫橆橳橾櫢櫤毖氿汜沆汯泚洄涇浯涖涬淏淸淲淼渹湜渧渼溿澈澵濵瀅瀇瀨炅炫焏焄煜煆煇凞燁燾犱犾猤猪獷玽珉珖珣珒琇珵琦琪琩琮瑢璉璟甁畯皂皜皞皛皦益睆劯砡硎硤硺礰礼神祥禔福禛竑竧靖竫箞精絈絜綷綠緖繒罇羡羽茁荢荿菇]/g);
			patternArr.push(/[菶葈蒴蕓蕙蕫﨟薰蘒﨡蠇裵訒訷詹誧誾諟諸諶譓譿賰賴贒赶﨣軏﨤逸遧郞都鄕鄧釚釗釞釭釮釤釥鈆鈐鈊鈺鉀鈼鉎鉙鉑鈹鉧銧鉷鉸鋧鋗鋙鋐﨧鋕鋠鋓錥錡鋻﨨錞鋿錝錂鍰鍗鎤鏆鏞鏸鐱鑅鑈閒隆﨩隝隯霳霻靃靍靏靑靕顗顥飯飼餧館馞驎髙髜魵魲鮏鮱鮻鰀鵰鵫鶴鸙黑ⅰⅱⅲⅳⅴⅵⅶⅷⅸ]/g);
			patternArr.push(/[ⅹ￢￤＇＂￢￤＇＂㈱№㏍℡]/g);
			
			var resultObj:Object;
			var tempSplStr:String = "";
			var inHighLightedString:String = inString; //エラーの箇所を着色しハイライトした文字
			var inReplacedString:String = inString; //エラーの箇所を変換、又はハイライトした文字
			var tempRepReg:RegExp;
			var isHighLightReplaced:Boolean = false;
			var safeRep:SafeStrReplace = new SafeStrReplace();
			
			//パターンと一致する文字が存在するかどうかチェック
			for(var i:uint=0; i<patternArr.length; i++){
				//= patternArr[i].exec(inString);
				while ( (resultObj = patternArr[i].exec(inString)) != null) {
					isHighLightReplaced = false;
					if (resultObj != null) {
						if (i == 0) {
							//置き換えるべき文字を示す。kanaクラスで変換できない記号はreplaceメソッドで変換。
							kana = new Kana(String(resultObj));
							tempSplStr = kana.toZenkakuCase().toString().replace("｡", "。").replace("｢", "「").replace("｣", "」").replace("､", "、").replace("･", "・").replace("＂", "”").replace("＼", "￥");
							errorMesStr += "<div class=\"errorMes_info\">　　→ 「" + safeRep.Rep_Encode_htmlExportUseString(String(resultObj)) + "」(位置:" + (resultObj.index + 1 < 10 ? " " : "") + String(resultObj.index + 1) + ") は半角記号です。全角「" + tempSplStr +"」に置き換えてください。</div>\n";
							inReplacedString = inReplacedString.replace( String(resultObj) , "●spanSS●" + tempSplStr + "●spanSE●");
						}else if (i == 1) {
							//置き換えるべき文字を示す。kanaクラスで変換できない記号はreplaceメソッドで変換。
							kana = new Kana(String(resultObj));
							tempSplStr = kana.toHankakuCase().toString();
							errorMesStr += "<div class=\"errorMes_info\">　　→ 「" + String(resultObj) + "」(位置:" + (resultObj.index + 1 < 10 ? " " : "") + String(resultObj.index + 1) + ") は全角英数字です。半角「" + tempSplStr + "」に置き換えてください。</div>\n";
							inReplacedString = inReplacedString.replace( String(resultObj) , "●spanSS●" + tempSplStr + "●spanSE●");
						}else if (i == 2){
							errorMesStr += "<div class=\"errorMes_info\">　　→ 「"+String(resultObj)+"」(位置:"+(resultObj.index+1 < 10 ? " " : "") + String(resultObj.index+1)+") は曲番号が入っている可能性があります。</div>\n";
						}else if (i == 3) {
							tempSplStr = "・・・";
							errorMesStr += "<div class=\"errorMes_info\">　　→ 「" + String(resultObj) + "」(位置:" + (resultObj.index + 1 < 10 ? " " : "") + String(resultObj.index + 1) + ") は「"+tempSplStr+"」(中点３つ)に置き換えてください。</div>\n";
							inReplacedString = inReplacedString.replace( String(resultObj) , "●spanSS●" + tempSplStr + "●spanSE●");
						}else if (i == 4) {
							//置き換えるべき文字を示す。kanaクラスで変換できない記号はreplaceメソッドで変換。
							tempSplStr = String(resultObj).replace("＆", "&").replace("‐", "-").replace("―", "-").replace("－", "-").replace("’", "'").replace("，", ",").replace("．", ".");
							errorMesStr += "<div class=\"errorMes_info\">　　→ 「" + String(resultObj) + "」(位置:" + (resultObj.index + 1 < 10 ? " " : "") + String(resultObj.index + 1) + ") は全角記号です。半角「" + tempSplStr + "」に置き換えてください。</div>\n";
							inReplacedString = inReplacedString.replace( String(resultObj) , "●spanSS●" + tempSplStr + "●spanSE●");							
						}else if (i == 5){
							errorMesStr += "<div class=\"errorMes_info\">　　→ 「" + String(resultObj[0]) + "」(位置:" + (resultObj.index + 1) + ") に空白が入っています。<br>　　   曲情報の前後にある空白は削除してください。</div>\n";
							inHighLightedString = inHighLightedString.replace(/(^[ 　])|([ 　]$)/, "●spanES●●BS●" + "_" + "●BE●●spanEE●");
							isHighLightReplaced = true;
							inReplacedString = inReplacedString.replace( /(^[ 　])|([ 　]$)/g , "");
						}else if (i == 6){
							errorMesStr += "<div class=\"errorMes_info\">　　→ 「" + String(resultObj) + "」(位置:" + (resultObj.index + 1) + ") に特殊なスペースが入っています。<br>　　   削除してください。(<a href=\"http://ja.wikipedia.org/wiki/%E3%82%B9%E3%83%9A%E3%83%BC%E3%82%B9\">詳細</a>)</div>\n";
							inHighLightedString = inHighLightedString.replace(String(resultObj), "●spanES●●BS●" + "_" + "●BE●●spanEE●");
							isHighLightReplaced = true;
							inReplacedString = inReplacedString.replace( String(resultObj) , "");
						}else if (i >= 7){
							errorMesStr += "<div class=\"errorMes_info\">　　→ 「" + String(resultObj) + "」(位置:" + (resultObj.index + 1 < 10 ? " " : "") + String(resultObj.index + 1) + ") は機種依存文字です。<br>　　   閲覧者の環境が異なると、文字化けして正しく表示されません。<br>　　   なるべく別の同義文字に置換してください。(<a href=\"http://www.d-toybox.com/studio/lib/romanNumerals.html\">詳細</a>)</div>\n";
							tempRepReg = null;
							tempRepReg = new RegExp(safeRep.Rep_Encode_RegExpUseString(String(resultObj)),"g");
							inReplacedString = inReplacedString.replace( tempRepReg , "●spanWS●" + String(resultObj) + "●spanWE●");
						}
						
						//エラーの箇所をハイライトする。
						tempRepReg = null;
						tempRepReg = new RegExp(safeRep.Rep_Encode_RegExpUseString(String(resultObj)),"g");
						if (!isHighLightReplaced) inHighLightedString = inHighLightedString.replace(tempRepReg, "●spanES●" + String(resultObj) + "●spanEE●");
						inHighLightedString = inHighLightedString.replace(/●spanES●●spanES●/g , "●spanES●").replace(/●spanEE●●spanEE●/g , "●spanEE●");
						
						//タグが重複している場合は1つにまとめる
						inReplacedString = inReplacedString.replace(/●spanWS●●spanWS●/g , "●spanWS●").replace(/●spanWE●●spanWE●/g , "●spanWE●").replace(/●spanSS●●spanSS●/g , "●spanSS●").replace(/●spanSE●●spanSE●/g , "●spanSE●");
					}
				}
			}
			
			//エラー箇所のハイライトを加える
			if (inHighLightedString != inString) {
				
				//記号を参照文字に変換
				inHighLightedString = safeRep.Rep_Encode_htmlExportUseString(inHighLightedString);
				inReplacedString = safeRep.Rep_Encode_htmlExportUseString(inReplacedString);
				
				//htmlタグに変換
				inHighLightedString = inHighLightedString.replace(/●spanES●/g , "<span class=\"error\">").replace(/●spanEE●/g , "</span>").replace(/●BS●/g , "<b>").replace(/●BE●/g , "</b>");
				inReplacedString = inReplacedString.replace(/●spanWS●/g , "<span class=\"warningWord\">").replace(/●spanSS●/g , "<span class=\"safeWord\">").replace(/●spanWE●/g , "</span>").replace(/●spanSE●/g , "</span>");
				errorMesStr = "<div class=\"shuseimae\">　　修正前：" + inHighLightedString +"</div>\n<div class=\"shuseigo\">　　修正後：" + inReplacedString +"</div>\n\n" + errorMesStr;
			}
			
			//エラーメッセージを返す。
			if (errorMesStr != "") errorMesStr = "<div class=\"errorMes\">" + errorMesStr + "</div>";
			
			//解放
			patternArr = null;
			inHighLightedString = null;
			inReplacedString = null;
			tempSplStr = null;
			resultObj = null;
			tempRepReg = null;
			safeRep = null;
			
			return errorMesStr;
		}
		
		
		//mp3タグの年代情報チェック。	
		public function check_id3Tag_year(inString:String):String{
			
			//空欄チェック
			if (inString == "") {
				return "<div class=\"errorMes_info\">　　→空欄です。内容を入力して下さい。</div>\n";
			}
			
			var errorMesStr:String = "";
			
			//チェックする文字パターン (チェック除外文字：/)
			var patternArr:Array = new Array();
			
			//除外記号：ⅰⅱⅲⅳⅴⅵⅶⅷⅸⅹⅠⅡⅢⅣⅤⅥⅦⅧⅨⅩ
			patternArr.push(/[\',.\-()&=･"!#$%\\*+:;<>?@[\]^_`{|}~｡｢｣､／.]/g);
			patternArr.push(/[１２３４５６７８９ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ]/g);
			patternArr.push(/…/g);
			patternArr.push(/[＆‐―－]/g);			//全角記号
			patternArr.push(/(^[ 　])|([ 　]$)/g);	//前後の空白
			patternArr.push(unicodeSpaceReg);		//unicodeの幅なしスペース(U+200B)などの特殊スペース
			patternArr.push(/[①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳㍉㌔㌢㍍㌘㌧㌃㌶㍑㍗㌍㌦㌣㌫㍊㌻㎜㎝㎞㎎㎏㏄㎡㍻〝〟№㏍℡㊤㊥㊦㊧㊨㈱㈲㈹㍾㍽㍼≒≡∫∮∑√⊥∠∟⊿∵∩∪]/g);
			patternArr.push(/[纊褜鍈銈蓜俉炻昱棈鋹曻彅丨仡仼伀伃伹佖侒侊侚侔俍偀倢俿倞偆偰偂傔僴僘兊兤冝冾凬刕劜劦勀勛匀匇匤卲厓厲叝﨎咜咊咩哿喆坙坥垬埈埇﨏塚增墲夋奓奛奝奣妤妺孖寀甯寘寬尞岦岺峵崧嵓﨑嵂嵭嶸嶹巐弡弴彧德忞恝悅悊惞惕愠惲愑愷愰憘戓抦揵摠撝擎敎昀昕昻昉昮昞昤晥晗晙]/g);
			patternArr.push(/[晴晳暙暠暲暿曺朎朗杦枻桒柀栁桄棏﨓楨﨔榘槢樰橫橆橳橾櫢櫤毖氿汜沆汯泚洄涇浯涖涬淏淸淲淼渹湜渧渼溿澈澵濵瀅瀇瀨炅炫焏焄煜煆煇凞燁燾犱犾猤猪獷玽珉珖珣珒琇珵琦琪琩琮瑢璉璟甁畯皂皜皞皛皦益睆劯砡硎硤硺礰礼神祥禔福禛竑竧靖竫箞精絈絜綷綠緖繒罇羡羽茁荢荿菇]/g);
			patternArr.push(/[菶葈蒴蕓蕙蕫﨟薰蘒﨡蠇裵訒訷詹誧誾諟諸諶譓譿賰賴贒赶﨣軏﨤逸遧郞都鄕鄧釚釗釞釭釮釤釥鈆鈐鈊鈺鉀鈼鉎鉙鉑鈹鉧銧鉷鉸鋧鋗鋙鋐﨧鋕鋠鋓錥錡鋻﨨錞鋿錝錂鍰鍗鎤鏆鏞鏸鐱鑅鑈閒隆﨩隝隯霳霻靃靍靏靑靕顗顥飯飼餧館馞驎髙髜魵魲鮏鮱鮻鰀鵰鵫鶴鸙黑ⅰⅱⅲⅳⅴⅵⅶⅷⅸ]/g);
			patternArr.push(/[ⅹ￢￤＇＂￢￤＇＂㈱№㏍℡]/g);
			
			var resultObj:Object;
			var safeRep:SafeStrReplace = new SafeStrReplace();
			
			//パターンと一致する文字が存在するかどうかチェック
			for(var i:uint=0; i<patternArr.length; i++){
				//= patternArr[i].exec(inString);
				while( (resultObj = patternArr[i].exec(inString)) != null){
					if(resultObj != null){
						if(i == 0){
							errorMesStr += "<div class=\"errorMes_info\">　　→ 「"+safeRep.Rep_Encode_htmlExportUseString(String(resultObj))+"」(位置:"+(resultObj.index+1 < 10 ? " " : "") + String(resultObj.index+1)+") が含まれています。削除してください。</div>\n";
						}else if(i == 1){
							errorMesStr += "<div class=\"errorMes_info\">　　→ 「"+String(resultObj)+"」(位置:"+(resultObj.index+1 < 10 ? " " : "") + String(resultObj.index+1)+") が含まれています。削除してください。</div>\n";
						}else if(i == 2){
							errorMesStr += "<div class=\"errorMes_info\">　　→ 「"+String(resultObj)+"」(位置:"+(resultObj.index+1 < 10 ? " " : "") + String(resultObj.index+1)+") が含まれています。削除してください。</div>\n";
						}else if(i == 3){
							errorMesStr += "<div class=\"errorMes_info\">　　→ 「"+String(resultObj)+"」(位置:"+(resultObj.index+1 < 10 ? " " : "") + String(resultObj.index+1)+") が含まれています。削除してください。</div>\n";
						}else if(i == 4){
							errorMesStr += "<div class=\"errorMes_info\">　　→ 「"+String(resultObj[0])+"」(位置："+(resultObj.index+1)+") に空白が入っています。<br>　　   曲情報の前後にある空白は削除してください。</div>\n";
						}else if(i == 5){
							errorMesStr += "<div class=\"errorMes_info\">　　→ 「"+String(resultObj)+"」(位置："+(resultObj.index+1)+") に特殊なスペースが入っています。削除してください。(<a href=\"http://ja.wikipedia.org/wiki/%E3%82%B9%E3%83%9A%E3%83%BC%E3%82%B9\">詳細</a>)</div>\n";
						}else if(i >= 6){
							errorMesStr += "<div class=\"errorMes_info\">　　→ 「"+String(resultObj)+"」(位置:"+(resultObj.index+1 < 10 ? " " : "") + String(resultObj.index+1)+") が含まれています。<br>　　   削除してください。(<a href=\"http://ja.wikipedia.org/wiki/%E3%82%B9%E3%83%9A%E3%83%BC%E3%82%B9\">詳細</a>)</div>\n";
						}
					}
				}
			}
			
			//解放
			patternArr = null;
			
			
			//年代の入力形式チェック
			patternArr = new Array();
			patternArr.push(/^[0-9][0-9][0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]$/);
			patternArr.push(/^[0-9][0-9][0-9][0-9]$/);
			
			//どちらの形式にも該当しない場合はエラーと判断
			if( !(patternArr[0].test(inString) || patternArr[1].test(inString) ) ){
				errorMesStr += "<div class=\"errorMes_info\">　　→年代「"+inString+"」"+"は正しい入力形式ではありません。「0000/00/00」か「0000」に修正してください。</div>\n";
			}
			
			//エラーメッセージを返す。
			if (errorMesStr != "") errorMesStr = "<div class=\"errorMes\">" + errorMesStr + "</div>";
			
			//解放
			patternArr = null;
			safeRep = null;
			resultObj = null;
			
			return errorMesStr;
		}
		
	}
}

//***********************************************************
//リッピングで犯しやすいミス
//***********************************************************
//１．ファイル名のトラック番号が抜けてしまう。(01 -) 					→ 当クラスで検出
//２．ファイル名と曲名が一致していない。(ファイル名は上記トラック番号を除く)	→ 別のクラスで検出
//３．年代の入力形式が0000/00/00から異なる。						→ 当クラスで検出

//***********************************************************
//SJIS注意すべき文字
//***********************************************************

//半角記号
//!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~｡｢｣､･

//全角英数
//１ ２ ３ ４ ５ ６ ７ ８ ９
//Ａ Ｂ Ｃ Ｄ Ｅ Ｆ Ｇ Ｈ Ｉ Ｊ Ｋ Ｌ Ｍ Ｎ Ｏ Ｐ 
//Ｑ Ｒ Ｓ Ｔ Ｕ Ｖ Ｗ Ｘ Ｙ Ｚ 　 
//ａ ｂ ｃ ｄ ｅ ｆ ｇ ｈ ｉ ｊ ｋ ｌ ｍ ｎ ｏ 
//ｐ ｑ ｒ ｓ ｔ ｕ ｖ ｗ ｘ ｙ ｚ

//機種依存文字
//① ② ③ ④ ⑤ ⑥ ⑦ ⑧ ⑨ ⑩ ⑪ ⑫ ⑬ ⑭ ⑮ ⑯ ここは機種により違う文字になる可能性があります。
//⑰ ⑱ ⑲ ⑳ Ⅰ Ⅱ Ⅲ Ⅳ Ⅴ Ⅵ Ⅶ Ⅷ Ⅸ Ⅹ ・ ㍉ 
//㌔ ㌢ ㍍ ㌘ ㌧ ㌃ ㌶ ㍑ ㍗ ㌍ ㌦ ㌣ ㌫ ㍊ ㌻ ㎜ 
//㎝ ㎞ ㎎ ㎏ ㏄ ㎡ ・ ・ ・ ・ ・ ・ ・ ・ ㍻ 　 
//〝 〟 № ㏍ ℡ ㊤ ㊥ ㊦ ㊧ ㊨ ㈱ ㈲ ㈹ ㍾ ㍽ ㍼ 
//≒ ≡ ∫ ∮ ∑ √ ⊥ ∠ ∟ ⊿ ∵ ∩ ∪

//機種依存文字2
//纊 褜 鍈 銈 蓜 俉 炻 昱 棈 鋹 曻 彅 丨 仡 仼 伀
//伃 伹 佖 侒 侊 侚 侔 俍 偀 倢 俿 倞 偆 偰 偂 傔 
//僴 僘 兊 兤 冝 冾 凬 刕 劜 劦 勀 勛 匀 匇 匤 卲 
//厓 厲 叝 﨎 咜 咊 咩 哿 喆 坙 坥 垬 埈 埇 﨏 　 
//塚 增 墲 夋 奓 奛 奝 奣 妤 妺 孖 寀 甯 寘 寬 尞 
//岦 岺 峵 崧 嵓 﨑 嵂 嵭 嶸 嶹 巐 弡 弴 彧 德 忞 
//恝 悅 悊 惞 惕 愠 惲 愑 愷 愰 憘 戓 抦 揵 摠 撝 
//擎 敎 昀 昕 昻 昉 昮 昞 昤 晥 晗 晙 晴 晳 暙 暠 
//暲 暿 曺 朎 朗 杦 枻 桒 柀 栁 桄 棏 﨓 楨 﨔 榘 
//槢 樰 橫 橆 橳 橾 櫢 櫤 毖 氿 汜 沆 汯 泚 洄 涇 
//浯 涖 涬 淏 淸 淲 淼 渹 湜 渧 渼 溿 澈 澵 濵 瀅 
//瀇 瀨 炅 炫 焏 焄 煜 煆 煇 凞 燁 燾 犱 
//犾 猤 猪 獷 玽 珉 珖 珣 珒 琇 珵 琦 琪 琩 琮 瑢 
//璉 璟 甁 畯 皂 皜 皞 皛 皦 益 睆 劯 砡 硎 硤 硺 
//礰 礼 神 祥 禔 福 禛 竑 竧 靖 竫 箞 精 絈 絜 綷 
//綠 緖 繒 罇 羡 羽 茁 荢 荿 菇 菶 葈 蒴 蕓 蕙 　 
//蕫 﨟 薰 蘒 﨡 蠇 裵 訒 訷 詹 誧 誾 諟 諸 諶 譓 
//譿 賰 賴 贒 赶 﨣 軏 﨤 逸 遧 郞 都 鄕 鄧 釚 釗 
//釞 釭 釮 釤 釥 鈆 鈐 鈊 鈺 鉀 鈼 鉎 鉙 鉑 鈹 鉧 
//銧 鉷 鉸 鋧 鋗 鋙 鋐 﨧 鋕 鋠 鋓 錥 錡 鋻 﨨 錞 
//鋿 錝 錂 鍰 鍗 鎤 鏆 鏞 鏸 鐱 鑅 鑈 閒 隆 﨩 隝 
//隯 霳 霻 靃 靍 靏 靑 靕 顗 顥 飯 飼 餧 館 馞 驎 
//髙 髜 魵 魲 鮏 鮱 鮻 鰀 鵰 鵫 鶴 鸙 黑 ・ ・ ⅰ 
//ⅱ ⅲ ⅳ ⅴ ⅵ ⅶ ⅷ ⅸ ⅹ ￢ ￤ ＇ ＂ 

//ⅰ ⅱ ⅲ ⅳ ⅴ ⅵ ⅶ ⅷ ⅸ ⅹ Ⅰ Ⅱ Ⅲ Ⅳ Ⅴ Ⅵ
//Ⅶ Ⅷ Ⅸ Ⅹ ￢ ￤ ＇ ＂ ㈱ № ㏍ ℡ 纊 褜 鍈 銈 
//蓜 俉 炻 昱 棈 鋹 曻 彅 丨 仡 仼 伀 伃 伹 佖 侒
//侊 侚 侔 俍 偀 倢 俿 倞 偆 偰 偂 傔 僴 僘 兊 　 
//兤 冝 冾 凬 刕 劜 劦 勀 勛 匀 匇 匤 卲 厓 厲 叝 
//﨎 咜 咊 咩 哿 喆 坙 坥 垬 埈 埇 﨏 塚 增 墲 夋
//奓 奛 奝 奣 妤 妺 孖 寀 甯 寘 寬 尞 岦 岺 峵 崧
//嵓 﨑 嵂 嵭 嶸 嶹 巐 弡 弴 彧 德 忞 恝 悅 悊 惞
//惕 愠 惲 愑 愷 愰 憘 戓 抦 揵 摠 撝 擎 敎 昀 昕
//昻 昉 昮 昞 昤 晥 晗 晙 晴 晳 暙 暠 暲 暿 曺 朎 
//朗 杦 枻 桒 柀 栁 桄 棏 﨓 楨 﨔 榘 槢 樰 橫 橆 
//橳 橾 櫢 櫤 毖 氿 汜 沆 汯 泚 洄 涇 浯
//涖 涬 淏 淸 淲 淼 渹 湜 渧 渼 溿 澈 澵 濵 瀅 瀇
//瀨 炅 炫 焏 焄 煜 煆 煇 凞 燁 燾 犱 犾 猤 猪 獷 
//玽 珉 珖 珣 珒 琇 珵 琦 琪 琩 琮 瑢 璉 璟 甁 畯 
//皂 皜 皞 皛 皦 益 睆 劯 砡 硎 硤 硺 礰 礼 神 　 
//祥 禔 福 禛 竑 竧 靖 竫 箞 精 絈 絜 綷 綠 緖 繒 
//罇 羡 羽 茁 荢 荿 菇 菶 葈 蒴 蕓 蕙 蕫 﨟 薰 蘒 
//﨡 蠇 裵 訒 訷 詹 誧 誾 諟 諸 諶 譓 譿 賰 賴 贒 
//赶 﨣 軏 﨤 逸 遧 郞 都 鄕 鄧 釚 釗 釞 釭 釮 釤 
//釥 鈆 鈐 鈊 鈺 鉀 鈼 鉎 鉙 鉑 鈹 鉧 銧 鉷 鉸 鋧 
//鋗 鋙 鋐 﨧 鋕 鋠 鋓 錥 錡 鋻 﨨 錞 ・ ・ ・ ・ 
//鍗 鎤 鏆 鏞 鏸 鐱 鑅 鑈 閒 隆 﨩 隝 隯 霳 霻 靃 
//靍 靏 靑 靕 顗 顥 飯 飼 餧 館 馞 驎 髙 
//髜 魵 魲 鮏 鮱 鮻 鰀 鵰 鵫 鶴 鸙 黑