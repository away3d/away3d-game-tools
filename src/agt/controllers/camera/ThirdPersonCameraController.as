package agt.controllers.camera
{

	import agt.controllers.IController;
	import agt.controllers.entities.character.AnimatedCharacterEntityController;
	import agt.input.data.InputType;

	import away3d.containers.ObjectContainer3D;

	import flash.geom.Vector3D;

	import flash.geom.Vector3D;

	// TODO: Very similar to orbit camera controller, extend?
	public class ThirdPersonCameraController extends CameraControllerBase implements IController
	{
		private var _targetSphericalCoordinates:Vector3D;
		private var _currentSphericalCoordinates:Vector3D;

		private var _minElevation:Number = -Math.PI / 2;
		private var _maxElevation:Number = Math.PI / 2;
		private var _minRadius:Number = 0;
		private var _maxRadius:Number = Number.MAX_VALUE;
		private var _directionEnforcement:Number = 1000;
		private var _free:Boolean = true;
		private var _targetController:AnimatedCharacterEntityController;

		public function ThirdPersonCameraController(camera:ObjectContainer3D, targetController:AnimatedCharacterEntityController)
		{
			_targetController = targetController;
			super(camera);
		}

		override public function update():void
		{
			super.update();

			// update input from context?
			if(_inputContext)
			{
				moveAzimuth(_inputContext.inputAmount(InputType.TRANSLATE_X));
				moveElevation(_inputContext.inputAmount(InputType.TRANSLATE_Y));
				moveRadius(_inputContext.inputAmount(InputType.TRANSLATE_Z));

				_free = _inputContext.inputActive(InputType.RELEASE);
			}

			// mimic character direction with camera (to see faster where the character is going)
			if(!_free && _directionEnforcement != 0)
			{
				var targetForward:Vector3D = Vector3D.X_AXIS;
				targetForward = _targetController.entity.rotationMatrix.transformVector(targetForward);
				targetForward.normalize();
				targetForward.y = 0;
				var cameraRight:Vector3D = _camera.transform.deltaTransformVector(Vector3D.Z_AXIS);
				cameraRight.normalize();
				cameraRight.y = 0;
				var proj:Number = targetForward.dotProduct(cameraRight);
				var speed:Number = _targetController.entity.characterController.walkDirection.length;
				var enforcement:Number = _directionEnforcement * proj * speed;
				moveAzimuth(enforcement);
			}

			// contain elevation and radius
			_targetSphericalCoordinates.y = containValue(_targetSphericalCoordinates.y, _minElevation, _maxElevation);
			_targetSphericalCoordinates.z = containValue(_targetSphericalCoordinates.z, _minRadius, _maxRadius);

			// ease spherical position
			var dx:Number = _targetSphericalCoordinates.x - _currentSphericalCoordinates.x;
			var dy:Number = _targetSphericalCoordinates.y - _currentSphericalCoordinates.y;
			var dz:Number = _targetSphericalCoordinates.z - _currentSphericalCoordinates.z;
			_currentSphericalCoordinates.x += dx * angularEase;
			_currentSphericalCoordinates.y += dy * angularEase;
			_currentSphericalCoordinates.z += dz * linearEase;
			_camera.position = sphericalToCartesian(_currentSphericalCoordinates);
			_camera.lookAt(_targetController.entity.position);
		}

		public function moveAzimuth(amount:Number):void
		{
			_targetSphericalCoordinates.x -= amount * 0.001;
		}

		public function moveElevation(amount:Number):void
		{
			_targetSphericalCoordinates.y -= amount * 0.001;
		}

		public function moveRadius(amount:Number):void
		{
			_targetSphericalCoordinates.z -= amount;
		}

		private function containValue(value:Number, min:Number, max:Number):Number
		{
			if(value < min)
				return min;
			else if(value > max)
				return max;
			else
				return value;
		}

		private function sphericalToCartesian(sphericalCoords:Vector3D):Vector3D
		{
			var cartesianCoords:Vector3D = new Vector3D();
			var r:Number = sphericalCoords.z;
			cartesianCoords.y = _targetController.entity.position.y + r * Math.sin(-sphericalCoords.y);
			var cosE:Number = Math.cos(-sphericalCoords.y);
			cartesianCoords.x = _targetController.entity.position.x + r * cosE * Math.sin(sphericalCoords.x);
			cartesianCoords.z = _targetController.entity.position.z + r * cosE * Math.cos(sphericalCoords.x);
			return cartesianCoords;
		}

		private function cartesianToSpherical(cartesianCoords:Vector3D):Vector3D
		{
			var cartesianFromCenter:Vector3D = new Vector3D();
			cartesianFromCenter.x = cartesianCoords.x - _targetController.entity.position.x;
			cartesianFromCenter.y = cartesianCoords.y - _targetController.entity.position.y;
			cartesianFromCenter.z = cartesianCoords.z - _targetController.entity.position.z;
			var sphericalCoords:Vector3D = new Vector3D();
			sphericalCoords.z = cartesianFromCenter.length;
			sphericalCoords.x = Math.atan2(cartesianFromCenter.x, cartesianFromCenter.z);
			sphericalCoords.y = -Math.asin((cartesianFromCenter.y) / sphericalCoords.z);
			return sphericalCoords;
		}

		public function get minElevation():Number
		{
			return _minElevation;
		}

		public function set minElevation(value:Number):void
		{
			_minElevation = value;
		}

		public function get maxElevation():Number
		{
			return _maxElevation;
		}

		public function set maxElevation(value:Number):void
		{
			_maxElevation = value;
		}

		public function get maxRadius():Number
		{
			return _maxRadius;
		}

		public function set maxRadius(value:Number):void
		{
			_maxRadius = value;
		}

		public function get minRadius():Number
		{
			return _minRadius;
		}

		public function set minRadius(value:Number):void
		{
			_minRadius = value;
		}

		override public function set camera(value:ObjectContainer3D):void
		{
			super.camera = value;
			_targetSphericalCoordinates = cartesianToSpherical(_camera.position);
			_currentSphericalCoordinates = _targetSphericalCoordinates.clone();
		}

		public function get directionEnforcement():Number
		{
			return _directionEnforcement;
		}

		public function set directionEnforcement(value:Number):void
		{
			_directionEnforcement = value;
		}
	}
}
