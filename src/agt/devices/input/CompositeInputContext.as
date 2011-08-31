package agt.devices.input {
	import agt.devices.input.events.InputEvent;

	public class CompositeInputContext extends InputContext {
		private var _inputContexts : Vector.<InputContext>;

		public function CompositeInputContext() {
			super();
			_inputContexts = new Vector.<InputContext>();
		}

		override protected function processInput() : void {
			for (var i : uint; i < _inputContexts.length; ++i)
				_inputContexts[i].update();
		}

		public function addContext(context : InputContext) : void {
			_inputContexts.push(context);
			context.addEventListener(InputEvent.MOVE_X, forwardEvent);
			context.addEventListener(InputEvent.MOVE_Y, forwardEvent);
			context.addEventListener(InputEvent.MOVE_Z, forwardEvent);
			context.addEventListener(InputEvent.ROTATE_X, forwardEvent);
			context.addEventListener(InputEvent.ROTATE_Y, forwardEvent);
			context.addEventListener(InputEvent.ROTATE_Z, forwardEvent);
		}

		private function forwardEvent(evt : InputEvent) : void {
			dispatchEvent(evt);
		}
	}
}
