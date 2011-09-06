package agt.input.ai
{

	import agt.input.InputContext;
	import agt.input.events.InputEvent;

	public class AIStupidInputContext extends InputContext
	{
		private var _walkEvent:InputEvent;
		private var _turnRightEvent:InputEvent;
		private var _turnLeftEvent:InputEvent;
		private var _currentEvent:InputEvent;
		private var _stopEvent:InputEvent;
		private var _nextChance:Number = 0;

		public function AIStupidInputContext()
		{
			super();

			_walkEvent = new InputEvent(InputEvent.MOVE_Z, 30); // TODO: Set these externally
			_turnRightEvent = new InputEvent(InputEvent.ROTATE_Y, 5);
			_turnLeftEvent = new InputEvent(InputEvent.ROTATE_Y, 5);
			_stopEvent = new InputEvent(InputEvent.STOP);
		}

		override protected function processContinuousInput():void
		{
			if(Math.random() > 0.9)
			{
				var options:Number = 5;
				var delta:Number = 1/options;

				var r:Number = Math.random();
				if(r > 4 * delta)
				{
					_currentEvent = _walkEvent;
					_nextChance = 0.99;
				}
				else if(r > 3 * delta)
				{
					_currentEvent = _turnRightEvent;
					_nextChance = 0.9;
				}
				else if(r > 2 * delta)
				{
					_currentEvent = _turnLeftEvent;
					_nextChance = 0.9;
				}
				else if(r > delta)
				{
					_currentEvent = _stopEvent;
					_nextChance = 0.99;
				}
				else
				{
					_currentEvent = null;
					_nextChance = 0.95;
				}
			}

			if(_currentEvent != null)
				dispatchEvent(_currentEvent);
		}
	}
}
