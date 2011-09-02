package agt.controllers.entities.character
{

	import agt.controllers.ControllerBase;
	import agt.input.InputContext;
import agt.input.events.InputEvent;
import agt.physics.entities.CharacterEntity;

import flash.geom.Matrix3D;
import flash.geom.Vector3D;

public class CharacterEntityController extends ControllerBase
{
	protected var _targetSpeed:Number = 0;
	protected var _currentSpeed:Number = 0;
	protected var _onGround:Boolean;
	protected var _walkDirection:Vector3D;
	protected var _speedEase:Number = 0.2;
	private var _rotationY:Number;
	private var _entity:CharacterEntity;

	public function CharacterEntityController(entity:CharacterEntity)
	{
		_walkDirection = new Vector3D();
		_rotationY = 0;
		_entity = entity;
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

		_currentSpeed += delta*_speedEase;

		_entity.ghost.rotation.copyRowTo(2, _walkDirection);
		_walkDirection.scaleBy(_currentSpeed);
		updateWalkDirection();

		_onGround = _entity.character.onGround();
	}

	public function moveZ(value:Number):void
	{
		if(_onGround)
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
			_entity.character.jump();
	}

	public function stop(value:Number = 0):void
	{
		_targetSpeed = _currentSpeed = 0;
	}

	protected function updateWalkDirection():void
	{
		_entity.character.setWalkDirection(_walkDirection);
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
		_entity.ghost.rotation = rotationMatrix;
	}

	public function get entity():CharacterEntity
	{
		return _entity;
	}
}
}
