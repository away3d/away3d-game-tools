package age.camera.controllers
{

import age.input.InputContext;
import age.input.events.InputEvent;

import away3d.containers.ObjectContainer3D;

import flash.events.EventDispatcher;
import flash.utils.Dictionary;

public class CameraControllerBase extends EventDispatcher
{
	public var linearEase:Number = 0.25;
	public var angularEase:Number = 0.25;

	protected var _camera:ObjectContainer3D;
	private var _inputContext:InputContext;
	protected var _eventMapping:Dictionary;

	public function CameraControllerBase(camera:ObjectContainer3D)
	{
		this.camera = camera;
		_eventMapping = new Dictionary();
		super();
	}

	public function update():void
	{
		if(_inputContext)
			_inputContext.update();
	}

	public function set camera(value:ObjectContainer3D):void
	{
		_camera = value;
	}
	public function get camera():ObjectContainer3D
	{
		return _camera;
	}

	protected function registerEvent(eventType:String, func:Function):void
	{
		_eventMapping[eventType] = func;
		_inputContext.addEventListener(eventType, processEvent);
	}

	private function processEvent(evt:InputEvent):void
	{
		_eventMapping[evt.type](evt.amount);
	}

	public function get inputContext():InputContext
	{
		return _inputContext;
	}

	public function set inputContext(value:InputContext):void
	{
		_inputContext = value;
	}
}
}
