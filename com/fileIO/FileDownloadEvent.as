package com.fileIO{
	
    import flash.events.Event;
    import flash.utils.ByteArray;
    
    public class FileDownloadEvent extends Event{
		
        public static const FILEDOWNLOAD_COMPLETE:String = "fileDownLoad_complete";
		public static const FILEDOWNLOAD_FAILED:String = "fileDownLoad_failed";

        private var _data:ByteArray;
		
        public function FileDownloadEvent(type:String , data:ByteArray){
			
            super(type, false, false);
            _data = data;
			
        }
		
        public function get data():ByteArray{
            return _data;
        }
    }
}