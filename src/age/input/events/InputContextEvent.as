package age.input.events
{

import flash.events.Event;

public class InputContextEvent extends Event
{
	public var amount:Number;

	public function InputContextEvent(type:String, amount:Number = 0, bubbles:Boolean = false, cancelable:Boolean = false)
	{
		this.amount = amount;
		super(type, bubbles, cancelable);
	}

	override public function clone():Event
	{
		return new InputContextEvent(type, amount, bubbles, cancelable);
	}
}
}
