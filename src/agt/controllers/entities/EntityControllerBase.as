package agt.controllers.entities
{

import agt.controllers.ControllerBase;
import agt.entities.KinematicEntity;
import agt.entities.PhysicsEntity;

public class EntityControllerBase extends ControllerBase
{
	protected var _entity:PhysicsEntity;

	public function EntityControllerBase(entity:KinematicEntity)
	{
		super();
		_entity = entity;
	}

	public function get entity():PhysicsEntity
	{
		return _entity;
	}

	public function set entity(value:PhysicsEntity):void
	{
		_entity = value;
	}
}
}
