//--*-coding:utf-8-*--

package {

    public class CutInCommandRollVisualDice extends CutInCommandBase {
        
        override protected function getCommand():String {
            return "rollVisualDice";
        }
        
        override protected function getPrintMessageText(params:Object):String {
            return params.chatMessage;
        }
        
        override protected function executeCommand(params:Object):void {
            Log.logging("CutInCommandRollVisualDice.executeCommand params", params);
            
            rollDice(params);
            
            executeGameCommand(params);
        }
        
        
        //汎用のダイスロール処理
        private function rollDice(params:Object):void {
            var randResults:Array = getRandResults(params);
            Log.logging("randResults", randResults);
            
            if( randResults == null ) {
                Log.logging("randResults is null.");
                return;
            }
            
            var resultText:String = getRollResultText(params);
            var power:int = params['power'];
            
            for(var i:int = 0 ; i < randResults.length ; i++) {
                var result:Array = randResults[i];
                rollDiceByRandResult(result, resultText, power);
            }
            
            getDiceBox().castDice();
        }
        
        private function rollDiceByRandResult(result:Array, resultText:String, power:int):void {
            if( (result == null) || (result.length != 2) ) {
                return;
            }
            
            var value:int = result[0];
            var diceType:int = result[1];
            
            if( ! DiceInfo.isValidDiceMax(diceType) ) {
                return;
            }
            
            if( diceType == 100 ) {
                addDice(100, getD10Value(value / 10), resultText, power);
                addDice( 10, getD10Value(value % 10), resultText, power);
            } else {
                addDice(diceType, value, resultText, power);
            }
        }
        
        private function getRandResults(params:Object):Array {
            if( ! isDiceBoxVisible() ) {
                Log.logging("diceBox invisible.");
                return null;
            }
            
            var randResults:Array = params.randResults;
            if( randResults == null ) {
                return null;
            }
            if( randResults.length == 0 ) {
                return null;
            }
            
            return randResults;
        }
        
        private function getD10Value(value:int):int {
            if( value == 0 ) {
                return 10;
            }
            return value;
        }
        
        private var diceBotResultReg:RegExp = /→\s*([^→]+)\Z/m;
        
        private function getRollResultText(params:Object):String {
            var message:String = params.chatMessage;
            if( message == null ) {
                return "";
            }
            
            message = Language.getKeywordText(message);
            
            var result:Object = diceBotResultReg.exec(message);
            
            if( result == null ) {
                return getSimpleMessage(message);
            }
            
            var resultText:String = result[1];
            Log.logging("resultText", resultText);
            
            return resultText;
        }
        
        private function getSimpleMessage(message:String):String {
            var markerList:Array = [" : ", ":"];
            var index:int = -1;
            
            for(var i:int = 0 ; i < markerList.length ; i++) {
                var marker:String = markerList[i];
                index = message.indexOf(marker);
                if( index != -1 ) {
                    index += (marker.length - 1)
                    break;
                }
            }
            
            if( index == -1 ) {
                return message;
            }
            
            return message.slice(index + 1);
        }
        
        private function addDice(diceType:int, value:int,
                                 text:String, power:int):void {
            
            if( ! isDiceBoxVisible() ) {
                Log.logging("diceBox invisible.");
                return;
            }
            
            var params:Object = {
                "resultValue" : value,
                "resultText" : text,
                "power" : power
            }
            
            getDiceBox().createDice('d' + diceType, params);
        }
        
        private function getDiceBox():DiceBox {
            var diceBox:DiceBox = DodontoF_Main.getInstance().getDiceBox();
            return diceBox;
        }
        
        private function isDiceBoxVisible():Boolean {
            var diceBox:DiceBox = getDiceBox();
            if( diceBox == null ) {
                return false;
            }
            
            return diceBox.visible;
        }
        
        
        
        private function executeGameCommand(params:Object):void {
            for each(var gameCommand:GameCommand in gameCommands) {
                if( Config.getInstance().isGameType( gameCommand.getGameType() )) {
                    gameCommand.executeCommand(params);
                    return;
                }
            }
        }
        
        private var gameCommands:Array = [new ElysionCommand(),
                                          new CardRankerCommand()];
        
    }
}
