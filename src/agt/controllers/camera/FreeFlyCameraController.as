package agt.controllers.camera {
	import agt.input.InputContext;
	import agt.input.events.InputEvent;

	import away3d.containers.ObjectContainer3D;

	public class FreeFlyCameraController extends CameraControllerBase {
		private var _cameraDummy : ObjectContainer3D;

		// this object is moved instantly, the camera tweens towards it
		public function FreeFlyCameraController(camera : ObjectContainer3D) {
			_cameraDummy = new ObjectContainer3D();
			super(camera);
		}

		override public function set inputContext(context : InputContext) : void {
			super.inputContext = context;
			registerEvent(InputEvent.MOVE_X, moveX);
			registerEvent(InputEvent.MOVE_Y, moveY);
			registerEvent(InputEvent.MOVE_Z, moveZ);
			registerEvent(InputEvent.ROTATE_X, rotateX);
			registerEvent(InputEvent.ROTATE_Y, rotateY);
		}

		override public function update() : void {
			super.update();

			// ease position
			var dx : Number = _cameraDummy.x - _camera.x;
			var dy : Number = _cameraDummy.y - _camera.y;
			var dz : Number = _cameraDummy.z - _camera.z;
			_camera.x += dx * linearEase;
			_camera.y += dy * linearEase;
			_camera.z += dz * linearEase;

			// ease orientation
			dx = _cameraDummy.rotationX - _camera.rotationX;
			dy = _cameraDummy.rotationY - _camera.rotationY;
			dz = _cameraDummy.rotationZ - _camera.rotationZ;
			_camera.rotationX += dx * angularEase;
			_camera.rotationY += dy * angularEase;
			_camera.rotationZ += dz * angularEase;
		}

		public function rotateY(value : Number) : void {
			_cameraDummy.rotationY += value;
		}

		public function rotateX(value : Number) : void {
			_cameraDummy.rotationX += value;
		}

		public function moveX(value : Number) : void {
			_cameraDummy.moveRight(value);
		}

		public function moveY(value : Number) : void {
			_cameraDummy.moveUp(value);
		}

		public function moveZ(value : Number) : void {
			_cameraDummy.moveForward(value);
		}

		override public function set camera(value : ObjectContainer3D) : void {
			super.camera = value;
			_cameraDummy.transform = _camera.transform.clone();
		}
	}
}
