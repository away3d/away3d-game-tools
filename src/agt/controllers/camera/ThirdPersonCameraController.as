package agt.controllers.camera
{

	import agt.controllers.IController;
	import agt.controllers.entities.character.AnimatedCharacterEntityController;
	import agt.input.data.InputType;

	import away3d.containers.ObjectContainer3D;

	import awayphysics.collision.dispatch.AWPCollisionObject;

	import awayphysics.collision.dispatch.AWPGhostObject;

	import awayphysics.collision.shapes.AWPSphereShape;
	import awayphysics.data.AWPCollisionFlags;

	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.dynamics.character.AWPKinematicCharacterController;
	import awayphysics.events.AWPCollisionEvent;

	import flash.geom.Vector3D;

	import flash.geom.Vector3D;

	// TODO: Very similar to orbit camera controller, extend?
	public class ThirdPersonCameraController extends CameraControllerBase implements IController
	{
		private var _targetSphericalCoordinates:Vector3D;
		private var _currentSphericalCoordinates:Vector3D;

		private var _minElevation:Number = - 0.9 * Math.PI / 2;
		private var _maxElevation:Number = 0.9 * Math.PI / 2;
		private var _minRadius:Number = 700;
		private var _maxRadius:Number = Number.MAX_VALUE;
		private var _directionEnforcement:Number = 700;
		private var _targetController:AnimatedCharacterEntityController;
		private var _collider:AWPKinematicCharacterController;
		private var _colliding:Boolean;
		private var _responseFactor:Number = 5;

		public function ThirdPersonCameraController(camera:ObjectContainer3D, targetController:AnimatedCharacterEntityController)
		{
			_targetController = targetController;
			super(camera);
		}

		public function initializeCollider(sphereRadius:Number = 50):AWPKinematicCharacterController
		{
			if(_collider)
			{
				if(_collider.ghostObject.hasEventListener(AWPCollisionEvent.COLLISION_ADDED))
					_collider.ghostObject.removeEventListener(AWPCollisionEvent.COLLISION_ADDED, colliderCollisionAddedHandler);
			}

			var colliderShape:AWPSphereShape = new AWPSphereShape(sphereRadius);
			var ghostObject:AWPGhostObject = new AWPGhostObject(colliderShape);
			ghostObject.collisionFlags = AWPCollisionFlags.CF_CHARACTER_OBJECT | AWPCollisionFlags.CF_NO_CONTACT_RESPONSE;
			_collider = new AWPKinematicCharacterController(ghostObject, colliderShape, 0.5);

			_collider.warp(_camera.position);

			_collider.ghostObject.addEventListener(AWPCollisionEvent.COLLISION_ADDED, colliderCollisionAddedHandler);

			return _collider;
		}

		private var _collisionNormal:Vector3D = new Vector3D();
		private var _collisionPoint:Vector3D = new Vector3D();
		private function colliderCollisionAddedHandler( evt:AWPCollisionEvent ):void
		{
			var collisionObj:AWPCollisionObject = evt.collisionObject;
			_collisionPoint = evt.manifoldPoint.localPointB;
			_collisionPoint = _collisionPoint.add( collisionObj.position );

			_collisionNormal = evt.manifoldPoint.normalWorldOnB;
			_collisionNormal.normalize();
			_collisionNormal.scaleBy( _responseFactor );

			_colliding = true;
		}

		override public function update():void
		{
			super.update();

			var dx:Number;
			var dy:Number;
			var dz:Number;
			var underInput:Boolean;

			if( !_colliding )
			{ // update input from context?
				if( _inputContext )
				{
					moveAzimuth( _inputContext.inputAmount( InputType.ROTATE_Y ) );
					moveElevation( _inputContext.inputAmount( InputType.ROTATE_X ) );
					moveRadius( _inputContext.inputAmount( InputType.TRANSLATE_Z ) );

					underInput = _inputContext.inputActive( InputType.PRESS ) || _inputContext.inputActive(InputType.ROTATE_Y) ||
								  _inputContext.inputActive(InputType.ROTATE_X) || _inputContext.inputActive(InputType.TRANSLATE_Z);
				}

				// mimic character direction with camera (to see faster where the character is going)
				// runs only when there is no input from the user
				if( !underInput && _directionEnforcement != 0 )
				{
					var targetForward:Vector3D = Vector3D.X_AXIS;
					targetForward = _targetController.entity.rotationMatrix.transformVector( targetForward );
					targetForward.normalize();
					targetForward.y = 0;
					var cameraRight:Vector3D = _camera.transform.deltaTransformVector( Vector3D.Z_AXIS );
					cameraRight.normalize();
					cameraRight.y = 0;
					var proj:Number = targetForward.dotProduct( cameraRight );
					var speed:Number = _targetController.entity.characterController.walkDirection.length;
					var enforcement:Number = _directionEnforcement * proj * speed;
					moveAzimuth( enforcement );
				}
			}

			// respond to collision
			if( _collider && _colliding )
			{
				// evaluate responses
				var collisionVector:Vector3D = _collisionPoint.add( _collisionNormal );
				var collisionVectorSpherical:Vector3D = cartesianToSpherical( collisionVector );
				dx = collisionVectorSpherical.x - _targetSphericalCoordinates.x;
				dy = collisionVectorSpherical.y - _targetSphericalCoordinates.y;
				dz = collisionVectorSpherical.z - _targetSphericalCoordinates.z;

				// avoid too large response
				dx = removeRedundantAngle( dx );
				dy = removeRedundantAngle( dy );
				dx = containValue( dx, -0.05, 0.05 );
				dy = containValue( dy, -0.05, 0.05 );

				// apply responses
				_targetSphericalCoordinates.x -= dx * 1;
				_targetSphericalCoordinates.y -= dy * 1;
//				if(dz < 0)
					_targetSphericalCoordinates.z += dz * 1;
			}

			// contain elevation and radius
			_targetSphericalCoordinates.y = containValue(_targetSphericalCoordinates.y, _minElevation, _maxElevation);
			_targetSphericalCoordinates.z = containValue(_targetSphericalCoordinates.z, _minRadius, _maxRadius);

			// ease spherical position
			dx = _targetSphericalCoordinates.x - _currentSphericalCoordinates.x;
			dy = _targetSphericalCoordinates.y - _currentSphericalCoordinates.y;
			dz = _targetSphericalCoordinates.z - _currentSphericalCoordinates.z;
			_currentSphericalCoordinates.x += dx * angularEase;
			_currentSphericalCoordinates.y += dy * angularEase;
			_currentSphericalCoordinates.z += dz * linearEase;
			_camera.position = sphericalToCartesian(_currentSphericalCoordinates);
			_camera.lookAt(_targetController.entity.position);

			if( _collider )
			{
				_collider.warp( _camera.position );
			}

			_colliding = false;
		}

		private function removeRedundantAngle( angle:Number ):Number
		{
			var twoPi:Number = 2 * Math.PI;
			var abs:Number = Math.abs( angle );
			var sign:Number = angle > 0 ? 1 : -1;
			while( angle > twoPi )
			{
				angle -= sign * twoPi;
				abs = Math.abs( angle );
			}

			return angle;
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

		public function get collisionPoint():Vector3D
		{
			return _collisionPoint;
		}
	}
}
