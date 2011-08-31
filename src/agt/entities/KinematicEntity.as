package agt.entities {
	import away3d.entities.Mesh;

	import awayphysics.collision.dispatch.AWPGhostObject;
	import awayphysics.collision.shapes.AWPCapsuleShape;
	import awayphysics.data.AWPCollisionFlags;
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.dynamics.character.AWPKinematicCharacterController;
	import awayphysics.events.AWPCollisionEvent;

	import flash.geom.Vector3D;

	public class KinematicEntity extends PhysicsEntity {
		private var _mesh : Mesh;
		private var _kinematics : AWPKinematicCharacterController;
		private var _capsuleRadius : Number;
		private var _capsuleHeight : Number;
		private var _ghostObject : AWPGhostObject;
		public var collideStrength : Number = 20;

		// force strength exerted on dynamic objects
		public function KinematicEntity(mesh : Mesh, capsuleRadius : Number, capsuleHeight : Number) {
			super();

			_capsuleRadius = capsuleRadius;
			_capsuleHeight = capsuleHeight;
			_mesh = mesh;

			initEntity();
		}

		public function get kinematics() : AWPKinematicCharacterController {
			return _kinematics;
		}

		public function set position(value : Vector3D) : void {
			_kinematics.warp(value);
		}

		private function initEntity() : void {
			// build entity shape
			var entityShape : AWPCapsuleShape = new AWPCapsuleShape(_capsuleRadius, _capsuleHeight);

			// use shape to produce ghost object
			_ghostObject = new AWPGhostObject(entityShape, _mesh);
			_ghostObject.collisionFlags = AWPCollisionFlags.CF_CHARACTER_OBJECT;
			_ghostObject.addEventListener(AWPCollisionEvent.COLLISION_ADDED, characterCollisionAddedHandler);

			// init character
			_kinematics = new AWPKinematicCharacterController(_ghostObject, entityShape, 0.1);
		}

		private function characterCollisionAddedHandler(event : AWPCollisionEvent) : void {
			if (!(event.collisionObject.collisionFlags & AWPCollisionFlags.CF_STATIC_OBJECT)) {
				var body : AWPRigidBody = AWPRigidBody(event.collisionObject);
				var force : Vector3D = event.manifoldPoint.normalWorldOnB.clone();

				// TODO: add _character.walkDirection.v3d to AWP -> force.scaleBy(-collideStrength * _character.walkDirection.v3d.length);
				force.scaleBy(-collideStrength);
				// trace("force: " + force);
				body.applyForce(force, event.manifoldPoint.localPointB);
			}
		}

		public function get mesh() : Mesh {
			return _mesh;
		}
	}
}
