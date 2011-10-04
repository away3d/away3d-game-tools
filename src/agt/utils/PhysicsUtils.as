package agt.utils
{

	import away3d.containers.ObjectContainer3D;

	import awayphysics.dynamics.AWPRigidBody;

	import flash.geom.Matrix3D;

	import flash.geom.Vector3D;

	public class PhysicsUtils
	{
		public static function applyObjectTransformToBodyTransform(obj:ObjectContainer3D, body:AWPRigidBody):void
	    {
//			const TO_DEGS:Number = 180/Math.PI;

	        var ms:Vector.<Vector3D> = obj.transform.decompose();
	        var position:Vector3D = ms[0];
	        var rotation:Vector3D = ms[1];
			var scale:Vector3D = ms[2];

//	        var rot:Matrix3D = new Matrix3D();
//	        rot.appendRotation( rotation.x * TO_DEGS, Vector3D.X_AXIS );
//	        rot.appendRotation( rotation.y * TO_DEGS, Vector3D.Y_AXIS );
//	        rot.appendRotation( rotation.z * TO_DEGS, Vector3D.Z_AXIS );

			body.position = position;
	        body.rotation = rotation;
//			body.shape.setLocalScaling(scale.x * _scale, scale.y * _scale, scale.z * _scale);
	    }
	}
}
