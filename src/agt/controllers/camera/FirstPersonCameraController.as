package agt.controllers.camera
{

	import agt.controllers.IController;
	import agt.controllers.entities.character.CharacterEntityController;
	import agt.input.data.InputType;
	import agt.physics.entities.CharacterEntity;

	import away3d.containers.ObjectContainer3D;

	import flash.geom.Matrix3D;

	import flash.geom.Vector3D;

	public class FirstPersonCameraController extends CameraControllerBase implements IController
	{
		private var _targetController:CharacterEntityController;
		private var _cameraDummy:ObjectContainer3D;
		private var _cameraOffset:Vector3D;

		public function FirstPersonCameraController(camera:ObjectContainer3D, targetController:CharacterEntityController = null)
		{
			_cameraDummy = new ObjectContainer3D();
			this.targetController = targetController;
			_cameraOffset = new Vector3D();
			super(camera);
		}

		override public function update():void
		{
			super.update();

			// update input from context?
			if(_inputContext)
			{
				rotateX(_inputContext.inputAmount(InputType.ROTATE_X) * 0.1);
				rotateY(_inputContext.inputAmount(InputType.ROTATE_Y) * -0.1);
			}

			// set camera position equal to entity, with offset
			var pos:Vector3D = _targetController.entity.container.transform.transformVector(_cameraOffset);
			_camera.x = pos.x;
			_camera.y = pos.y;
			_camera.z = pos.z;

			// ease orientation
			var dx:Number = _cameraDummy.rotationX - _camera.rotationX;
			var dy:Number = _cameraDummy.rotationY - _camera.rotationY;
			var dz:Number = _cameraDummy.rotationZ - _camera.rotationZ;
			_camera.rotationX += dx * angularEase;
			_camera.rotationY += dy * angularEase;
			_camera.rotationZ += dz * angularEase;

			// fix target rotation to camera rotation
			_targetController.rotationY = _camera.rotationY;
		}

		public function rotateX(value:Number):void
		{
			_cameraDummy.rotationX += value;
		}

		public function rotateY(value:Number):void
		{
			_cameraDummy.rotationY += value;
		}

		public function get targetController():CharacterEntityController
		{
			return _targetController;
		}

		public function set targetController(value:CharacterEntityController):void
		{
			_targetController = value;
		}

		override public function set camera(value:ObjectContainer3D):void
		{
			super.camera = value;

			_camera.transform = CharacterEntity(_targetController.entity).container.transform.clone();
			_cameraDummy.transform = _camera.transform.clone();

			// TODO: Not sure why, but if this isn't done, Y rotation is inverted some times
			// Happens after coming from an orbit camera and being at certain rotations
			// this sucks since it makes the camera jump when changed, but avoids the bug
			_cameraDummy.rotationX = _cameraDummy.rotationY = _cameraDummy.rotationZ = 0;
		}

		public function get cameraOffset():Vector3D
		{
			return _cameraOffset;
		}

		public function set cameraOffset(value:Vector3D):void
		{
			_cameraOffset = value;
		}
	}
}
