package agt.physics.entities
{

	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;

	import awayphysics.collision.shapes.AWPShape;
	import awayphysics.dynamics.AWPRigidBody;

	import flash.geom.Matrix3D;

	import flash.geom.Vector3D;

	public class DynamicEntity extends PhysicsEntity
	{
		private var _body:AWPRigidBody;

		public function DynamicEntity(shape:AWPShape, container:ObjectContainer3D, mass:Number = 0)
		{
			super(shape, container);
			_body = new AWPRigidBody(_shape, _container, mass);
			objTransformToBodyTransform(_container, _body);
		}

		public function get body():AWPRigidBody
		{
			return _body;
		}

		private function objTransformToBodyTransform(obj:ObjectContainer3D, body:AWPRigidBody):void
	    {
			const TO_DEGS:Number = 180/Math.PI;

	        var ms:Vector.<Vector3D> = obj.transform.decompose();
	        var position:Vector3D = ms[0];
	        var rotation:Vector3D = ms[1];
	        var rot:Matrix3D = new Matrix3D();

	        body.position = position;
	        rot.appendRotation( rotation.x * TO_DEGS, Vector3D.X_AXIS );
	        rot.appendRotation( rotation.y * TO_DEGS, Vector3D.Y_AXIS );
	        rot.appendRotation( rotation.z * TO_DEGS, Vector3D.Z_AXIS );

	        body.rotation = rot;
	    }
	}
}
