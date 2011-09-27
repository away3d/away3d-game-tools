package agt.physics.entities
{

	import agt.debug.DebugMaterialLibrary;

	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.primitives.Capsule;

	import awayphysics.collision.dispatch.AWPGhostObject;
	import awayphysics.collision.shapes.AWPCapsuleShape;
	import awayphysics.data.AWPCollisionFlags;
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.dynamics.character.AWPKinematicCharacterController;
	import awayphysics.events.AWPCollisionEvent;

	import flash.geom.Vector3D;
	import flash.utils.Dictionary;

	/*
		Associates a mesh with a kinematic entity, a dynamic entity and a kinematic character controller.
	 */
	public class CharacterEntity extends PhysicsEntity
	{

		private var _kinematicCapsuleMesh:Capsule;
		private var _dynamicCapsuleMesh:Mesh;
		private var _character:AWPKinematicCharacterController;
		private var _body:AWPRigidBody;
		private var _ghost:AWPGhostObject;

		private var _collideStrength:Number = 1000;
		private var _jumpStrength:Number;

		// force strength exerted on dynamic objects
		public function CharacterEntity(container:ObjectContainer3D, capsuleRadius:Number, capsuleHeight:Number)
		{
			// build kinematic entity
			var kinematicShape:AWPCapsuleShape = new AWPCapsuleShape(capsuleRadius, capsuleHeight);
			_kinematicCapsuleMesh = new Capsule(DebugMaterialLibrary.instance.transparentGreenMaterial, capsuleRadius, capsuleHeight);
			_kinematicCapsuleMesh.visible = false;
			container.addChild(_kinematicCapsuleMesh);
			var kinematicEntity:KinematicEntity = new KinematicEntity(kinematicShape, container);
			_ghost = kinematicEntity.ghost;
			_ghost.collisionFlags = AWPCollisionFlags.CF_CHARACTER_OBJECT;

			// build dynamic entity
			var dynamicOffset:Number = 1.1; // TODO: Make settable
			var dynamicShape:AWPCapsuleShape = new AWPCapsuleShape(capsuleRadius * dynamicOffset, capsuleHeight);
			_dynamicCapsuleMesh = new Capsule(DebugMaterialLibrary.instance.transparentRedMaterial, capsuleRadius * dynamicOffset, capsuleHeight);
			_dynamicCapsuleMesh.visible = false;
			var dynamicEntity:DynamicEntity = new DynamicEntity(dynamicShape, _dynamicCapsuleMesh, 1);
			_body = dynamicEntity.body;
			_body.angularFactor = new Vector3D(0, 1, 0);
			_body.friction = 0.9;

			// build character controller
			_character = new AWPKinematicCharacterController(kinematicEntity.ghost, kinematicShape, 0.1);
			_jumpStrength = _character.jumpSpeed;

			super(kinematicEntity.shape, container);
		}

		private var _collisionNotifications:Dictionary;
		public function addNotifyOnCollision(entity:DynamicEntity, action:Function):void
		{
	   		if(!_collisionNotifications)
				_collisionNotifications = new Dictionary();

			if(!_ghost.hasEventListener(AWPCollisionEvent.COLLISION_ADDED))
				_ghost.addEventListener(AWPCollisionEvent.COLLISION_ADDED, collisionAddedHandler);

			_collisionNotifications[entity.body] = action;
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
			var vel:Vector3D = character.walkDirection;
			vel.scaleBy(_collideStrength);
			_body.linearVelocity = vel;
			_body.position = _ghost.position;
		}

		public function set position(value:Vector3D):void
		{
			_container.position = value;
			_character.warp(value);
		}

		public function get character():AWPKinematicCharacterController
		{
			return _character;
		}

		public function get body():AWPRigidBody
		{
			return _body;
		}

		public function get ghost():AWPGhostObject
		{
			return _ghost;
		}

		public function get kinematicCapsuleMesh():Capsule
		{
			return _kinematicCapsuleMesh;
		}

		public function get dynamicCapsuleMesh():Mesh
		{
			return _dynamicCapsuleMesh;
		}

		public function get jumpStrength():Number
		{
			return _jumpStrength;
		}

		public function set jumpStrength(value:Number):void
		{
			_jumpStrength = value;
			_character.jumpSpeed = value;
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
