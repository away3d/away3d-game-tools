package agt.physics.entities
{

	import away3d.containers.ObjectContainer3D;

	import awayphysics.collision.dispatch.AWPGhostObject;

	import awayphysics.collision.shapes.AWPShape;

	public class KinematicEntity extends PhysicsEntity
	{
		private var _ghost:AWPGhostObject;

		public function KinematicEntity(shape:AWPShape, container:ObjectContainer3D)
		{
			super(shape, container);
			_ghost = new AWPGhostObject(shape, container);
		}

		public function get ghost():AWPGhostObject
		{
			return _ghost;
		}
	}
}
