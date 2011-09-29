package agt.physics
{

	import agt.physics.entities.CharacterEntity;

	import away3d.containers.Scene3D;

	import awayphysics.dynamics.AWPDynamicsWorld;
	import awayphysics.dynamics.AWPRigidBody;

	import flash.geom.Vector3D;
	import flash.utils.getTimer;

	public class PhysicsScene3D extends Scene3D
	{
		private var _physics:AWPDynamicsWorld;
		// keep this at 1/60 or 1/120
		private var _fixedTimeStep:Number = 1 / 60; // TODO: add option to not use adaptive time step?
		// time since last timestep
		private var _deltaTime:Number;
		private var _maxSubStep:int = 2;
		private var _lastTimeStep:Number = -1;
		private var _characterEntities:Vector.<CharacterEntity>;

		private var _allObjectsCollisionGroup:int = -1;
		private var _sceneObjectsCollisionGroup:int = 1;
		private var _characterDynamicObjectsCollisionGroup:int = 2;
		private var _characterKinematicObjectsCollisionGroup:int = 4;

		public function PhysicsScene3D()
		{
			super();
			initPhysics();

			_characterEntities = new Vector.<CharacterEntity>();
		}

		private function initPhysics():void
		{
			// init world
			_physics = AWPDynamicsWorld.getInstance();
			_physics.initWithDbvtBroadphase();
			_physics.collisionCallbackOn = true;
			_physics.gravity = new Vector3D(0, -10, 0);
		}

		public function addRigidBody(body:AWPRigidBody):void
		{
			_physics.addRigidBodyWithGroup(body, _sceneObjectsCollisionGroup, _allObjectsCollisionGroup | _characterDynamicObjectsCollisionGroup);
		}

		public function removeRigidBody(body:AWPRigidBody):void
		{
			_physics.removeRigidBody(body);
		}

		public function addCharacterEntity(entity:CharacterEntity):void
		{
			// add physics kinematics part
			_physics.addCharacter(entity.characterController, _characterKinematicObjectsCollisionGroup, _sceneObjectsCollisionGroup);
			entity.characterController.gravity = -_physics.gravity.y * _physics.scaling * 2.9;

			// add physics dynamics part
			_physics.addRigidBodyWithGroup(entity.dynamicBody, _characterDynamicObjectsCollisionGroup, _sceneObjectsCollisionGroup);

			// register player
			_characterEntities.push(entity);
		}

		public function updatePhysics():void
		{
			// kinematic entities update
			var loop:uint = _characterEntities.length;
			for(var i:uint; i < loop; ++i)
				_characterEntities[i].update();

			// world update
			if(_lastTimeStep == -1) _lastTimeStep = getTimer();
			_deltaTime = (getTimer() - _lastTimeStep)/1000;
			_lastTimeStep = getTimer();
			_physics.step(_deltaTime, _maxSubStep, _fixedTimeStep);
		}

		public function set gravity(value:Vector3D):void
		{
			_physics.gravity = value;
			for(var i:uint; i < _characterEntities.length; ++i)
				_characterEntities[i].characterController.gravity = -_physics.gravity.y * _physics.scaling * 2.9;
		}
		public function get gravity():Vector3D
		{
			return _physics.gravity;
		}
	}
}
