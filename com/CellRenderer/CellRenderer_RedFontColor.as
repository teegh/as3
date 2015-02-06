package com.CellRenderer {
	
	//棚上げチェック用のセル文字色変化クラス。データプロバイダーcdNoに応じて文字を赤色に変化
	
	import fl.controls.listClasses.CellRenderer;
	import flash.text.TextFormat;
	
    public class CellRenderer_RedFontColor extends CellRenderer {
	
		private static  var _myArray:Array = new Array;
		private var myFormat_red:TextFormat = new TextFormat();
		private var myFormat:TextFormat = new TextFormat();
		private var isColorText:Boolean = false;

		
		public function CellRenderer_RedFontColor():void
		{
			super ();
			myFormat_red.color = 0xCC0000;
			myFormat_red.bold = "bold";
			myFormat.color = 0x000000;
		}
		
		public static function selectIndex (sid:int):void
		{
			_myArray.push (sid);
		}

		override protected function drawBackground ():void
		{
			//trace(this.label+" / "+data);
			var isColorCell:Boolean = false;
			if(data.cdNo != undefined){
				isColorText = data.cdNo.indexOf(getCat()) != -1;
				if(isColorText){
					setStyle ("textFormat", myFormat_red);		//フォントとスキンを着色
					setStyle ("upSkin", CellRenderer_tanaageChkErea);
					isColorCell = true;
				}
			}	
			if(!isColorCell){
				setStyle ("textFormat", myFormat);				//通常のフォントカラーとスキンへ
				setStyle ("upSkin", CellRenderer_upSkin);
			}
			super.drawBackground ();
			
		}
		
		private function getCat():String {
			//現在の列番号によって、返す値を変更
			switch(listData.column) {
				case 3:
					return "人名";
					break;
					
				case 5:
					return "曲名";
					break;
					
				case 8:
					return "アルバム";
					break;
				
				case 7:
					return "トラック";
					break;
				
				case 10:
					return "年代";
					break;
				
				case 11:
					return "ジャンル";
					break;
				
				case 12:
					return "コメント";
					break;
				
				default:
					return "該当なし";
			}
		}
		
		override protected function drawLayout ():void
		{
			/*
			textField.wordWrap = false;
			textField.autoSize = "left";
			textField.width = this.width;
			textField.htmlText=this.label;
			*/
			super.drawLayout ();
		}
		
		public function get isColorTEXT():Boolean {
			return isColorText;
		}

		public function set isColorTEXT(inIsColorTEXT):void {
			isColorText = inIsColorTEXT;
		}
    }
}