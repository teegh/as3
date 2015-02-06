package com.CellRenderer{
    // Import the required component classes.
    import fl.containers.UILoader;
    import fl.controls.listClasses.ICellRenderer;
    import fl.controls.listClasses.ListData;
    import fl.core.InvalidationType;
    import fl.data.DataProvider;
    import flash.events.Event;
	
	//改善時
	import fl.controls.listClasses.CellRenderer;
	import fl.controls.listClasses.ListData;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;

	import fl.core.UIComponent;
    import fl.controls.listClasses.CellRenderer;

    /**
     * This class creates a custom cell renderer which displays an image in a cell.
     * Make sure the class is marked "public" and in the case of our custom cell renderer, 
     * extends the UILoader class and implements the ICellRenderer interface.
     */
    public class JacketCellRenderer extends UILoader implements ICellRenderer {
       
	   
	   
	  //  public function JacketCellRenderer() {
//            super();
//        }
//
//        private static var defaultStyles:Object = {
//            upSkin:"cellRendererTestSkin",
//            downSkin:"cellRendererTestSkin",
//            overSkin:"cellRendererTestSkin",
//            disabledSkin:"cellRendererTestSkin",
//			selectedUpSkin: "cellRendererTestSkin"
//        };
//
//        public static function getStyleDefinition():Object {
//            return UIComponent.mergeStyles(defaultStyles, CellRenderer.getStyleDefinition());
//        }
	   
	   
	   
	   
	   
	   
//	   /**
//         * Constructor.
//         */
//        public function JacketCellRenderer():void {
//            super();
//        }
//
//        /**
//         * This method returns the style definition object from the CellRenderer class.
//         */
//        public static function getStyleDefinition():Object {
//            return CellRenderer.getStyleDefinition();
//        }
//
//        /** 
//         * This method overrides the inherited drawBackground() method and sets the renderer's
//         * upSkin style based on the row's rowColor value in the data provider. For example, 
//         * if the item's rowColor value is "green," the upSkin style is set to the 
//         * CellRenderer_upSkinGreen linkage in the library. If the rowColor value is "red," the
//         * upSkin style is set to the CellRenderer_upSkinRed linkage in the library.
//         */
//        override protected function drawBackground():void {
//            //switch (data.rowColor) {
	//			if(data.data != null){
	//				var mc:MovieClip=MovieClip(data.data);
	//				mc.scaleX=1;
	//				mc.alpha=0.2;
	//				trace(mc.width);
	//				setStyle("upSkin",mc);
	//				//setStyle("upSkin",cellRendererTestSkin);
	//			}else{
	//				setStyle("upSkin",cellRendererTestSkin);
	//			}
//			super.drawBackground();
//			//listData=new ListData(listData.label, null, listData.owner, listData.index, listData.row, listData.column);
//			//listData=new ListData(listData.label, listData.data, listData.owner, listData.index, listData.row, listData.column);
//        }

	   
	   
	   
		protected var _data:Object;
        protected var _listData:ListData;
        protected var _selected:Boolean;

     
        public function JacketCellRenderer():void {
            super();
        }

       
        public function get data():Object {
            return _data;
        }
      
        public function set data(value:Object):void {
            _data = value;
			source = value.data;
			scaleContent=false;		//セルのサイズに応じてインスタンスの縮尺が行われるかどうか
			
        }

      
        public function get listData():ListData {
            return _listData;
			
        }
       
        public function set listData(value:ListData):void {
            _listData = value;
            invalidate(InvalidationType.DATA);
            invalidate(InvalidationType.STATE);
        }

      
        public function get selected():Boolean {
            return _selected;
        }
      
        public function set selected(value:Boolean):void {
            _selected = value;
            invalidate(InvalidationType.STATE);
        }

       
        public function setMouseState(state:String):void {
			
        }		
    }
}