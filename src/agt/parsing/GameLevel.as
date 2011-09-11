package agt.parsing
{

	import agt.debug.DebugMaterialLibrary;
	import agt.physics.PhysicsScene3D;
	import agt.physics.entities.DynamicEntity;

	import away3d.bounds.AxisAlignedBoundingBox;

	import away3d.containers.ObjectContainer3D;

	import away3d.entities.Mesh;
	import away3d.library.assets.IAsset;
	import away3d.materials.DefaultMaterialBase;

	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.collision.shapes.AWPBvhTriangleMeshShape;
	import awayphysics.collision.shapes.AWPCollisionShape;

	import awayphysics.collision.shapes.AWPConeShape;
	import awayphysics.collision.shapes.AWPCylinderShape;

	import awayphysics.collision.shapes.AWPSphereShape;
	import awayphysics.collision.shapes.AWPStaticPlaneShape;

	import flash.geom.Vector3D;

	public class GameLevel
	{
		protected var _scene:PhysicsScene3D;
		protected var _sourceMesh:Mesh;
		protected var _defMass:Number;
		protected var _defFriction:Number;
		protected var _colliderMeshes:Vector.<ObjectContainer3D>;
		protected var _nonColliderMeshes:Vector.<ObjectContainer3D>;

		public var playerSpawnPosition:Vector3D;

		private var _debugColliders:Boolean = false;

		public function GameLevel(scene:PhysicsScene3D, sourceMesh:Mesh, defMass:Number = 0, defFriction:Number = 0.9)
		{
			_scene = scene;
			_sourceMesh = sourceMesh;
			_defMass = defMass;
			_defFriction = defFriction;

			_colliderMeshes = new Vector.<ObjectContainer3D>();
			_nonColliderMeshes = new Vector.<ObjectContainer3D>();
		}

		public function parse():void
		{
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
			if(obj.extra) // parse objects
			{
				if(obj.extra.hasOwnProperty("type") && obj.extra.type != "collider") // parse by type
					processDefault(obj);

				for(var prop:String in obj.extra)
				{
					if(prop == "shape")
						continue;

					redirectParse(obj.extra[prop], prop, obj);
				}
			}
			else
				processDefault(obj);
		}

		private function processDefault(obj:ObjectContainer3D):void
		{
			if(obj is Mesh) // parse materials
			{
				var mesh:Mesh = Mesh(obj);
				mesh.castsShadows = false; // TODO: Create a default mesh parser in extending classes?
				if(mesh.material)
				{
					var mat:DefaultMaterialBase = DefaultMaterialBase(mesh.material);
					if(mat.extra)
					{
						for(var prop:String in mat.extra)
						{
//							trace("XXX MAT PROP: " + prop + " -> " + mat.extra[prop]);
							redirectParse(mat.extra[prop], prop, mat);
						}
					}
				}
			}

			_nonColliderMeshes.push(obj);

			_scene.addChild(obj);
		}

		private function redirectParse(propValue:String, propName:String, asset:IAsset):void
		{
			propValue = firstCharToUpperCase(propValue);
			propName = firstCharToUpperCase(propName);
			var funcName:String = "parse" + propName + propValue;
			if(this.hasOwnProperty(funcName))
			{
				trace("@@@ redirecting parse to: " + funcName + "()");
				this[funcName](asset);
			}
			else
				trace("------------------------- *** Warning, parsing method '" + funcName + "()' does not exist. ***");
		}

		private function firstCharToUpperCase(str:String):String
		{
			var firstChar:String = str.substr(0, 1);
			var restOfString:String = str.substr(1, str.length);
			return firstChar.toUpperCase() + restOfString.toLowerCase();
		}

		// -----------------------
		// default parse methods
		// -----------------------

		public function parseRepeatTrue(mat:DefaultMaterialBase):void
		{
			mat.repeat = true;
		}

		public function parseAlphathresholdTrue(mat:DefaultMaterialBase):void
		{
			mat.alphaThreshold = 0.5;
		}

		public function parseTypePlayerspawn(obj:ObjectContainer3D):void
		{
			playerSpawnPosition = obj.position;
		}

		public function parseTypeCollider(obj:ObjectContainer3D):void
		{
			var mesh:Mesh = obj as Mesh;
			mesh.material = DebugMaterialLibrary.instance.redMaterial;

			var aabb:AxisAlignedBoundingBox;
			var friction:Number;
			var mass:Number;
			var shape:AWPCollisionShape;

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
					mesh.material = DebugMaterialLibrary.instance.greenMaterial;
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

			var entity:DynamicEntity = new DynamicEntity(shape, mesh, mass, true, 1); // TODO: add scaling options
			entity.body.friction = friction;

			mesh.visible = false;
			_colliderMeshes.push(mesh);

			_scene.addDynamicEntity(entity);
		}

		public function get debugColliders():Boolean
		{
			return _debugColliders;
		}

		public function set debugColliders(value:Boolean):void
		{
			_debugColliders = value;

			showColliders(_debugColliders);
			showNonColliders(!_debugColliders);
		}

		public function showColliders(visible:Boolean = true):void
		{
			var len:uint = _colliderMeshes.length;
			for(var i:uint; i < len; ++i)
				_colliderMeshes[i].visible = visible;
		}

		public function showNonColliders(visible:Boolean = true):void
		{
			var len:uint = _nonColliderMeshes.length;
			for(var i:uint; i < len; ++i)
				_nonColliderMeshes[i].visible = visible;
		}
	}
}
