package CameraAndCharacterControl
{

	import agt.controllers.entities.AnimatedKinematicEntityController;
	import agt.controllers.entities.KinematicEntityController;
	import agt.core.PhysicsScene3D;
	import agt.entities.KinematicEntity;
	import agt.input.KeyboardInputContext;
	import agt.input.events.InputEvent;

	import away3d.animators.data.SkeletonAnimationSequence;

	import away3d.entities.Mesh;
	import away3d.extrusions.Elevation;
	import away3d.lights.PointLight;

	import away3d.materials.BitmapMaterial;

	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;

	public class Player
	{
		public var baseMesh:Mesh;
		public var entity:KinematicEntity;
		public var inputContext:KeyboardInputContext;
		public var controller:AnimatedKinematicEntityController;

		public function Player(stage:Stage, scene:PhysicsScene3D, light:PointLight, idleAnimation:SkeletonAnimationSequence, walkAnimation:SkeletonAnimationSequence, mesh:Mesh, texture:BitmapData, normalMap:BitmapData, specularMap:BitmapData, terrainMesh:Elevation)
		{
			// prepare material
			var hellknightMaterial:BitmapMaterial = new BitmapMaterial(texture);
			hellknightMaterial.lights = [light];
			hellknightMaterial.normalMap = normalMap;
			hellknightMaterial.specularMap = specularMap;

			// get mesh
			baseMesh = mesh.clone() as Mesh;
			// transform is controlled by animator
			baseMesh.material = hellknightMaterial;
			var middleMesh:Mesh = new Mesh();
			middleMesh.rotationY = -180;
			middleMesh.scale(6);
			middleMesh.moveTo(0, -400, 20);
			middleMesh.addChild(baseMesh);
			var playerMesh:Mesh = new Mesh();
			// transform is controlled by AWP
			playerMesh.addChild(middleMesh); // TODO: Can simplify hierarchy here?
			scene.addChild(playerMesh);

			// setup player
			entity = new KinematicEntity(playerMesh, 150, 500);
			entity.kinematics.jumpSpeed = 2000; // TODO: can avoid/mask .kinematics access?
			scene.addKinematicEntity(entity);
			var terrainPos:Number = terrainMesh.getHeightAt(0, 0);
			entity.position = new Vector3D(0, terrainPos + 1000, -1000);
			// TODO: review use of .x, .y, .z in AGT architecture

			// player controller input context
			inputContext = new KeyboardInputContext(stage);
			inputContext.map(Keyboard.W, new InputEvent(InputEvent.MOVE_Z, 30));
			inputContext.map(Keyboard.S, new InputEvent(InputEvent.MOVE_Z, -30));
			inputContext.map(Keyboard.D, new InputEvent(InputEvent.ROTATE_Y, 3));
			inputContext.map(Keyboard.A, new InputEvent(InputEvent.ROTATE_Y, -3));
			inputContext.map(Keyboard.SPACE, new InputEvent(InputEvent.JUMP));
			inputContext.mapOnAllKeysUp(new InputEvent(InputEvent.STOP));
			inputContext.mapMultiplier(Keyboard.SHIFT, 2);

			// player controller
			controller = new AnimatedKinematicEntityController(entity, baseMesh);
			controller.addAnimationSequence(walkAnimation); // TODO: Map animations to actions too?
			controller.addAnimationSequence(idleAnimation);
			controller.inputContext = inputContext;
			controller.stop();
			controller.speedEase = 0.1;
			controller.animatorTimeScaleFactor = 0.05;
		}

		public function update():void
		{
			controller.update();
		}
	}
}
