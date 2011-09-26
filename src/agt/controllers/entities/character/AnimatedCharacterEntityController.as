package agt.controllers.entities.character
{

	import agt.controllers.ControllerBase;
	import agt.controllers.IController;
	import agt.input.data.InputType;
	import agt.physics.entities.CharacterEntity;

	import away3d.animators.SmoothSkeletonAnimator;
	import away3d.animators.data.SkeletonAnimationSequence;
	import away3d.animators.data.SkeletonAnimationState;

	import flash.geom.Matrix3D;

	import flash.geom.Vector3D;

	public class AnimatedCharacterEntityController extends ControllerBase implements IController
	{
		public var walkAnimationName:String = "walk";
		public var idleAnimationName:String = "idle";
		public var runAnimationName:String = "run";
		public var jumpAnimationName:String = "jump";
		public var animationCrossFadeTime:Number = 0.25;
		public var runSpeedThreshold:Number = 1;

		private var _activeAnimationName:String;
		private var _animator:SmoothSkeletonAnimator;
		private var _jumping:Boolean;
		private var _entity:CharacterEntity;
		private var _walkDirection:Vector3D;
		private var _onGround:Boolean;
		private var _rotationY:Number = 0;
		private var _rotationMatrix:Matrix3D;

		public var speedFactor:Number = 1;

		public function AnimatedCharacterEntityController(entity:CharacterEntity, animationState:SkeletonAnimationState)
		{
			_animator = new SmoothSkeletonAnimator(SkeletonAnimationState(animationState));
			_animator.updateRootPosition = false;
			_activeAnimationName = "";
			_walkDirection = new Vector3D();
			_entity = entity;
			_rotationMatrix = new Matrix3D();
		}

		public function addAnimationSequence(sequence:SkeletonAnimationSequence):void
		{
			if(sequence != null)
				_animator.addSequence(sequence);
		}

		override public function update():void
		{
			super.update();

			// update input from context
			if(_inputContext)
			{
				moveZ(_inputContext.inputAmount(InputType.TRANSLATE_Z));
				rotateY(_inputContext.inputAmount(InputType.ROTATE_Y));

				if(_inputContext.inputActive(InputType.JUMP))
					jump();
			}

			// update ground contact
			_onGround = _entity.character.onGround();

			// end of jump?
			if(_jumping && _onGround)
				_jumping = false;
		}

		public function rotateY(value:Number):void
		{
			if(value == 0)
				return;

			rotationY += value;
		}

		public function moveZ(value:Number):void
		{
			if(value == 0)
			{
				if(!_jumping)
				{
					playAnimation(idleAnimationName);
					_walkDirection.x = 0;
					_walkDirection.y = 0;
					_walkDirection.z = 0;
					_entity.character.setWalkDirection(_walkDirection);
				}
				return;
			}

			if(!_jumping)
			{
				_walkDirection.x = -_animator.rootDelta.x * speedFactor;
				_walkDirection.y = -_animator.rootDelta.y * speedFactor;
				_walkDirection.z = -_animator.rootDelta.z * speedFactor;
				_rotationMatrix.identity();
				_rotationMatrix.appendRotation(_rotationY, Vector3D.Y_AXIS);
				_walkDirection = _rotationMatrix.transformVector(_walkDirection);
				_entity.character.setWalkDirection(_walkDirection);
			}

			if(_onGround && !_jumping)
			{
//				if(_currentSpeed > runSpeedThreshold * speedFactor)
//				{
//					playAnimation(runAnimationName);
//				}
//				else
//				{
					playAnimation(walkAnimationName);
//				}
			}
		}

		public function jump():void
		{
			if(_onGround)
			{
				playAnimation(jumpAnimationName);
				_jumping = true;
				_entity.character.jump();
			}
		}

		public function set rotationY(value:Number):void
		{
			_rotationY = value;

			var rotationMatrix:Matrix3D = new Matrix3D(); // TODO: Optimize.
			rotationMatrix.appendRotation(_rotationY, Vector3D.Y_AXIS);
			_entity.ghost.rotation = rotationMatrix;
		}

		public function get rotationY():Number
		{
			return _rotationY;
		}

		private function playAnimation(animationName:String):void
		{
			if(_activeAnimationName == animationName)
				return;

			if(_animator.hasSequence(animationName))
				_animator.play(animationName, animationCrossFadeTime);

			_activeAnimationName = animationName;
		}

		public function set timeScale(value:Number):void
		{
			_animator.timeScale = value;
		}

		public function get timeScale():Number
		{
			return _animator.timeScale;
		}

		public function get entity():CharacterEntity
		{
			return _entity;
		}
	}
}
