package
{

import agt.controllers.camera.CameraControllerBase;
import agt.controllers.camera.OrbitCameraController;
import agt.controllers.camera.FreeFlyCameraController;
import agt.devices.input.WASDAndMouseInputContext;

import away3d.containers.View3D;
import away3d.debug.AwayStats;
import away3d.entities.Mesh;
import away3d.lights.PointLight;
import away3d.materials.ColorMaterial;
import away3d.primitives.Cube;
import away3d.primitives.Sphere;

import com.bit101.components.Label;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.geom.Vector3D;
import flash.utils.getTimer;

import uk.co.soulwire.gui.SimpleGUI;

/*
	TODO:
 	- extend contexts instead of configuring them?
 	- give input contexts continuous = true/false option
 */
public class SimpleCameraControls extends Sprite
{
	public var view:View3D;
	public var light:PointLight;
	public var gui:SimpleGUI;
	public var cameraController:CameraControllerBase;
	public var wasdInputContext:WASDAndMouseInputContext;

	private var _sphere:Sphere;

	private var _positionLabel:Label;
	private var _orientationLabel:Label;

	public function SimpleCameraControls()
	{
		// wait for stage
		addEventListener(Event.ADDED_TO_STAGE, stageInitHandler);
	}

	private function stageInitHandler(evt:Event):void
	{
	    removeEventListener(Event.ADDED_TO_STAGE, stageInitHandler);

	    // init stage
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;

		// init elements
		initAway3d();
		initGui();

		// start loop
		addEventListener(Event.ENTER_FRAME, enterframeHandler);
	}

	private function initAway3d():void
	{
		// view
		view = new View3D();
		view.antiAlias = 4;
		view.camera.lens.far = 20000;
		addChild(view);

		// camera
		view.camera.position = new Vector3D(0, 3500, -3500);
		view.camera.lookAt(new Vector3D(0, 0, 0));

		// lights
		light = new PointLight();
		light.position = new Vector3D(1000, 1000, -1000);
		light.lookAt(new Vector3D(0, 0, 0));
		view.scene.addChild(light);

		// cube grid
		var i:uint,  j:uint, k:uint;
		var units:uint = 9;
		var dims:Number = 5000;
		var offset:Number = -dims/2 + 0.5*dims/units;
		var delta:Number = dims/units;
		var cubeMaterial:ColorMaterial = new ColorMaterial(0x222222);
		cubeMaterial.lights = [light];
		var referenceCube:Cube = new Cube(cubeMaterial);
		referenceCube.width = referenceCube.height = referenceCube.depth = 350;
		for(i = 0; i<units; i++)
		{
			for(j = 0; j<units; j++)
			{
				for(k = 0; k<units; k++)
				{
					var x:Number = offset + delta*i;
					var y:Number = offset + delta*j;
					var z:Number = offset + delta*k;

					var dis:Number = Math.sqrt( x*x + y*y + z*z);
					if(dis > 2400)
					{
						var cube:Mesh = Mesh(referenceCube.clone());
						cube.x = x;
						cube.y = y;
						cube.z = z;
						view.scene.addChild(cube);
					}
				}
			}
		}

		// main sphere
		var sphereMaterial:ColorMaterial = new ColorMaterial(0xFF0000);
		sphereMaterial.lights = [light];
		_sphere = new Sphere(sphereMaterial, 500, 32, 24);
		view.scene.addChild(_sphere);

		// stats
        var stats:AwayStats = new AwayStats(view);
        stats.x = stage.stageWidth - stats.width;
        addChild(stats);

		// start camera control
		cameraMode = "fly";
	}

	private function enterframeHandler(evt:Event):void
	{
		// sphere position
		if(_moveSphere)
		{
			_sphere.x = 1000*Math.sin(0.001*getTimer());
			_sphere.y = 1000*Math.sin(0.002*getTimer());
			_sphere.z = 1000*Math.cos(0.003*getTimer());
		}
		else
		 	_sphere.position = new Vector3D();

		// light follows camera
		light.transform = view.camera.transform.clone();

		// update camera transform
		cameraController.update();

		// render 3d
		view.render();

		// update gui stuff
		_positionLabel.text = "position: " + roundValue(view.camera.x) + ", "
										   + roundValue(view.camera.y) + ", "
										   + roundValue(view.camera.z);
		_orientationLabel.text = "orientation: " + roundValue(view.camera.rotationX) + ", "
										   		 + roundValue(view.camera.rotationY) + ", "
										   		 + roundValue(view.camera.rotationZ);
	}

	private function roundValue(value:Number, tick:Number = 1):Number
	{
		return Math.round(value / tick) * tick;
	}

	// ---------------------------------------------------------------------
	// camera controller setup
	// ---------------------------------------------------------------------

	private function enableOrbitCameraController():void
	{
		cameraController = new OrbitCameraController(view.camera, _sphere);
		wasdInputContext = new WASDAndMouseInputContext(stage, view, 100, -3, 3);
		cameraController.inputContext = wasdInputContext;
	}

	private function enableFlyCameraController():void
	{
		cameraController = new FreeFlyCameraController(view.camera);
		wasdInputContext = new WASDAndMouseInputContext(stage, view, 100, 0.25, 0.25);
		cameraController.inputContext = wasdInputContext;
	}

	// ---------------------------------------------------------------------
	// SimpleGUI
	// ---------------------------------------------------------------------

	private function initGui():void
	{
		gui = new SimpleGUI(this);

		// controls
		gui.addGroup("camera controls");
		var cameraModes:Array = [
            {label:"orbit",		   data:"orbit"},
            {label:"free fly",	   data:"fly"}
        ];
        gui.addComboBox("cameraMode", cameraModes, {width:100, label:"camera mode", numVisibleItems:cameraModes.length});
		gui.addSlider("cameraController.linearEase", 0.01, 1, {label:"linear ease"});
		gui.addSlider("cameraController.angularEase", 0.01, 1, {label:"angular ease"});
		gui.addToggle("wasdInputContext.keyboardContext.enabled", {label:"keyboard input"});
		gui.addToggle("wasdInputContext.mouseContext.enabled", {label:"mouse input"});
		gui.addToggle("wasdInputContext.enabled", {label:"input"});

		// info
		gui.addGroup("camera info");
		_positionLabel = gui.addLabel("position");
		_orientationLabel = gui.addLabel("orientation");

		// extra
		gui.addGroup("extra");
		gui.addToggle("moveSphere");

		// instructions
		gui.addGroup("instructions");
		gui.addLabel("- try different camera modes \n" +
					 "- use keyboard arrows and keys WASDZX to move \n" +
					 "- holding SHIFT increases speed \n" +
					 "- drag the mouse on stage to move");

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

	private var _moveSphere:Boolean = false;
	public function get moveSphere():Boolean
	{
		return _moveSphere;
	}
	public function set moveSphere(value:Boolean):void
	{
		_moveSphere = value;
	}
}
}
