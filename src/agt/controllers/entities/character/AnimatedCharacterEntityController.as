package agt.controllers.entities.character
{

	import agt.input.InputType;
	import agt.physics.entities.CharacterEntity;

	import away3d.animators.SmoothSkeletonAnimator;
	import away3d.animators.data.SkeletonAnimationSequence;
	import away3d.animators.data.SkeletonAnimationState;

	public class AnimatedCharacterEntityController extends CharacterEntityController
	{
		public var walkAnimationName:String = "walk";
		public var idleAnimationName:String = "idle";
		public var runAnimationName:String = "run";
		public var jumpAnimationName:String = "jump";
		public var animationCrossFadeTime:Number = 0.5;
		public var idleAnimationToSpeedFactor:Number = 1;
		public var walkAnimationToSpeedFactor:Number = 1;
		public var runAnimationToSpeedFactor:Number = 1;
		public var jumpAnimationToSpeedFactor:Number = 1;
		public var overallAnimationToSpeedFactor:Number = 1;
		public var runSpeedLimit:Number = 50;

		private var _activeAnimationName:String;
		private var _animator:SmoothSkeletonAnimator;
		private var _currentAnimationToSpeedFactor:Number = walkAnimationToSpeedFactor;
		private var _jumping:Boolean;

		public function AnimatedCharacterEntityController(entity:CharacterEntity, animationState:SkeletonAnimationState)
		{
			_animator = new SmoothSkeletonAnimator(SkeletonAnimationState(animationState));
			_animator.updateRootPosition = false;
			_activeAnimationName = "";
			super(entity);
		}

		public function addAnimationSequence(sequence:SkeletonAnimationSequence):void
		{
			if(sequence != null)
				_animator.addSequence(sequence);
		}

		override public function update():void
		{
			super.update();

			// end of jump?
			if(_jumping && _onGround)
				_jumping = false;

			_animator.timeScale = (1 + _currentSpeed) * _currentAnimationToSpeedFactor * overallAnimationToSpeedFactor;
		}

		override public function moveZ(value:Number):void
		{
			super.moveZ(value);

			if(_onGround && !_jumping)
			{
				if(_currentSpeed > runSpeedLimit)
				{
					playAnimation(runAnimationName);
					_currentAnimationToSpeedFactor = runAnimationToSpeedFactor;
				}
				else if(_currentSpeed != 0)
				{
					playAnimation(walkAnimationName);
					_currentAnimationToSpeedFactor = walkAnimationToSpeedFactor;
				}
			}

			if(_currentSpeed == 0)
			{
				playAnimation(idleAnimationName);
				_currentAnimationToSpeedFactor = idleAnimationToSpeedFactor;
			}
		}

		override public function jump():void
		{
			if(_onGround)
			{
				playAnimation(jumpAnimationName);
				_currentAnimationToSpeedFactor = jumpAnimationToSpeedFactor;
				_jumping = true;
			}

			super.jump();
		}

		private function playAnimation(animationName:String):void
		{
			if(_activeAnimationName == animationName)
				return;

			if(_animator.hasSequence(animationName))
				_animator.play(animationName, animationCrossFadeTime);

			_activeAnimationName = animationName;
		}
	}
}
