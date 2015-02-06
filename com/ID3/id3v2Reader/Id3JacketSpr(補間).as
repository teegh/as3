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
		import flash.geom.Matrix;
		
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
			
			//-----------------
			//縮尺率処理は保留
			//-----------------
			/*
			var w:Number = (W/_imgldr.width);			//ジャケット表示領域に合わせる
			var h:Number = (H/_imgldr.height);			//
			
			var raito:Number = (w>h)?w:h;				//横縦の幅でいずれか小さい方に合わせる。これを縮尺率とする。
			_thumb.scaleX=_thumb.scaleY=raito;		//縮尺率を_thumbに適用する。
			*/
			
			
			//-----------------
			//変更箇所
			//-----------------
			
			var w:Number = W / _imgldr.width;			//ジャケット表示領域に合わせる
			var h:Number = H / _imgldr.height;			//
			
			var raito:Number = (w>h)?w:h;				//横縦の幅でいずれか小さい方に合わせる。これを縮尺率とする。
			var _matrix = new Matrix();
			
			/*
			_matrix.scale(1.0, 1.0);
			var thumbImg:BitmapData = new BitmapData(_imgldr.width  , _imgldr.height  , true ,0xFFFFFF );
			thumbImg.draw( _imgldr , _matrix , null , null , null , false );
			thumbImg = resize(thumbImg);
			*/
			
			
			_matrix.scale(raito, raito);
			var thumbImg:BitmapData = new BitmapData(_imgldr.width * raito , _imgldr.height * raito  , true , 0xFFFFFF );
			thumbImg.draw(_imgldr , _matrix , null, null ,null , true);
			
			
			_thumb.addChild(new Bitmap(thumbImg));	//画像のLoaderオブジェクトを_thumbにaddchildする。
			//_thumb.addChild(_imgldr);						//画像のLoaderオブジェクトを_thumbにaddchildする。
			
			
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
		
		
		
		
		
		//-----------------------------------------------------
		//　画像のリサイズ処理内容　(サイズを ratio 倍する)
		//-----------------------------------------------------
		public function resize(s:BitmapData):BitmapData {
			
			var w:Number = (W/_imgldr.width);			//ジャケット表示領域に合わせる
			var h:Number = (H/_imgldr.height);			//
			var raito:Number = (w>h)?w:h;				//横縦の幅でいずれか小さい方に合わせる。これを縮尺率とする。
			
			var sw:int = s.width;
			var sh:int = s.height;
			var dw:int = Math.ceil(sw * raito);
			var dh:int = Math.ceil(sh * raito);
			var d:BitmapData = new BitmapData(dw, dh);
			for (var j:int = 0; j < dh; j++) {
				var j1:int = j / raito;
				var j2:int = Math.min(j1 + 1, sh - 1);
				var q:Number = j / raito - j1;
				for (var i:int = 0; i < dw; i++) {
					var i1:int = i / raito;
					var i2:int = Math.min(i1 + 1, sw - 1);
					var p:Number = i / raito - i1;
					var rgb:uint = interpolation(s, {p:p, q:q, i1:i1, i2:i2, j1:j1, j2:j2});
					//var rgb:uint = interpolate(s, i1, j1);	//一応動作
					d.setPixel(i, j, rgb);
				}
			}
			return d;
		}
		
		
		
		
		
		//-----------------------------------------------------
		//　画像のリサイズを行う。 
		//-----------------------------------------------------
		public function interpolation(b:BitmapData, o:Object):int {
			var px:int = Math.round(o.i1);  //実数座標を四捨五入
			var py:int = Math.round(o.j1);
			return b.getPixel(px, py);								//最近傍法(ニアレストネイバー法)
			//return interpolationB(b , o); 						//バイリニア補間法 (線形補間法)
			//return interpolate(b , o.i1 ,o.j1); 				//バイキュービック補間法 (双三次補間法)
		}
		
		
		
		//-----------------------------------------------------
		//　双三次補間法（バイキュービック補間）
		//-----------------------------------------------------
		private function interpolate(imgData:BitmapData, x1:Number, y1:Number):int {
		  var px:Number = Math.floor(x1);
		  var py:Number = Math.floor(y1);
		  var adr:int = 0;
		  var r:int = 0;
		  var g:int = 0;
		  var b:int = 0;
		  var val:uint = 0;
		  var bufR:Vector.<int> = new Vector.<int>(16);  //16近傍の画素値
		  var bufG:Vector.<int> = new Vector.<int>(16);
		  var bufB:Vector.<int> = new Vector.<int>(16);
		
		  for(var ly:int=0;ly<4;ly++){
			adr = ly*4;
			for(var lx:int=0;lx<4;lx++){
			  val = imgData.getPixel(px+lx-1, py+ly-1);
			  bufR[adr] = (val >> 16) & 0xff;
			  bufG[adr] = (val >> 8) & 0xff;
			  bufB[adr] = val & 0xff;
			  adr++;
			}
		  }
		  r = biCubic(x1, y1, bufR);
		  g = biCubic(x1, y1, bufG);
		  b = biCubic(x1, y1, bufB);
		  return (r << 16) | (g << 8) | b;
		}
		
		private function biCubic(x1:Number, y1:Number, buf:Vector.<int>):int{
		  var fx:Vector.<Number> = new Vector.<Number>(4);
		  var fy:Vector.<Number> = new Vector.<Number>(4);
		  var tmp:Vector.<Number> = new Vector.<Number>(4);
		  var mat:Vector.<Number> = new Vector.<Number>(4);
		  var dx:Number = x1 - Math.floor(x1);
		  var dy:Number = y1 - Math.floor(y1);
		  var res:int = 0;
		
		  fx[0] = cubicFunc(1.0+dx);
		  fx[1] = cubicFunc(    dx);
		  fx[2] = cubicFunc(1.0-dx);
		  fx[3] = cubicFunc(2.0-dx);
		
		  fy[0] = cubicFunc(1.0+dy);
		  fy[1] = cubicFunc(    dy);
		  fy[2] = cubicFunc(1.0-dy);
		  fy[3] = cubicFunc(2.0-dy);
		
		  for(var i:int=0;i<4;i++){
			for(var j:int=0;j<4;j++){
			  mat[j] = buf[j*4+i];
			}
			tmp[i] = innerProduct(fy, mat);
		  }
		  res = Math.floor(innerProduct(tmp, fx));
		  if(res<0) res = 0;
		  else if(res>255) res = 255;
		  return res;
		}
		
		private function cubicFunc(t:Number):Number {
		  var at:Number = 0.0;
		  var res:Number = 0.0;
		  var a:Number = -1.0;
		
		  at = t < 0 ? -t : t;
		  if(0.0 <= at && at < 1.0){
			res = (a+2)*at*at*at-(a+3)*at*at+1.0;
		  }else if(1.0 <= at && at < 2.0){
			res = a*at*at*at-5*a*at*at+8*a*at-4*a;
		  }
		  return res;
		}
		
		private function innerProduct(x:Vector.<Number>, y:Vector.<Number>):Number {
		  var res:Number = 0.0;
		  for(var i:int=0;i<4;i++) res += x[i]*y[i]
		  return res;
		}

		
		
		
		
		
		
		//-----------------------------------------------------
		//　線形補間法（バイリニア補間）
		//-----------------------------------------------------
		public function interpolationB(bd:BitmapData, o:Object):int {
			var p:Number = o.p;
			var q:Number = o.q;
			var i1:int = o.i1;
			var i2:int = o.i2;
			var j1:int = o.j1;
			var j2:int = o.j2;
			var c11:int = bd.getPixel(i1, j1);
			var c21:int = bd.getPixel(i2, j1);
			var c12:int = bd.getPixel(i1, j2);
			var c22:int = bd.getPixel(i2, j2);
			var r11:int = (c11 >> 16) & 0xFF;
			var g11:int = (c11 >> 8) & 0xFF;
			var b11:int = c11 & 0xFF;
			var r12:int = (c12 >> 16) & 0xFF;
			var g12:int = (c12 >> 8) & 0xFF;
			var b12:int = c12 & 0xFF;
			var r21:int = (c21 >> 16) & 0xFF;
			var g21:int = (c21 >> 8) & 0xFF;
			var b21:int = c21 & 0xFF;
			var r22:int = (c22 >> 16) & 0xFF;
			var g22:int = (c22 >> 8) & 0xFF;
			var b22:int = c22 & 0xFF;
			var r:int = (1 - q) * ((1 - p) * r11 + p * r21) + q * ((1 - p) * r12 + p * r22);
			var g:int = (1 - q) * ((1 - p) * g11 + p * g21) + q * ((1 - p) * g12 + p * g22);
			var b:int = (1 - q) * ((1 - p) * b11 + p * b21) + q * ((1 - p) * b12 + p * b22);
			return (r << 16) | (g << 8) | b;
		}
				
		
		
	}
}