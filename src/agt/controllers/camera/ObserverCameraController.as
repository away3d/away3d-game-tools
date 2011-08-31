package agt.controllers.camera
{

import away3d.containers.ObjectContainer3D;

public class ObserverCameraController extends CameraControllerBase
{
	// TODO: Make orbit, 1st person and 3rd person camera controllers extend this one (these are all target based).

	private var _target:ObjectContainer3D;

	public function ObserverCameraController(camera:ObjectContainer3D, target:ObjectContainer3D)
	{
		this.target = target || new ObjectContainer3D();
		super(camera);
	}

	override public function update():void
	{
		_camera.lookAt(target.position);
	}

	public function get target():ObjectContainer3D
	{
		return _target;
	}

	public function set target(value:ObjectContainer3D):void
	{
		_target = value;
	}
}
}
