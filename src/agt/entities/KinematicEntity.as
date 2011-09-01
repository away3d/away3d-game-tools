package agt.entities
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

	public class KinematicEntity extends PhysicsEntity
	{

		private var _container:ObjectContainer3D;
		private var _kinematicCapsuleMesh:Capsule;
		private var _dynamicCapsuleMesh:Mesh;
		private var _dynamicCapsule:AWPRigidBody;
		private var _kinematics:AWPKinematicCharacterController;
		private var _capsuleRadius:Number;
		private var _capsuleHeight:Number;
		private var _ghostObject:AWPGhostObject;

		public var collideStrength:Number = 5000;

		// force strength exerted on dynamic objects
		public function KinematicEntity(mesh:Mesh, capsuleRadius:Number, capsuleHeight:Number)
		{
			super();

			_capsuleRadius = capsuleRadius;
			_capsuleHeight = capsuleHeight;
			_container = mesh;

			initEntity();
		}

		public function get kinematics():AWPKinematicCharacterController
		{
			return _kinematics;
		}

		public function set position(value:Vector3D):void
		{
			_kinematics.warp(value);
		}

		private function initEntity():void
		{
			// build entity shape
			var entityShape:AWPCapsuleShape = new AWPCapsuleShape(_capsuleRadius, _capsuleHeight);

			// build capsule meshes for visual debugging
			_kinematicCapsuleMesh = new Capsule(DebugMaterialLibrary.instance.transparentGreenMaterial, _capsuleRadius, _capsuleHeight);
			_container.addChild(_kinematicCapsuleMesh);
			_kinematicCapsuleMesh.visible = false;

			// build entity shape
			var dynOffset:Number = 100; // TODO: Make settable
			var entityShape1:AWPCapsuleShape = new AWPCapsuleShape(_capsuleRadius + dynOffset, _capsuleHeight);

			// dynamic
			_dynamicCapsuleMesh = new Capsule(DebugMaterialLibrary.instance.transparentRedMaterial, _capsuleRadius + dynOffset, _capsuleHeight);
			_container.parent.addChild(_dynamicCapsuleMesh);
			_dynamicCapsuleMesh.visible = false;

			// use shape to produce rigid body for dynamics
			_dynamicCapsule = new AWPRigidBody(entityShape1, _dynamicCapsuleMesh);
			_dynamicCapsule.angularFactor = new Vector3D(0, 1, 0); // limit rotation to Y axis only
			_dynamicCapsule.friction = 0.9;

			// use shape to produce ghost object for kinematics
			_ghostObject = new AWPGhostObject(entityShape, _container);
			_ghostObject.collisionFlags = AWPCollisionFlags.CF_CHARACTER_OBJECT;

			// init character
			_kinematics = new AWPKinematicCharacterController(_ghostObject, entityShape, 0.1);
		}

		public function get container():ObjectContainer3D
		{
			return _container;
		}

		public function get dynamics():AWPRigidBody
		{
			return _dynamicCapsule;
		}

		public function update():void
		{
			// apply ghost position and 'velocity' to rigid body
			var vel:Vector3D = kinematics.walkDirection.v3d;
			vel.scaleBy(collideStrength);
			_dynamicCapsule.linearVelocity = vel;
			_dynamicCapsule.position = _ghostObject.position;
		}

		public function set kinematicCapsuleVisible(value:Boolean):void
		{
			_kinematicCapsuleMesh.visible = value;
		}
		public function get kinematicCapsuleVisible():Boolean
		{
			return _kinematicCapsuleMesh.visible;
		}

		public function set dynamicCapsuleVisible(value:Boolean):void
		{
			_dynamicCapsuleMesh.visible = value;
		}
		public function get dynamicCapsuleVisible():Boolean
		{
			return _dynamicCapsuleMesh.visible;
		}
	}
}
