package agt.controllers.motion.entities {
	import agt.controllers.ControllerBase;
	import agt.entities.KinematicEntity;

	import flash.geom.Vector3D;

	public class EntityControllerBase extends ControllerBase {
		protected var _entity : KinematicEntity;
		protected var _walkDirection : Vector3D;
		protected var _rotationY : Number;

		public function EntityControllerBase(entity : KinematicEntity) {
			super();
			_entity = entity;
			_walkDirection = new Vector3D();
			_rotationY = 0;
		}

		protected function updateWalkDirection() : void {
			_entity.character.setWalkDirection(_walkDirection);
		}
	}
}
