package agt.controllers.entities.character
{

	import agt.controllers.ControllerBase;
	import agt.input.InputContext;
	import agt.input.events.InputEvent;
	import agt.physics.entities.CharacterEntity;

	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	public class CharacterEntityController extends ControllerBase
	{
		protected var _currentSpeed:Number = 0;
		protected var _onGround:Boolean;
		protected var _walkDirection:Vector3D;

		private var _rotationY:Number = 0;
		private var _entity:CharacterEntity;

		public var moveEase:Number = 0.25;

		public function CharacterEntityController(entity:CharacterEntity)
		{
			_walkDirection = new Vector3D();
			_entity = entity;
		}

		override public function set inputContext(context:InputContext):void
		{
			super.inputContext = context;
			registerEvent(InputEvent.MOVE_Z, moveZ);
			registerEvent(InputEvent.SPIN, rotateY);
			registerEvent(InputEvent.STOP, stop);
			registerEvent(InputEvent.JUMP, jump);
		}

		override public function update():void
		{
			super.update();

			// update on ground
			_onGround = _entity.character.onGround();

			// update walk vector
			_entity.ghost.rotation.copyRowTo(2, _walkDirection);
			_walkDirection.scaleBy(_currentSpeed);
			_entity.character.setWalkDirection(_walkDirection);
		}

		public function moveZ(value:Number):void
		{
			if(!_onGround)
				return;

			var delta:Number = moveEase * (value - _currentSpeed);
			_currentSpeed = _currentSpeed + delta <= value ? _currentSpeed + delta : value;
		}

		public function rotateY(value:Number):void
		{
			rotationY += value;
		}

		public function jump(value:Number = 0):void
		{
			if(_onGround)
				_entity.character.jump();
		}

		public function stop(value:Number = 0):void
		{
			_currentSpeed = 0;
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
