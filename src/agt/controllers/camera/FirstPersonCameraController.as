package agt.controllers.camera
{

import agt.input.InputContext;
import agt.input.events.InputEvent;

import away3d.containers.ObjectContainer3D;

public class FirstPersonCameraController extends CameraControllerBase
{
	private var _target:ObjectContainer3D;
	private var _cameraDummy:ObjectContainer3D;
	private var _cameraOffsetY:Number = 0;

	public function FirstPersonCameraController(camera:ObjectContainer3D, target:ObjectContainer3D = null)
	{
		_cameraDummy = new ObjectContainer3D();
		this.target = target || new ObjectContainer3D();
		super(camera);
	}

	override public function set inputContext(context:InputContext):void
	{
		super.inputContext = context;
		registerEvent(InputEvent.ROTATE_X, rotateX);
		registerEvent(InputEvent.ROTATE_Y, rotateY);
	}

	override public function update():void
	{
		super.update();

		_camera.x = _target.x;
		_camera.y = _target.y + _cameraOffsetY;
		_camera.z = _target.z;

		// ease orientation
		var dx:Number = _cameraDummy.rotationX - _camera.rotationX;
		var dy:Number = _cameraDummy.rotationY - _camera.rotationY;
		var dz:Number = _cameraDummy.rotationZ - _camera.rotationZ;
		_camera.rotationX += dx * angularEase;
		_camera.rotationY += dy * angularEase;
		_camera.rotationZ += dz * angularEase;
	}

	public function rotateX(value:Number):void
	{
		_cameraDummy.rotationX += value;
	}

	public function rotateY(value:Number):void
	{
		_cameraDummy.rotationY += value;
	}

	public function get target():ObjectContainer3D
	{
		return _target;
	}

	public function set target(value:ObjectContainer3D):void
	{
		_target = value;
	}

	override public function set camera(value:ObjectContainer3D):void
	{
		super.camera = value;
		_cameraDummy.transform = _camera.transform.clone();
	}

	public function get cameraOffsetY():Number
	{
		return _cameraOffsetY;
	}

	public function set cameraOffsetY(value:Number):void
	{
		_cameraOffsetY = value;
	}
}
}
