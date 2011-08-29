package
{

import agt.controllers.camera.CameraControllerBase;
import agt.controllers.camera.FreeFlyCameraController;
import agt.controllers.camera.OrbitCameraController;
import agt.controllers.entities.GroundEntityController;
import agt.devices.input.CompositeInputContext;
import agt.devices.input.KeyboardInputContext;
import agt.devices.input.WASDAndMouseInputContext;
import agt.devices.input.events.InputEvent;
import agt.entities.LiveEntity;
import agt.physics.PhysicsScene3D;

import away3d.containers.View3D;
import away3d.debug.AwayStats;
import away3d.entities.Mesh;
import away3d.extrusions.Elevation;
import away3d.lights.PointLight;
import away3d.materials.BitmapMaterial;
import away3d.materials.ColorMaterial;
import away3d.primitives.Cube;

import awayphysics.collision.shapes.AWPBoxShape;
import awayphysics.collision.shapes.AWPBvhTriangleMeshShape;

import awayphysics.dynamics.AWPRigidBody;
import awayphysics.plugin.away3d.Away3DMesh;

import flash.display.BitmapData;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.geom.Vector3D;
import flash.ui.Keyboard;

import uk.co.soulwire.gui.SimpleGUI;

public class SimplePlayerControls extends Sprite
{
	public var view:View3D;
	public var scene:PhysicsScene3D;
	public var light:PointLight;
	public var cameraController:CameraControllerBase;
	public var cameraInputContext:WASDAndMouseInputContext;
	public var terrainMesh:Mesh;
	public var gui:SimpleGUI;
	public var playerController:GroundEntityController;
	public var playerInputContext:KeyboardInputContext;
	public var player:LiveEntity;

	public function SimplePlayerControls()
	{
		// wait for stage
		addEventListener(Event.ADDED_TO_STAGE, stageInitHandler);
	}

	// ---------------------------------------------------------------------
	// init
	// ---------------------------------------------------------------------

	private function stageInitHandler(evt:Event):void
	{
		removeEventListener(Event.ADDED_TO_STAGE, stageInitHandler);

		// init stage
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;

		// init elements
		initAway3d();
		initTerrain();
		initElements();
		initPlayer();
		cameraMode = "orbit";
		initGui();

		// start loop
		addEventListener(Event.ENTER_FRAME, enterframeHandler);
	}

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

	private function initTerrain():void
	{
		// perlin noise height map
		var heightMap:BitmapData = new BitmapData(1024, 1024, false, 0x000000);
		heightMap.perlinNoise(250, 250, 2, Math.floor(1000*Math.random()) + 1, false, true, 7, true);

		// trace 2d height map
//		var bmp:Bitmap = new Bitmap(heightMap);
//		bmp.scaleX = bmp.scaleY = bmp.scaleZ = 0.25;
//		addChild(bmp);

		// use height map to produce mesh
		var terrainMaterial:BitmapMaterial = new BitmapMaterial(heightMap);
		terrainMaterial.lights = [light];
		terrainMesh = new Elevation(terrainMaterial, heightMap,
				15000, 2000, 15000,
				120, 120);
		scene.addChild(terrainMesh);

		// add body
		var sceneSkin:Away3DMesh = new Away3DMesh(terrainMesh);
		var sceneShape:AWPBvhTriangleMeshShape = new AWPBvhTriangleMeshShape(sceneSkin);
		var sceneBody:AWPRigidBody = new AWPRigidBody(sceneShape, sceneSkin, 0);
		scene.addRigidBody(sceneBody);
	}

	private function initElements():void
	{
		// box shape
		var boxShape:AWPBoxShape = new AWPBoxShape(200, 200, 200);

		// box material
		var material:ColorMaterial = new ColorMaterial(0xFF0000);
		material.lights = [light];

		// create box array
		var mesh:Mesh;
		var body:AWPRigidBody;
		var numX:int = 3;
		var numY:int = 3;
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
					body = new AWPRigidBody(boxShape, new Away3DMesh(mesh), 0.1);
					body.friction = .9;
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
		// player visible material
		var playerMaterial:ColorMaterial = new ColorMaterial(0x0000FF);
		playerMaterial.lights = [light];

		// player visible mesh
		var playerMesh:Cube = new Cube(playerMaterial, 300, 500, 300);
		scene.addChild(playerMesh);

		// player
		player = new LiveEntity(playerMesh, 150, 500);
		scene.addPlayer(player);
		player.position = new Vector3D(0, 2000, -1000);

		// player controller input context
		playerInputContext = new KeyboardInputContext(stage);
		playerInputContext.map(Keyboard.UP, new InputEvent(InputEvent.MOVE_Z, 25));
		playerInputContext.map(Keyboard.RIGHT, new InputEvent(InputEvent.ROTATE_Y, 3));
		playerInputContext.map(Keyboard.LEFT, new InputEvent(InputEvent.ROTATE_Y, -3));
		playerInputContext.map(Keyboard.SPACE, new InputEvent(InputEvent.JUMP));
		playerInputContext.mapOnKeyUp(new InputEvent(InputEvent.STOP));

		// player controller
		playerController = new GroundEntityController(player);
		playerController.inputContext = playerInputContext;
	}

	// -----------------------
	// camera
	// -----------------------

	private function enableOrbitCameraController():void
	{
		cameraController = new OrbitCameraController(view.camera, player.mesh);
		cameraInputContext = new WASDAndMouseInputContext(stage, view, 100, -3, 3);
		cameraController.inputContext = cameraInputContext;
	}

	private function enableFlyCameraController():void
	{
		cameraController = new FreeFlyCameraController(view.camera);
		cameraInputContext = new WASDAndMouseInputContext(stage, view, 100, 0.25, 0.25);
		cameraController.inputContext = cameraInputContext;
	}

	// ---------------------------------------------------------------------
	// loop
	// ---------------------------------------------------------------------

	private function enterframeHandler(evt:Event):void
	{
		// update camera position
		cameraController.update();

		// light follows camera
		light.transform = view.camera.transform.clone();

		// update player position
		playerController.update();

		// update scene physics
		scene.updatePhysics();

		// render 3d view
		view.render();
	}

	// ---------------------------------------------------------------------
	// gui
	// ---------------------------------------------------------------------

	private function initGui():void
	{
		gui = new SimpleGUI(this);

		// camera
		gui.addGroup("camera");
		var cameraModes:Array = [
            {label:"orbit",		   data:"orbit"},
            {label:"free fly",	   data:"fly"}
        ];
        gui.addComboBox("cameraMode", cameraModes, {width:100, label:"camera mode", numVisibleItems:cameraModes.length});
		gui.addSlider("cameraController.linearEase", 0.01, 1, {label:"linear ease"});
		gui.addSlider("cameraController.angularEase", 0.01, 1, {label:"angular ease"});
		gui.addToggle("cameraInputContext.keyboardContext.enabled", {label:"keyboard input"});
		gui.addToggle("cameraInputContext.mouseContext.enabled", {label:"mouse input"});
		gui.addToggle("cameraInputContext.enabled", {label:"overall input"});

		// player
		gui.addGroup("player");
		gui.addToggle("playerInputContext.enabled", {label:"keyboard input"});

		// instructions
		gui.addGroup("instructions & info");
		gui.addLabel("- triangle based collision with dynamic objects and a character \n" +
					 "- camera controllers and character are both controlled by \n" +
					 "  input context objects \n" +
					 "- in this case camera controls respond to mouse drag and WASDZX, \n" +
					 "  player controls respond to keyboard arrows and SPACEBAR");

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
		}
	}
}
}
