package agt.parsing
{

	import agt.debug.DebugMaterialLibrary;
	import agt.physics.PhysicsScene3D;
	import agt.physics.entities.DynamicEntity;

	import away3d.bounds.AxisAlignedBoundingBox;

	import away3d.containers.ObjectContainer3D;

	import away3d.entities.Mesh;
	import away3d.library.assets.IAsset;
	import away3d.materials.MaterialBase;

	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.collision.shapes.AWPBvhTriangleMeshShape;

	import awayphysics.collision.shapes.AWPConeShape;
	import awayphysics.collision.shapes.AWPCylinderShape;

	import awayphysics.collision.shapes.AWPShape;
	import awayphysics.collision.shapes.AWPSphereShape;
	import awayphysics.collision.shapes.AWPStaticPlaneShape;

	import flash.events.Event;

	import flash.geom.Vector3D;

	public class GameLevel
	{
		protected var _scene:PhysicsScene3D;
		protected var _sourceMesh:Mesh;
		protected var _defMass:Number;
		protected var _defFriction:Number;

		public var playerSpawnPosition:Vector3D;
		public var showColliders:Boolean = false;
		public var showNonColliders:Boolean = true;

		private var _meshes:Array;

		public function GameLevel(scene:PhysicsScene3D, sourceMesh:Mesh, defMass:Number = 0, defFriction:Number = 0.9)
		{
			_scene = scene;
			_sourceMesh = sourceMesh;
			_defMass = defMass;
			_defFriction = defFriction;

			_meshes = [];
		}

		public function parse():void
		{
			trace("parsing scene /////////////////");

			// register children in array and sweep them
			var len:uint = _sourceMesh.numChildren;
			var children:Array = [];
			for(var i:uint; i < len; ++i)
				children.push(_sourceMesh.getChildAt(i));
			for(i = 0; i < len; ++i)
				parseObject(children[i]);
		}

		private function parseObject(obj:ObjectContainer3D):void
		{
			trace("parsing game level object >>>>>>>> ");

			// check for type property and apply the appropriate function to the object
			if(obj.extra && obj.extra.hasOwnProperty("type"))
			{
				trace("type: " + obj.extra.type);
				redirectParse(obj.extra.type, obj);
//				var typeStr:String = obj.extra.type;
//				var firstChar:String = typeStr.substr(0, 1);
//				var restOfString:String = typeStr.substr(1, typeStr.length);
//				var funcName:String = "parse" + firstChar.toUpperCase() + restOfString.toLowerCase();
//				if(this.hasOwnProperty(funcName))
//					this[funcName](obj);
//				else
//					trace("*** Warning, parsing method '" + funcName + "()' does not exist. ***");
			}
			else
			{
				if(obj is Mesh)
				{
					var mesh:Mesh = Mesh(obj);
					if(mesh.material && mesh.material.extra && mesh.material.extra.hasOwnProperty("surface"))
						redirectParse(mesh.material.extra.surface, mesh.material);
				}

				if(!showNonColliders)
					obj.visible = false;

				_scene.addChild(obj);
			}
		}

		private function redirectParse(id:String, asset:IAsset):void
		{
			var firstChar:String = id.substr(0, 1);
			var restOfString:String = id.substr(1, id.length);
			var funcName:String = "parse" + firstChar.toUpperCase() + restOfString.toLowerCase();
			if(this.hasOwnProperty(funcName))
				this[funcName](asset);
			else
				trace("------------------------- *** Warning, parsing method '" + funcName + "()' does not exist. ***");
		}

		// -----------------------
		// default parse methods
		// -----------------------

		public function parsePlayerspawn(obj:ObjectContainer3D):void
		{
			playerSpawnPosition = obj.position;
		}

		public function parseCollider(obj:ObjectContainer3D):void
		{
			var mesh:Mesh = obj as Mesh;
//			mesh.material = DebugMaterialLibrary.instance.transparentRedMaterial;
			mesh.material = DebugMaterialLibrary.instance.redMaterial;

			var aabb:AxisAlignedBoundingBox;
			var friction:Number;
			var mass:Number;
			var shape:AWPShape;

			trace("shape: " + mesh.extra.shape);

			switch(mesh.extra.shape)
			{
				case 'plane':
					var up:Vector3D = mesh.transform.deltaTransformVector(Vector3D.Y_AXIS);
					up.negate();
					shape = new AWPStaticPlaneShape(up);
					break;

				case 'sphere':
					aabb = AxisAlignedBoundingBox(mesh.bounds);
					shape = new AWPSphereShape((aabb.max.x - aabb.min.x) / 2.0);
					break;

				case 'cone':
					aabb = AxisAlignedBoundingBox(mesh.bounds);
					shape = new AWPConeShape((aabb.max.x - aabb.min.x) / 2.0, aabb.max.y - aabb.min.y);
					break;

				case 'cylinder':
					aabb = AxisAlignedBoundingBox(mesh.bounds);
					shape = new AWPCylinderShape((aabb.max.x - aabb.min.x) / 2.0, aabb.max.y - aabb.min.y);
					break;

				case 'mesh':
					shape = new AWPBvhTriangleMeshShape(mesh);
					break;

				case 'box':
				default:
					// Default is to use bounding box
					aabb = AxisAlignedBoundingBox(mesh.bounds);
					shape = new AWPBoxShape(aabb.max.x - aabb.min.x, aabb.max.y - aabb.min.y, aabb.max.z - aabb.min.z);
					break;
			}

			friction = mesh.extra.hasOwnProperty('friction') ? parseFloat(mesh.extra["friction"]) : _defFriction;
			mass = mesh.extra.hasOwnProperty('mass') ? parseFloat(mesh.extra["mass"]) : _defMass;

			var entity:DynamicEntity = new DynamicEntity(shape, mesh, mass, true);
			entity.body.friction = friction;

			entity.container.visible = showColliders;
			mesh.scale(1.05);

			_meshes.push(mesh);
			/*mesh.addEventListener(Event.ENTER_FRAME, function(evt:Event):void {

				trace("ETF!");

				var mesh:Mesh = evt.target as Mesh;
				mesh.rotationX += 5;

			})*/

			_scene.addDynamicEntity(entity);
		}

		public function update():void
		{
			for(var i:uint; i < _meshes.length; ++i)
			{
				_meshes[i].rotationX += 1;
			}
		}
	}
}
