package agt.input
{

	import flash.events.EventDispatcher;

	public class InputContextBase extends EventDispatcher
	{
		protected var _implementedInputs:Vector.<String>;

		public function InputContextBase()
		{
			super();

			_implementedInputs = new Vector.<String>();
		}

		public function inputImplemented(inputType : String) : Boolean
		{
			return (_implementedInputs.indexOf(inputType) >= 0);
		}
	}
}
