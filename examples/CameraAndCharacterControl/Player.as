package CameraAndCharacterControl
{

	import agt.physics.PhysicsScene3D;
	import agt.input.device.KeyboardInputContext;
	import agt.input.events.InputEvent;

	import away3d.animators.data.SkeletonAnimationSequence;

	import away3d.entities.Mesh;
	import flash.display.Stage;
	import flash.ui.Keyboard;

	public class Player extends HellKnight
	{
		public var inputContext:KeyboardInputContext;

		public function Player(mesh:Mesh, scene:PhysicsScene3D, idleAnimation:SkeletonAnimationSequence, walkAnimation:SkeletonAnimationSequence, stage:Stage)
		{
			super(mesh, scene, idleAnimation, walkAnimation);

			// player controller input context
			inputContext = new KeyboardInputContext(stage);
			inputContext.map(Keyboard.W, new InputEvent(InputEvent.MOVE_Z, 50));
			inputContext.map(Keyboard.S, new InputEvent(InputEvent.MOVE_Z, -50));
			inputContext.map(Keyboard.D, new InputEvent(InputEvent.ROTATE_Y, 5));
			inputContext.map(Keyboard.A, new InputEvent(InputEvent.ROTATE_Y, -5));
			inputContext.map(Keyboard.SPACE, new InputEvent(InputEvent.JUMP));
			inputContext.mapOnAllKeysUp(new InputEvent(InputEvent.STOP));
			inputContext.mapMultiplier(Keyboard.SHIFT, 2);
			controller.inputContext = inputContext;
		}

		public function update():void
		{
			controller.update();
		}
	}
}
