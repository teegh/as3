package com.image {
	
	//ビットマップのサイズ変換
	//http://d.hatena.ne.jp/flashrod/20081109#1226213419
	//http://rest-term.com/archives/613/
	import flash.display.BitmapData;
	//import flash.utils.*;
	
	public class ResizeImage {
		
		private var _tested:Boolean = false;
		
		public function ResizeImage():void{
			
		}
		
		//サイズ変換
		public function resize(s:BitmapData, ratio:Number):BitmapData {
			
			var sw:int = s.width;
			var sh:int = s.height;
			var dw:int = Math.ceil(sw * ratio);
			var dh:int = Math.ceil(sh * ratio);
			var d:BitmapData = new BitmapData(dw, dh);
			for (var j:int = 0; j < dh; j++) {
				var j1:int = j / ratio;
				var j2:int = Math.min(j1 + 1, sh - 1);
				var q:Number = j / ratio - j1;
				for (var i:int = 0; i < dw; i++) {
					var i1:int = i / ratio;
					var i2:int = Math.min(i1 + 1, sw - 1);
					var p:Number = i / ratio - i1;
					var rgb:uint = interpolation_2(s, { p:p, q:q, i1:i1, i2:i2, j1:j1, j2:j2 } );
					//var rgb:uint = interpolation_3(s, i2, j2);	//バイキュービック (テスト中)
					d.setPixel(i, j, rgb);
				}
			}
			return d;
		}
		
		//最近傍法
		private function interpolation_1(b:BitmapData, o:Object):int {
			return b.getPixel(o.i1, o.j1);
		}
		//drawを使った場合 (最近傍法)
		//smoothing:Booleanの値により滑らかになる
		/*
		public function resize(s:BitmapData):BitmapData {
			var sw:int = s.width;
			var sh:int = s.height;
			var dw:int = Math.ceil(sw * ratio);
			var dh:int = Math.ceil(sh * ratio);
			var d:BitmapData = new BitmapData(dw, dh);
			d.draw(s, new Matrix(ratio, 0, 0, ratio), null, null, null, smoothing);
			return d;
		}
		*/
		
		//線形補間法
		private function interpolation_2(bd:BitmapData, o:Object):int {
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
		
		
		//双三次補間法 (バイキュービック)
		private function interpolation_3(imgData:BitmapData, x1:Number, y1:Number):int {
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
			adr = ly * 4;
			for(var lx:int=0;lx<4;lx++){
			  val = imgData.getPixel(px + lx - 1, py + ly - 1);
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
		
	}
}