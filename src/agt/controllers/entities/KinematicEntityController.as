package agt.controllers.entities
{

import agt.input.InputContext;
import agt.input.events.InputEvent;
import agt.entities.KinematicEntity;

import flash.geom.Matrix3D;
import flash.geom.Vector3D;

public class KinematicEntityController extends EntityControllerBase
{
	protected var _targetSpeed:Number = 0;
	protected var _currentSpeed:Number = 0;
	protected var _onGround:Boolean;
	protected var _walkDirection:Vector3D;
	private var _rotationY:Number;
	protected var _speedEase:Number = 0.2;

	public function KinematicEntityController(entity:KinematicEntity)
	{
		super(entity);
		_walkDirection = new Vector3D();
		_rotationY = 0;
	}

	override public function set inputContext(context:InputContext):void
	{
		super.inputContext = context;
		registerEvent(InputEvent.MOVE_Z, moveZ);
//		registerEvent(InputEvent.MOVE_X, moveX);
		registerEvent(InputEvent.ROTATE_Y, rotateY);
		registerEvent(InputEvent.STOP, stop);
		registerEvent(InputEvent.JUMP, jump);
	}

	override public function update():void
	{
		super.update();

		var delta:Number = _targetSpeed - _currentSpeed;

		_currentSpeed += delta*0.25;

		KinematicEntity(_entity).kinematics.ghostObject.rotation.copyRowTo(2, _walkDirection);
		_walkDirection.scaleBy(_currentSpeed);
		updateWalkDirection();

		_onGround = KinematicEntity(_entity).kinematics.onGround();
	}

	public function moveZ(value:Number):void
	{
		_targetSpeed = value;
	}

	public function moveX(value:Number):void
	{
		// TODO: Add ability to strafe
	}

	public function rotateY(value:Number):void
	{
		rotationY += value;
	}

	public function jump(value:Number = 0):void
	{
		if(_onGround)
			KinematicEntity(_entity).kinematics.jump();
	}

	public function stop(value:Number = 0):void
	{
		_targetSpeed = 0;
	}

	protected function updateWalkDirection():void
	{
		KinematicEntity(_entity).kinematics.setWalkDirection(_walkDirection);
	}

	public function get rotationY():Number
	{
		return _rotationY;
	}

	public function set rotationY(value:Number):void
	{
		_rotationY = value;

		var rotationMatrix:Matrix3D = new Matrix3D();
		rotationMatrix.appendRotation(_rotationY, Vector3D.Y_AXIS);
		KinematicEntity(_entity).kinematics.ghostObject.rotation = rotationMatrix;
	}
}
}
