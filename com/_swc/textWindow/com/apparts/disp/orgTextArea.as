package com.apparts.disp{
	
	//汎用テキストエリア、スクロールバー付き
	
	//その他の機能
	//html表示の切り替え (初期設定はON)
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.StyleSheet;
	import flash.ui.Mouse;
	
	public class orgTextArea extends MovieClip {
		
		private var _maxViewLines:uint = 0;
		private var _barDefaultPosY:Number = 0;
		private var _barDefaultPosX:Number = 0;
		private var _barDefaultHeight:Number = 0;
		private var _isMouseDrag:Boolean = false;
		private var _isHTML:Boolean = true;
		private var _css:String = "";
		
		public function orgTextArea():void {
			
			initSetting();
			this.gotoAndStop(1);
			/*
			//スクロール実験
			_message.text = "";
			for (var i:uint = 1; i <= 300; i++) {
				_message.text = _message.text + String(i)+"\n"; 
			}
			*/
			setScrollBar();
		}
		
		//初期設定
		private function initSetting():void {
			
			_protectIcon.alpha = 0.0;
			_protectIcon.gotoAndStop(1);
			_protectIcon.mouseEnabled = false;
			_bar._bar.alpha = 0.3;
			setDefaultVarSetting();
			_message.addEventListener(Event.CHANGE , onTextChange);
			_message.addEventListener(Event.SCROLL , onTextScroll);
			_bar._btn.addEventListener(MouseEvent.MOUSE_DOWN , onBar_MouseDown);
			_bar._btn.addEventListener(MouseEvent.MOUSE_OVER , onBar_MouseOver);
			_bar._btn.addEventListener(MouseEvent.MOUSE_OUT , onBar_MouseOut);
			this.addEventListener(MouseEvent.MOUSE_UP , onBar_MouseUp);
			
			//cssの設定
			var style:StyleSheet = new StyleSheet();
			
			var a:Object = new Object();
			//a.color = "#336666";
			a.color = "#33CCCC";
			a.textDecoration = "underline";
			
			var body:Object = new Object();
			body.fontSize = 12;
			body.letterSpacing = 0.1;
			body.leading = 9;
			body.color = "#FFFFFF";
			
			var h3:Object = new Object();
			h3.fontSize = 11;
			h3.fontWeight = "bold";
			
			var trackInfo:Object = new Object();
			trackInfo.color = "#FFFFFF";
			trackInfo.fontSize = 12;
			trackInfo.fontWeight = "bold";
			
			var em:Object = new Object();
			em.color = "#888888";
			em.fontWeight = "bold";
			em.display = "inline";
			
			var error:Object = new Object();
			error.color = "#CD5C5C";
			//error.fontWeight = "bold";
			
			var newInfo:Object = new Object();
			newInfo.color = "#EEEE66";
			
			//置換して安全な文字
			var safeWord:Object = new Object();
			safeWord.color = "#339966";

			//置換しておらず変換するかどうかを各自判断させる文字
			var warningWord:Object = new Object();
			warningWord.color = "#FF8C00";
			
			style.setStyle(".h3", h3);
			style.setStyle(".trackInfo", trackInfo);
			style.setStyle(".warningWord", warningWord);
			style.setStyle(".safeWord", safeWord);
			style.setStyle(".error", error);
			style.setStyle(".newInfo", newInfo);
			style.setStyle("em", em);
			style.setStyle("a", a);
			style.setStyle("body", body);
			
			_message.styleSheet = style;
			
			//css一覧
			/*
			color	color	16 進数のカラー値のみがサポートされます。blue などの名前付きカラーはサポートされません。カラーは、#FF0000 のようなフォーマットで記述されます。
			display	display	サポートされる値は inline、block、および none です。
			font-family	fontFamily	使用するフォントをカンマ区切りリストで指定します。優先度の高い順に並べます。任意のフォントファミリ名を使用できます。汎用フォント名を指定した場合、適切なデバイスフォントに置換されます。次のようなフォント変換が行われます。mono は _typewriter に、sans-serif は _sans に、serif は _serif にそれぞれ変換されます。
			font-size	fontSize 	値の数字の部分だけを使用します。単位 (px、pt) は解析されません。ピクセルとポイントは同じ意味になります。
			font-style	fontStyle	有効な値は normal と italic です。
			font-weight	fontWeight	有効な値は normal と bold です。
			kerning	kerning	有効な値は true と false です。カーニングは、埋め込みフォントに対してのみサポートされています。Courier New など特定のフォントでは、カーニングがサポートされていません。カーニングのプロパティは、Macintosh で作成された SWF ファイルではなく、Windows で作成された SWF ファイルでのみサポートされます。ただし、カーニングを使用した SWF ファイルは Windows 以外のバージョンの Flash Player でも表示でき、カーニングも適用されます。
			leading	leading	行間に均等に配分されるスペースの量です。各行の下に追加されるピクセル数を表す値です。負の値を指定すると、行の間隔が狭くなります。値の数字の部分だけを使用します。単位 (px、pt) は解析されません。ピクセルとポイントは同じ意味になります。
			letter-spacing	letterSpacing	文字間に均等に配分されるスペースの量です。この値は、各文字の後の送りに追加されるピクセル数を示します。負の値を指定すると、文字の間隔が狭くなります。値の数字の部分だけを使用します。単位 (px、pt) は解析されません。ピクセルとポイントは同じ意味になります。
			margin-left	marginLeft	値の数字の部分だけを使用します。単位 (px、pt) は解析されません。ピクセルとポイントは同じ意味になります。
			margin-right	marginRight	値の数字の部分だけを使用します。単位 (px、pt) は解析されません。ピクセルとポイントは同じ意味になります。
			text-align	textAlign	有効な値は left、center、right、および justify です。
			text-decoration	textDecoration	有効な値は none と underline です。
			text-indent	textIndent	値の数字の部分だけを使用します。単位 (px、pt) は解析されません。ピクセルとポイントは同じ意味になります。 
			*/
		}
		private function setDefaultVarSetting():void {
			_bar.height = _message.height;
			_barDefaultHeight = _bar.height;
			_bar.y = _message.y;
			_bar.x = 8 + _message.width + 6;
			_barDefaultPosX = _bar.x;
			_barDefaultPosY = _bar.y;
		}
		
		//解放
		private function dealloc():void {
			_message.removeEventListener(Event.CHANGE , onTextChange);
			_message.removeEventListener(Event.SCROLL , onTextScroll);
			_bar._btn.removeEventListener(MouseEvent.MOUSE_DOWN , onBar_MouseDown);
			_bar._btn.removeEventListener(MouseEvent.MOUSE_OVER , onBar_MouseOver);
			_bar._btn.removeEventListener(MouseEvent.MOUSE_OUT , onBar_MouseOut);
			this.removeEventListener(MouseEvent.MOUSE_UP , onBar_MouseUp);
		}
		
		//各表示オブジェクトの配置 ステージに合わせる
		public function setObject(inWidth:Number, inHeight:Number):void {
			this.x = this.y =0.0;
			_back.width = inWidth;
			_back.height = inHeight;
			_closeBtn.x = inWidth - _closeBtn.width -6.0;
			_closeBtn.y = 6.0;
			_closeBtnIcon.x = _closeBtn.x + 3.0;
			_closeBtnIcon.y = _closeBtn.y + 3.0;
			_message.width = inWidth - 36;
			
			if(_protectIcon.alpha == 0.0){
				_message.height = inHeight - 47;
			}else {
				_message.height = inHeight - 47 - 30;
				_protectIcon.y = _message.y + _message.height + 15;
			}
			setDefaultVarSetting();
			setScrollBar();
		}
		
		//メッセージを表示する。
		public function set message(inString:String) {
			if(_isHTML){
				_message.htmlText = "<html><body>" + inString + "</body></html>";		//html表示
			}else{
				_message.text = inString;			//プレーンテキスト
			}
			setScrollBar();
		}
		
		//メッセージを返す。
		public function get message():String {
			return _message.text;
		}
		
		//html表示を行うか否か
		public function set htmlMode(isHTML:Boolean) {
			_isHTML = isHTML;
		}
		
		public function get htmlMode():Boolean {
			return _isHTML;
		}
		
		//スクロールを先頭に戻す。
		public function skipHead():void {
			_message.scrollV = 1;		//テキストフィールド
			_bar.y = _barDefaultPosY;	//スクロールバー
		}
		
		//テキストの内容が変化したとき
		private function onTextChange(evt:Event):void {
			
			//trace("bottomScrollV : "+_message.bottomScrollV);
			//trace("numLines : "+_message.numLines);					//複数行テキストフィールド内のテキスト行の数を定義します。
			//trace("scrollV : "+_message.scrollV);
			//trace("maxScrollV : " + _message.maxScrollV);				//位置割り出し
			
			setScrollBar();
		}
		
		
		//バーにマウスが乗ったとき
		private function onBar_MouseOver(evt:MouseEvent):void {
			_bar._bar.alpha = 0.2;
		}
		
		//バーからマウスが外れたとき
		private function onBar_MouseOut(evt:MouseEvent):void {
			if(!_isMouseDrag)_bar._bar.alpha = 0.3;
		}
		
		//バーをドラッグした時
		private function onBar_MouseDown(evt:MouseEvent):void {
			_bar.startDrag(false , new Rectangle(_barDefaultPosX , _barDefaultPosY , 0 , _message.height - _bar.height) );
			_bar.addEventListener(Event.ENTER_FRAME , onEnterFrame_setTxtScrollCall);
			_message.removeEventListener(Event.SCROLL , onTextScroll);
			_bar._bar.alpha = 0.15;
			_isMouseDrag = true;
		}
		
		//バーを離した時
		private function onBar_MouseUp(evt:MouseEvent):void {
			stopDragBar();
		}
		
		private function stopDragBar() :void{
			_bar.stopDrag();
			if(_bar.hasEventListener(Event.ENTER_FRAME))_bar.removeEventListener(Event.ENTER_FRAME , onEnterFrame_setTxtScrollCall);
			if(!_message.hasEventListener(Event.SCROLL))_message.addEventListener(Event.SCROLL , onTextScroll);
			setTxtScroll();
			_bar._bar.alpha = 0.3;
			_isMouseDrag = false;
		}
		
		
		//フレーム毎にテキストをスクロール
		private function onEnterFrame_setTxtScrollCall(evt:Event) {
			setTxtScroll();
			if (mouseX > width || mouseX < 0 || mouseY > height || mouseY < 0)stopDragBar();		//画面外にマウスが外れたときにドラッグ停止
		}
		
		
		//--------------------------------------------------
		//移動・伸縮処理
		//--------------------------------------------------
		//テキストの中でスクロールしたとき
		private function onTextScroll(evt:Event):void {
			_bar.y =  _barDefaultPosY + _message.height * (_message.scrollV -1) / _message.numLines;
		}
		
		//テキストをバーの位置に合わせてスクロール
		private function setTxtScroll():void{
			_message.scrollV  = Math.round((_bar.y - _barDefaultPosY) / _message.height * _message.numLines) + 1;
		}
		
		//テキストの内容やスクロール位置に合わせて、伸縮・移動
		private function setScrollBar():void {
			_maxViewLines = _message.numLines - (_message.maxScrollV - 1);
			_bar.height = _barDefaultHeight * Number(_maxViewLines / _message.numLines);
			_bar.y =  _barDefaultPosY + _message.height * (_message.scrollV -1) / _message.numLines;
		}
	}
}