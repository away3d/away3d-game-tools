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

		public var signature:Signature;
		public var _light:PointLight;
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

		private function loadStuff():void
		{
			// (1) retrieve hell knight mesh
			var loader:Loader3D = new Loader3D();
			loader.parseData(new HellKnightMesh(), new MD5MeshParser());
			loader.addEventListener(AssetEvent.ASSET_COMPLETE, load1);
			trace("loading hellknight mesh...");
		}

		private function load1(evt:AssetEvent):void
		{
			// retrieve hell knight mesh}
			if(evt.asset.assetType != AssetType.MESH)
				return;
			trace("hellknight mesh loaded");
			hellKnightMesh = evt.asset as Mesh;

			// set hell knight material
			var hellknightMaterial:BitmapMaterial = new BitmapMaterial(new HellKnightTexture().bitmapData);
			hellknightMaterial.normalMap = new HellKnightNormalMap().bitmapData;
			hellknightMaterial.specularMap = new HellKnightSpecularMap().bitmapData;
			hellKnightMesh.material = hellknightMaterial;

			// (2) retrieve hell knight idle animation sequence
			trace("loading idle animation...");
			var loader:Loader3D = new Loader3D();
			loader.addEventListener(AssetEvent.ASSET_COMPLETE, load2);
			loader.parseData(new HellKnightIdleAnimation(), new MD5AnimParser());
		}

		private function load2(evt:AssetEvent):void
		{
			// retrieve hell knight idle animation sequence
			trace("idle animation loaded");
			idleAnimation = evt.asset as SkeletonAnimationSequence;
			idleAnimation.name = "idle";

			// (3) retrieve hell knight idle animation sequence
			trace("loading walk animation...");
			var loader:Loader3D = new Loader3D();
			loader.addEventListener(AssetEvent.ASSET_COMPLETE, load3);
			loader.parseData(new HellKnightWalkAnimation(), new MD5AnimParser());
		}

		private function load3(evt:AssetEvent):void
		{
			// retrieve hell knight idle animation sequence
			trace("walk animation loaded");
			walkAnimation = evt.asset as SkeletonAnimationSequence;
			walkAnimation.name = "walk";

			// run example
			startExample();
		}

		private function startExample():void
		{
			// init stage
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = 30;

			// init signature
			signature = new Signature();
			addChild(signature);

			// init away3d
			scene = new PhysicsScene3D();
			view = new View3D(scene); // use physics
			addChild(view);

			// init stats
			stats = new AwayStats(view);
			addChild(stats);

			// set example signature
			signature.text = "AwayGameTools 2011 - Camera and character control example.";

			// init away3d general settings
			view.antiAlias = 4;
			view.camera.lens.near = 150;
			view.camera.lens.far = 50000;
			view.camera.position = new Vector3D(2000, 2000, -2000);
			view.camera.lookAt(new Vector3D(0, 0, 0));

			// lights
			_light = new PointLight();
			view.scene.addChild(_light);
			DebugMaterialLibrary.instance.lights = [_light];

			// setup floor
			var floorMesh:Plane = new Plane(DebugMaterialLibrary.instance.redMaterial);
			floorMesh.width = floorMesh.height = 5000;
			floorMesh.rotationX = 90;
			var floor:DynamicEntity = new DynamicEntity(new AWPStaticPlaneShape(), floorMesh);
			scene.addDynamicEntity(floor);

			// init player
			hellKnightMesh.material.lights = [_light];
			var middleMesh:Mesh = new Mesh();
			middleMesh.rotationY = -180;
			middleMesh.scale(6);
			middleMesh.moveTo(0, -400, 20);
			middleMesh.addChild(hellKnightMesh);
			var playerMesh:Mesh = new Mesh();
			playerMesh.addChild(middleMesh);

			// setup player
			var player:CharacterEntity = new CharacterEntity(playerMesh, 150 * playerMesh.scaleX, 500 * playerMesh.scaleX);
			player.character.jumpSpeed = 4000;
			scene.addCharacterEntity(player);

			// player controller input context
			var playerInputContext:KeyboardInputContext = new KeyboardInputContext(stage);
			playerInputContext.mapOnKeyComboDown(new InputEvent(InputEvent.WALK, 60), Keyboard.SHIFT, Keyboard.W);
			playerInputContext.mapOnKeyDown(new InputEvent(InputEvent.WALK, 30), Keyboard.W);
			playerInputContext.mapOnKeyDown(new InputEvent(InputEvent.WALK, -5), Keyboard.S);
			playerInputContext.mapOnKeyDown(new InputEvent(InputEvent.SPIN, 5), Keyboard.D);
			playerInputContext.mapOnKeyDown(new InputEvent(InputEvent.SPIN, -5), Keyboard.A);
			playerInputContext.mapOnKeyPressed(new InputEvent(InputEvent.JUMP), Keyboard.SPACE);
			playerInputContext.mapOnAllDownKeysReleased(new InputEvent(InputEvent.STOP));

			// player controller
			playerController = new AnimatedCharacterEntityController(player, hellKnightMesh.animationState as SkeletonAnimationState);
			playerController.addAnimationSequence(walkAnimation);
			playerController.addAnimationSequence(idleAnimation);
			playerController.walkAnimationToSpeedFactor = 0.06;
			playerController.jumpAnimationToSpeedFactor = 0.005;
			playerController.stop();
			playerController.inputContext = playerInputContext;

			// setup camera control
			var cameraInputContext:MouseInputContext = new MouseInputContext(view);
			cameraInputContext.mapOnDragX(new InputEvent(InputEvent.ROTATE_Y));
			cameraInputContext.mapOnDragY(new InputEvent(InputEvent.ROTATE_X));
			cameraInputContext.mapOnWheel(new InputEvent(InputEvent.MOVE_Z));
			cameraInputContext.mouseInputFactorX = -3;
			cameraInputContext.mouseInputFactorY = 3;
			cameraInputContext.mouseInputFactorWheel = 25;
			cameraController = new OrbitCameraController(view.camera, player.container);
			cameraController.inputContext = cameraInputContext;

			// listen for stage resize
			stage.addEventListener(Event.RESIZE, stageResizeHandler);
			stageResizeHandler(null);

			// start loop
			addEventListener(Event.ENTER_FRAME, enterframeHandler);
		}

		private function enterframeHandler(evt:Event):void
		{
			playerController.update();
			scene.updatePhysics();
			cameraController.update();
			_light.transform = view.camera.transform.clone();
			view.render();
		}

		private function stageResizeHandler(evt:Event):void
		{
			signature.x = 5;
			signature.y = stage.stageHeight - 22 - 5;

			stats.x = stage.stageWidth - stats.width;
		}
	}
}
