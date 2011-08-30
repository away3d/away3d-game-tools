package agt.physics {
	import agt.entities.LiveEntity;

	import away3d.containers.Scene3D;

	import awayphysics.dynamics.AWPDynamicsWorld;
	import awayphysics.dynamics.AWPRigidBody;

	import flash.geom.Vector3D;
	import flash.utils.getTimer;

	public class PhysicsScene3D extends Scene3D {
		private var _physicsWorld : AWPDynamicsWorld;
		// keep this at 1/60 or 1/120
		private var _fixedTimeStep : Number = 1 / 60;
		// time since last timestep
		private var _deltaTime : Number;
		private var _maxSubStep : int = 10;
		private var _lastTimeStep : Number = -1;

		public function PhysicsScene3D() {
			super();
			initPhysics();
		}

		private function initPhysics() : void {
			// init world
			_physicsWorld = AWPDynamicsWorld.getInstance();
			_physicsWorld.initWithDbvtBroadphase();
			_physicsWorld.collisionCallbackOn = true;
			_physicsWorld.gravity = new Vector3D(0, -10, 0);
		}

		public function addRigidBody(body : AWPRigidBody) : void {
			_physicsWorld.addRigidBody(body);
		}

		public function addPlayer(player : LiveEntity) : void {
			_physicsWorld.addCharacter(player.character);
		}

		public function updatePhysics() : void {
			if (_lastTimeStep == -1) _lastTimeStep = getTimer();
			_deltaTime = (getTimer() - _lastTimeStep) / 1000;
			_lastTimeStep = getTimer();
			_physicsWorld.step(_deltaTime, _maxSubStep, _fixedTimeStep);
		}
	}
}
