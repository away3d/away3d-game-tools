package agt.controllers.entities
{

import agt.input.InputContext;
import agt.input.events.InputEvent;
import agt.entities.KinematicEntity;

import flash.geom.Matrix3D;
import flash.geom.Vector3D;

public class KinematicEntityController extends EntityControllerBase
{
	private var _targetSpeed:Number = 0;
	private var _currentSpeed:Number = 0;

	public function KinematicEntityController(entity:KinematicEntity)
	{
		super(entity);
	}

	override public function set inputContext(context:InputContext):void
	{
		super.inputContext = context;
		registerEvent(InputEvent.MOVE_Z, moveZ);
		registerEvent(InputEvent.ROTATE_Y, rotateY);
		registerEvent(InputEvent.STOP, stop);
		registerEvent(InputEvent.JUMP, jump);
	}

	override public function update():void
	{
		super.update();

		var delta:Number = _targetSpeed - _currentSpeed;

		_currentSpeed += delta*0.25;
		_entity.kinematics.ghostObject.rotation.copyRowTo(2, _walkDirection);
		_walkDirection.scaleBy(_currentSpeed);
		updateWalkDirection();
	}

	public function moveZ(value:Number):void
	{
		_targetSpeed = value;
	}

	public function rotateY(value:Number):void
	{
		_rotationY += value;
		var rotationMatrix:Matrix3D = new Matrix3D();
		rotationMatrix.appendRotation(_rotationY, Vector3D.Y_AXIS);
		_entity.kinematics.ghostObject.rotation = rotationMatrix;
	}

	public function jump(value:Number = 0):void
	{
		if(_entity.kinematics.onGround())
			_entity.kinematics.jump();
	}

	public function stop(value:Number = 0):void
	{
		_targetSpeed = 0;
	}
}
}
