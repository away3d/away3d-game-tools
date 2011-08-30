package agt.controllers.motion.entities
{

import agt.devices.input.InputContext;
import agt.devices.input.events.InputEvent;
import agt.entities.KinematicEntity;

import flash.geom.Matrix3D;

import flash.geom.Vector3D;

public class GroundEntityController extends EntityControllerBase
{
	private var _targetWalkSpeed:Number = 0;
	private var _currentWalkSpeed:Number = 0;

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

//		return;

//		trace("GroundEntityController.as - update()");

		var delta:Number = _targetWalkSpeed - _currentWalkSpeed;

//		trace("------------------");
//		trace("target walk speed: " + _targetWalkSpeed);
//		trace("current walk speed: " + _currentWalkSpeed);
//		trace("walkDirection: " + _walkDirection);
//		trace("delta: " + delta);

		_currentWalkSpeed += delta * 0.1;
//		_walkDirection.z = _currentWalkSpeed;
		_entity.character.ghostObject.rotation.copyRowTo(2, _walkDirection);
		_walkDirection.scaleBy(_currentWalkSpeed);
		updateWalkDirection();
	}

	public function moveZ(value:Number):void
	{
//		trace("moveZ");

//		_entity.character.ghostObject.rotation.copyRowTo(2, _walkDirection);
//		_walkDirection.scaleBy(value);
//		updateWalkDirection();

		_targetWalkSpeed = value;
	}

	public function rotateY(value:Number):void
	{
//		trace("rotateY");

		var rotationMatrix:Matrix3D = new Matrix3D();
		_rotationY += value;
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
//		trace("stop");

//		_walkDirection.scaleBy(0);
//		updateWalkDirection();

		_targetWalkSpeed = 0;
	}


}
}
