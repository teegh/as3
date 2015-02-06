package com.tilfin.adc.echo
{
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.net.Socket;
    import flash.utils.ByteArray;
	
	import flash.events.IOErrorEvent;

    public class TcpClient extends Client
    {
        private var _socket:Socket;
        private var _message:Object;
		private var _tranceferClass:String = "";
        
        public function TcpClient()
        {
            super();
            
            _socket = new Socket();
            _socket.addEventListener(Event.CONNECT, onConnect);
            _socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
			_socket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
        }
        
		
		//接続時にIOErrorが発生した場合
		private function onIOError(event:IOErrorEvent):void{
			trace("[TcpClient]サーバーへメッセージ送信する際にエラーが発生しました。サーバーとの接続が確立されていない可能性があります。");
			close();
			super.onDataSendError();	//エラーイベント発生
		}
		
		
        private function onSocketData(event:ProgressEvent):void
        {
            var socket:Socket = Socket(event.target);
            
            // 応答データの読み取り
            var data:ByteArray = new ByteArray();
            socket.readBytes(data, 0, socket.bytesAvailable);
            
            super.onDataReceived(data);
        }
        
		
		//sendを実行する前に送る内容を設定する。
		override public function presetMessage(message:Object , inTranceferClass:String):void
		{
			_tranceferClass 	= inTranceferClass;
			_message			= message;
			
			/*
			if(_tranceferClass == "String"){
				trace("-----------------");
				trace("[TcpClient](presetMessage)"+"message:");
				trace(String(_message));
			}
			*/
			
			//if(_tranceferClass == "ByteArray")trace("★TcpCliet presetMessage : _message.length = "+ ByteArray(_message).length);
		}
		
		//送信 (setMessageを事前に実行する必要あり)
        override public function send(desthost:String, destport:int,  message:String):void
		{
			if(_tranceferClass == "")return;
            _socket.connect(desthost, destport);
			//trace("[TcpClient]接続を試みます。"+desthost+":"+String(destport));
		}
		
        private function onConnect(event:Event):void
        {
			//trace("★TcpCliet onConnect"+_tranceferClass);
			var data:ByteArray = new ByteArray();
			if (_tranceferClass == "String") {
				/*
				trace("-----------------");
				trace("[TcpClient](onConnect)message:");
				trace(String(_message));
				*/
				
            	data.writeUTFBytes(String(_message));
				
			}else if (_tranceferClass == "ByteArray") {
				
				//trace("★[TcpClient] _message.length = "+_message.length);
				
				data = ByteArray(_message);
			}
            
            _socket.writeBytes(data, 0, data.length);
			//_socket.flush();
			super.onConnectData();		//接続イベント発生
        }
        
        override public function close():void
        {
            if (_socket.connected)
            {
                _socket.close();
            }
			
			//イベントの削除
			_socket.removeEventListener(Event.CONNECT, onConnect);
            _socket.removeEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
			_socket.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			
			//解放
			_socket = null;
        }
    }
}