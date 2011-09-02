package agt.input.device
{

	import agt.input.*;

import agt.input.device.data.MouseActions;
import agt.input.events.InputEvent;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Vector3D;

public class MouseInputContext extends InputContext
{
	private var _display:Sprite;
	private var _wheelDelta:Number = 0;
	private var _mouseIsDown:Boolean;
	private var _mousePositionCurrent:Vector3D;
	private var _mousePositionLast:Vector3D;

	private var _mouseInputFactorX:Number = 1;
	private var _mouseInputFactorY:Number = 1;
	private var _mouseInputFactorWheel:Number = 25;

	public function MouseInputContext(display:Sprite)
	{
		super();

		_display = display;
		_display.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		_display.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		_display.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		_display.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);

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
						evt.amount = positionDeltaX();
						dispatchEvent(evt);
						break;
					case MouseActions.DRAG_Y:
						evt.amount = positionDeltaY();
						dispatchEvent(evt);
						break;
				}
			} else
			{
				switch(code)
				{
					case MouseActions.MOVE_X:
						evt.amount = positionDeltaX();
						dispatchEvent(evt);
						break;
					case MouseActions.MOVE_Y:
						evt.amount = positionDeltaY();
						dispatchEvent(evt);
						break;
				}
			}

			if(code == MouseActions.WHEEL)
			{
				evt.amount = _wheelDelta * _mouseInputFactorWheel;
				dispatchEvent(evt);
			}
		}

		_wheelDelta = 0;
	}

	private function positionDeltaX():Number
	{
		var dx:Number = (_mousePositionCurrent.x - _mousePositionLast.x)*_mouseInputFactorX;
		_mousePositionLast.x = _mousePositionCurrent.x;
		return dx;
	}

	private function positionDeltaY():Number
	{
		var dy:Number = (_mousePositionCurrent.y - _mousePositionLast.y)*_mouseInputFactorY;
		_mousePositionLast.y = _mousePositionCurrent.y;
		return dy;
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

	private function mouseWheelHandler(evt:MouseEvent):void
	{
		_wheelDelta = evt.delta;
	}

	public function get mouseInputFactorY():Number
	{
		return _mouseInputFactorY;
	}

	public function set mouseInputFactorY(value:Number):void
	{
		_mouseInputFactorY = value;
	}

	public function get mouseInputFactorX():Number
	{
		return _mouseInputFactorX;
	}

	public function set mouseInputFactorX(value:Number):void
	{
		_mouseInputFactorX = value;
	}

	public function get mouseInputFactorWheel():Number
	{
		return _mouseInputFactorWheel;
	}

	public function set mouseInputFactorWheel(value:Number):void
	{
		_mouseInputFactorWheel = value;
	}
}
}
