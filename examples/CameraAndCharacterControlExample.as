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
	import agt.controllers.camera.OrbitCameraController;
	import agt.controllers.camera.ThirdPersonCameraController;
	import agt.controllers.entities.character.AnimatedCharacterEntityController;

	import agt.debug.DebugMaterialLibrary;
	import agt.input.contexts.DefaultMouseKeyboardInputContext;
	import agt.input.data.InputType;
	import agt.input.contexts.KeyboardInputContext;
	import agt.physics.PhysicsScene3D;
	import agt.physics.entities.CharacterEntity;
	import agt.utils.PhysicsUtils;

	import away3d.animators.data.SkeletonAnimationSequence;
	import away3d.animators.data.SkeletonAnimationState;
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.entities.SegmentSet;
	import away3d.events.AssetEvent;
	import away3d.extrusions.Elevation;
	import away3d.library.assets.AssetType;
	import away3d.lights.PointLight;
	import away3d.loaders.Loader3D;
	import away3d.loaders.parsers.MD5AnimParser;
	import away3d.loaders.parsers.MD5MeshParser;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.Cube;
	import away3d.primitives.Cylinder;
	import away3d.primitives.LineSegment;
	import away3d.primitives.Plane;
	import away3d.primitives.Sphere;

	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.collision.shapes.AWPBvhTriangleMeshShape;
	import awayphysics.collision.shapes.AWPCylinderShape;

	import awayphysics.collision.shapes.AWPStaticPlaneShape;
	import awayphysics.dynamics.AWPRigidBody;

	import flash.display.BitmapData;

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
		[Embed(source="assets/models/hellknight/stand.md5anim", mimeType="application/octet-stream")]
		private var HellKnightIdleAnimation:Class;
		[Embed(source="assets/models/hellknight/walk7.md5anim", mimeType="application/octet-stream")]
		private var HellKnightWalkAnimation:Class;
		[Embed(source="assets/models/hellknight/ik_pose.md5anim", mimeType="application/octet-stream")]
		private var HellKnightJumpAnimation:Class;
		[Embed(source="assets/models/hellknight/pain1.md5anim", mimeType="application/octet-stream")]
		private var HellKnightHitAnimation:Class;
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
		public var jumpAnimation:SkeletonAnimationSequence;
		public var hitAnimation:SkeletonAnimationSequence;
		public var cameraController:IController;
		public var player:CharacterEntity;
		public var playerController:AnimatedCharacterEntityController;
