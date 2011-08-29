package agt.controllers.entities
{

import agt.devices.input.InputContext;
import agt.devices.input.events.InputEvent;
import agt.entities.LiveEntity;

import flash.geom.Matrix3D;

import flash.geom.Vector3D;

public class GroundEntityController extends EntityControllerBase
{
	public function GroundEntityController(entity:LiveEntity)
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

//		trace("GroundEntityController.as - update()");
	}

	public function moveZ(value:Number):void
	{
		_entity.character.ghostObject.rotation.copyRowTo(2, _walkDirection);
		_walkDirection.scaleBy(value);
		updateWalkDirection();
	}

	public function rotateY(value:Number):void
	{
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
		_walkDirection.scaleBy(value);
		updateWalkDirection();
	}


}
}
