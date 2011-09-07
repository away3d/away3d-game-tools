package agt.input
{

	public class CompositeInputContext extends InputContextBase implements IInputContext
	{
		private var _inputContexts:Vector.<IInputContext>;

		public function CompositeInputContext()
		{
			super();

			_inputContexts = new Vector.<IInputContext>();
		}

		public function update():void
		{
			var len:uint = _inputContexts.length;
			for(var i:uint; i < len; ++i)
				_inputContexts[i].update();
		}

		public function inputActive(inputType:String):Boolean
		{
			var len:uint = _inputContexts.length;
			for(var i:uint; i < len; ++i)
			{
				if(_inputContexts[i].inputActive(inputType))
					return true;
			}

			return false;
		}

		public function inputAmount(inputType:String):Number
		{
			var total:Number = 0;
			var len:uint = _inputContexts.length;
			for(var i:uint; i < len; ++i)
				total += _inputContexts[i].inputAmount(inputType);

			return total;
		}

		public function addContext(context:InputContextBase):void
		{
			_inputContexts.push(context);
		}
	}
}
