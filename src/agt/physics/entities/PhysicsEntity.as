package agt.physics.entities
{

	import away3d.containers.ObjectContainer3D;

	import awayphysics.collision.shapes.AWPCollisionShape;

	public class PhysicsEntity
	{
		protected var _shape:AWPCollisionShape;
		protected var _container:ObjectContainer3D;

		public function PhysicsEntity(shape:AWPCollisionShape, container:ObjectContainer3D)
		{
			_shape = shape;
			_container = container;
		}

		public function get shape():AWPCollisionShape
		{
			return _shape;
		}

		public function get container():ObjectContainer3D
		{
			return _container;
		}
	}
}
