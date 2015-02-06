package com.tilfin.adc.echo
{
    import com.tilfin.adc.echo.events.EchoDataEvent;
    
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.utils.ByteArray;
    
    [Event(name="dataReceived", type="com.tilfin.echo.events.EchoDataEvent")]
    
    public class Server extends EventDispatcher
    {
        public function Server(target:IEventDispatcher=null)
        {
            super(target);
        }
        
        public function start(ipaddress:String, port:int):void
        {
            throw new Error("実装してください");
        }
        
        public function stop():void
        {
            throw new Error("実装してください");
        }
        
        protected function onDataReceived(clientAddress:String, clientPort:int, data:ByteArray):void
        {
            dispatchEvent(new EchoDataEvent(EchoDataEvent.DATA_RECEIVED,
                                   clientAddress, clientPort, data));
        }
		
		//バインドエラー(ネットワークの切断によるもの)
		protected function onBindError():void{
			 dispatchEvent(new EchoDataEvent(EchoDataEvent.BIND_ERROR,
                                   null, NaN, null));
		}
    }
}