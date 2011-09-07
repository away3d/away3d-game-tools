package agt.input.contexts
{

	import agt.input.*;
	import agt.input.data.MouseAction;

	import flash.display.Sprite;
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
		private var _inputMappings:Object;

		public function MouseInputContext(context:Sprite)
		{
			super();

			_context = context;
			_context.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			_context.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			_context.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);

			_mousePositionLast = new Vector3D();
			_inputMappings = new Object();

			_deltaWheel = 0;
		}

		public function update():void
		{
			_deltaX = _context.mouseX - _mousePositionLast.x;
			_deltaY = _context.mouseY - _mousePositionLast.y;
			_mousePositionLast.x = _context.mouseX;
			_mousePositionLast.y = _context.mouseY;
		}

		public function map(inputType:String, mouseAction:String, multiplier:Number):void
		{
			_inputMappings[inputType] = new MouseMapping(mouseAction, multiplier);
			_implementedInputs.push(inputType);
		}

		public function inputActive(inputType:String):Boolean
		{
			if(_inputMappings[inputType])
			{
				var mouseAction:String = _inputMappings[inputType].mouseAction;
				if(_mouseIsDown)
				{
					if(mouseAction == MouseAction.DRAG_X && _deltaX != 0)
						return true;
					if(mouseAction == MouseAction.DRAG_Y && _deltaY != 0)
						return true;
				}
				else
				{
					if(mouseAction == MouseAction.MOVE_X && _deltaX != 0)
						return true;
					if(mouseAction == MouseAction.MOVE_Y && _deltaY != 0)
						return true;
				}
				if(mouseAction == MouseAction.WHEEL && _deltaWheel != 0)
					return true;
			}

			return false;
		}

		public function inputAmount(inputType:String):Number
		{
			if(_inputMappings[inputType])
			{
				var mouseAction:String = _inputMappings[inputType].mouseAction;
				if(_mouseIsDown)
				{
					if(mouseAction == MouseAction.DRAG_X && _deltaX != 0)
						return _deltaX * _inputMappings[inputType].multiplier;
					if(mouseAction == MouseAction.DRAG_Y && _deltaY != 0)
						return _deltaY * _inputMappings[inputType].multiplier;
				}
				else
				{
					if(mouseAction == MouseAction.MOVE_X && _deltaX != 0)
						return _deltaX * _inputMappings[inputType].multiplier;
					if(mouseAction == MouseAction.MOVE_Y && _deltaY != 0)
						return _deltaY * _inputMappings[inputType].multiplier;
				}
				if(mouseAction == MouseAction.WHEEL && _deltaWheel != 0)
				{
					var delta:Number = _deltaWheel * _inputMappings[inputType].multiplier;
					_deltaWheel = 0;
					return delta;
				}
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

class MouseMapping
{
	public var mouseAction:String;
	public var multiplier:Number;

	public function MouseMapping(mouseAction:String, multiplier:Number)
	{
		this.mouseAction = mouseAction;
		this.multiplier = multiplier;
	}
}
