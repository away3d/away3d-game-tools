package agt.controllers.camera
{

import agt.controllers.entities.character.CharacterEntityController;
import agt.entities.CharacterEntity;
import agt.input.InputContext;
import agt.input.events.InputEvent;

import away3d.containers.ObjectContainer3D;

import flash.geom.Matrix3D;
import flash.geom.Vector3D;

public class ThirdPersonCameraController extends CameraControllerBase
{
	private var _cameraDummy:ObjectContainer3D;
	private var _targetController:CharacterEntityController;

	private var _cameraOffsetY:Number = 500;
    private var _cameraOffsetXZ:Number = 1000;
    private var _directionEnforcement:Number = 10;

	public function ThirdPersonCameraController(camera:ObjectContainer3D, targetController:CharacterEntityController)
	{
		_cameraDummy = new ObjectContainer3D();
		this.targetController = targetController;
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

		var target:ObjectContainer3D = _targetController.entity.container;

		// maintain 3rd person relation to target
        var realDelta:Vector3D = new Vector3D(); // evaluate delta between camera and target
        realDelta.x = target.x - _cameraDummy.x;
        realDelta.y = target.y - _cameraDummy.y;
        realDelta.z = target.z - _cameraDummy.z;
        var xzDelta:Vector3D = new Vector3D(realDelta.x, 0, realDelta.z); // ignore y
        xzDelta.normalize();
        xzDelta.scaleBy(-_cameraOffsetXZ); // apply xz delta
        _cameraDummy.x = target.x + xzDelta.x;
        _cameraDummy.z = target.z + xzDelta.z;
		_cameraDummy.y = target.y + _cameraOffsetY;

		// mimic character direction with camera (to see faster where the character is going)
		if(_directionEnforcement != 0)
		{
			var targetForward:Vector3D = target.transform.deltaTransformVector(Vector3D.X_AXIS);
			targetForward.normalize();
			targetForward.y = 0;
			var cameraRight:Vector3D = _camera.transform.deltaTransformVector(Vector3D.Z_AXIS);
			cameraRight.normalize();
			cameraRight.y = 0;
			var proj:Number = targetForward.dotProduct(cameraRight);
			var speed:Number = _targetController.entity.character.walkDirection.v3d.length;
			rotateCamera(-_directionEnforcement * proj * speed);
		}

		// ease camera towards the dummy
        var dx:Number = _cameraDummy.x - _camera.x;
        var dy:Number = _cameraDummy.y - _camera.y;
        var dz:Number = _cameraDummy.z - _camera.z;
        _camera.x += dx * linearEase;
        _camera.y += dy * linearEase;
        _camera.z += dz * linearEase;

        // always look at target
        _camera.lookAt( target.position );
	}

	public function rotateX(value:Number = 0):void
	{
		rotateCamera(0, value);
	}

	public function rotateY(value:Number = 0):void
	{
		rotateCamera(value, 0);
	}

	private function rotateCamera(degreesY:Number, degreesX:Number = 0):void
    {
		var target:ObjectContainer3D = CharacterEntity(_targetController.entity).container;

        var t:Matrix3D = _cameraDummy.transform.clone(); // rotate in target space
        t.appendTranslation(-target.x, -target.y, -target.z);
        if(degreesX != 0)
            t.appendRotation(degreesX, Vector3D.X_AXIS);
        if(degreesY != 0)
            t.appendRotation(degreesY, Vector3D.Y_AXIS);
        t.appendTranslation(target.x, target.y, target.z);
        var cs:Vector.<Vector3D> = t.decompose(); // extract and apply position from transform
        _cameraDummy.position = cs[0];
    }

	public function get targetController():CharacterEntityController
	{
		return _targetController;
	}

	public function set targetController(value:CharacterEntityController):void
	{
		_targetController = value;
	}

	public function get cameraOffsetXZ():Number
	{
		return _cameraOffsetXZ;
	}

	public function set cameraOffsetXZ(value:Number):void
	{
		_cameraOffsetXZ = value;
	}

	public function get cameraOffsetY():Number
	{
		return _cameraOffsetY;
	}

	public function set cameraOffsetY(value:Number):void
	{
		_cameraOffsetY = value;
	}

	public function get directionEnforcement():Number
	{
		return _directionEnforcement;
	}

	public function set directionEnforcement(value:Number):void
	{
		_directionEnforcement = value;
	}

	override public function set camera(value:ObjectContainer3D):void
	{
		super.camera = value;
		_cameraDummy.transform = _camera.transform.clone();
	}
}
}
