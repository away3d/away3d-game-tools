/*

 Basic character and camera control using AwayGameTools.

 Demonstrates:

 How to set up input controllers for use in camera and character controllers

 Code by Alejandro Santander
 palebluedot@gmail.com
 http://www.lidev.com.ar

 This code is distributed under the MIT License

 Copyright (c)

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the “Software”), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.

 */

package
{

	import agt.controllers.IController;
	import agt.controllers.camera.CameraControllerBase;
	import agt.controllers.camera.FirstPersonCameraController;
	import agt.controllers.camera.FreeFlyCameraController;
	import agt.controllers.camera.ObserverCameraController;
	import agt.controllers.camera.OrbitCameraController;
	import agt.controllers.camera.ThirdPersonCameraController;
	import agt.controllers.entities.character.AnimatedCharacterEntityController;

	import agt.debug.DebugMaterialLibrary;
	import agt.input.CompositeInputContext;
	import agt.input.InputType;
	import agt.input.KeyboardInputContext;
	import agt.input.MouseAction;
	import agt.input.MouseInputContext;
	import agt.physics.PhysicsScene3D;
	import agt.physics.entities.CharacterEntity;
	import agt.physics.entities.DynamicEntity;

	import away3d.animators.data.SkeletonAnimationSequence;
	import away3d.animators.data.SkeletonAnimationState;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.library.assets.AssetType;
	import away3d.lights.PointLight;
	import away3d.loaders.Loader3D;
	import away3d.loaders.parsers.MD5AnimParser;
	import away3d.loaders.parsers.MD5MeshParser;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.Cube;
	import away3d.primitives.Plane;

	import awayphysics.collision.shapes.AWPBoxShape;

	import awayphysics.collision.shapes.AWPStaticPlaneShape;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;

	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;

	public class CameraAndCharacterControlExample extends Sprite
	{
		[Embed(source="assets/models/hellknight/hellknight.md5mesh", mimeType="application/octet-stream")]
		private var HellKnightMesh:Class;
		[Embed(source="assets/models/hellknight/idle2.md5anim", mimeType="application/octet-stream")]
		private var HellKnightIdleAnimation:Class;
		[Embed(source="assets/models/hellknight/walk7.md5anim", mimeType="application/octet-stream")]
		private var HellKnightWalkAnimation:Class;
		[Embed(source="assets/models/hellknight/hellknight.jpg")]
		private var HellKnightTexture:Class;
		[Embed(source="assets/models/hellknight/hellknight_s.png")]
		private var HellKnightSpecularMap:Class;
		[Embed(source="assets/models/hellknight/hellknight_local.png")]
		private var HellKnightNormalMap:Class;

		public var light:PointLight;
		public var view:View3D;
		public var scene:PhysicsScene3D;
		public var stats:AwayStats;
		public var hellKnightMesh:Mesh;
		public var idleAnimation:SkeletonAnimationSequence;
		public var walkAnimation:SkeletonAnimationSequence;
		public var cameraController:IController;
		public var player:CharacterEntity;
		public var playerController:AnimatedCharacterEntityController;

		public function CameraAndCharacterControlExample()
		{
			// wait for stage before init...
			addEventListener(Event.ADDED_TO_STAGE, stageInitHandler);
		}

		private function stageInitHandler(evt:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, stageInitHandler);
			loadStuff();
		}

		// ---------------------------------------------------------------------
		// loading
		// ---------------------------------------------------------------------

		private function loadStuff():void
		{
			// (1) retrieve hell knight mesh
			var loader:Loader3D = new Loader3D();
			loader.parseData(new HellKnightMesh(), new MD5MeshParser());
			loader.addEventListener(AssetEvent.ASSET_COMPLETE, load1);
		}

		private function load1(evt:AssetEvent):void
		{
			// retrieve hell knight mesh}
			if(evt.asset.assetType != AssetType.MESH)
				return;

			hellKnightMesh = evt.asset as Mesh;

			// set hell knight material
			var hellknightMaterial:BitmapMaterial = new BitmapMaterial(new HellKnightTexture().bitmapData);
			hellknightMaterial.normalMap = new HellKnightNormalMap().bitmapData;
			hellknightMaterial.specularMap = new HellKnightSpecularMap().bitmapData;
			hellKnightMesh.material = hellknightMaterial;

			// (2) retrieve hell knight idle animation sequence
			var loader:Loader3D = new Loader3D();
			loader.addEventListener(AssetEvent.ASSET_COMPLETE, load2);
			loader.parseData(new HellKnightIdleAnimation(), new MD5AnimParser());
		}

		private function load2(evt:AssetEvent):void
		{
			// retrieve hell knight idle animation sequence
			idleAnimation = evt.asset as SkeletonAnimationSequence;
			idleAnimation.name = "idle";

			// (3) retrieve hell knight idle animation sequence
			var loader:Loader3D = new Loader3D();
			loader.addEventListener(AssetEvent.ASSET_COMPLETE, load3);
			loader.parseData(new HellKnightWalkAnimation(), new MD5AnimParser());
		}

		private function load3(evt:AssetEvent):void
		{
			// retrieve hell knight idle animation sequence
			walkAnimation = evt.asset as SkeletonAnimationSequence;
			walkAnimation.name = "walk";

			// run example
			startExample();
		}

		// ---------------------------------------------------------------------
		// example
		// ---------------------------------------------------------------------

		private function startExample():void
		{
			// stage
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = 30;

			// away3d
			scene = new PhysicsScene3D();
			view = new View3D(scene); // use physics
			addChild(view);
			view.antiAlias = 4;
			view.camera.lens.near = 150;
			view.camera.lens.far = 50000;
			view.camera.position = new Vector3D(2000, 2000, -2000);
			view.camera.lookAt(new Vector3D(0, 0, 0));

			// stats
			stats = new AwayStats(view);
			stats.x = stage.stageWidth - stats.width;
			addChild(stats);

			// light
			light = new PointLight();
			view.scene.addChild(light);
			DebugMaterialLibrary.instance.lights = [light];

			// level, player and camera control
			setupLevel();
			setupPlayer();
			setupCameraControl();

			// start loop
			addEventListener(Event.ENTER_FRAME, enterframeHandler);
		}

		private function setupLevel():void
		{
			// floor
			var floorMesh:Plane = new Plane(DebugMaterialLibrary.instance.redMaterial);
			floorMesh.width = floorMesh.height = 15000;
			floorMesh.rotationX = 90;
			var floor:DynamicEntity = new DynamicEntity(new AWPStaticPlaneShape(), floorMesh);
			scene.addDynamicEntity(floor);

			// boxes
			var boxMesh:Cube = new Cube(boxMaterial, 200, 200, 200);
			var boxShape:AWPBoxShape = new AWPBoxShape(200, 200, 200);
			var boxMaterial:ColorMaterial = DebugMaterialLibrary.instance.blueMaterial;
			boxMaterial.lights = [light];
			boxMesh.material = boxMaterial;
			var numX:int = 16;
			var numY:int = 4;
			var numZ:int = 1;
			for(var i:uint = 0; i < numX; i++)
			{
				for(var j:int = 0; j < numZ; j++)
				{
					var x:Number = i * 200 - 75 * numX;
					var z:Number = j * 200;

					for(var k:int = 0; k < numY; k++)
					{
						var y:Number = 100 + k * 200;
						var box:DynamicEntity = new DynamicEntity(boxShape, boxMesh.clone() as ObjectContainer3D, 0.5);
						box.body.friction = 0.9;
						box.body.linearDamping = 0.03;
						box.body.angularDamping = 0.03;
						box.body.position = new Vector3D(x, y, z);
						scene.addDynamicEntity(box);
					}
				}
			}
		}

		private function setupPlayer():void
		{
			// player
			hellKnightMesh.material.lights = [light];
			var middleMesh:Mesh = new Mesh();
			middleMesh.rotationY = -180;
			middleMesh.scale(6);
			middleMesh.moveTo(0, -400, 20);
			middleMesh.addChild(hellKnightMesh);
			var playerMesh:Mesh = new Mesh();
			playerMesh.addChild(middleMesh);
			player = new CharacterEntity(playerMesh, 150 * playerMesh.scaleX, 500 * playerMesh.scaleX);
			player.character.jumpSpeed = 4000;
			player.position = new Vector3D(0, 500 * playerMesh.scaleX - 150 * playerMesh.scaleX, -1700);
			scene.addCharacterEntity(player);

			// player input context
			var keyboardContext:KeyboardInputContext = new KeyboardInputContext(stage);
			keyboardContext.mapWithAmount(InputType.TRANSLATE_Z, 50, Keyboard.W);
			keyboardContext.mapWithAmount(InputType.TRANSLATE_Z, -15, Keyboard.S);
			keyboardContext.mapWithAmount(InputType.TRANSLATE_Z, 100, Keyboard.W, Keyboard.SHIFT);
			keyboardContext.mapWithAmount(InputType.ROTATE_Y, 5, Keyboard.D);
			keyboardContext.mapWithAmount(InputType.ROTATE_Y, -5, Keyboard.A);
			keyboardContext.map(InputType.JUMP, Keyboard.SPACE);

			// player controller
			playerController = new AnimatedCharacterEntityController(player, hellKnightMesh.animationState as SkeletonAnimationState);
			playerController.addAnimationSequence(walkAnimation);
			playerController.addAnimationSequence(idleAnimation);
			playerController.moveEase = 0.2;
			playerController.overallAnimationToSpeedFactor = 0.05;
			playerController.walkAnimationToSpeedFactor = 1;
			playerController.runAnimationToSpeedFactor = 0.5;
			playerController.idleAnimationToSpeedFactor = 25;
			playerController.jumpAnimationToSpeedFactor = 0.1;
			playerController.runSpeedLimit = 50;
			playerController.inputContext = keyboardContext;
		}

		private function setupCameraControl():void
		{
			// mouse input
			var mouseInput:MouseInputContext = new MouseInputContext(view);
			mouseInput.map(InputType.TRANSLATE_X, MouseAction.DRAG_X, -5);
			mouseInput.map(InputType.TRANSLATE_Y, MouseAction.DRAG_Y, 5);
//			mouseInput.map(InputType.ROTATE_Y, MouseAction.DRAG_X, -5); // use these with free fly or 1st person camera controllers
//			mouseInput.map(InputType.ROTATE_X, MouseAction.DRAG_Y, 5);
			mouseInput.map(InputType.TRANSLATE_Z, MouseAction.WHEEL, 50);

			// keyboard input
			var keyboardInput:KeyboardInputContext = new KeyboardInputContext(stage);
			keyboardInput.mapWithAmount(InputType.TRANSLATE_X, 50, Keyboard.RIGHT);
			keyboardInput.mapWithAmount(InputType.TRANSLATE_X, -50, Keyboard.LEFT);
			keyboardInput.mapWithAmount(InputType.TRANSLATE_Z, 50, Keyboard.UP);
			keyboardInput.mapWithAmount(InputType.TRANSLATE_Z, -50, Keyboard.DOWN);
			keyboardInput.mapWithAmount(InputType.TRANSLATE_Y, 50, Keyboard.Z);
			keyboardInput.mapWithAmount(InputType.TRANSLATE_Y, -50, Keyboard.X);

			// composite input
			var compositeInput:CompositeInputContext = new CompositeInputContext();
			compositeInput.addContext(mouseInput);
			compositeInput.addContext(keyboardInput);

			// camera controller (choose one)
			cameraController = new OrbitCameraController(view.camera, player.container);
//			cameraController = new ObserverCameraController(view.camera, player.container);
//			cameraController = new ThirdPersonCameraController(view.camera, playerController);
//			cameraController = new FreeFlyCameraController(view.camera);
//			cameraController = new FirstPersonCameraController(view.camera, playerController);
			cameraController.inputContext = compositeInput;
		}

		private function enterframeHandler(evt:Event):void
		{
			playerController.update();
			scene.updatePhysics();
			cameraController.update();
			light.transform = view.camera.transform.clone();
			view.render();
		}
	}
}
