package agt.controllers.entities.character
{

	import agt.input.InputContextBase;
	import agt.input.events.InputEvent;
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

		private var _animator:SmoothSkeletonAnimator;
		private var _currentAnimationToSpeedFactor:Number = walkAnimationToSpeedFactor;
		private var _jumping:Boolean;

		public function AnimatedCharacterEntityController(entity:CharacterEntity, animationState:SkeletonAnimationState)
		{
			_animator = new SmoothSkeletonAnimator(SkeletonAnimationState(animationState));
			_animator.updateRootPosition = false;
			super(entity);
		}

		override public function set inputContext(context:InputContextBase):void
		{
			super.inputContext = context;
			registerEvent(InputEvent.WALK, walk);
			registerEvent(InputEvent.RUN, run);
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
			{
				_jumping = false;
			}

			_animator.timeScale = (1 + _currentSpeed) * _currentAnimationToSpeedFactor;
		}

		public function run(value:Number):void
		{
			if(!_jumping)
			{
				if(_animator.hasSequence(runAnimationName))
					_animator.play(runAnimationName, animationCrossFadeTime);

				_currentAnimationToSpeedFactor = runAnimationToSpeedFactor;
			}

			super.moveZ(value);
		}

		public function walk(value:Number):void
		{
			if(!_jumping)
			{
				if(_animator.hasSequence(walkAnimationName))
					_animator.play(walkAnimationName, animationCrossFadeTime);

				_currentAnimationToSpeedFactor = walkAnimationToSpeedFactor;
			}

			super.moveZ(value);
		}

		override public function jump(value:Number = 0):void
		{
			if(_onGround)
			{
				if(_animator.hasSequence(jumpAnimationName))
					_animator.play(jumpAnimationName, animationCrossFadeTime);

				_currentAnimationToSpeedFactor = jumpAnimationToSpeedFactor;

				_jumping = true;
			}

			super.jump(value);
		}

		override public function stop(value:Number = 0):void
		{
			if(_animator.hasSequence(idleAnimationName))
				_animator.play(idleAnimationName, animationCrossFadeTime);

			_currentAnimationToSpeedFactor = idleAnimationToSpeedFactor;

			super.stop(value);
		}
	}
}
