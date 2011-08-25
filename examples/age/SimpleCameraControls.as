package
{

import age.camera.controllers.CameraControllerBase;
import age.camera.controllers.DebugCameraController;

import away3d.containers.View3D;
import away3d.debug.AwayStats;
import away3d.lights.PointLight;
import away3d.materials.ColorMaterial;
import away3d.primitives.Cube;

import com.bit101.components.Label;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Vector3D;

import uk.co.soulwire.gui.SimpleGUI;

public class SimpleCameraControls extends Sprite
{
	public var view:View3D;
	public var light:PointLight;
	public var gui:SimpleGUI;
	public var cameraController:CameraControllerBase;

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

		// view listeners
		view.addEventListener(MouseEvent.MOUSE_DOWN, viewMouseDownHandler);
		view.addEventListener(MouseEvent.MOUSE_UP, viewMouseUpHandler);
		view.addEventListener(MouseEvent.MOUSE_MOVE, viewMouseMoveHandler);

		// stage listeners
		stage.addEventListener(KeyboardEvent.KEY_DOWN, viewKeyDownHandler);
		stage.addEventListener(KeyboardEvent.KEY_UP, viewKeyUpHandler);

		// camera
		view.camera.position = new Vector3D(0, 2500, -2500);
		view.camera.lookAt(new Vector3D(0, 0, 0));

		// camera control
		cameraController = new DebugCameraController();
		cameraController.camera = view.camera;

		// lights
		light = new PointLight();
		light.position = new Vector3D(1000, 1000, -1000);
		light.lookAt(new Vector3D(0, 0, 0));
		view.scene.addChild(light);

		// cube grid
		var i:uint,  j:uint, k:uint;
		var units:uint = 6;
		var dims:Number = 5000;
		var delta:Number = dims/units;
		var mat:ColorMaterial = new ColorMaterial(0xFF0000);
		mat.lights = [light];
		for(i = 0; i<units; i++)
		{
			for(j = 0; j<units; j++)
			{
				for(k = 0; k<units; k++)
				{
					var cube:Cube = new Cube(mat);
					cube.width = cube.height = cube.depth = 100;
					cube.x = -dims/2 + delta*i;
					cube.y = -dims/2 + delta*j;
					cube.z = -dims/2 + delta*k;
					view.scene.addChild(cube);
				}
			}
		}

		// stats
        var stats:AwayStats = new AwayStats(view);
        stats.x = stage.stageWidth - stats.width;
        addChild(stats);
	}

	private function enterframeHandler(evt:Event):void
	{
		// update camera transform
		cameraController.update();

		// light follows camera
		light.transform = view.camera.transform.clone();

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
	// listeners
	// ---------------------------------------------------------------------

	private function viewMouseDownHandler(evt:MouseEvent):void
	{
		cameraController.mouseDown();
	}

	private function viewMouseUpHandler(evt:MouseEvent):void
	{
		cameraController.mouseUp();
	}

	private function viewMouseMoveHandler(evt:MouseEvent):void
	{
		cameraController.mouseMove(view.mouseX, view.mouseY);
	}

	private function viewKeyDownHandler(evt:KeyboardEvent):void
	{
		cameraController.keyDown(evt.keyCode);
	}

	private function viewKeyUpHandler(evt:KeyboardEvent):void
	{
		cameraController.keyUp(evt.keyCode);
	}

	// ---------------------------------------------------------------------
	// SimpleGUI
	// ---------------------------------------------------------------------

	private function initGui():void
	{
		gui = new SimpleGUI(this);

		// controls
		gui.addGroup("camera controls");
		gui.addToggle("cameraController.alwaysLookAtTarget", {label:"look at target"});
		gui.addSlider("cameraController.linearKeyboardSpeed", 1, 200, {label:"linear speed"});
		gui.addSlider("cameraController.angularMouseFactor", 0.01, 1, {label:"angular mouse factor"});
		gui.addSlider("cameraController.linearEase", 0.01, 1, {label:"linear ease"});
		gui.addSlider("cameraController.angularEase", 0.01, 1, {label:"angular ease"});

		// info
		gui.addGroup("camera info");
		_positionLabel = gui.addLabel("position");
		_orientationLabel = gui.addLabel("orientation");

		// instructions
		gui.addGroup("instructions");
		gui.addLabel("- use arrows or wasd to move (z/x to move up or down)");
		gui.addLabel("- drag mouse to rotate camera");

		gui.show();
	}
}
}
