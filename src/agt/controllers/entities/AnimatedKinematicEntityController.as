package agt.controllers.entities
{

import agt.input.InputContext;
import agt.input.events.InputEvent;
import agt.entities.KinematicEntity;

import away3d.animators.SmoothSkeletonAnimator;
import away3d.animators.data.SkeletonAnimationSequence;
import away3d.animators.data.SkeletonAnimationState;
import away3d.entities.Mesh;

public class AnimatedKinematicEntityController extends KinematicEntityController
{
	private var _animator:SmoothSkeletonAnimator;
	private var _animationCrossFadeTime:Number = 0.5;
	private var _animatorTimeScaleFactor:Number = 0.1;

	public function AnimatedKinematicEntityController(entity:KinematicEntity, animatedMesh:Mesh)
	{
		_animator = new SmoothSkeletonAnimator(SkeletonAnimationState(animatedMesh.animationState));
		_animator.updateRootPosition = false;
		super(entity);
	}

	public function addAnimationSequence(sequence:SkeletonAnimationSequence):void
	{
		_animator.addSequence(sequence);
	}

	override public function set inputContext(context:InputContext):void
	{
		super.inputContext = context;
		registerEvent(InputEvent.MOVE_Z, moveZ);
		registerEvent(InputEvent.ROTATE_Y, rotateY);
		registerEvent(InputEvent.STOP, stop);
		registerEvent(InputEvent.JUMP, jump);
	}

	override public function update():void
	{
		super.update();

		_animator.timeScale = 1 + _currentSpeed * _animatorTimeScaleFactor;
	}

	override public function moveZ(value:Number):void
	{
		_animator.play("walk", _animationCrossFadeTime);
		super.moveZ(value);
	}

	override public function jump(value:Number = 0):void
	{
		if(_onGround)
			_animator.play("idle", _animationCrossFadeTime);

		super.jump(value);
	}

	override public function stop(value:Number = 0):void
	{
		_animator.play("idle", _animationCrossFadeTime);
		super.stop(value);
	}

	public function get animationCrossFadeTime():Number
	{
		return _animationCrossFadeTime;
	}

	public function set animationCrossFadeTime(value:Number):void
	{
		_animationCrossFadeTime = value;
	}

	public function get animatorTimeScaleFactor():Number
	{
		return _animatorTimeScaleFactor;
	}

	public function set animatorTimeScaleFactor(value:Number):void
	{
		_animatorTimeScaleFactor = value;
	}

	public function get speedEase():Number
	{
		return _speedEase;
	}

	public function set speedEase(value:Number):void
	{
		_speedEase = value;
	}
}
}
