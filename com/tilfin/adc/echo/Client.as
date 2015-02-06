package com.tilfin.adc.echo
{
    import com.tilfin.adc.echo.events.EchoDataEvent;
    
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.utils.ByteArray;
    
    [Event(name="dataReceived", type="com.tilfin.echo.events.EchoDataEvent")]
    
    public class Client extends EventDispatcher
    {
        public function Client(target:IEventDispatcher=null)
        {
            super(target);
        }
        
        public function send(desthost:String, destport:int, message:String):void
        {
            throw new Error("実装してください");
        }
        
        public function close():void
        {
            throw new Error("実装してください");
        }
		
		
		public function presetMessage(message:Object , inTranceferClass:String):void
		{
			 throw new Error("実装してください");
		}
	
        
        protected function onDataReceived(data:ByteArray):void
        {
            dispatchEvent(new EchoDataEvent(EchoDataEvent.DATA_RECEIVED, null, NaN, data));
        }
		
		//サーバーへのメッセージ送信失敗時
		 protected function onDataSendError():void
        {
            dispatchEvent(new EchoDataEvent(EchoDataEvent.DATA_SEND_ERROR, null, NaN, null));
        }
		
		//サーバーへのソケット接続時
		protected function onConnectData():void
		{
			dispatchEvent(new EchoDataEvent(EchoDataEvent.DATA_SEND_CONNECT, null, NaN, null));
		}
    }
}