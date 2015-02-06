//クラスの仕様
//(継承) Id3JacketSet → Id3Pic
//イメージのバイナリデータ(ByteArray)をSpriteとして表示オブジェクトに追加。表示オブジェクトを返す。

//******************************************************************
//Id3JacketSpr(filePath:String, filePos:int, fileFrameSize:int)
//[入力]　	filePath			:	mp3ファイルのファイルパス						(String)
//				filePos			:	画像のフレーム本体を示すファイル位置		(int)
//				fileFrameSize	:	画像のフレーム本体のサイズ					(int)
//
//	[出力]	getImgSpr():Sprite
//
//				(出力の使い方)
//				ステージにあるムービークリップに入れ子する。
//				例. _imageCanvasムービークリップに追加する。
//				_imageCanvas.addChild(_thumb);			//_imageCanvasに_thumbをaddchildする。_imageCanvasはムービークリップ。
//******************************************************************

package com.gusen.id3Reader{
	public class Id3JacketSpr extends Id3Pic{
		
		import flash.display.*;
		import flash.events.*;
		
		private var _imgldr:Loader;							//画像用ローダー
		private var _thumb:Sprite;
		private var W:uint=0;
		private var H:uint=0;
		private var _loadCompFlg:Boolean;
		
		//コンストラクタ
		public function Id3JacketSpr(filePath:String, filePos:int, fileFrameSize:int , Width:uint , Height:uint){
			super(filePath, filePos, fileFrameSize);
			//初期化
			_imgldr=new Loader();
			_thumb=new Sprite();
			W=Width;
			H=Height;
			_loadCompFlg=false;
			//読み込み実行
			imageLoad();
		}
		
		//スーパークラスのgetPicByteArr()をLoaderオブジェクトに読みこみ。
		public function imageLoad(){
			_imgldr.loadBytes(getPicByteArr());																	//Loaderオブジェクトに読み込み
			_imgldr.contentLoaderInfo.addEventListener(Event.COMPLETE,imageScaleAjd);		//(読み込み完了)画像を表示する。
		}

		//画像ジャケットのリサイズと表示
		private function imageScaleAjd(evt:Event):void{
			var w:Number = (W/_imgldr.width);			//ジャケット表示領域に合わせる
			var h:Number = (H/_imgldr.height);			//
			
			var raito:Number = (w>h)?w:h;				//横縦の幅でいずれか小さい方に合わせる。これを縮尺率とする。
			_thumb.scaleX=_thumb.scaleY=raito;		//縮尺率を_thumbに適用する。
			_thumb.addChild(_imgldr);						//画像のLoaderオブジェクトを_thumbにaddchildする。
			_loadCompFlg=true;
			//trace("▼スプライト作成");
			//isImage=true;									//ジャケット画像の有無を示すフラグ。有にする。
		}
		//ゲッターメソッド：画像オブジェクトの読み込みが完了しているかどうか確認
		public function getImgSprFlg():Boolean{
			return _loadCompFlg;
		}
		//ゲッターメソッド：表示オブジェクトに画像を追加した_thumbを返す。
		public function getImgSpr():Sprite{
			return _thumb;
		}
	}
}