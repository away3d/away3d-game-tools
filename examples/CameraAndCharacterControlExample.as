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

package {

	import agt.controllers.camera.OrbitCameraController;
	import agt.controllers.entities.character.AnimatedCharacterEntityController;

	import agt.debug.DebugMaterialLibrary;
	import agt.input.device.KeyboardInputContext;
	import agt.input.device.MouseInputContext;
	import agt.input.events.InputEvent;
	import agt.physics.PhysicsScene3D;
	import agt.physics.entities.CharacterEntity;
	import agt.physics.entities.DynamicEntity;

	import away3d.animators.data.SkeletonAnimationSequence;
	import away3d.animators.data.SkeletonAnimationState;
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
	import away3d.primitives.Plane;

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
		public var cameraController:OrbitCameraController;
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

			// floor
			var floorMesh:Plane = new Plane(DebugMaterialLibrary.instance.redMaterial);
			floorMesh.width = floorMesh.height = 5000;
			floorMesh.rotationX = 90;
			var floor:DynamicEntity = new DynamicEntity(new AWPStaticPlaneShape(), floorMesh);
			scene.addDynamicEntity(floor);

			// player
			hellKnightMesh.material.lights = [light];
			var middleMesh:Mesh = new Mesh();
			middleMesh.rotationY = -180;
			middleMesh.scale(6);
			middleMesh.moveTo(0, -400, 20);
			middleMesh.addChild(hellKnightMesh);
			var playerMesh:Mesh = new Mesh();
			playerMesh.addChild(middleMesh);
			var player:CharacterEntity = new CharacterEntity(playerMesh, 150 * playerMesh.scaleX, 500 * playerMesh.scaleX);
			player.character.jumpSpeed = 4000;
			scene.addCharacterEntity(player);

			// player controller
			var playerInputContext:KeyboardInputContext = new KeyboardInputContext(stage);
			playerInputContext.mapOnKeyComboDown(new InputEvent(InputEvent.WALK, 60), Keyboard.SHIFT, Keyboard.W);
			playerInputContext.mapOnKeyDown(new InputEvent(InputEvent.WALK, 30), Keyboard.W);
			playerInputContext.mapOnKeyDown(new InputEvent(InputEvent.WALK, -5), Keyboard.S);
			playerInputContext.mapOnKeyDown(new InputEvent(InputEvent.SPIN, 5), Keyboard.D);
			playerInputContext.mapOnKeyDown(new InputEvent(InputEvent.SPIN, -5), Keyboard.A);
			playerInputContext.mapOnKeyPressed(new InputEvent(InputEvent.JUMP), Keyboard.SPACE);
			playerInputContext.mapOnAllDownKeysReleased(new InputEvent(InputEvent.STOP));
			playerController = new AnimatedCharacterEntityController(player, hellKnightMesh.animationState as SkeletonAnimationState);
			playerController.addAnimationSequence(walkAnimation);
			playerController.addAnimationSequence(idleAnimation);
			playerController.walkAnimationToSpeedFactor = 0.06;
			playerController.jumpAnimationToSpeedFactor = 0.005;
			playerController.stop();
			playerController.inputContext = playerInputContext;

			// camera control
			var cameraInputContext:MouseInputContext = new MouseInputContext(view);
			cameraInputContext.mapOnDragX(new InputEvent(InputEvent.ROTATE_Y));
			cameraInputContext.mapOnDragY(new InputEvent(InputEvent.ROTATE_X));
			cameraInputContext.mapOnWheel(new InputEvent(InputEvent.MOVE_Z));
			cameraInputContext.mouseInputFactorX = -3;
			cameraInputContext.mouseInputFactorY = 3;
			cameraInputContext.mouseInputFactorWheel = 25;
			cameraController = new OrbitCameraController(view.camera, player.container);
			cameraController.inputContext = cameraInputContext;

			// start loop
			addEventListener(Event.ENTER_FRAME, enterframeHandler);
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
