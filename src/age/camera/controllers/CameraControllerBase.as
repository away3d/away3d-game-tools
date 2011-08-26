package age.camera.controllers
{

import age.camera.events.CameraControllerEvent;
import age.input.InputContext;

import away3d.containers.ObjectContainer3D;

import flash.events.EventDispatcher;
import flash.utils.Dictionary;

public class CameraControllerBase extends EventDispatcher
{
	public var linearEase:Number = 0.25;
	public var angularEase:Number = 0.25;

	protected var _camera:ObjectContainer3D;
	protected var _inputContexts:Vector.<InputContext>;
	protected var _eventMapping:Dictionary;

	public function CameraControllerBase(camera:ObjectContainer3D)
	{
		this.camera = camera;
		_eventMapping = new Dictionary();
		_inputContexts = new Vector.<InputContext>();
		super();
	}

	public function update():void
	{
		for(var i:uint; i < _inputContexts.length; ++i)
			_inputContexts[i].update();
	}

	public function set camera(value:ObjectContainer3D):void
	{
		_camera = value;
	}
	public function get camera():ObjectContainer3D
	{
		return _camera;
	}

	public function addInputContext(context:InputContext):void
	{
		_inputContexts.push(context);
	}

	protected function registerEvent(eventType:String, func:Function):void
	{
		_eventMapping[eventType] = func;
		_inputContexts[_inputContexts.length - 1].addEventListener(eventType, processEvent);
	}

	private function processEvent(evt:CameraControllerEvent):void
	{
		_eventMapping[evt.type](evt.amount);
	}
}
}
