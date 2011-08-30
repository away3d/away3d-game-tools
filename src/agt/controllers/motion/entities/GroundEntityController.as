package agt.controllers.motion.entities
{

import agt.devices.input.InputContext;
import agt.devices.input.events.InputEvent;
import agt.entities.KinematicEntity;

import flash.geom.Matrix3D;

import flash.geom.Vector3D;

public class GroundEntityController extends EntityControllerBase
{
	private var _targetSpeed:Number = 0;
	private var _currentSpeed:Number = 0;

	public function GroundEntityController(entity:KinematicEntity)
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

		_currentSpeed += delta * 0.25;
		_entity.character.ghostObject.rotation.copyRowTo(2, _walkDirection);
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
		_entity.character.ghostObject.rotation = rotationMatrix;
	}

	public function jump(value:Number = 0):void
	{
		if(_entity.character.onGround())
			_entity.character.jump();
	}

	public function stop(value:Number = 0):void
	{
		_targetSpeed = 0;
	}


}
}
