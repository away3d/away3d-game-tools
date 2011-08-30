package agt.controllers.motion.animation
{

import agt.devices.input.InputContext;
import agt.devices.input.events.InputEvent;

import away3d.entities.Mesh;

public class SkeletonAnimationController extends AnimationControllerBase
{
	public function SkeletonAnimationController(mesh:Mesh)
	{
		super(mesh);
	}

	override public function set inputContext(context:InputContext):void
	{
		super.inputContext = context;
		registerEvent(InputEvent.WALK, walk);
		registerEvent(InputEvent.STOP, stop);
	}

	override public function update():void
	{
		super.update();

//		trace("GroundEntityController.as - update()");
	}

	public function walk(value:Number):void
	{
		_animator.play("walk", 0.5);
	}

	public function stop(value:Number):void
	{
		_animator.play("idle", 0.5);
	}
}
}
