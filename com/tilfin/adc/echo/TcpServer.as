package com.tilfin.adc.echo
{
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.events.ServerSocketConnectEvent;
    import flash.net.ServerSocket;
    import flash.net.Socket;
    import flash.utils.ByteArray;
	
	import flash.errors.IOError;
    
    import mx.collections.ArrayCollection;
    import mx.utils.ArrayUtil;

    public class TcpServer extends Server
    {
        private var _svrsock:ServerSocket;
        private var _connectedSockets:ArrayCollection;
        private var _port:int = 0;
		private var _ip:String = "";
		
		//コンストラクタ
        public function TcpServer()
        {
            super();
            
            init();
        }
        
		private function init():void {
			_svrsock = new ServerSocket();
            _svrsock.addEventListener(ServerSocketConnectEvent.CONNECT, onConnect);
            _connectedSockets = new ArrayCollection();
		}
		
		
		//
        override public function start(ipaddress:String, port:int):void
        {
			try {
            	_svrsock.bind(port, ipaddress);
            	_svrsock.listen();
				_ip = ipaddress;
				_port = port;
			}catch(e:IOError){
				trace("[TcpServer]バインドエラー。WANに接続されていない可能性があります。");
				//stop();	//サーバー停止 ※利用しているクラスでstop();している
				super.onBindError();
			}
        }
        
        override public function stop():void
        {
            if (_svrsock != null)
            {
                for each (var socket:Socket in _connectedSockets)
                {
                    socket.close();
                }
                _connectedSockets = null;
				
				try{
					_svrsock.removeEventListener(ServerSocketConnectEvent.CONNECT, onConnect);
					_svrsock.close();
				}catch(e:IOError){
					trace("[TcpServer]_svrsockがバインドされていない状態でcloseされました。");
				}finally{
					_svrsock = null;	//解放
				}
            }
        }
		
        private function onConnect(event:ServerSocketConnectEvent):void
        {
            var connsock:Socket = event.socket;
            connsock.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
            connsock.addEventListener(Event.CLOSE, onSocketClose);
            
            _connectedSockets.addItem(connsock);
        }
		
        private function onSocketData(event:ProgressEvent):void
        {
            var socket:Socket = Socket(event.target);
            var data:ByteArray = new ByteArray();
            socket.readBytes(data, 0, socket.bytesAvailable);
			var readDataStr:String = data.readUTFBytes(data.length);
			data.position = 0;
			
			//受信イベント発行
            super.onDataReceived(socket.remoteAddress, socket.remotePort, data);
			
			//HTTPリクエストを受信した場合は、HTTPレスポンスを返す。
			if(readDataStr.indexOf("GET") != -1 && readDataStr.indexOf("HTTP/1.") != -1){
				//********************************************
				//▼ソケット接続受信時に、HTTPレスポンスを送り返す
				//********************************************
				var sendMes_http:String = "";
				var returnWords:String = "\r\n";
				var returnWords_html:String = "\n";
				var nowTime:Date = new Date();
				
				sendMes_http += "HTTP/1.0 200 OK"+returnWords;		//Document follows
				sendMes_http += "Cache-Control: no-store, must-revalidate"+returnWords;
				sendMes_http += "Pragma: no-cache"+returnWords;
				sendMes_http += "Content-type: text/html; charset=UTF-8" + returnWords;
				sendMes_http += "Server: SP" + returnWords;
				sendMes_http += returnWords;
				
				sendMes_http += "<html>";
				sendMes_http += "<head><title></title></head>";
				sendMes_http += "<body>";
				sendMes_http += "<p>";
				sendMes_http += "アクセス時刻：　"+ nowTime.toLocaleTimeString();
				sendMes_http += "</p>";
				sendMes_http += "</body>";
				sendMes_http += "</html>";
				
				// クライアントにデータを送り返す
				socket.writeUTFBytes(sendMes_http);
				socket.flush();
				stop();
				init();
				start(_ip, _port);
				
				//解放
				sendMes_http 		= null;
				returnWords 		= null;
				returnWords_html 	= null;
				nowTime 			= null;
				//********************************************
				//▲終了
				//********************************************
			}
			
			socket 		= null;
			data 		= null;
			readDataStr = null;
        }
        
        private function onSocketClose(event:Event):void
        {
            var socket:Socket = Socket(event.target);
            socket.removeEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
            socket.removeEventListener(Event.CLOSE, onSocketClose);
            
            _connectedSockets.removeItemAt(_connectedSockets.getItemIndex(socket));
        }
    
    }
}