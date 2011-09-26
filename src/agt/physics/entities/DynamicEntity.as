package agt.physics.entities
{

	import away3d.containers.ObjectContainer3D;

	import awayphysics.collision.shapes.AWPCollisionShape;

	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.events.AWPCollisionEvent;

	import flash.geom.Matrix3D;

	import flash.geom.Vector3D;
	import flash.utils.Dictionary;

	public class DynamicEntity extends PhysicsEntity
	{
		private var _body:AWPRigidBody;
		private var _scale:Number;

		public function DynamicEntity(shape:AWPCollisionShape, container:ObjectContainer3D, mass:Number = 0, alterTransform:Boolean = true, scale:Number = 1)
		{
			super(shape, container);

			_scale = scale;
			_body = new AWPRigidBody(_shape, _container, mass);

			if(alterTransform)
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
			var scale:Vector3D = ms[2];
	        var rot:Matrix3D = new Matrix3D();

	        rot.appendRotation( rotation.x * TO_DEGS, Vector3D.X_AXIS );
	        rot.appendRotation( rotation.y * TO_DEGS, Vector3D.Y_AXIS );
	        rot.appendRotation( rotation.z * TO_DEGS, Vector3D.Z_AXIS );

			body.position = position;
	        body.rotation = rot;
//			body.shape.setLocalScaling(scale.x * _scale, scale.y * _scale, scale.z * _scale);
	    }
	}
}
