package age.input
{

import age.input.events.InputEvent;

import flash.events.EventDispatcher;
import flash.utils.Dictionary;

public class InputContext extends EventDispatcher
{
	public var enabled:Boolean;

	protected var _eventMappings:Dictionary;
	protected var _continuity:Dictionary;
	protected var _mappedCodes:Vector.<uint>;

	public function InputContext()
	{
		enabled = true;
		_mappedCodes = new Vector.<uint>();
		_eventMappings = new Dictionary();
		_continuity = new Dictionary();
		super();
	}

	public function update():void
	{
		if(!enabled)
			return;

		processInput();
	}

	public function map(inputCode:uint, event:InputEvent, continuous:Boolean = true):void
	{
		_mappedCodes.push(inputCode);
		_eventMappings[inputCode] = event;
		_continuity[inputCode] = continuous;
	}

	protected function processInput():void
	{
		throw new Error("Method must be overriden.");
	}
}
}
