package age.camera.events
{

import age.input.events.InputContextEvent;

import flash.events.Event;

public class CameraControllerEvent extends InputContextEvent
{
	public static const MOVE_X:String = "move_x";
	public static const MOVE_Y:String = "move_y";
	public static const MOVE_Z:String = "move_z";
	public static const ROTATE_X:String = "rotate_x";
	public static const ROTATE_Y:String = "rotate_y";
	public static const ROTATE_Z:String = "rotate_z";

	public function CameraControllerEvent(type:String, amount:Number = 0, bubbles:Boolean = false, cancelable:Boolean = false)
	{
		super(type, amount, bubbles, cancelable);
	}

	override public function clone():Event
	{
		return new CameraControllerEvent(type, amount, bubbles, cancelable);
	}
}
}
