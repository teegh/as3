package  com.ms3.php{
	
	import flash.events.Event;
	
	public class ms3phpEvent extends Event{
		
		//イベント
		public static const CHK_ACT_LIST_GET:String = "CHK_ACT_LIST_GET";			//パスワード入力を求めるイベント
		
		public var m:String;			//エラー・イベントメッセージ
		public var returnObject:Object;	//イベントで渡すObject
		
		
		public function ms3phpEvent(type:String , returnObject:Object){
			super(type);
			this.returnObject = returnObject;	//渡す値をおさめたObject
		}
		public override function clone():Event{
			return new ms3phpEvent(type , returnObject);
		}
		public override function toString():String{
			return formatToString("mp3phpEvent","returnObject");
		}
		
	}
	
}