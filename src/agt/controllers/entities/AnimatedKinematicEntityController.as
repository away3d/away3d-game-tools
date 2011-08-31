package agt.controllers.entities
{

import agt.input.InputContext;
import agt.input.events.InputEvent;
import agt.entities.KinematicEntity;

import away3d.animators.SmoothSkeletonAnimator;
import away3d.animators.data.SkeletonAnimationSequence;
import away3d.animators.data.SkeletonAnimationState;
import away3d.entities.Mesh;

import flash.geom.Matrix3D;
import flash.geom.Vector3D;

public class AnimatedKinematicEntityController extends EntityControllerBase
{
	private var _targetSpeed:Number = 0;
	private var _currentSpeed:Number = 0;

	private var _animator:SmoothSkeletonAnimator;
	private var _animationCrossFadeTime:Number = 0.5;
	private var _speedEase:Number = 0.2;
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

		var delta:Number = _targetSpeed - _currentSpeed;

		_currentSpeed += delta * _speedEase;
		_entity.kinematics.ghostObject.rotation.copyRowTo(2, _walkDirection);
		_walkDirection.scaleBy(_currentSpeed);
		updateWalkDirection();

		_animator.timeScale = 1 + _currentSpeed * _animatorTimeScaleFactor;
	}

	public function moveZ(value:Number):void
	{
		_targetSpeed = value;
		_animator.play("walk", _animationCrossFadeTime);
	}

	public function rotateY(value:Number):void
	{
		_rotationY += value;
		var rotationMatrix:Matrix3D = new Matrix3D();
		rotationMatrix.appendRotation(_rotationY, Vector3D.Y_AXIS);
		_entity.kinematics.ghostObject.rotation = rotationMatrix;
	}

	public function jump(value:Number = 0):void
	{
		if(_entity.kinematics.onGround())
		{
			_entity.kinematics.jump();
			_animator.play("idle", _animationCrossFadeTime);
		}
	}

	public function stop(value:Number = 0):void
	{
		_targetSpeed = _currentSpeed = 0;
		_animator.play("idle", _animationCrossFadeTime);
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
