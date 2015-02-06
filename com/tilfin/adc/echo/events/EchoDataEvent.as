package com.tilfin.adc.echo.events
{
    import flash.events.Event;
    import flash.utils.ByteArray;
    
    public class EchoDataEvent extends Event
    {
        public static const DATA_RECEIVED:String = "dataReceived";
        public static const DATA_SEND_ERROR:String = "dataSendError";	//クライアントがサーバーにデータを送信失敗した場合
		public static const BIND_ERROR:String = "bindError";						//サーバーがバインドに失敗した場合
		public static const DATA_SEND_CONNECT:String = "dataSendConnect";	//クライアントがサーバーにデータ送信を行った場合
		
        private var _clientAddress:String;
        private var _clientPort:int;
        private var _data:ByteArray;
        private var _isByteArray:Boolean = false;
		
        public function EchoDataEvent(type:String, clientAddress:String, clientPort:int, data:ByteArray)
        {
            super(type, false, false);
			
            _clientAddress = clientAddress;
            _clientPort = clientPort;
            _data = data;
			
			//受信内容がバイトストリームか判別
			if(_data != null){
				if(_data.length >= 8){
						
					//trace("[EchoDataEvent] data.length = "+data.length);
						
					_isByteArray = (_data[0] == 0x62);								//b (8bitJIS)
					//trace("判定の結果："+_isByteArray+" : "+_data[0]);
					_isByteArray = _isByteArray && (_data[1] == 0x79);		//y (8bitJIS)
					//trace("判定の結果："+_isByteArray+" : "+_data[1]);
					_isByteArray = _isByteArray && (_data[2] == 0x74);		//t (8bitJIS)
					//trace("判定の結果："+_isByteArray+" : "+_data[2]);
					_isByteArray = _isByteArray && (_data[3] == 0x4D);		//M (8bitJIS)
					//trace("判定の結果："+_isByteArray+" : "+_data[3]);
				}else{
					_isByteArray = false;
				}
			}
        }
        
		public function get isByteArray():Boolean
        {
            return _isByteArray;
        }
		
        public function get clientAddress():String
        {
            return _clientAddress;
        }
        
        public function get clientPort():int
        {
            return _clientPort;
        }
        
        public function get data():ByteArray
        {
            return _data;
        }
        
        public function get dataString():String
        {
			if(_isByteArray)return "**ByteArray**";
            return _data.readUTFBytes(_data.length);
        }
    }
}