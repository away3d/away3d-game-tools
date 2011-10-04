package agt.physics.entities
{

	import away3d.containers.ObjectContainer3D;

	import awayphysics.collision.dispatch.AWPGhostObject;
	import awayphysics.collision.shapes.AWPCapsuleShape;
	import awayphysics.collision.shapes.AWPCompoundShape;
	import awayphysics.data.AWPCollisionFlags;
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.dynamics.character.AWPKinematicCharacterController;
	import awayphysics.events.AWPCollisionEvent;

	import flash.geom.Matrix3D;

	import flash.geom.Vector3D;
	import flash.utils.Dictionary;

	/*
		Associates a mesh with a kinematic body, a dynamic body and a character controller.
	 */
	public class CharacterEntity
	{
		private var _characterController:AWPKinematicCharacterController;
		private var _dynamicBody:AWPRigidBody;
		private var _kinematicBody:AWPGhostObject;
		private var _collisionNotifications:Dictionary;
		private var _skin:ObjectContainer3D;
		private var _collideStrength:Number = 1000;
		private var _jumpStrength:Number;

		// force strength exerted on dynamic objects
		public function CharacterEntity(capsuleRadius:Number, capsuleHeight:Number)
		{
			var dynamicOffset:Number = 1.1; // TODO: Make settable
			var dynamicShape:AWPCapsuleShape = new AWPCapsuleShape(capsuleRadius * dynamicOffset, capsuleHeight);
			var kinematicShape:AWPCapsuleShape = new AWPCapsuleShape(capsuleRadius, capsuleHeight);

//			var compoundShape:AWPCompoundShape = new AWPCompoundShape(); // TODO: any way to use this instead of collision groups to avoid internal collision?
//			compoundShape.addChildShape(kinematicShape);
//			compoundShape.addChildShape(dynamicShape);

			_kinematicBody = new AWPGhostObject( kinematicShape );
			_kinematicBody.collisionFlags = AWPCollisionFlags.CF_CHARACTER_OBJECT;

			_dynamicBody = new AWPRigidBody( dynamicShape );
			_dynamicBody.angularFactor = new Vector3D(0, 1, 0);
			_dynamicBody.friction = 0.9;

			// build character controller
			_characterController = new AWPKinematicCharacterController( _kinematicBody, kinematicShape, 0.1 );
			_jumpStrength = _characterController.jumpSpeed;
		}

		public function set jumpSpeed(value:Number):void
		{
			_characterController.jumpSpeed = value;
		}

		public function get jumpSpeed():Number
		{
			return _characterController.jumpSpeed;
		}

		public function get skin():ObjectContainer3D
		{
			return _skin;
		}

		public function set skin(value:ObjectContainer3D):void
		{
			_skin = value;
			_kinematicBody.skin = _skin;
		}

		public function addNotifyOnCollision(body:AWPRigidBody, action:Function):void
		{
	   		if(!_collisionNotifications)
				_collisionNotifications = new Dictionary();

			if(!_kinematicBody.hasEventListener(AWPCollisionEvent.COLLISION_ADDED))
				_kinematicBody.addEventListener(AWPCollisionEvent.COLLISION_ADDED, collisionAddedHandler);

			_collisionNotifications[body] = action;
		}

		public function removeNotifyOnCollision():void
		{
			// TODO.
		}

		private function collisionAddedHandler(evt:AWPCollisionEvent):void
		{
			if(_collisionNotifications && _collisionNotifications[AWPRigidBody(evt.collisionObject)])
				_collisionNotifications[AWPRigidBody(evt.collisionObject)]();
		}

		// updated by PhysicsScene automatically...
		public function update():void
		{
			// apply ghost position and 'velocity' to rigid body
			var vel:Vector3D = characterController.walkDirection;
			vel.scaleBy(_collideStrength);
			_dynamicBody.linearVelocity = vel;
			_dynamicBody.position = _kinematicBody.position;
		}

		public function get position():Vector3D
		{
			return _kinematicBody.position;
		}

		public function set position(value:Vector3D):void
		{
			_characterController.warp(value);
		}

		public function get rotation():Vector3D
		{
			return _kinematicBody.rotation;
		}

		public function get characterController():AWPKinematicCharacterController
		{
			return _characterController;
		}

		public function get dynamicBody():AWPRigidBody
		{
			return _dynamicBody;
		}

		public function get kinematicBody():AWPGhostObject
		{
			return _kinematicBody;
		}

		public function get jumpStrength():Number
		{
			return _jumpStrength;
		}

		public function set jumpStrength(value:Number):void
		{
			_jumpStrength = value;
			_characterController.jumpSpeed = value;
		}

		public function get collideStrength():Number
		{
			return _collideStrength;
		}

		public function set collideStrength(value:Number):void
		{
			_collideStrength = value;
		}
	}
}
