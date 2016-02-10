//--*-coding:utf-8-*--

package {
    public class ChangeMapMarkerWindow extends AddMapMarkerWindow {
        import mx.managers.PopUpManager;
        
        private var mapMarker:MapMarker;
        
        public function setMapMarker(mapMarker_:MapMarker):void {
            mapMarker = mapMarker_;
        }
        
        protected override function init():void {
            title = Language.s.changeMapMarkerWindowTitle;
            
            this.isCreate = false;
            this.changeExecuteSpace.height = 25;
            this.height += 25;
            
            message.text = mapMarker.getMessage();
            colorPicker.selectedColor = mapMarker.getColor();
            isPaint.selected = mapMarker.isPaintMode();
            mapMarkerWidth.value = mapMarker.getWidth();
            mapMarkerHeigth.value = mapMarker.getHeight();
            isFixed.selected = ( ! mapMarker.getDraggable());
        }
        
        override protected function setDragEvent():void {
        }
        
        
        override protected function changeMapMarker():void {
            try{
                var guiInputSender:GuiInputSender = DodontoF_Main.getInstance().getGuiInputSender();
                
                mapMarker.setMessage( message.text );
                mapMarker.setColor( colorPicker.selectedColor );
                mapMarker.setPaintMode( isPaint.selected );
                mapMarker.setWidth( mapMarkerWidth.value );
                mapMarker.setHeight( mapMarkerHeigth.value );
                mapMarker.setDraggable( ! isFixed.selected );
                mapMarker.updateImage();
                
                guiInputSender.getSender().changeCharacter( mapMarker.getJsonData() );
                PopUpManager.removePopUp(this);
            } catch(error:Error) {
                this.status = error.message;
            }
        }
    }
}