//		public var collideBox:DynamicEntity;
//		public var collideBox1:DynamicEntity;
		public var redBox:AWPRigidBody;
		public var greenBox:AWPRigidBody;
		public var playerMesh:Mesh;

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
			loader.loadData(new HellKnightMesh(), new MD5MeshParser());
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
			loader.loadData(new HellKnightIdleAnimation(), new MD5AnimParser());
		}

		private function load2(evt:AssetEvent):void
		{
			// retrieve hell knight idle animation sequence
			idleAnimation = evt.asset as SkeletonAnimationSequence;
			idleAnimation.name = "idle";

			// (3) retrieve hell knight walk animation sequence
			var loader:Loader3D = new Loader3D();
			loader.addEventListener(AssetEvent.ASSET_COMPLETE, load3);
			loader.loadData(new HellKnightWalkAnimation(), new MD5AnimParser());
		}

		private function load3(evt:AssetEvent):void
		{
			// retrieve hell knight idle animation sequence
			walkAnimation = evt.asset as SkeletonAnimationSequence;
			walkAnimation.name = "walk";

			// (4) retrieve hell knight walk animation sequence
			var loader:Loader3D = new Loader3D();
			loader.addEventListener(AssetEvent.ASSET_COMPLETE, load4);
			loader.loadData(new HellKnightJumpAnimation(), new MD5AnimParser());
		}

		private function load4(evt:AssetEvent):void
		{
			// retrieve hell knight jump animation sequence
			jumpAnimation = evt.asset as SkeletonAnimationSequence;
			jumpAnimation.name = "jump";

			// (5) retrieve hell knight walk animation sequence
			var loader:Loader3D = new Loader3D();
			loader.addEventListener(AssetEvent.ASSET_COMPLETE, load5);
			loader.loadData(new HellKnightHitAnimation(), new MD5AnimParser());
		}

		private function load5(evt:AssetEvent):void
		{
			// retrieve hell knight hit animation sequence
			hitAnimation = evt.asset as SkeletonAnimationSequence;
			hitAnimation.name = "hit";

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
			view.camera.lens.near = 1;
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

			// level and player
			setupLevel();
			setupPlayer();
			setupCollideBoxes();

			// camera control
//			cameraController = new OrbitCameraController(view.camera, playerMesh);
			cameraController = new ThirdPersonCameraController(view.camera, playerController);
			scene.addCharacter( ThirdPersonCameraController(cameraController).initializeCollider( 50, 500 ) );
			ThirdPersonCameraController(cameraController).maxElevation = 0;
			cameraController.inputContext = new DefaultMouseKeyboardInputContext(view, stage);

			// start loop
			addEventListener(Event.ENTER_FRAME, enterframeHandler);
		}

		private var _cameraContactTracer:SegmentSet;
		private var _floor:Elevation;

		private function setupLevel():void
		{
			// floor
			var bmd:BitmapData = new BitmapData(2048, 2048, false, 0);
			bmd.perlinNoise(256, 256, 2, 1, false, true, 7, true);
			var bitmapMaterial:BitmapMaterial = new BitmapMaterial(bmd);
			bitmapMaterial.lights = [light];
			_floor = new Elevation(bitmapMaterial, bmd,
													25000, 1500, 25000, 30, 30);
			scene.addChild(_floor);
			var floorBody:AWPRigidBody = new AWPRigidBody( new AWPBvhTriangleMeshShape( _floor.geometry ) );
			scene.addRigidBody( floorBody );

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
						// add mesh
						var mesh:Mesh = boxMesh.clone() as Mesh;
						scene.addChild(mesh);

						// add body
						var body:AWPRigidBody = new AWPRigidBody(boxShape, mesh, 0.5);
						var y:Number = 1500 + 100 + k * 200;
						body.friction = 0.9;
						body.linearDamping = 0.03;
						body.angularDamping = 0.03;
						body.position = new Vector3D(x, y, z);
						scene.addRigidBody(body);
					}
				}
			}

			// pillars
			var wallMaterial:ColorMaterial = new ColorMaterial( 0xFFFFFF );
			wallMaterial.lights = [light];
			for(i = 0; i < 50; ++i)
				addPillar( rand(-10000, 10000), rand( -10000, 10000 ), rand( 100, 1000 ), wallMaterial );

			// trace
			_cameraContactTracer = new SegmentSet();
			var line:LineSegment = new LineSegment( new Vector3D(), new Vector3D(0, 100, 0), 0xFF0000, 0xFF0000, 10 );
			_cameraContactTracer.addSegment(line);
			scene.addChild(_cameraContactTracer);
		}

		private function addPillar( px:Number, pz:Number, radius:Number, material:ColorMaterial  ):void
		{
			var mesh:Cylinder = new Cylinder(material, radius, radius, 2000);
			mesh.x = px;
			mesh.y = 1500;
			mesh.z = pz;
			view.scene.addChild(mesh);

			var shape:AWPCylinderShape = new AWPCylinderShape( radius, 2000 );
			var body:AWPRigidBody = new AWPRigidBody( shape, mesh );
			PhysicsUtils.applyObjectTransformToBodyTransform(mesh, body);
			scene.addChild(mesh);
			scene.addRigidBody(body);
		}

		private function setupCollideBoxes():void
		{
			// Red box
			var redBoxMesh:Cube = new Cube(DebugMaterialLibrary.instance.redMaterial, 500, 500, 500);
			scene.addChild(redBoxMesh);
			var redBoxShape:AWPBoxShape = new AWPBoxShape(redBoxMesh.width, redBoxMesh.height, redBoxMesh.depth);
			redBox = new AWPRigidBody( redBoxShape, redBoxMesh );
			redBox.position = new Vector3D(0, 500 + redBoxMesh.height/2, -600);
			scene.addRigidBody( redBox );
			player.addNotifyOnCollision(redBox, onPlayerRedBoxCollision);

			// Green box
			var greenBoxMesh:Cube = new Cube(DebugMaterialLibrary.instance.greenMaterial, 500, 25, 1000);
			scene.addChild(greenBoxMesh);
			var greenBoxShape:AWPBoxShape = new AWPBoxShape(greenBoxMesh.width, greenBoxMesh.height, greenBoxMesh.depth);
			greenBox = new AWPRigidBody( greenBoxShape, greenBoxMesh )
			greenBox.position = new Vector3D(0, 1000, 2000);
			scene.addRigidBody( greenBox );
			player.addNotifyOnCollision(greenBox, onPlayerGreenBoxCollision);
		}

		private function rand(min:Number, max:Number):Number
		{
		    return (max - min)*Math.random() + min;
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
			playerMesh = new Mesh();
			playerMesh.addChild(middleMesh);
			view.scene.addChild(playerMesh);

			player = new CharacterEntity(150 * playerMesh.scaleX, 500 * playerMesh.scaleX);
			player.skin = playerMesh;
			player.collideStrength *= 10;
			player.characterController.jumpSpeed = 2000;
			player.position = new Vector3D(0, 1000 + 500 * playerMesh.scaleX - 150 * playerMesh.scaleX, -1700);
			scene.addCharacterEntity(player);

			// player input context
			var keyboardContext:KeyboardInputContext = new KeyboardInputContext(stage);
			keyboardContext.map(InputType.WALK, Keyboard.W);
			keyboardContext.map(InputType.RUN, Keyboard.W, Keyboard.SHIFT);
			keyboardContext.mapWithAmount(InputType.ROTATE_Y, 5, Keyboard.D);
			keyboardContext.mapWithAmount(InputType.ROTATE_Y, -5, Keyboard.A);
			keyboardContext.map(InputType.JUMP, Keyboard.SPACE);

			// player controller
			playerController = new AnimatedCharacterEntityController(player, hellKnightMesh.animationState as SkeletonAnimationState);
			playerController.addAnimationSequence(walkAnimation);
			playerController.addAnimationSequence(idleAnimation);
			playerController.addAnimationSequence(jumpAnimation);
			playerController.addAnimationSequence(hitAnimation);
			playerController.speedFactor = 3;
			playerController.timeScale = 1.5;
			playerController.inputContext = keyboardContext;
			playerController.playAnimation(idleAnimation.name);
		}

		public function onPlayerGreenBoxCollision():void
		{
			playerController.jump();
		}

		public function onPlayerRedBoxCollision():void
		{
			// eval character speed
			var speed:Number = player.characterController.walkDirection.length;
			if(speed > 0) // if moving
			{
				var playerToObject:Vector3D = redBox.position;
				playerToObject = playerToObject.subtract(player.kinematicBody.position);
				playerToObject.normalize();
				var comp:Number = player.characterController.walkDirection.dotProduct(playerToObject);
				if(comp > 0.1) // if moving towards the box
				{
					playerController.playAnimation("hit", true);
				}
			}
		}

		private function enterframeHandler(evt:Event):void
		{
			var line:LineSegment = _cameraContactTracer.getSegment(0) as LineSegment;
			var start:Vector3D = ThirdPersonCameraController( cameraController ).collisionPoint;
			var end:Vector3D = start.add( ThirdPersonCameraController( cameraController ).collisionNormal );
			line.start = start;
			line.end = end;
//			trace( "start: " + start + ", end: " + end );

			player.update();
			playerController.update();
			scene.updatePhysics();
			cameraController.update();
			light.transform = view.camera.transform.clone();
			view.render();
		}
	}
}
