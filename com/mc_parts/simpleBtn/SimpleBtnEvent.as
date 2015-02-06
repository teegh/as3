package com.mc_parts.simpleBtn{
	
    import flash.events.Event;
	import flash.display.*;
    import com.mc_parts.simpleBtn.SimpleBtn;
	
    public class SimpleBtnEvent extends Event{
		
        public static const SELECTED:String = "btn_selected";
		//public var selectedMC:String;
		
        public function SimpleBtnEvent(type:String){// , data:String) {
            super(type);
            //this.selectedMC = data;
        }
		
		/*
        public function get mc():SimpleBtn{
            return _selectedMC;
        }*/
		
		public override function clone():Event{
			return new SimpleBtnEvent(type);// ,  selectedMC);
		}
		public override function toString():String{
			return formatToString("SimpleBtnEvent");// , "selectedMC");
		}
    }
}