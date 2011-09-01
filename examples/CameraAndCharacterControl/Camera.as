package CameraAndCharacterControl
{

	import agt.controllers.camera.CameraControllerBase;
	import agt.controllers.camera.FirstPersonCameraController;
	import agt.controllers.camera.FreeFlyCameraController;
	import agt.controllers.camera.ObserverCameraController;
	import agt.controllers.camera.OrbitCameraController;
	import agt.controllers.camera.ThirdPersonCameraController;
	import agt.controllers.entities.KinematicEntityController;
	import agt.data.MouseActions;
	import agt.entities.KinematicEntity;
	import agt.input.CompositeInputContext;
	import agt.input.KeyboardInputContext;
	import agt.input.MouseInputContext;
	import agt.input.events.InputEvent;

	import away3d.containers.View3D;
	import away3d.entities.Mesh;

	import flash.display.Stage;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;

	public class Camera
	{
		public var controller:CameraControllerBase;

		private var _stage:Stage;
		private var _view:View3D;
		private var _player:KinematicEntity;
		private var _playerController:KinematicEntityController;
		private var _playerBaseMesh:Mesh;
		private var _cameraInputContext:CompositeInputContext;

		public function Camera(stage:Stage, view:View3D, player:KinematicEntity, playerController:KinematicEntityController, playerBaseMesh:Mesh)
		{
			_stage = stage;
			_view = view;
			_player = player;
			_playerController = playerController;
			_playerBaseMesh = playerBaseMesh;
		}

		public function enableObserverCameraController():void
		{
			_cameraInputContext = new CompositeInputContext();
			controller = new ObserverCameraController(_view.camera, _player.container);
			controller.inputContext = _cameraInputContext;
		}

		public function enableOrbitCameraController():void
		{
			_cameraInputContext = new CompositeInputContext();
			var keyboardContext:KeyboardInputContext = new KeyboardInputContext(_stage);
			keyboardContext.map(Keyboard.UP, new InputEvent(InputEvent.ROTATE_X, 25));
			keyboardContext.map(Keyboard.DOWN, new InputEvent(InputEvent.ROTATE_X, -25));
			keyboardContext.map(Keyboard.RIGHT, new InputEvent(InputEvent.ROTATE_Y, 25));
			keyboardContext.map(Keyboard.LEFT, new InputEvent(InputEvent.ROTATE_Y, -25));
			_cameraInputContext.addContext(keyboardContext);
			var mouseContext:MouseInputContext = new MouseInputContext(_view);
			mouseContext.map(MouseActions.DRAG_X, new InputEvent(InputEvent.ROTATE_Y));
			mouseContext.map(MouseActions.DRAG_Y, new InputEvent(InputEvent.ROTATE_X));
			mouseContext.map(MouseActions.WHEEL, new InputEvent(InputEvent.MOVE_Z));
			mouseContext.mouseInputFactorX = -3;
			mouseContext.mouseInputFactorY = 3;
			mouseContext.mouseInputFactorWheel = 25;
			_cameraInputContext.addContext(mouseContext);

			controller = new OrbitCameraController(_view.camera, _player.container);
			OrbitCameraController(controller).minRadius = 1000;
			controller.inputContext = _cameraInputContext;
		}

		public function enableFlyCameraController():void
		{
			_cameraInputContext = new CompositeInputContext();
			var keyboardContext:KeyboardInputContext = new KeyboardInputContext(_stage);
			keyboardContext.map(Keyboard.UP, new InputEvent(InputEvent.MOVE_Z, 100));
			keyboardContext.map(Keyboard.DOWN, new InputEvent(InputEvent.MOVE_Z, -100));
			keyboardContext.map(Keyboard.RIGHT, new InputEvent(InputEvent.MOVE_X, 100));
			keyboardContext.map(Keyboard.LEFT, new InputEvent(InputEvent.MOVE_X, -100));
			keyboardContext.mapMultiplier(Keyboard.SHIFT, 4);
			_cameraInputContext.addContext(keyboardContext);
			var mouseContext:MouseInputContext = new MouseInputContext(_view);
			mouseContext.map(MouseActions.DRAG_X, new InputEvent(InputEvent.ROTATE_Y));
			mouseContext.map(MouseActions.DRAG_Y, new InputEvent(InputEvent.ROTATE_X));
			mouseContext.mouseInputFactorX = 0.25;
			mouseContext.mouseInputFactorY = 0.25;
			_cameraInputContext.addContext(mouseContext);

			controller = new FreeFlyCameraController(_view.camera);
			controller.inputContext = _cameraInputContext;
		}

		public function enableFPSCameraController():void
		{
			_cameraInputContext = new CompositeInputContext();
			var mouseContext:MouseInputContext = new MouseInputContext(_view);
			mouseContext.map(MouseActions.DRAG_X, new InputEvent(InputEvent.ROTATE_Y));
			mouseContext.map(MouseActions.DRAG_Y, new InputEvent(InputEvent.ROTATE_X));
			mouseContext.mouseInputFactorX = 0.25;
			mouseContext.mouseInputFactorY = 0.25;
			_cameraInputContext.addContext(mouseContext);

			controller = new FirstPersonCameraController(_view.camera, _playerController);
			FirstPersonCameraController(controller).cameraOffset = new Vector3D(0, 170, 100);
			controller.inputContext = _cameraInputContext;
		}

		public function enable3rdPersonCameraController():void
		{
			_cameraInputContext = new CompositeInputContext();
			var mouseContext:MouseInputContext = new MouseInputContext(_view);
			mouseContext.map(MouseActions.DRAG_X, new InputEvent(InputEvent.ROTATE_Y));
			mouseContext.map(MouseActions.DRAG_Y, new InputEvent(InputEvent.ROTATE_X));
			mouseContext.mouseInputFactorX = 0.25;
			mouseContext.mouseInputFactorY = 0.25;
			_cameraInputContext.addContext(mouseContext);

			controller = new ThirdPersonCameraController(_view.camera, _playerController);
			controller.inputContext = _cameraInputContext;
		}

		public function update():void
		{
			controller.update();
		}
	}
}
