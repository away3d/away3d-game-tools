package agt.input.contexts
{

	import agt.input.*;

	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;

	public class KeyboardInputContext extends InputContextBase implements IInputContext
	{
		private var _keysDown:Dictionary;
		private var _inputMappings:Object;

		public function KeyboardInputContext(context:EventDispatcher)
		{
			super();

			_keysDown = new Dictionary();
			_inputMappings = new Object();

			context.addEventListener(KeyboardEvent.KEY_DOWN, keyPressedHandler);
			context.addEventListener(KeyboardEvent.KEY_UP, keyReleasedHandler);
		}

		public function update():void
		{
			// no actions need to be performed on update for this context
		}

		public function map(inputType:String, ...keyCodes):void
		{
//			mapWithAmount(inputType, 0, keyCodes);
			mapWithAmount.apply(this, [inputType, 0].concat(keyCodes));
		}

		public function mapWithAmount(inputType:String, amount:Number, ...keyCodes):void
		{
			if(!_inputMappings.hasOwnProperty(inputType))
				_inputMappings[inputType] = new KeyboardMapping();

			_inputMappings[inputType].addKeyCombo(Vector.<uint>(keyCodes), amount);

			_implementedInputs.push(inputType);
		}

		public function inputActive(inputType:String):Boolean
		{
			if(_inputMappings[inputType])
			{
				outer: for each(var keyCombo:Vector.<uint> in _inputMappings[inputType].keyCombos)
				{
					for each(var keyCode:uint in keyCombo)
					{
						if(!_keysDown[keyCode])
							continue outer;
					}
					return true;
				}
			}
			return false;
		}

		public function inputAmount(inputType:String):Number
		{
			if(_inputMappings[inputType])
			{
				outer: for each(var keyCombo:Vector.<uint> in _inputMappings[inputType].keyCombos)
				{
					for each(var keyCode:uint in keyCombo)
					{
						if(!_keysDown[keyCode])
							continue outer;
					}
					return _inputMappings[inputType].amount(keyCombo);
				}
			}
			return 0;
		}

		private function keyPressedHandler(evt:KeyboardEvent):void
		{
			_keysDown[evt.keyCode] = true;
		}

		private function keyReleasedHandler(evt:KeyboardEvent):void
		{
			_keysDown[evt.keyCode] = false;
		}
	}
}

import flash.utils.Dictionary;

internal class KeyboardMapping
{
	private var _keyCombos:Vector.<Vector.<uint>>;
	private var _amounts:Dictionary;

	public function KeyboardMapping()
	{
		_keyCombos = new Vector.<Vector.<uint>>();
		_amounts = new Dictionary();
	}

	public function addKeyCombo(keyCombo:Vector.<uint>, amount:Number):void
	{
		_keyCombos.push(keyCombo);
		_amounts[keyCombo] = amount;
		_keyCombos = _keyCombos.sort(compareByLength);
//		trace("new key combo");
//		for(var i:uint; i < _keyCombos.length; ++i)
//			trace(_keyCombos[i].length);
	}

	public function get keyCombos():Vector.<Vector.<uint>>
	{
		return _keyCombos;
	}

	public function amount(keyCombo:Vector.<uint>):Number
	{
		return _amounts[keyCombo];
	}

	private function compareByLength(keyComboA:Vector.<uint>, keyComboB:Vector.<uint>):Number
	{
		if(keyComboA.length > keyComboB.length)
			return -1;
		else
			return 1;
	}
}
