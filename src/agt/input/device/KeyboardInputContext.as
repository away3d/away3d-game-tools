package agt.input.device
{

	import agt.input.*;

	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;

	public class KeyboardInputContext extends InputContextBase implements IInputContext
	{
		private var _keysDown:Dictionary;
		private var _inputMappings:Object;
		private var _inputAmounts:Object;

		public function KeyboardInputContext(context:EventDispatcher)
		{
			super();

			_keysDown = new Dictionary();
			_inputMappings = new Object();
			_inputAmounts = new Object();

			context.addEventListener(KeyboardEvent.KEY_DOWN, keyPressedHandler);
			context.addEventListener(KeyboardEvent.KEY_UP, keyReleasedHandler);
		}

		// -----------------------
		// public
		// -----------------------

		public function map(inputType:String, ...keyCodes):void
		{
			mapWithAmount.apply(this, [NaN].concat(keyCodes));
		}

		public function mapWithAmount(inputType:String, amount:Number, ...keyCodes):void
		{
			if(!_inputMappings.hasOwnProperty(inputType))
			{
				_inputMappings[inputType] = new Vector.<Vector.<uint>>();
				_inputAmounts[inputType] = new Vector.<Number>();
			}

			_inputMappings[inputType].push(Vector.<uint>(keyCodes));
			_inputAmounts[inputType].push(amount);

			_implementedInputs.push(inputType);
		}

		public function inputActive(inputType:String):Boolean
		{
			var mappingsForThisInputType:Vector.<Vector.<uint>> = _inputMappings[inputType];

			if(mappingsForThisInputType)
			{
				outer: for each(var mapping:Vector.<uint> in mappingsForThisInputType)
				{
					for each(var keyCode:uint in mapping)
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
			var mappingsForThisInputType:Vector.<Vector.<uint>> = _inputMappings[inputType];

			if(mappingsForThisInputType)
			{
				var mappingNum:uint;
				outer: for each(var mapping:Vector.<uint> in mappingsForThisInputType)
				{
					for each(var keyCode:uint in mapping)
					{
						if(!_keysDown[keyCode])
						{
							mappingNum++;
							continue outer;
						}
					}

					return _inputAmounts[inputType][mappingNum];
				}
			}

			return 0;
		}

		// -----------------------
		// private
		// -----------------------

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
