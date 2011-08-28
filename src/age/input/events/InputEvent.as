package age.input.events
{

import flash.events.Event;

public class InputEvent extends Event
{
	public static const MOVE_X:String = "move_x";
	public static const MOVE_Y:String = "move_y";
	public static const MOVE_Z:String = "move_z";
	public static const ROTATE_X:String = "rotate_x";
	public static const ROTATE_Y:String = "rotate_y";
	public static const ROTATE_Z:String = "rotate_z";

	public var amount:Number;
	public var multiplier:Number;

	public function InputEvent(type:String, amount:Number = 0, multiplier:Number = 1, bubbles:Boolean = false, cancelable:Boolean = false)
	{
		this.amount = amount;
		this.multiplier = multiplier;
		super(type, bubbles, cancelable);
	}

	override public function clone():Event
	{
		return new InputEvent(type, amount, multiplier, bubbles, cancelable);
	}
}
}
