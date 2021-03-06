package agt.input
{

	public class InputContextBase
	{
		protected var _implementedInputs:Vector.<String>;

		public function InputContextBase()
		{
			super();

			_implementedInputs = new Vector.<String>();
		}

		public function inputImplemented(inputType:String):Boolean
		{
			return _implementedInputs.indexOf(inputType) >= 0;
		}
	}
}
