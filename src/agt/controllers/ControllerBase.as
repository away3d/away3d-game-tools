package agt.controllers
{

	import agt.input.IInputContext;

	public class ControllerBase
	{
		protected var _inputContext:IInputContext;

		public function ControllerBase()
		{
			super();
		}

		public function get inputContext():IInputContext
		{
			return _inputContext;
		}

		public function set inputContext(value:IInputContext):void
		{
			_inputContext = value;
		}

		public function update():void
		{
			if(_inputContext)
				_inputContext.update();
		}
	}
}
