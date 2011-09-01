package agt.controllers.camera
{

import agt.controllers.entities.KinematicEntityController;
import agt.entities.KinematicEntity;
import agt.input.InputContext;
import agt.input.events.InputEvent;

import away3d.containers.ObjectContainer3D;

import flash.geom.Vector3D;

public class FirstPersonCameraController extends CameraControllerBase
{
	private var _targetController:KinematicEntityController;
	private var _cameraDummy:ObjectContainer3D;
	private var _cameraOffset:Vector3D;

	public function FirstPersonCameraController(camera:ObjectContainer3D, targetController:KinematicEntityController = null)
	{
		_cameraDummy = new ObjectContainer3D();
		this.targetController = targetController;
		_cameraOffset = new Vector3D();
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

		// set camera position equal to entity, with offset
		var pos:Vector3D = KinematicEntity(_targetController.entity).container.transform.transformVector(_cameraOffset);
		_camera.x = pos.x;
		_camera.y = pos.y;
		_camera.z = pos.z;

		// ease orientation
		var dx:Number = _cameraDummy.rotationX - _camera.rotationX;
		var dy:Number = _cameraDummy.rotationY - _camera.rotationY;
		var dz:Number = _cameraDummy.rotationZ - _camera.rotationZ;
		_camera.rotationX += dx * angularEase;
		_camera.rotationY += dy * angularEase;
		_camera.rotationZ += dz * angularEase;

		// fix target rotation to camera rotation
		_targetController.rotationY = _camera.rotationY;
	}

	public function rotateX(value:Number):void
	{
		_cameraDummy.rotationX += value;
	}

	public function rotateY(value:Number):void
	{
		_cameraDummy.rotationY += value;
	}

	public function get targetController():KinematicEntityController
	{
		return _targetController;
	}

	public function set targetController(value:KinematicEntityController):void
	{
		_targetController = value;
	}

	override public function set camera(value:ObjectContainer3D):void
	{
		super.camera = value;
		_camera.transform = KinematicEntity(_targetController.entity).container.transform.clone();
		_cameraDummy.transform = _camera.transform.clone();
	}

	public function get cameraOffset():Vector3D
	{
		return _cameraOffset;
	}

	public function set cameraOffset(value:Vector3D):void
	{
		_cameraOffset = value;
	}
}
}
