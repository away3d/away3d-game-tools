package agt.input
{

	import agt.input.events.InputEvent;

	public class CompositeInputContext extends InputContextBase
	{
		private var _inputContexts:Vector.<InputContextBase>;

		public function CompositeInputContext()
		{
			super();
			_inputContexts = new Vector.<InputContextBase>();
		}

		override protected function processContinuousInput():void
		{
			for(var i:uint; i < _inputContexts.length; ++i)
			{
				_inputContexts[i].update();
			}
		}

		public function addContext(context:InputContextBase):void
		{
			_inputContexts.push(context);
			context.addEventListener(InputEvent.MOVE_X, forwardEvent);
			context.addEventListener(InputEvent.MOVE_Y, forwardEvent);
			context.addEventListener(InputEvent.MOVE_Z, forwardEvent);
			context.addEventListener(InputEvent.ROTATE_X, forwardEvent);
			context.addEventListener(InputEvent.ROTATE_Y, forwardEvent);
			context.addEventListener(InputEvent.ROTATE_Z, forwardEvent);
		}

		private function forwardEvent(evt:InputEvent):void
		{
			dispatchEvent(evt);
		}
	}
}
