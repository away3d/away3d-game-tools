package CameraAndCharacterControl
{

	import away3d.animators.data.SkeletonAnimationSequence;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.library.assets.AssetType;
	import away3d.loaders.Loader3D;
	import away3d.loaders.parsers.MD5AnimParser;
	import away3d.loaders.parsers.MD5MeshParser;
	import away3d.materials.BitmapMaterial;

	import flash.events.Event;

	import flash.events.EventDispatcher;

	public class Resources extends EventDispatcher
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

		public var hellKnightMesh:Mesh;
		public var idleAnimation:SkeletonAnimationSequence;
		public var walkAnimation:SkeletonAnimationSequence;

		public function Resources()
		{
			super();
		}

		public function load():void
		{
			// start load process...
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

			// notify load complete
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}
