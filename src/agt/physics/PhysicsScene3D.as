package agt.physics
{

import agt.entities.LiveEntity;

import away3d.containers.Scene3D;

import awayphysics.dynamics.AWPDynamicsWorld;

import awayphysics.dynamics.AWPRigidBody;

import flash.geom.Vector3D;

public class PhysicsScene3D extends Scene3D
{
	private var _physicsWorld:AWPDynamicsWorld;
	private var _timeStep:Number = 1/30;

	public function PhysicsScene3D()
	{
		super();
		initPhysics();
	}

	private function initPhysics():void
	{
		// init world
		_physicsWorld = AWPDynamicsWorld.getInstance();
		_physicsWorld.initWithDbvtBroadphase();
		_physicsWorld.collisionCallbackOn = true;
		_physicsWorld.gravity = new Vector3D(0, -50, 0);
	}

	public function addRigidBody(body:AWPRigidBody):void
	{
		_physicsWorld.addRigidBody(body);
	}

	public function addPlayer(player:LiveEntity):void
	{
		_physicsWorld.addCharacter(player.character);
	}

	public function updatePhysics():void
	{
		_physicsWorld.step(_timeStep);
	}
}
}
