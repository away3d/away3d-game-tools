package agt.input.contexts
{

	import agt.input.*;
	import agt.input.data.InputType;

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;

	public class MouseInputContext extends InputContextBase implements IInputContext
	{
		private var _context:Sprite;
		private var _mouseIsDown:Boolean;
		private var _mousePositionLast:Vector3D;
		private var _deltaX:Number;
		private var _deltaY:Number;
		private var _deltaWheel:Number;
		private var _stage:Stage;

		public var dragXMultiplier:Number = -5;
		public var dragYMultiplier:Number = 5;
		public var wheelMultiplier:Number = 50;

		private var _inputMethodX:String;
		private var _inputMethodY:String;

		public function MouseInputContext(context:Sprite, stage:Stage, translational:Boolean = false)
		{
			super();

			_context = context;
			_stage = stage;
			_context.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			_stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			_context.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);

			_mousePositionLast = new Vector3D();

			_deltaWheel = 0;

			if(translational)
			{
				_inputMethodX = InputType.TRANSLATE_X;
				_inputMethodY = InputType.TRANSLATE_Y;
			}
			else
			{
				_inputMethodX = InputType.ROTATE_X;
				_inputMethodY = InputType.ROTATE_Y;
			}
		}

		public function update():void
		{
			_deltaX = _context.mouseX - _mousePositionLast.x;
			_deltaY = _context.mouseY - _mousePositionLast.y;
			_mousePositionLast.x = _context.mouseX;
			_mousePositionLast.y = _context.mouseY;
		}

		public function inputActive(inputType:String):Boolean
		{
			if( inputType != _inputMethodY && inputType != _inputMethodX && inputType != InputType.TRANSLATE_Z && inputType != InputType.PRESS )
				return false;

			if(_mouseIsDown)
			{
				if(inputType == _inputMethodY && _deltaX != 0)
					return true;
				if(inputType == _inputMethodX && _deltaY != 0)
					return true;
				if(inputType == InputType.PRESS)
					return true;
			}

			if(inputType == InputType.TRANSLATE_Z && _deltaWheel != 0)
				return true;

			return false;
		}

		public function inputAmount(inputType:String):Number
		{
			if( inputType != _inputMethodY && inputType != _inputMethodX && inputType != InputType.TRANSLATE_Z && inputType != InputType.PRESS )
				return 0;

			if(_mouseIsDown)
			{
				if(inputType == _inputMethodY && _deltaX != 0)
					return _deltaX * dragXMultiplier;
				if(inputType == _inputMethodX && _deltaY != 0)
					return _deltaY * dragYMultiplier;
			}

			if(inputType == InputType.TRANSLATE_Z && _deltaWheel != 0)
			{
				var delta:Number = _deltaWheel * wheelMultiplier;
				_deltaWheel = 0;
				return delta;
			}

			return 0;
		}

		private function mouseDownHandler(evt:MouseEvent):void
		{
			_mousePositionLast.x = _context.mouseX;
			_mousePositionLast.y = _context.mouseY;
			_mouseIsDown = true;
		}

		private function mouseUpHandler(evt:MouseEvent):void
		{
			_mouseIsDown = false;
		}

		private function mouseWheelHandler(evt:MouseEvent):void
		{
			_deltaWheel = evt.delta;
		}
	}
}
