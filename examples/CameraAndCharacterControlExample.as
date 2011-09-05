/*

Basic character and camera control using AwayGameTools.

Demonstrates:

How to set up input controllers
How to set up an animated character
How to manage basic physics
How to use a triangle based collision mesh

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

	import CameraAndCharacterControl.*;

	import agt.debug.AGTSimpleGUI;

	import agt.debug.DebugMaterialLibrary;
	import agt.physics.PhysicsScene3D;

	import away3d.animators.data.SkeletonAnimationSequence;
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

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;

	import flash.events.Event;
	import flash.geom.Vector3D;

	public class CameraAndCharacterControlExample extends Sprite
	{
		public var signature:Signature;
		public var _light:PointLight;
		public var _enemies:Vector.<Enemy>;
		public var gui:AGTSimpleGUI;
		public var view:View3D;
		public var scene:PhysicsScene3D;
		public var stats:AwayStats;
		public var level:Level;
		public var player:Player;
		public var camera:Camera;
		public var resources:Resources;

		public function CameraAndCharacterControlExample()
		{
			// wait for stage before pre-init...
			addEventListener(Event.ADDED_TO_STAGE, stageInitHandler);
		}

		private function stageInitHandler(evt:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, stageInitHandler);
			init();
		}

		private function stageResizeHandler(evt:Event):void
		{
			// place signature at bottom left
			signature.x = 5;
			signature.y = stage.stageHeight - 22 - 5;

			// place stats at top right
			stats.x = stage.stageWidth - stats.width;
		}

		// ---------------------------------------------------------------------
		// init
		// ---------------------------------------------------------------------

		private function init():void
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

			// init simple gui
			gui = new AGTSimpleGUI(this, "", "C");
			gui.addGroup("View");
			gui.addStepper("view.antiAlias", 0, 8, {label:"AntiAlias"});
			gui.addSlider("view.camera.lens.near", 0, 1000, {label:"lens near"});
			gui.addSlider("view.camera.lens.far", 0, 100000, {label:"lens far"});
			gui.show();

			// listen for stage resize
			stage.addEventListener(Event.RESIZE, stageResizeHandler);
			stageResizeHandler(null);

			// trigger init
			startExample();
		}

		private function startExample():void
		{
			// set example signature
			signature.text = "AwayGameTools 2011 - Camera and character control example.";

			// init away3d general settings
			view.antiAlias = 4;
			view.camera.lens.near = 150;
			view.camera.lens.far = 50000;
			view.camera.position = new Vector3D(2000, 2000, -2000);
			view.camera.lookAt(new Vector3D(0, 0, 0));
			_light = new PointLight();
			view.scene.addChild(_light);
			DebugMaterialLibrary.instance.lights = [_light];

			// start load process...
			resources = new Resources();
			resources.addEventListener(Event.COMPLETE, resourcesLoadedHandler);
			resources.load();
		}

		private function resourcesLoadedHandler(evt:Event):void
		{
			resources.removeEventListener(Event.COMPLETE, resourcesLoadedHandler);

			// init level
			level = new Level(scene, _light);

			// init player
			resources.hellKnightMesh.material.lights = [_light];
			player = new Player(resources.hellKnightMesh.clone() as Mesh, scene, resources.idleAnimation, resources.walkAnimation, stage);
			player.entity.position = new Vector3D(0, 500 + level.terrainMesh.getHeightAt(0, -1000), -1000);

			// init enemies
			_enemies = new Vector.<Enemy>();
			for(var i:uint; i < 2; ++i)
			{
				var x:Number = rand(-3000, 3000);
				var z:Number = rand(-3000, 3000);
				var mesh:Mesh = resources.hellKnightMesh.clone() as Mesh;
				mesh.scale(rand(0.5, 1.5));
				var enemy:Enemy = new Enemy(mesh, scene, resources.idleAnimation, resources.walkAnimation);
				enemy.entity.position = new Vector3D(x, 500 + level.terrainMesh.getHeightAt(x, z), z);
				_enemies.push(enemy);
			}

			// init camera control
			camera = new Camera(stage, view, player.entity, player.controller, player.baseMesh);
			cameraMode = "orbit";

			// set additional gui...

			// camera
			gui.addGroup("camera");
			var cameraModes:Array = [
				{label:"observer", data:"observer"},
				{label:"orbit", data:"orbit"},
				{label:"free fly", data:"fly"},
				{label:"third person", data:"3rd"},
				{label:"first person", data:"1st"}
			];
			gui.addComboBox("cameraMode", cameraModes, {width:100, label:"camera mode", numVisibleItems:cameraModes.length});
			gui.addSlider("camera.controller.linearEase", 0.01, 1, {label:"linear ease"});
			gui.addSlider("camera.controller.angularEase", 0.01, 1, {label:"angular ease"});

			// player
			gui.addGroup("player");
			gui.addToggle("player.entity.kinematicCapsuleMesh.visible", {label:"debug kinematic"});
			gui.addToggle("player.entity.dynamicCapsuleMesh.visible", {label:"debug dynamic"});
			gui.addSlider("player.entity.collideStrength", 0.01, 25000, {label:"strength"});
			gui.addSlider("player.controller.speedEase", 0.01, 1, {label:"move ease"});
			gui.addSlider("player.controller.animatorTimeScaleFactor", 0.01, 1, {label:"anim speed"});
			gui.addSlider("player.controller.animationCrossFadeTime", 0.01, 2, {label:"anim fade"});

			// physics
			gui.addGroup("physics");
			_gravityY = scene.gravity.y;
			gui.addSlider("gravityY", -50, 50, {label:"gravity"});

			// level
			gui.addGroup("level");
			gui.addButton("reset", {callback:level.reset});

			// start loop
			addEventListener(Event.ENTER_FRAME, enterframeHandler);
		}

		// ---------------------------------------------------------------------
		// loop
		// ---------------------------------------------------------------------

		private function enterframeHandler(evt:Event):void
		{
			// update player
			player.update();

			// update enemies
			for(var i:uint; i < _enemies.length; ++i)
			{
				_enemies[i].update();
			}

			// update scene physics
			scene.updatePhysics();

			// update camera transform
			camera.update();

			// light follows camera
			_light.transform = view.camera.transform.clone();

			// render 3d view
			view.render();
		}

		// ---------------------------------------------------------------------
		// utils
		// ---------------------------------------------------------------------

		private function rand(min:Number, max:Number):Number
		{
		    return (max - min)*Math.random() + min;
		}

		// ---------------------------------------------------------------------
		// additional gui stuff
		// ---------------------------------------------------------------------

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
				case "observer":
					camera.enableObserverCameraController();
					break;
				case "orbit":
					camera.enableOrbitCameraController();
					break;
				case "fly":
					camera.enableFlyCameraController();
					break;
				case "1st":
					camera.enableFPSCameraController();
					break;
				case "3rd":
					camera.enable3rdPersonCameraController();
					break;
			}
		}

		private var _gravityY:Number;
		public function get gravityY():Number
		{
			return _gravityY;
		}

		public function set gravityY(value:Number):void
		{
			_gravityY = value;
			scene.gravity = new Vector3D(0, _gravityY, 0);
		}
	}
}
