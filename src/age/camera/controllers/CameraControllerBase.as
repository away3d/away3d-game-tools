package age.camera.controllers
{

import away3d.containers.ObjectContainer3D;

import flash.events.EventDispatcher;
import flash.geom.Vector3D;

import age.utils.KeyManager;

public class CameraControllerBase extends EventDispatcher
{
	protected var _camera:ObjectContainer3D; // the positionable and orientable object that represents the camera
	protected var _target:ObjectContainer3D; // the positionable object that the camera always looks at
	protected var _cameraDummy:ObjectContainer3D; // this object is moved instantly, the camera tweens towards it
	protected var _mouseIsDown:Boolean;
	protected var _mousePositionCurrent:Vector3D;
	protected var _mousePositionLast:Vector3D;
	protected var _key:KeyManager;

	protected var _alwaysLookAtTarget:Boolean;

	public var linearEase:Number = 0.25; // camera to dummy linear motion ease
	public var angularEase:Number = 0.5; // camera to dummy angular motion ease

	public function CameraControllerBase()
	{
		super();

		_key = new KeyManager();

		_mousePositionCurrent = new Vector3D();
		_mousePositionLast = new Vector3D();

		_target = new ObjectContainer3D();
		_cameraDummy = new ObjectContainer3D();

		_alwaysLookAtTarget = false;
	}

	// ---------------------------------------------------------------------
	// mouse input
	// ---------------------------------------------------------------------

	public function mouseDown():void
	{
		storeMousePosition();
		_mouseIsDown = true;
	}

	public function mouseUp():void
	{
		_mouseIsDown = false;
	}

	public function mouseMove(mouseX:Number, mouseY:Number):void
	{
		_mousePositionCurrent.x = mouseX;
		_mousePositionCurrent.y = mouseY;
	}

	// ---------------------------------------------------------------------
	// keyboard input
	// ---------------------------------------------------------------------

	public function keyDown(keyCode:uint):void
	{
		_key.keyDown(keyCode);
	}

	public function keyUp(keyCode:uint):void
	{
		_key.keyUp(keyCode);
	}

	// ---------------------------------------------------------------------
	// protected
	// ---------------------------------------------------------------------

	protected function storeMousePosition():void
	{
		_mousePositionLast.x = _mousePositionCurrent.x;
		_mousePositionLast.y = _mousePositionCurrent.y;
	}

	// ---------------------------------------------------------------------
	// loop
	// ---------------------------------------------------------------------

	public function update():void
	{
		// ease position
		var dx:Number = _cameraDummy.x - _camera.x;
		var dy:Number = _cameraDummy.y - _camera.y;
		var dz:Number = _cameraDummy.z - _camera.z;
		_camera.x += dx * linearEase;
		_camera.y += dy * linearEase;
		_camera.z += dz * linearEase;

		// look at target
		if(_alwaysLookAtTarget)
		{
			_camera.lookAt(_target.position);
			_cameraDummy.lookAt(_target.position);
		}
		else
		{
//			_camera.rotationX = _cameraDummy.rotationX;
//			_camera.rotationY = _cameraDummy.rotationY;
//			_camera.rotationZ = _cameraDummy.rotationZ;

			// ease orientation
			dx = _cameraDummy.rotationX - _camera.rotationX;
			dy = _cameraDummy.rotationY - _camera.rotationY;
			dz = _cameraDummy.rotationZ - _camera.rotationZ;
			_camera.rotationX += dx * angularEase;
			_camera.rotationY += dy * angularEase;
			_camera.rotationZ += dz * angularEase;
		}
	}

	// ---------------------------------------------------------------------
	// getters and setters
	// ---------------------------------------------------------------------

	public function set camera(value:ObjectContainer3D):void
	{
		_camera = value;
		_cameraDummy.transform = _camera.transform.clone();
	}
	public function get camera():ObjectContainer3D
	{
		return _camera;
	}

	public function get alwaysLookAtTarget():Boolean
	{
		return _alwaysLookAtTarget;
	}
	public function set alwaysLookAtTarget(value:Boolean):void
	{
		_alwaysLookAtTarget = value;
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
