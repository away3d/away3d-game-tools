package agt.controllers.motion.camera
{

import agt.controllers.ControllerBase;

import away3d.containers.ObjectContainer3D;

public class CameraControllerBase extends ControllerBase
{
	public var linearEase:Number = 0.25;
	public var angularEase:Number = 0.25;

	protected var _camera:ObjectContainer3D;

	public function CameraControllerBase(camera:ObjectContainer3D)
	{
		super();
		this.camera = camera;
	}

	public function set camera(value:ObjectContainer3D):void
	{
		_camera = value;
	}
	public function get camera():ObjectContainer3D
	{
		return _camera;
	}


}
}
