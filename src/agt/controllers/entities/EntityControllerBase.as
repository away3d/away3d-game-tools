package agt.controllers.entities
{

import agt.controllers.ControllerBase;
import agt.entities.LiveEntity;

import flash.geom.Vector3D;

public class EntityControllerBase extends ControllerBase
{
	protected var _entity:LiveEntity;
	protected var _walkDirection:Vector3D;
	protected var _rotationY:Number;

	public function EntityControllerBase(entity:LiveEntity)
	{
		super();
		_entity = entity;
		_walkDirection = new Vector3D();
		_rotationY = 0;
	}

	protected function updateWalkDirection():void
	{
		_entity.character.setWalkDirection(_walkDirection);
	}
}
}
