package agt.core
{

	import agt.entities.KinematicEntity;

	import away3d.containers.Scene3D;

	import awayphysics.dynamics.AWPDynamicsWorld;
	import awayphysics.dynamics.AWPRigidBody;

	import flash.geom.Vector3D;
	import flash.utils.getTimer;

	public class PhysicsScene3D extends Scene3D
	{
		private var _physicsWorld:AWPDynamicsWorld;
		// keep this at 1/60 or 1/120
		private var _fixedTimeStep:Number = 1/60; // TODO: add option to not use adaptive time step?
		// time since last timestep
		private var _deltaTime:Number;
		private var _maxSubStep:int = 2;
		private var _lastTimeStep:Number = -1;
		private var _kinematicEntities:Vector.<KinematicEntity>;

		private var _allObjectsCollisionGroup:int = -1;
		private var _sceneObjectsCollisionGroup:int = 1;
		private var _characterObjectsCollisionGroup:int = 2;
		private var _ghostObjectsCollisionGroup:int = 4;

		public function PhysicsScene3D()
		{
			super();
			initPhysics();

			_kinematicEntities = new Vector.<KinematicEntity>();
		}

		private function initPhysics():void
		{
			// init world
			_physicsWorld = AWPDynamicsWorld.getInstance();
			_physicsWorld.initWithDbvtBroadphase();
			_physicsWorld.collisionCallbackOn = true;
			_physicsWorld.gravity = new Vector3D(0, -10, 0);
		}

		public function addRigidBody(body:AWPRigidBody):void
		{
			_physicsWorld.addRigidBodyWithGroup(body, _sceneObjectsCollisionGroup, _allObjectsCollisionGroup | _characterObjectsCollisionGroup);
		}

		public function removeRigidBody(body:AWPRigidBody):void
		{
			_physicsWorld.removeRigidBody(body);
		}

		public function addKinematicEntity(player:KinematicEntity):void
		{
			// add kinematics part
			_physicsWorld.addCharacter(player.kinematics, _ghostObjectsCollisionGroup, _sceneObjectsCollisionGroup);

			// add dynamics part
			_physicsWorld.addRigidBodyWithGroup(player.dynamics, _characterObjectsCollisionGroup, _sceneObjectsCollisionGroup);

			// register player
			_kinematicEntities.push(player);
		}

		public function updatePhysics():void
		{
			// kinematic entities update
			var loop:uint = _kinematicEntities.length;
			for(var i:uint; i < loop; ++i)
				_kinematicEntities[i].update();

			// world update
			if(_lastTimeStep == -1) _lastTimeStep = getTimer();
			_deltaTime = (getTimer() - _lastTimeStep)/1000;
			_lastTimeStep = getTimer();
			_physicsWorld.step(_deltaTime, _maxSubStep, _fixedTimeStep);
		}
	}
}
