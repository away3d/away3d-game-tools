package CameraAndCharacterControl
{

	import agt.debug.DebugMaterialLibrary;

	import away3d.animators.data.SkeletonAnimationSequence;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.library.assets.AssetType;
	import away3d.lights.PointLight;
	import away3d.loaders.Loader3D;
	import away3d.loaders.parsers.MD5AnimParser;
	import away3d.loaders.parsers.MD5MeshParser;

	import flash.events.Event;
	import flash.geom.Vector3D;

	public class CameraAndCharacterControlExample extends AGTExampleBase
	{
		[Embed(source="../assets/models/hellknight/hellknight.md5mesh", mimeType="application/octet-stream")]
		private var HellKnightMesh:Class;
		[Embed(source="../assets/models/hellknight/idle2.md5anim", mimeType="application/octet-stream")]
		private var HellKnightIdleAnimation:Class;
		[Embed(source="../assets/models/hellknight/walk7.md5anim", mimeType="application/octet-stream")]
		private var HellKnightWalkAnimation:Class;
		[Embed(source="../assets/models/hellknight/hellknight.jpg")]
		private var HellKnightTexture:Class;
		[Embed(source="../assets/models/hellknight/hellknight_s.png")]
		private var HellKnightSpecularMap:Class;
		[Embed(source="../assets/models/hellknight/hellknight_local.png")]
		private var HellKnightNormalMap:Class;

		private var _light:PointLight;
		private var _hellKnightMesh:Mesh;
		private var _idleAnimation:SkeletonAnimationSequence;
		private var _walkAnimation:SkeletonAnimationSequence;

		public var level:Level;
		public var player:Player;
		public var camera:Camera;

		public function CameraAndCharacterControlExample()
		{
			super();
		}

		// ---------------------------------------------------------------------
		// init
		// ---------------------------------------------------------------------

		override protected function startExample():void
		{
			// set example signature
			signatureText = "AwayGameTools 2011 - Camera and character control example.";

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
			// (1) retrieve hell knight mesh
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
			_hellKnightMesh = evt.asset as Mesh;

			// (2) retrieve hell knight idle animation sequence
			trace("loading idle animation...");
			var loader:Loader3D = new Loader3D();
			loader.addEventListener(AssetEvent.ASSET_COMPLETE, init2);
			loader.parseData(new HellKnightIdleAnimation(), new MD5AnimParser());
		}

		private function init2(evt:AssetEvent):void
		{
			// retrieve hell knight idle animation sequence
			trace("idle animation loaded");
			_idleAnimation = evt.asset as SkeletonAnimationSequence;
			_idleAnimation.name = "idle";

			// (3) retrieve hell knight idle animation sequence
			trace("loading walk animation...");
			var loader:Loader3D = new Loader3D();
			loader.addEventListener(AssetEvent.ASSET_COMPLETE, init3);
			loader.parseData(new HellKnightWalkAnimation(), new MD5AnimParser());
		}

		private function init3(evt:AssetEvent):void
		{
			// retrieve hell knight idle animation sequence
			trace("walk animation loaded");
			_walkAnimation = evt.asset as SkeletonAnimationSequence;
			_walkAnimation.name = "walk";

			// load process complete.

			// init level
			level = new Level(scene, _light);

			// init player
			player = new Player(stage, scene, _light,
					_idleAnimation, _walkAnimation,
					_hellKnightMesh,
					new HellKnightTexture().bitmapData,
					new HellKnightNormalMap().bitmapData,
					new HellKnightSpecularMap().bitmapData,
					level.terrainMesh);

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
