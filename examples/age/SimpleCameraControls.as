package
{

import age.camera.controllers.CameraControllerBase;
import age.camera.controllers.OrbitCameraController;
import age.camera.controllers.FreeFlyCameraController;
import age.input.CompositeInputContext;
import age.input.KeyboardInputContext;
import age.input.data.MouseActions;
import age.input.MouseInputContext;
import age.input.events.InputEvent;

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
import flash.ui.Keyboard;
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
					if(dis > 2600)
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
			_sphere.x = 1500*Math.sin(0.001*getTimer());
			_sphere.y = 1500*Math.sin(0.001*getTimer());
			_sphere.z = 1500*Math.cos(0.001*getTimer());
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
	// camera controllers
	// ---------------------------------------------------------------------

	private function enableOrbitCameraController():void
	{
		cameraController = new OrbitCameraController(view.camera, _sphere);

		var keyboardContext:KeyboardInputContext = new KeyboardInputContext(stage);
		keyboardContext.map(Keyboard.Z, new InputEvent(InputEvent.MOVE_Z, -100));
		keyboardContext.map(Keyboard.X, new InputEvent(InputEvent.MOVE_Z, 100));
		keyboardContext.map(Keyboard.W, new InputEvent(InputEvent.ROTATE_X, -0.1));
		keyboardContext.map(Keyboard.S, new InputEvent(InputEvent.ROTATE_X, 0.1));
		keyboardContext.map(Keyboard.A, new InputEvent(InputEvent.ROTATE_Y, 0.1));
		keyboardContext.map(Keyboard.D, new InputEvent(InputEvent.ROTATE_Y, -0.1));
		keyboardContext.map(Keyboard.UP, new InputEvent(InputEvent.ROTATE_X, -0.1));
		keyboardContext.map(Keyboard.DOWN, new InputEvent(InputEvent.ROTATE_X, 0.1));
		keyboardContext.map(Keyboard.LEFT, new InputEvent(InputEvent.ROTATE_Y, 0.1));
		keyboardContext.map(Keyboard.RIGHT, new InputEvent(InputEvent.ROTATE_Y, -0.1));

		var mouseContext:MouseInputContext = new MouseInputContext(view);
		mouseContext.map(MouseActions.DRAG_X, new InputEvent(InputEvent.ROTATE_Y));
		mouseContext.map(MouseActions.DRAG_Y, new InputEvent(InputEvent.ROTATE_X));
		mouseContext.mouseInputFactorX = 0.005;
		mouseContext.mouseInputFactorY = -0.005;

		var compositeContext:CompositeInputContext = new CompositeInputContext();
		compositeContext.addContext(keyboardContext);
		compositeContext.addContext(mouseContext);

		cameraController.inputContext = compositeContext;
	}

	private function enableFlyCameraController():void
	{
		cameraController = new FreeFlyCameraController(view.camera);

		var keyboardContext:KeyboardInputContext = new KeyboardInputContext(stage);
		keyboardContext.map(Keyboard.W, new InputEvent(InputEvent.MOVE_Z, 100));
		keyboardContext.map(Keyboard.S, new InputEvent(InputEvent.MOVE_Z, -100));
		keyboardContext.map(Keyboard.A, new InputEvent(InputEvent.MOVE_X, -100));
		keyboardContext.map(Keyboard.D, new InputEvent(InputEvent.MOVE_X, 100));
		keyboardContext.map(Keyboard.UP, new InputEvent(InputEvent.MOVE_Z, 100));
		keyboardContext.map(Keyboard.DOWN, new InputEvent(InputEvent.MOVE_Z, -100));
		keyboardContext.map(Keyboard.LEFT, new InputEvent(InputEvent.MOVE_X, -100));
		keyboardContext.map(Keyboard.RIGHT, new InputEvent(InputEvent.MOVE_X, 100));
		keyboardContext.map(Keyboard.Z, new InputEvent(InputEvent.MOVE_Y, -100));
		keyboardContext.map(Keyboard.X, new InputEvent(InputEvent.MOVE_Y, 100));

		var mouseContext:MouseInputContext = new MouseInputContext(view);
		mouseContext.map(MouseActions.DRAG_X, new InputEvent(InputEvent.ROTATE_Y));
		mouseContext.map(MouseActions.DRAG_Y, new InputEvent(InputEvent.ROTATE_X));
		mouseContext.mouseInputFactorX = mouseContext.mouseInputFactorY = 0.25;

		var compositeContext:CompositeInputContext = new CompositeInputContext();
		compositeContext.addContext(keyboardContext);
		compositeContext.addContext(mouseContext);

		cameraController.inputContext = compositeContext;
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

		// info
		gui.addGroup("camera info");
		_positionLabel = gui.addLabel("position");
		_orientationLabel = gui.addLabel("orientation");

		// extra
		gui.addGroup("extra");
		gui.addToggle("moveSphere");

		// instructions
		gui.addGroup("instructions");
		gui.addLabel("- try different camera modes");
		gui.addLabel("- use keyboard arrows and keys WASDZX to move");
		gui.addLabel("- drag the mouse on stage to move");

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

	private var _moveSphere:Boolean;
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
