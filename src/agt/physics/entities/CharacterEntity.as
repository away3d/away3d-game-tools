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

	import flash.geom.Vector3D;

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

		public var collideStrength:Number = 1000;

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
			var dynamicOffset:Number = 100; // TODO: Make settable
			var dynamicShape:AWPCapsuleShape = new AWPCapsuleShape(capsuleRadius + dynamicOffset, capsuleHeight);
			_dynamicCapsuleMesh = new Capsule(DebugMaterialLibrary.instance.transparentRedMaterial, capsuleRadius + dynamicOffset, capsuleHeight);
			_dynamicCapsuleMesh.visible = false;
			var dynamicEntity:DynamicEntity = new DynamicEntity(dynamicShape, _dynamicCapsuleMesh);
			_body = dynamicEntity.body;
			_body.angularFactor = new Vector3D(0, 1, 0);
			_body.friction = 0.9;

			// build character controller
			_character = new AWPKinematicCharacterController(kinematicEntity.ghost, kinematicShape, 0.1);

			super(kinematicEntity.shape, container);
		}

		public function update():void
		{
			// apply ghost position and 'velocity' to rigid body
			var vel:Vector3D = character.walkDirection;
			vel.scaleBy(collideStrength);
			_body.linearVelocity = vel;
			_body.position = _ghost.position;
		}

		public function set position(value:Vector3D):void
		{
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
	}
}
