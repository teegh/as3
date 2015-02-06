package com.CellRenderer{
    // Import the required component classes.
    import fl.containers.UILoader;
    import fl.controls.listClasses.ICellRenderer;
    import fl.controls.listClasses.ListData;
    import fl.core.InvalidationType;
    import fl.data.DataProvider;
    import flash.events.Event;

import fl.controls.listClasses.CellRenderer;


    /**
     * This class creates a custom cell renderer which displays an image in a cell.
     * Make sure the class is marked "public" and in the case of our custom cell renderer, 
     * extends the UILoader class and implements the ICellRenderer interface.
     */
    public class JacketCellRenderer extends UILoader implements ICellRenderer {
        protected var _data:Object;
        protected var _listData:ListData;
        protected var _selected:Boolean;

        /**
         * Constructor.
         */
        public function JacketCellRenderer():void {
            super();
			setStyle("downSkin",null);
        }

        /**
         * Gets or sets the cell's internal _data property.
         */
        public function get data():Object {
            return _data;
        }
        /** 
         * @private (setter)
         */
        public function set data(value:Object):void {
            _data = value;
			source = value.data;
			scaleContent=false;		//セルのサイズに応じてインスタンスの縮尺が行われるかどうか
			
        }

        /**
         * Gets or sets the cell's internal _listData property.
         */
        public function get listData():ListData {
            return _listData;
			
        }
        /**
         * @private (setter)
         */
        public function set listData(value:ListData):void {
            _listData = value;
            invalidate(InvalidationType.DATA);
            invalidate(InvalidationType.STATE);
        }

        /**
         * Gets or sets the cell's internal _selected property.
         */
        public function get selected():Boolean {
            return _selected;
        }
        /**
         * @private (setter)
         */
        public function set selected(value:Boolean):void {
            _selected = value;
            invalidate(InvalidationType.STATE);
        }

        /**
         * Sets the internal mouse state.
         */
        public function setMouseState(state:String):void {
			
        }		
    }
}