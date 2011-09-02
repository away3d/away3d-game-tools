package agt.input.device
{

	import agt.input.*;

import agt.input.events.InputEvent;

import flash.display.Stage;
import flash.events.KeyboardEvent;
import flash.utils.Dictionary;

public class KeyboardInputContext extends InputContext
{
	private var _keysDown:Dictionary;
	private var _onAnyRegisteredKeyUpEvent:InputEvent;
	private var _onAllRegisteredKeysUpEvent:InputEvent;

	public function KeyboardInputContext(stage:Stage)
	{
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);

		_keysDown = new Dictionary();

		super();
	}

	public function mapOnAnyKeyUp(event:InputEvent):void
	{
		_onAnyRegisteredKeyUpEvent = event;
	}

	public function mapOnAllKeysUp(event:InputEvent):void
	{
		_onAnyRegisteredKeyUpEvent = event;
	}

	override protected function processInput():void
	{
		// check multipliers
		var k:Number = 1;
		if(_multiplierCode >= 0 && keyIsDown(_multiplierCode))
			k = _multiplierValue;

		// dispatch events from any pressed key mappings
		for(var i:uint; i < _mappedCodes.length; i++)
		{
			var keyCode:uint = _mappedCodes[i];
			if(_continuity[keyCode] && keyIsDown(keyCode))
			{
				var evt:InputEvent = _eventMappings[keyCode];
				evt.multiplier = k;
				dispatchEvent(evt);
			}
		}
	}

	private function keyDownHandler(evt:KeyboardEvent):void
	{
		_keysDown[evt.keyCode] = true;

		// dispatch event from key mapping?
		if(_continuity[evt.keyCode] != null && !_continuity[evt.keyCode])
			dispatchEvent(_eventMappings[evt.keyCode]);
	}

	private function keyUpHandler(evt:KeyboardEvent):void
	{
		_keysDown[evt.keyCode] = false;

		// analyze up keys
		if(_onAnyRegisteredKeyUpEvent || _onAllRegisteredKeysUpEvent)
		{
			var allRegisteredKeysAreUp:Boolean = true;
			var anyRegisteredKeyIsUp:Boolean = false;

			// sweep all registered keys
			for(var i:uint; i < _mappedCodes.length; i++)
			{
				var keyCode:uint = _mappedCodes[i];
				if(keyIsDown(keyCode))
					allRegisteredKeysAreUp = false;
				else
					anyRegisteredKeyIsUp = true;
			}

			// dispatch event for any registered key being up
			if(_onAnyRegisteredKeyUpEvent && anyRegisteredKeyIsUp)
				dispatchEvent(_onAnyRegisteredKeyUpEvent);

			// dispatch event for all registered keys being up?
			if(_onAllRegisteredKeysUpEvent && allRegisteredKeysAreUp)
				dispatchEvent(_onAllRegisteredKeysUpEvent);
		}
	}

	private function keyIsDown(keyCode:uint):Boolean
	{
		return _keysDown[keyCode] ? _keysDown[keyCode] : false;
	}
}
}
