package agt.entities
{

	import away3d.containers.ObjectContainer3D;

	import awayphysics.collision.shapes.AWPShape;
	import awayphysics.dynamics.AWPRigidBody;

	public class DynamicEntity extends PhysicsEntity
	{
		private var _body:AWPRigidBody;

		public function DynamicEntity(shape:AWPShape, container:ObjectContainer3D)
		{
			super(shape, container);
			_body = new AWPRigidBody(_shape, _container);
		}

		public function get body():AWPRigidBody
		{
			return _body;
		}
	}
}
