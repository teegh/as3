package com.thread.fileReadThread.FileReadPathArr{
	
    import flash.events.Event;
    
    public class FileReadPathArrEvent extends Event{
		
        public static const FILE_LOAD_COMPLETE:String = "fileload_complete";

        private var _data:Vector.<String>;
		
        public function FileReadPathArrEvent(type:String , data:Vector.<String>){
			
            super(type, false, false);
            _data = data;
			
        }
		
        public function get data():Vector.<String>{
            return _data;
        }
    }
}