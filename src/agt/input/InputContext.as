package agt.input
{

	import flash.events.EventDispatcher;

	public class InputContext extends EventDispatcher
	{
		public var enabled:Boolean;

		public function InputContext()
		{
			enabled = true;
			super();
		}

		public function update():void
		{
			if(!enabled)
				return;

			processContinuousInput();
		}

		protected function processContinuousInput():void
		{
			throw new Error("Method must be overriden.");
		}
	}
}
