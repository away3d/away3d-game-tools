package agt.controllers.entities.character
{

	import agt.controllers.ControllerBase;
	import agt.controllers.IController;
	import agt.input.InputContextBase;
	import agt.input.data.InputType;
	import agt.physics.entities.CharacterEntity;

	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	public class CharacterEntityController extends ControllerBase implements IController
	{
		protected var _currentSpeed:Number = 0;
		protected var _onGround:Boolean;
		protected var _walkDirection:Vector3D;

		private var _rotationY:Number = 0;
		private var _entity:CharacterEntity;

		public var moveEase:Number = 1;
		public var speedFactor:Number = 1;

		public function CharacterEntityController(entity:CharacterEntity)
		{
			_walkDirection = new Vector3D();
			_entity = entity;
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

			// update on ground
			_onGround = _entity.character.onGround();

			// update walk vector
			_entity.ghost.rotation.copyColumnTo(2, _walkDirection);
			_walkDirection.scaleBy(_currentSpeed);
			_entity.character.setWalkDirection(_walkDirection);
		}

		public function moveZ(value:Number):void
		{
			if(!_onGround)
				return;

			value *= speedFactor;

			var delta:Number = moveEase * (value - _currentSpeed);
			_currentSpeed = _currentSpeed + delta <= value ? _currentSpeed + delta : value;
		}

		public function rotateY(value:Number):void
		{
			rotationY += value;
		}

		public function jump():void
		{
			if(_onGround)
				_entity.character.jump();
		}

		public function get rotationY():Number
		{
			return _rotationY;
		}

		public function set rotationY(value:Number):void
		{
			_rotationY = value;

			var rotationMatrix:Matrix3D = new Matrix3D(); // TODO: Optimize.
			rotationMatrix.appendRotation(_rotationY, Vector3D.Y_AXIS);
			_entity.ghost.rotation = rotationMatrix;
		}

		public function get entity():CharacterEntity
		{
			return _entity;
		}
	}
}
