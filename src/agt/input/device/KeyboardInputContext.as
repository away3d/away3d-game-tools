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
		private var _keyPressedMappings:Dictionary;
		private var _keyReleasedMappings:Dictionary;
		private var _keyDownMappings:Dictionary;
		private var _keyComboDownMappings:Dictionary;
		private var _onAllDownKeysReleasedEvent:InputEvent;

		public function KeyboardInputContext(stage:Stage)
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressedHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyReleasedHandler);

			_keysDown = new Dictionary();
			_keyPressedMappings = new Dictionary();
			_keyReleasedMappings = new Dictionary();
			_keyDownMappings = new Dictionary();
			_keyComboDownMappings = new Dictionary();

			super();
		}

		// -----------------------
		// public
		// -----------------------

		public function mapOnKeyComboDown(event:InputEvent, ...keyCodes):void
		{
			_keyComboDownMappings[keyCodes] = event;
		}

		public function mapOnKeyPressed(event:InputEvent, keyCode:uint):void
		{
			_keyPressedMappings[keyCode] = event;
		}

		public function mapOnKeyReleased(event:InputEvent, keyCode:uint):void
		{
			_keyReleasedMappings[keyCode] = event;
		}

		public function mapOnKeyDown(event:InputEvent, keyCode:uint):void
		{
			_keyDownMappings[keyCode] = event;
		}

		public function mapOnAllDownKeysReleased(event:InputEvent):void
		{
			_onAllDownKeysReleasedEvent = event;
		}

		// ----------------------------
		// InputContext.as overrides
		// ----------------------------

		override protected function processContinuousInput():void
		{
			// reset non eligible key codes
			var nonEligibleKeyCodes:Vector.<uint> = new Vector.<uint>();

			// check mapped down key combos
			var i:uint, j:uint;
			for(var keyCodes:Object in _keyComboDownMappings)
			{
				// check if any key in the combo is not pressed
				var keyCodesArray:Array = String(keyCodes).split(",");
				var allPressed:Boolean = true;
				for(i = 0; i < keyCodesArray.length; ++i)
				{
					if(!keyIsDown(keyCodesArray[i]))
					{
						allPressed = false;
						break;
					}
				}

				// if all pressed, dispatch event and consider pressed keys
				// non eligible for single down keys
				if(allPressed)
				{
					dispatchEvent(_keyComboDownMappings[keyCodes]);
					for(j = 0; j < keyCodesArray.length; ++j)
						nonEligibleKeyCodes.push(keyCodesArray[j]);
				}
			}

			// check mapped down keys
			for(var keyCode:Object in _keyDownMappings)
			{
				var keyCodeUint:uint = uint(keyCode);
				if(nonEligibleKeyCodes.indexOf(keyCodeUint) == -1 && keyIsDown(keyCodeUint))
					dispatchEvent(_keyDownMappings[keyCode]);
			}
		}

		// -----------------------
		// private
		// -----------------------

		private function keyPressedHandler(evt:KeyboardEvent):void
		{
			_keysDown[evt.keyCode] = true;

			if(!enabled)
				return;

			// check mapped pressed keys
			if(_keyPressedMappings[evt.keyCode])
				dispatchEvent(_keyPressedMappings[evt.keyCode]);
		}

		private function keyReleasedHandler(evt:KeyboardEvent):void
		{
			_keysDown[evt.keyCode] = false;

			if(!enabled)
				return;

			// check mapped released keys
			if(_keyReleasedMappings[evt.keyCode])
				dispatchEvent(_keyReleasedMappings[evt.keyCode]);

			// report all down keys up?
			if(_onAllDownKeysReleasedEvent)
			{
				var allKeysUp:Boolean = true;
				for(var keyCode:Object in _keyDownMappings)
				{
					var keyCodeUint:uint = uint(keyCode);
					if(keyIsDown(keyCodeUint))
						allKeysUp = false;
				}
				if(allKeysUp)
					dispatchEvent(_onAllDownKeysReleasedEvent);
			}
		}

		private function keyIsDown(keyCode:uint):Boolean
		{
			return _keysDown[keyCode] ? _keysDown[keyCode] : false;
		}
	}
}
