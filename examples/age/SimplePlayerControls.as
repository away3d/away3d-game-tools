package {
	import agt.controllers.motion.animation.SkeletonAnimationController;
	import agt.controllers.motion.camera.CameraControllerBase;
	import agt.controllers.motion.camera.FreeFlyCameraController;
	import agt.controllers.motion.camera.OrbitCameraController;
	import agt.controllers.motion.entities.GroundEntityController;
	import agt.debug.DebugMaterialLibrary;
	import agt.debug.SimpleGUI;
	import agt.devices.input.KeyboardInputContext;
	import agt.devices.input.WASDAndMouseInputContext;
	import agt.devices.input.events.InputEvent;
	import agt.entities.KinematicEntity;
	import agt.physics.PhysicsScene3D;

	import away3d.animators.data.SkeletonAnimationSequence;
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
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

	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.collision.shapes.AWPBvhTriangleMeshShape;
	import awayphysics.collision.shapes.AWPHeightfieldTerrainShape;
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.extend.AWPTerrain;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;

	public class SimplePlayerControls extends Sprite {
		[Embed(source="../assets/hellknight/hellknight.md5mesh", mimeType="application/octet-stream")]
		private var HellKnightMesh : Class;
		[Embed(source="../assets/hellknight/idle2.md5anim", mimeType="application/octet-stream")]
		private var HellKnightIdleAnimation : Class;
		[Embed(source="../assets/hellknight/walk7.md5anim", mimeType="application/octet-stream")]
		private var HellKnightWalkAnimation : Class;
		public var view : View3D;
		public var scene : PhysicsScene3D;
		public var light : PointLight;
		public var cameraController : CameraControllerBase;
		public var cameraInputContext : WASDAndMouseInputContext;
		public var terrainMesh : Elevation;
		public var gui : SimpleGUI;
		public var playerMotionController : GroundEntityController;
		public var playerAnimationController : SkeletonAnimationController;
		public var playerInputContext : KeyboardInputContext;
		public var player : KinematicEntity;
		public var hellKnightMesh : Mesh;
		public var idleAnimation : SkeletonAnimationSequence;
		public var walkAnimation : SkeletonAnimationSequence;
		public var useCameraController : Boolean;

		public function SimplePlayerControls() {
			// wait for stage
			addEventListener(Event.ADDED_TO_STAGE, stageInitHandler);
		}

		// ---------------------------------------------------------------------
		// init process
		// ---------------------------------------------------------------------
		private function stageInitHandler(evt : Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, stageInitHandler);

			// init stage
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			// retrieve hell knight mesh
			var loader : Loader3D = new Loader3D();
			loader.parseData(new HellKnightMesh(), new MD5MeshParser());
			loader.addEventListener(AssetEvent.ASSET_COMPLETE, init1);
			trace("loading hellknight mesh...");
		}

		private function init1(evt : AssetEvent) : void {
			// retrieve hell knight mesh}
			if (evt.asset.assetType != AssetType.MESH)
				return;
			trace("hellknight mesh loaded");
			hellKnightMesh = evt.asset as Mesh;

			// retrieve hell knight idle animation sequence
			trace("loading idle animation...");
			var loader : Loader3D = new Loader3D();
			loader.addEventListener(AssetEvent.ASSET_COMPLETE, init2);
			loader.parseData(new HellKnightIdleAnimation(), new MD5AnimParser());
		}

		private function init2(evt : AssetEvent) : void {
			// retrieve hell knight idle animation sequence
			trace("idle animation loaded");
			idleAnimation = evt.asset as SkeletonAnimationSequence;
			idleAnimation.name = "idle";

			// retrieve hell knight idle animation sequence
			trace("loading walk animation...");
			var loader : Loader3D = new Loader3D();
			loader.addEventListener(AssetEvent.ASSET_COMPLETE, init3);
			loader.parseData(new HellKnightWalkAnimation(), new MD5AnimParser());
		}

		private function init3(evt : AssetEvent) : void {
			// retrieve hell knight idle animation sequence
			trace("walk animation loaded");
			walkAnimation = evt.asset as SkeletonAnimationSequence;
			walkAnimation.name = "walk";

			// adjust hellknight stuff
			// hellKnightMesh.rotationY = -90;
			// hellKnightMesh.scale(6);
			// hellKnightMesh.moveTo(0, -400, 20);
			// hellKnightMesh.geometry.applyTransformation(hellKnightMesh.transform);
			// hellKnightMesh.transform = new Matrix3D();
			// DebugMeshInfo.traceMeshBounds(hellKnightMesh);

			// init rest
			start();
		}

		private function start() : void {
			trace("starting...");

			// init elements
			initAway3d();
			initTerrainMesh();
			// initTerrainHeightMap();
			initElements();
			initPlayer();
			cameraMode = "orbit";
			initGui();

			// start loop
			addEventListener(Event.ENTER_FRAME, enterframeHandler);
		}

		// -----------------------
		// 3d core
		// -----------------------
		private function initAway3d() : void {
			// physics scene
			scene = new PhysicsScene3D();

			// view
			view = new View3D(scene);
			view.antiAlias = 4;
			view.camera.lens.far = 20000;
			addChild(view);

			// camera
			view.camera.position = new Vector3D(0, 2000, -2000);
			view.camera.lookAt(new Vector3D(0, 0, 0));

			// lights
			light = new PointLight();
			view.scene.addChild(light);

			// stats
			var stats : AwayStats = new AwayStats(view);
			stats.x = stage.stageWidth - stats.width;
			addChild(stats);
		}

		// -----------------------
		// terrain
		// -----------------------
		private function initTerrainMesh() : void {
			/*
			Terrain collision here uses triangle based collision, which is of course
			not very efficient. It is done so tho just for the sake of testing
			performance on triangle based collision.
			TODO: optional switching with height map collision?
			 */

			// perlin noise height map
			var heightMap : BitmapData = new BitmapData(1024, 1024, false, 0x000000);
			heightMap.perlinNoise(500, 500, 3, Math.floor(1000 * Math.random()) + 1, false, true, 7, true);
			for (var i : uint; i < 10; ++i) {
				drawRandomCircleOnBitmapData(heightMap);
			}

			// trace 2d height map
			var bmp : Bitmap = new Bitmap(heightMap);
			bmp.scaleX = bmp.scaleY = bmp.scaleZ = 0.25;
			bmp.x = stage.stageWidth - bmp.width;
			bmp.y = stage.stageHeight - bmp.height;
			addChild(bmp);

			// use height map to produce mesh
			var terrainMaterial : ColorMaterial = DebugMaterialLibrary.instance.whiteMaterial;
			terrainMaterial.lights = [light];
			terrainMesh = new Elevation(terrainMaterial, heightMap, 15000, 5000, 15000, 80, 80);
			scene.addChild(terrainMesh);

			// add body
			// var sceneSkin:Away3DMesh = new Away3DMesh(terrainMesh);
			var sceneShape : AWPBvhTriangleMeshShape = new AWPBvhTriangleMeshShape(terrainMesh);
			var sceneBody : AWPRigidBody = new AWPRigidBody(sceneShape, terrainMesh, 0);
			scene.addRigidBody(sceneBody);
		}

		private function initTerrainHeightMap() : void {
			// perlin noise height map
			var heightMap : BitmapData = new BitmapData(1024, 1024, false, 0x000000);
			heightMap.perlinNoise(250, 250, 2, Math.floor(1000 * Math.random()) + 1, false, true, 7, true);

			// terrain material
			var terrainMaterial : BitmapMaterial = new BitmapMaterial(heightMap);
			terrainMaterial.lights = [light];

			// terrain mesh
			var terrain : AWPTerrain = new AWPTerrain(terrainMaterial, heightMap, 15000, 2000, 15000, 50, 50, 1200, 0, false);
			scene.addChild(terrain);

			// create the terrain shape and rigidbody
			var terrainShape : AWPHeightfieldTerrainShape = new AWPHeightfieldTerrainShape(terrain);
			var terrainBody : AWPRigidBody = new AWPRigidBody(terrainShape, terrain, 0);
			scene.addRigidBody(terrainBody);
		}

		// -----------------------
		// elements
		// -----------------------
		private function initElements() : void {
			// box shape
			var boxShape : AWPBoxShape = new AWPBoxShape(200, 200, 200);

			// box material
			DebugMaterialLibrary.instance.lights = [light];
			var material : ColorMaterial = DebugMaterialLibrary.instance.redMaterial;
			material.lights = [light];

			// create box array
			var mesh : Mesh;
			var body : AWPRigidBody;
			var numX : int = 3;
			var numY : int = 8;
			var numZ : int = 1;
			for (var i : int = 0; i < numX; i++) {
				for (var j : int = 0; j < numZ; j++) {
					for (var k : int = 0; k < numY; k++) {
						// create boxes
						mesh = new Cube(material, 200, 200, 200);
						scene.addChild(mesh);
						body = new AWPRigidBody(boxShape, mesh, 0.1);
						body.friction = .9;
						body.linearDamping = 0.05;
						body.angularDamping = 0.05;
						body.position = new Vector3D(i * 200, 2000 + k * 200, j * 200);
						scene.addRigidBody(body);
					}
				}
			}
		}

		// -----------------------
		// player
		// -----------------------
		private function initPlayer() : void {
			// get mesh
			var innerMesh : Mesh = hellKnightMesh.clone() as Mesh;
			// transform is controlled by animator
			innerMesh.material = DebugMaterialLibrary.instance.blueMaterial;
			var middleMesh : Mesh = new Mesh();
			middleMesh.rotationY = -180;
			middleMesh.scale(6);
			middleMesh.moveTo(0, -400, 20);
			middleMesh.addChild(innerMesh);
			var playerMesh : Mesh = new Mesh();
			// transform is controlled by AWP
			playerMesh.addChild(middleMesh);
			scene.addChild(playerMesh);

			// setup player
			player = new KinematicEntity(playerMesh, 150, 500);
			scene.addPlayer(player);
			var terrainPos : Number = terrainMesh.getHeightAt(0, 0);
			player.position = new Vector3D(0, terrainPos + 1000, -1000);
			// TODO: review use of .x, .y, .z in AGT architecture

			// player motion controller input context
			playerInputContext = new KeyboardInputContext(stage);
			playerInputContext.map(Keyboard.UP, new InputEvent(InputEvent.MOVE_Z, 30));
			playerInputContext.map(Keyboard.RIGHT, new InputEvent(InputEvent.ROTATE_Y, 3));
			playerInputContext.map(Keyboard.LEFT, new InputEvent(InputEvent.ROTATE_Y, -3));
			playerInputContext.map(Keyboard.SPACE, new InputEvent(InputEvent.JUMP));
			playerInputContext.mapOnKeyUp(new InputEvent(InputEvent.STOP));
			playerInputContext.mapMultiplier(Keyboard.SHIFT, 4);

			// player motion controller
			playerMotionController = new GroundEntityController(player);
			playerMotionController.inputContext = playerInputContext;

			// player animation controller
			var cc : KeyboardInputContext = new KeyboardInputContext(stage);
			cc.map(Keyboard.UP, new InputEvent(InputEvent.WALK), false);
			cc.mapOnKeyUp(new InputEvent(InputEvent.STOP));
			// TODO: causes animation to stop when turning, need to improve keyboard context
			playerAnimationController = new SkeletonAnimationController(innerMesh);
			playerAnimationController.addAnimationSequence(idleAnimation);
			playerAnimationController.addAnimationSequence(walkAnimation);
			playerAnimationController.inputContext = cc;
		}

		// -----------------------
		// camera
		// -----------------------
		private function enableOrbitCameraController() : void {
			useCameraController = true;
			cameraController = new OrbitCameraController(view.camera, player.mesh);
			cameraInputContext = new WASDAndMouseInputContext(stage, view, 100, -3, 3);
			cameraController.inputContext = cameraInputContext;
		}

		private function enableFlyCameraController() : void {
			useCameraController = true;
			cameraController = new FreeFlyCameraController(view.camera);
			cameraInputContext = new WASDAndMouseInputContext(stage, view, 100, 0.25, 0.25);
			cameraController.inputContext = cameraInputContext;
		}

		private function enableFPSCameraController() : void {
			useCameraController = false;
		}

		// ---------------------------------------------------------------------
		// loop
		// ---------------------------------------------------------------------
		private function enterframeHandler(evt : Event) : void {
			// update camera position
			if (useCameraController)
				cameraController.update();
			else {
				view.camera.transform = player.mesh.transform.clone();
				view.camera.y += 100;
				// TODO: make an actual FPS camera controller
			}

			// light follows camera
			light.transform = view.camera.transform.clone();

			// update player position
			if (playerMotionController)
				playerMotionController.update();

			// update player animation
			if (playerAnimationController)
				playerAnimationController.update();

			// update scene physics
			scene.updatePhysics();

			// render 3d view
			view.render();

			// _tt.transform = new Matrix3D(); // TODO: hacks animator altering mesh transform!
			// trace(_tt.position);
		}

		// -----------------------
		// utils
		// -----------------------
		private function drawRandomCircleOnBitmapData(bmd : BitmapData) : void {
			var radius : Number = (bmd.width / 10) * Math.random();
			var x : Number = rand(radius, bmd.width - radius);
			var y : Number = rand(radius, bmd.height - radius);
			var spr : Sprite = new Sprite();
			var gray : Number = 127 + 127 * Math.random();
			spr.graphics.beginFill(gray << 16 | gray << 8 | gray);
			spr.graphics.drawCircle(x, y, radius);
			bmd.draw(spr);
		}

		private function rand(min : Number, max : Number) : Number {
			return (max - min) * Math.random() + min;
		}

		// ---------------------------------------------------------------------
		// gui
		// ---------------------------------------------------------------------
		private function initGui() : void {
			gui = new SimpleGUI(this);

			// camera
			gui.addGroup("camera");
			var cameraModes : Array = [{label:"orbit", data:"orbit"}, {label:"free fly", data:"fly"}, {label:"first person", data:"1st"}];
			gui.addComboBox("cameraMode", cameraModes, {width:100, label:"camera mode", numVisibleItems:cameraModes.length});
			gui.addSlider("cameraController.linearEase", 0.01, 1, {label:"linear ease"});
			gui.addSlider("cameraController.angularEase", 0.01, 1, {label:"angular ease"});
			gui.addGroup("View");
			var viewAntiAlias : Array = [{label:"none", data:0}, {label:"1x", data:1}, {label:"2x", data:2}, {label:"4x", data:4}, {label:"8x", data:8}];
			gui.addComboBox("viewAntiAlias", viewAntiAlias, {width:100, label:"anti alias", numVisibleItems:viewAntiAlias.length});
			// input
			gui.addColumn("Input");
			gui.addToggle("cameraInputContext.keyboardContext.enabled", {label:"keyboard input"});
			gui.addToggle("cameraInputContext.mouseContext.enabled", {label:"mouse input"});
			gui.addToggle("cameraInputContext.enabled", {label:"overall input"});
			// player
			gui.addGroup("player");
			gui.addToggle("playerInputContext.enabled", {label:"keyboard input"});
			gui.addColumn("Instructions");
			// instructions
			// gui.addGroup("instructions & info");
			gui.addLabel("- triangle based collision with dynamic objects and a character \n" + "- camera controllers and character are both controlled by \n" + "  input context objects \n" + "- in this case camera controls respond to mouse drag and WASDZX, \n" + "  player controls respond to keyboard arrows and SPACEBAR");

			gui.show();
		}

		private var _cameraMode : String;

		public function get cameraMode() : String {
			return _cameraMode;
		}

		public function set cameraMode(value : String) : void {
			_cameraMode = value;
			switch(value) {
				case "orbit":
					enableOrbitCameraController();
					break;
				case "fly":
					enableFlyCameraController();
					break;
				case "1st":
					enableFPSCameraController();
					break;
			}
		}

		public function get viewAntiAlias() : int {
			return view.antiAlias;
		}

		public function set viewAntiAlias(value : int) : void {
			view.antiAlias = value;
		}
	}
}
