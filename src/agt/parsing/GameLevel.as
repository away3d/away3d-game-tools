package agt.parsing
{

	import agt.debug.DebugMaterialLibrary;
	import agt.physics.PhysicsScene3D;
	import agt.physics.entities.DynamicEntity;

	import away3d.bounds.AxisAlignedBoundingBox;

	import away3d.containers.ObjectContainer3D;

	import away3d.entities.Mesh;

	import awayphysics.collision.shapes.AWPBoxShape;

	import awayphysics.collision.shapes.AWPConeShape;
	import awayphysics.collision.shapes.AWPCylinderShape;

	import awayphysics.collision.shapes.AWPShape;
	import awayphysics.collision.shapes.AWPSphereShape;
	import awayphysics.collision.shapes.AWPStaticPlaneShape;

	import flash.geom.Vector3D;

	public class GameLevel
	{
		private var _scene:PhysicsScene3D;
		private var _sourceMesh:Mesh;
		private var _defMass : Number;
		private var _defFriction : Number;

		public var showColliders:Boolean = false;

		public function GameLevel(scene:PhysicsScene3D, sourceMesh:Mesh, defMass:Number = 0, defFriction:Number = 0.9)
		{
			_scene = scene;
			_sourceMesh = sourceMesh;
			_defMass = defMass;
			_defFriction = defFriction;
		}

		public function parse():void
		{
			trace("parsing scene...");

			var len:uint = _sourceMesh.numChildren;
			var children:Array = [];
			for(var i:uint; i < len; ++i)
			{
				children.push(_sourceMesh.getChildAt(i));
			}
			for(i = 0; i < len; ++i)
			{
			    parseObject(children[i]);
			}
		}

		private function parseObject(obj:ObjectContainer3D):void
		{
			trace("parsing game level object...");
			if(obj.extra && obj.extra.hasOwnProperty("type"))
			{
				trace("type: " + obj.extra.type);

				switch(obj.extra.type)
				{
					case ObjectType.COLLIDER:
						parseCollider(obj);
						break;
					default:
						_scene.addChild(obj);
						break;
				}

				if(obj.extra.hasOwnProperty("type"))
				{

				}
			}
		}

		private function parseCollider(obj:ObjectContainer3D):void
		{
			var mesh:Mesh = obj as Mesh;
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

				case 'box':
				default:
					// Default is to use bounding box
					aabb = AxisAlignedBoundingBox(mesh.bounds);
					shape = new AWPBoxShape(aabb.max.x - aabb.min.x, aabb.max.y - aabb.min.y, aabb.max.z - aabb.min.z);
					break;
			}

			friction = mesh.extra.hasOwnProperty('friction') ? parseFloat(mesh.extra["friction"]) : _defFriction;
			mass = mesh.extra.hasOwnProperty('mass') ? parseFloat(mesh.extra["mass"]) : _defMass;

			var entity:DynamicEntity = new DynamicEntity(shape, mesh, mass);
			entity.body.friction = friction;

			entity.container.visible = showColliders;

			_scene.addDynamicEntity(entity);
		}
	}
}
