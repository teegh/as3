//RC4で暗号化
//http://thorshammer.blog95.fc2.com/blog-entry-261.html
package com.CriptRC4{
	import flash.utils.ByteArray;
	public class CriptRC4    {
		private var rowKey:String;
		private var keyCodes:Array;
		private var keyLength:int = 256;
		
		public function CriptRC4(key:String){
			var i:int;
			var j:int;
			rowKey = key;
			keyCodes = new Array();
			var bufCodes:Array = new Array();
			var length:int = rowKey.length;
			
			for(i = 0; i < keyLength; i++){
				bufCodes.push(int(rowKey.charCodeAt(i % length)));
				keyCodes.push(i);
			} 
			for(j = i = 0; i < keyLength; i++){
				j = (j + keyCodes[i] + bufCodes[i]) % keyLength;
				var temp:int = keyCodes[i];
				keyCodes[i] = keyCodes[j];
				keyCodes[j] = temp;
			}
		}
		
		public function cript(data:ByteArray):ByteArray{ 
			var i:int;
			var j:int;
			var k:int;
			var buf:Array = keyCodes.slice(0, keyCodes.length);
			var length:int = data.length;
			var cripted:ByteArray = new ByteArray();
			data.position = 0;
			cripted.position = 0;
			
			for(i = j = k = 0; k < length; k++){
				i = (i + 1) % keyLength;
				j = (j + buf[i]) % keyLength;
				var temp:int = buf[i];
				buf[i] = buf[j];
				buf[j] = temp;
				var t:int = (buf[i] + buf[j]) % keyLength;
				var byte:int = data.readByte() ^ buf[t];
				cripted.writeByte(byte);
			}
			return cripted;
		}
	}
}