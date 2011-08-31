package
{

import agt.controllers.camera.CameraControllerBase;
import agt.controllers.camera.FirstPersonCameraController;
import agt.controllers.camera.FreeFlyCameraController;
import agt.controllers.camera.OrbitCameraController;
import agt.controllers.entities.AnimatedKinematicEntityController;
import agt.controllers.entities.KinematicEntityController;
import agt.data.MouseActions;
import agt.debug.DebugMaterialLibrary;
import agt.debug.AGTSimpleGUI;
import agt.input.CompositeInputContext;
import agt.input.KeyboardInputContext;
import agt.input.MouseInputContext;
import agt.input.WASDAndMouseInputContext;
import agt.input.events.InputEvent;
import agt.entities.KinematicEntity;
import agt.core.PhysicsScene3D;

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

public class SimplePlayerControls extends Sprite
{
	[Embed(source="../assets/hellknight/hellknight.md5mesh", mimeType="application/octet-stream")]
	private var HellKnightMesh:Class;
	[Embed(source="../assets/hellknight/idle2.md5anim", mimeType="application/octet-stream")]
	private var HellKnightIdleAnimation:Class;
	[Embed(source="../assets/hellknight/walk7.md5anim", mimeType="application/octet-stream")]
	private var HellKnightWalkAnimation:Class;
	[Embed(source="../assets/hellknight/hellknight.jpg")]
	private var HellKnightTexture:Class;
	[Embed(source="../assets/hellknight/hellknight_s.png")]
	private var HellKnightSpecularMap:Class;
	[Embed(source="../assets/hellknight/hellknight_local.png")]
	private var HellKnightNormalMap:Class;

	public var view:View3D;
	public var scene:PhysicsScene3D;
	public var light:PointLight;
	public var terrainMesh:Elevation;
	public var gui:AGTSimpleGUI;
	public var player:KinematicEntity;
	public var hellKnightMesh:Mesh;
	public var idleAnimation:SkeletonAnimationSequence;
	public var walkAnimation:SkeletonAnimationSequence;

	// input contexts
	public var playerMotionInputContext:KeyboardInputContext;
	public var cameraInputContext:CompositeInputContext;

	// controllers
	public var cameraController:CameraControllerBase;
	public var playerMotionController:AnimatedKinematicEntityController;

	public function SimplePlayerControls()
	{
		// wait for stage
		addEventListener(Event.ADDED_TO_STAGE, stageInitHandler);
	}

	// ---------------------------------------------------------------------
	// init process
	// ---------------------------------------------------------------------
	private function stageInitHandler(evt:Event):void
	{
		removeEventListener(Event.ADDED_TO_STAGE, stageInitHandler);

		// init stage
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;

		// retrieve hell knight mesh
		var loader:Loader3D = new Loader3D();
		loader.parseData(new HellKnightMesh(), new MD5MeshParser());
		loader.addEventListener(AssetEvent.ASSET_COMPLETE, init1);
		trace("loading hellknight mesh...");
	}

	private function init1(evt:AssetEvent):void
	{
		// retrieve hell knight mesh}
		if(evt.asset.assetType != AssetType.MESH)
			return;
		trace("hellknight mesh loaded");
		hellKnightMesh = evt.asset as Mesh;

		// retrieve hell knight idle animation sequence
		trace("loading idle animation...");
		var loader:Loader3D = new Loader3D();
		loader.addEventListener(AssetEvent.ASSET_COMPLETE, init2);
		loader.parseData(new HellKnightIdleAnimation(), new MD5AnimParser());
	}

	private function init2(evt:AssetEvent):void
	{
		// retrieve hell knight idle animation sequence
		trace("idle animation loaded");
		idleAnimation = evt.asset as SkeletonAnimationSequence;
		idleAnimation.name = "idle";

		// retrieve hell knight idle animation sequence
		trace("loading walk animation...");
		var loader:Loader3D = new Loader3D();
		loader.addEventListener(AssetEvent.ASSET_COMPLETE, init3);
		loader.parseData(new HellKnightWalkAnimation(), new MD5AnimParser());
	}

	private function init3(evt:AssetEvent):void
	{
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

	private function start():void
	{
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
	private function initAway3d():void
	{
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
		var stats:AwayStats = new AwayStats(view);
		stats.x = stage.stageWidth - stats.width;
		addChild(stats);
	}

	// -----------------------
	// terrain
	// -----------------------
	private function initTerrainMesh():void
	{
		/*
		 Terrain collision here uses triangle based collision, which is of course
		 not very efficient. It is done so tho just for the sake of testing
		 performance on triangle based collision.
		 TODO: optional switching with height map collision?
		 */

		// perlin noise height map
		var heightMap:BitmapData = new BitmapData(1024, 1024, false, 0x000000);
		heightMap.perlinNoise(500, 500, 3, Math.floor(1000*Math.random()) + 1, false, true, 7, true);
		for(var i:uint; i < 10; ++i)
		{
			drawRandomCircleOnBitmapData(heightMap);
		}

		// trace 2d height map
		var bmp:Bitmap = new Bitmap(heightMap);
		bmp.scaleX = bmp.scaleY = bmp.scaleZ = 0.25;
		bmp.x = stage.stageWidth - bmp.width;
		bmp.y = stage.stageHeight - bmp.height;
		addChild(bmp);

		// use height map to produce mesh
		var terrainMaterial:ColorMaterial = DebugMaterialLibrary.instance.whiteMaterial;
		terrainMaterial.lights = [light];
		terrainMesh = new Elevation(terrainMaterial, heightMap, 15000, 1000, 15000, 80, 80);
		scene.addChild(terrainMesh);

		// add body
		// var sceneSkin:Away3DMesh = new Away3DMesh(terrainMesh);
		var sceneShape:AWPBvhTriangleMeshShape = new AWPBvhTriangleMeshShape(terrainMesh);
		var sceneBody:AWPRigidBody = new AWPRigidBody(sceneShape, terrainMesh, 0);
		scene.addRigidBody(sceneBody);
	}

	private function initTerrainHeightMap():void
	{
		// perlin noise height map
		var heightMap:BitmapData = new BitmapData(1024, 1024, false, 0x000000);
		heightMap.perlinNoise(250, 250, 2, Math.floor(1000*Math.random()) + 1, false, true, 7, true);

		// terrain material
		var terrainMaterial:BitmapMaterial = new BitmapMaterial(heightMap);
		terrainMaterial.lights = [light];

		// terrain mesh
		var terrain:AWPTerrain = new AWPTerrain(terrainMaterial, heightMap, 15000, 2000, 15000, 50, 50, 1200, 0, false);
		scene.addChild(terrain);

		// create the terrain shape and rigidbody
		var terrainShape:AWPHeightfieldTerrainShape = new AWPHeightfieldTerrainShape(terrain);
		var terrainBody:AWPRigidBody = new AWPRigidBody(terrainShape, terrain, 0);
		scene.addRigidBody(terrainBody);
	}

	// -----------------------
	// elements
	// -----------------------
	private function initElements():void
	{
		// box shape
		var boxShape:AWPBoxShape = new AWPBoxShape(200, 200, 200);

		// box material
		DebugMaterialLibrary.instance.lights = [light];
		var material:ColorMaterial = DebugMaterialLibrary.instance.redMaterial;
		material.lights = [light];

		// create box array
		var mesh:Mesh;
		var body:AWPRigidBody;
		var numX:int = 3;
		var numY:int = 8;
		var numZ:int = 1;
		for(var i:int = 0; i < numX; i++)
		{
			for(var j:int = 0; j < numZ; j++)
			{
				for(var k:int = 0; k < numY; k++)
				{
					// create boxes
					mesh = new Cube(material, 200, 200, 200);
					scene.addChild(mesh);
					body = new AWPRigidBody(boxShape, mesh, 0.1);
					body.friction = .9;
					body.linearDamping = 0.05;
					body.angularDamping = 0.05;
					body.position = new Vector3D(i*200, 2000 + k*200, j*200);
					scene.addRigidBody(body);
				}
			}
		}
	}

	// -----------------------
	// player
	// -----------------------
	private function initPlayer():void
	{
		// prepare material
		var hellknightMaterial:BitmapMaterial = new BitmapMaterial(new HellKnightTexture().bitmapData);
		hellknightMaterial.lights = [light];
		hellknightMaterial.normalMap = new HellKnightNormalMap().bitmapData;
		hellknightMaterial.specularMap = new HellKnightSpecularMap().bitmapData;

		// get mesh
		var innerMesh:Mesh = hellKnightMesh.clone() as Mesh;
		// transform is controlled by animator
		innerMesh.material = hellknightMaterial;
		var middleMesh:Mesh = new Mesh();
		middleMesh.rotationY = -180;
		middleMesh.scale(6);
		middleMesh.moveTo(0, -400, 20);
		middleMesh.addChild(innerMesh);
		var playerMesh:Mesh = new Mesh();
		// transform is controlled by AWP
		playerMesh.addChild(middleMesh); // TODO: Can simplify hierarchy here?
		scene.addChild(playerMesh);

		// setup player
		player = new KinematicEntity(playerMesh, 150, 500);
		player.kinematics.jumpSpeed = 2000; // TODO: can avoid/mask .kinematics access?
		scene.addPlayer(player);
		var terrainPos:Number = terrainMesh.getHeightAt(0, 0);
		player.position = new Vector3D(0, terrainPos + 1000, -1000);
		// TODO: review use of .x, .y, .z in AGT architecture

		// player controller input context
		playerMotionInputContext = new KeyboardInputContext(stage);
		playerMotionInputContext.map(Keyboard.W, new InputEvent(InputEvent.MOVE_Z, 30));
		playerMotionInputContext.map(Keyboard.S, new InputEvent(InputEvent.MOVE_Z, -30));
		playerMotionInputContext.map(Keyboard.D, new InputEvent(InputEvent.ROTATE_Y, 3));
		playerMotionInputContext.map(Keyboard.A, new InputEvent(InputEvent.ROTATE_Y, -3));
		playerMotionInputContext.map(Keyboard.SPACE, new InputEvent(InputEvent.JUMP));
		playerMotionInputContext.mapOnAllKeysUp(new InputEvent(InputEvent.STOP));
//		playerMotionInputContext.mapMultiplier(Keyboard.SHIFT, 2);

		// player controller
		playerMotionController = new AnimatedKinematicEntityController(player, innerMesh);
		playerMotionController.addAnimationSequence(walkAnimation); // TODO: Map animations to actions too?
		playerMotionController.addAnimationSequence(idleAnimation);
		playerMotionController.inputContext = playerMotionInputContext;
		playerMotionController.stop();
		playerMotionController.speedEase = 0.1;
		playerMotionController.animatorTimeScaleFactor = 0.08;
	}

	// -----------------------
	// camera
	// -----------------------
	private function enableOrbitCameraController():void
	{
		cameraInputContext = new CompositeInputContext();
		var keyboardContext:KeyboardInputContext = new KeyboardInputContext(stage);
		keyboardContext.map(Keyboard.UP, new InputEvent(InputEvent.ROTATE_X, 25));
		keyboardContext.map(Keyboard.DOWN, new InputEvent(InputEvent.ROTATE_X, -25));
		keyboardContext.map(Keyboard.RIGHT, new InputEvent(InputEvent.ROTATE_Y, 25));
		keyboardContext.map(Keyboard.LEFT, new InputEvent(InputEvent.ROTATE_Y, -25));
		cameraInputContext.addContext(keyboardContext);
		var mouseContext:MouseInputContext = new MouseInputContext(view);
		mouseContext.map(MouseActions.DRAG_X, new InputEvent(InputEvent.ROTATE_Y));
		mouseContext.map(MouseActions.DRAG_Y, new InputEvent(InputEvent.ROTATE_X));
		mouseContext.map(MouseActions.WHEEL, new InputEvent(InputEvent.MOVE_Z));
		mouseContext.mouseInputFactorX = -3;
		mouseContext.mouseInputFactorY = 3;
		mouseContext.mouseInputFactorWheel = 25;
		cameraInputContext.addContext(mouseContext);

		cameraController = new OrbitCameraController(view.camera, player.mesh);
		OrbitCameraController(cameraController).minRadius = 500;
		cameraController.inputContext = cameraInputContext;
	}

	private function enableFlyCameraController():void
	{
		cameraInputContext = new CompositeInputContext();
		var keyboardContext:KeyboardInputContext = new KeyboardInputContext(stage);
		keyboardContext.map(Keyboard.UP, new InputEvent(InputEvent.MOVE_Z, 100));
		keyboardContext.map(Keyboard.DOWN, new InputEvent(InputEvent.MOVE_Z, -100));
		keyboardContext.map(Keyboard.RIGHT, new InputEvent(InputEvent.MOVE_X, 100));
		keyboardContext.map(Keyboard.LEFT, new InputEvent(InputEvent.MOVE_X, -100));
		keyboardContext.mapMultiplier(Keyboard.SHIFT, 4);
		cameraInputContext.addContext(keyboardContext);
		var mouseContext:MouseInputContext = new MouseInputContext(view);
		mouseContext.map(MouseActions.DRAG_X, new InputEvent(InputEvent.ROTATE_Y));
		mouseContext.map(MouseActions.DRAG_Y, new InputEvent(InputEvent.ROTATE_X));
		mouseContext.mouseInputFactorX = 0.25;
		mouseContext.mouseInputFactorY = 0.25;
		cameraInputContext.addContext(mouseContext);

		cameraController = new FreeFlyCameraController(view.camera);
		cameraController.inputContext = cameraInputContext;
	}

	private function enableFPSCameraController():void
	{
		cameraInputContext = new CompositeInputContext();
		var mouseContext:MouseInputContext = new MouseInputContext(view);
		mouseContext.map(MouseActions.DRAG_X, new InputEvent(InputEvent.ROTATE_Y));
		mouseContext.map(MouseActions.DRAG_Y, new InputEvent(InputEvent.ROTATE_X));
		mouseContext.mouseInputFactorX = 0.25;
		mouseContext.mouseInputFactorY = 0.25;
		cameraInputContext.addContext(mouseContext);

		cameraController = new FirstPersonCameraController(view.camera, player.mesh);
		FirstPersonCameraController(cameraController).cameraOffsetY = 500;
		cameraController.inputContext = cameraInputContext;
	}

	// ---------------------------------------------------------------------
	// loop
	// ---------------------------------------------------------------------
	private function enterframeHandler(evt:Event):void
	{

		// update scene physics
		scene.updatePhysics();

		// update camera position
		cameraController.update();

		// light follows camera
		light.transform = view.camera.transform.clone();

		// update player
		if(playerMotionController)
			playerMotionController.update();

		// render 3d view
		view.render();

		// _tt.transform = new Matrix3D(); // TODO: hacks animator altering mesh transform!
		// trace(_tt.position);
	}

	// -----------------------
	// utils
	// -----------------------
	private function drawRandomCircleOnBitmapData(bmd:BitmapData):void
	{
		var radius:Number = (bmd.width/10)*Math.random();
		var x:Number = rand(radius, bmd.width - radius);
		var y:Number = rand(radius, bmd.height - radius);
		var spr:Sprite = new Sprite();
		var gray:Number = 127 + 127*Math.random();
		spr.graphics.beginFill(gray << 16 | gray << 8 | gray);
		spr.graphics.drawCircle(x, y, radius);
		bmd.draw(spr);
	}

	private function rand(min:Number, max:Number):Number
	{
		return (max - min)*Math.random() + min;
	}

	// ---------------------------------------------------------------------
	// gui
	// ---------------------------------------------------------------------
	private function initGui():void
	{
		gui = new AGTSimpleGUI(this);

		// camera
		gui.addGroup("camera");
		var cameraModes:Array = [
			{label:"orbit", data:"orbit"},
			{label:"free fly", data:"fly"},
			{label:"first person", data:"1st"} // TODO: Add FPS camera, 3rd person camera and ObserverCamera controllers
		];
		gui.addComboBox("cameraMode", cameraModes, {width:100, label:"camera mode", numVisibleItems:cameraModes.length});
		gui.addSlider("cameraController.linearEase", 0.01, 1, {label:"linear ease"});
		gui.addSlider("cameraController.angularEase", 0.01, 1, {label:"angular ease"});
		gui.addGroup("View");
		var viewAntiAlias:Array = [
			{label:"none", data:0},
			{label:"1x", data:1},
			{label:"2x", data:2},
			{label:"4x", data:4},
			{label:"8x", data:8}
		];
		gui.addComboBox("viewAntiAlias", viewAntiAlias, {width:100, label:"anti alias", numVisibleItems:viewAntiAlias.length});
		// input
		gui.addColumn("Input");
//		gui.addToggle("cameraInputContext.keyboardContext.enabled", {label:"keyboard input"});
//		gui.addToggle("cameraInputContext.mouseContext.enabled", {label:"mouse input"});
		gui.addToggle("cameraInputContext.enabled", {label:"overall input"});
		// player
		gui.addGroup("player");
		gui.addToggle("playerMotionInputContext.enabled", {label:"keyboard input"});
		gui.addColumn("Instructions");
		// instructions
		// gui.addGroup("instructions & info");
		gui.addLabel("- triangle based collision with dynamic objects and a character \n" + "- camera controllers and character are both controlled by \n" + "  input context objects \n" + "- in this case camera controls respond to mouse drag and WASDZX, \n" + "  player controls respond to keyboard arrows and SPACEBAR");

		gui.show();
	}

	private var _cameraMode:String;

	public function get cameraMode():String
	{
		return _cameraMode;
	}

	public function set cameraMode(value:String):void
	{
		_cameraMode = value;
		switch(value)
		{
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

	public function get viewAntiAlias():int
	{
		return view.antiAlias;
	}

	public function set viewAntiAlias(value:int):void
	{
		view.antiAlias = value;
	}
}
}
