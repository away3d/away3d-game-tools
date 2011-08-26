package age.input
{

import age.input.data.MouseActions;
import age.input.events.InputEvent;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Vector3D;

public class MouseInputContext extends InputContext
{
	private var _display:Sprite;

	protected var _mouseIsDown:Boolean;
	protected var _mousePositionCurrent:Vector3D;
	protected var _mousePositionLast:Vector3D;

	public var mouseInputFactorX:Number = 1;
	public var mouseInputFactorY:Number = 1;

	public function MouseInputContext(display:Sprite)
	{
		super();

		_display = display;
		_display.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		_display.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		_display.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);

		_mousePositionCurrent = new Vector3D();
		_mousePositionLast = new Vector3D();
	}

	override protected function processInput():void
	{
		for(var i:uint; i < _mappedCodes.length; i++)
		{
			var code:uint = _mappedCodes[i];
			var evt:InputEvent = _eventMappings[code];

			if(_mouseIsDown)
			{
				switch(code)
				{
					case MouseActions.DRAG_X:
						var dx:Number = _mousePositionCurrent.x - _mousePositionLast.x;
						_mousePositionLast.x = _mousePositionCurrent.x;
						evt.amount = dx * mouseInputFactorX;
						break;
					case MouseActions.DRAG_Y:
						var dy:Number = _mousePositionCurrent.y - _mousePositionLast.y;
						_mousePositionLast.y = _mousePositionCurrent.y;
						evt.amount = dy * mouseInputFactorY;
						break;
				}

				dispatchEvent(evt);
			}
		}
	}

	private function mouseDownHandler(evt:MouseEvent):void
	{
		_mousePositionLast.x = _mousePositionCurrent.x;
		_mousePositionLast.y = _mousePositionCurrent.y;
		_mouseIsDown = true;
	}

	private function mouseUpHandler(evt:MouseEvent):void
	{
		_mouseIsDown = false;
	}

	private function mouseMoveHandler(evt:MouseEvent):void
	{
		_mousePositionCurrent.x = _display.mouseX;
		_mousePositionCurrent.y = _display.mouseY;
	}
}
}
