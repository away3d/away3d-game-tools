package agt.controllers
{

	import agt.input.InputContext;
	import agt.input.events.InputEvent;

	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	public class ControllerBase extends EventDispatcher
	{
		private var _inputContext:InputContext;
		protected var _eventMapping:Dictionary;

		public function ControllerBase()
		{
			_eventMapping = new Dictionary();
			super();
		}

		public function update():void
		{
			if(_inputContext)
				_inputContext.update();
		}

		protected function registerEvent(eventType:String, func:Function):void
		{
//			trace("ControllerBase.as - registering event of type: " + eventType);
			_eventMapping[eventType] = func;
			_inputContext.addEventListener(eventType, processEvent);
		}

		private function processEvent(evt:InputEvent):void
		{
//			trace("ControllerBase.as - processing event type: " + evt.type + ", amount: " + evt.amount);
			_eventMapping[evt.type](evt.amount);
		}

		public function get inputContext():InputContext
		{
			return _inputContext;
		}

		public function set inputContext(value:InputContext):void
		{
			_inputContext = value;
		}
	}
}
