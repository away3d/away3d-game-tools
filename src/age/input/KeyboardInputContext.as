package age.input
{

import age.input.events.InputContextEvent;

import flash.display.Stage;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.utils.Dictionary;

public class KeyboardInputContext extends InputContext
{
	private var _keysDown:Dictionary;

	public function KeyboardInputContext(stage:Stage)
	{
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);


		_keysDown = new Dictionary();

		super();
	}

	override protected function processInput():void
	{
		// dispatch events from key mappings
		for(var i:uint; i < _mappedCodes.length; i++)
		{
			var keyCode:uint = _mappedCodes[i];
			if(keyIsDown(keyCode))
			{
				var evt:InputContextEvent = _eventMappings[keyCode];
				dispatchEvent(evt);
			}
		}
	}

	private function keyDownHandler(evt:KeyboardEvent):void
	{
		_keysDown[evt.keyCode] = true;
	}

	private function keyUpHandler(evt:KeyboardEvent):void
	{
		_keysDown[evt.keyCode] = false;
	}

	private function keyIsDown(keyCode:uint):Boolean
    {
        return _keysDown[keyCode] ? _keysDown[keyCode] : false;
    }
}
}
