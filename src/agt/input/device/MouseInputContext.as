package agt.input.device
{

	import agt.input.*;

	import agt.input.events.InputEvent;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;

	public class MouseInputContext extends InputContext
	{
		private var _display:Sprite;
		private var _mouseIsDown:Boolean;
		private var _mousePositionCurrent:Vector3D;
		private var _mousePositionLast:Vector3D;
		private var _deltaX:Number = 0;
		private var _deltaY:Number = 0;

		public var mouseInputFactorX:Number = 1;
		public var mouseInputFactorY:Number = 1;
		public var mouseInputFactorWheel:Number = 25;

		private var _onMouseMoveXEvent:InputEvent;
		private var _onMouseMoveYEvent:InputEvent;
		private var _onMouseDragXEvent:InputEvent;
		private var _onMouseDragYEvent:InputEvent;
		private var _onMouseWheelEvent:InputEvent;

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

		public function mapOnDragX(event:InputEvent):void
		{
			_onMouseDragXEvent = event;
		}

		public function mapOnDragY(event:InputEvent):void
		{
			_onMouseDragYEvent = event;
		}

		public function mapOnMoveX(event:InputEvent):void
		{
			_onMouseMoveXEvent = event;
		}

		public function mapOnMoveY(event:InputEvent):void
		{
			_onMouseMoveYEvent = event;
		}

		public function mapOnWheel(event:InputEvent):void
		{
			_onMouseWheelEvent = event;
		}

		private function updateDeltas():void
		{
			_deltaX = (_mousePositionCurrent.x - _mousePositionLast.x)*mouseInputFactorX;
			_deltaY = (_mousePositionCurrent.y - _mousePositionLast.y)*mouseInputFactorY;
			_mousePositionLast.x = _mousePositionCurrent.x;
			_mousePositionLast.y = _mousePositionCurrent.y;
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

			updateDeltas();

			if(!enabled)
				return;

			if(_onMouseMoveXEvent)
			{
				_onMouseMoveXEvent.amount = _deltaX;
				dispatchEvent(_onMouseMoveXEvent);
			}

			if(_onMouseMoveYEvent)
			{
				_onMouseMoveYEvent.amount = _deltaY;
				dispatchEvent(_onMouseMoveYEvent);
			}

			if(_mouseIsDown && _onMouseDragXEvent)
			{
				_onMouseDragXEvent.amount = _deltaX;
				dispatchEvent(_onMouseDragXEvent);
			}

			if(_mouseIsDown && _onMouseDragYEvent)
			{
				_onMouseDragYEvent.amount = _deltaY;
				dispatchEvent(_onMouseDragYEvent);
			}
		}

		private function mouseWheelHandler(evt:MouseEvent):void
		{
			if(!enabled)
				return;

			if(_onMouseWheelEvent)
			{
				_onMouseWheelEvent.amount = evt.delta * mouseInputFactorWheel;
				dispatchEvent(_onMouseWheelEvent);
			}
		}
	}
}
