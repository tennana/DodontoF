//--*-coding:utf-8-*--

package {
    import mx.managers.PopUpManager;
    
    public class ChangeCutInMovieWindow extends AddCutInMovieWindow {
        
        private var effectId:String = "";
        private var cutInInfo:Object = new Object();
        
        public function init(cutInInfo_:Object):void {
            cutInInfo = cutInInfo_;
            
            title = Language.s.changeCutInWindowTitle;
            executeButton.label = Language.s.changeButton;
            
            effectId = cutInInfo.effectId;
            
            message.text = cutInInfo.message;
            if( cutInInfo.displaySeconds != null ) {
                displaySeconds.value = cutInInfo.displaySeconds;
            }
            
            imageWidth.value = parseInt(cutInInfo.width);
            imageHeight.value = parseInt(cutInInfo.height);
            
            if(  cutInInfo.cutInTag != null ) {
                cutInTag.text = cutInInfo.cutInTag;
            }

            
            if( cutInInfo.volume == null ) {
                cutInInfo.volume = 0.1;
            }
            volume.value = parseFloat(cutInInfo.volume);
            
            if( cutInInfo.isTail == null ) {
                isTail.selected = true;
            } else {
                isTail.selected = cutInInfo.isTail;
            }
            
            Utils.selectComboBox(positionComboBox, cutInInfo.position, 'data', 3);
            
            var imageSourceText:String = imageSelecter.getSelectedImageUrl();
            checkImageUrl(imageSourceText);
        }
        
        override public function imageLoadComplete():void {
            imageSelecter.selectImageUrl( cutInInfo.source );
            soundSourceEdit.text = cutInInfo.soundSource;
            isSoundLoopCheck.selected = cutInInfo.isSoundLoop;
            printPreview();
        }
        
        override protected function getCommandParams():Object {
            var params:Object = super.getCommandParams();
            params.effectId = effectId;
            
            return params;
        }
        
        protected override function execute():void {
            var index:int = getEffectIndex(effectId)
            if( index == -1 ) {
                PopUpManager.removePopUp(this);
            }
            
            var params:Object = getCommandParams();
            CutInBase.cutInInfos[index] = params;
            
            var guiInputSender:GuiInputSender = DodontoF_Main.getInstance().getGuiInputSender();
            guiInputSender.changeEffect(params);
            
            PopUpManager.removePopUp(this);
        }
        
        static public function getEffectIndex(effectId:String):int {
            var array:Array = CutInBase.cutInInfos;
            
            for(var i:int ; i < array.length ; i++) {
                var info:Object = array[i];
                info.effectId = effectId;
                return i;
            }
            return -1;
        }
        
    }
}

