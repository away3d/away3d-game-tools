package CameraAndCharacterControl
{

	import agt.physics.PhysicsScene3D;
	import agt.debug.DebugMaterialLibrary;
	import agt.physics.entities.DynamicEntity;

	import away3d.containers.ObjectContainer3D;

	import away3d.entities.Mesh;

	import away3d.extrusions.Elevation;

	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.Cube;

	import awayphysics.collision.shapes.AWPBoxShape;

	import awayphysics.collision.shapes.AWPBvhTriangleMeshShape;
	import awayphysics.dynamics.AWPRigidBody;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Vector3D;

	public class Level
	{
		public var terrainMesh:Elevation;

		private var _boxes:Vector.<DynamicEntity>;
		private var _scene:PhysicsScene3D;
		private var _light:PointLight;

		public function Level(scene:PhysicsScene3D, light:PointLight)
		{
			_scene = scene;
			_light = light;
			initTerrain();
			initObjects();
		}

		public function reset():void
		{
			initObjects();
		}

		private function initTerrain():void
		{
			/*
			 NOTE: Terrain collision here uses triangle based collision, which is of course
			 not very efficient. It is done so just for the sake of testing the performance on triangle based collision.
			 */

			// perlin noise height map
			var heightMap:BitmapData = new BitmapData(1024, 1024, false, 0x000000);
			heightMap.perlinNoise(500, 500, 3, Math.floor(1000*Math.random()) + 1, false, true, 7, true);

			// alter the height map a little
			for(var i:uint; i < 20; ++i)
			{
				var circleRadius:Number = rand(32, 128);
				var r:Number = rand(256, 512);
				var angle:Number = 2 * Math.PI * Math.random();
				var x:Number = r * Math.cos(angle);
				var y:Number = r * Math.sin(angle);
				var spr:Sprite = new Sprite();
				var gray:Number = 127 + 127*Math.random();
				spr.graphics.beginFill(gray << 16 | gray << 8 | gray);
				spr.graphics.drawCircle(512 + x, 512 + y, circleRadius);
				heightMap.draw(spr);
			}

			// use height map to produce mesh
			var terrainMaterial:ColorMaterial = DebugMaterialLibrary.instance.whiteMaterial;
			terrainMesh = new Elevation(terrainMaterial, heightMap, 15000, 2000, 15000, 60, 60);

			// add body
			var terrainShape:AWPBvhTriangleMeshShape = new AWPBvhTriangleMeshShape(terrainMesh);
			var terrain:DynamicEntity = new DynamicEntity(terrainShape, terrainMesh);
			terrain.body.mass = 0;
			_scene.addDynamicEntity(terrain);
		}

		private function initObjects():void
		{
			var i:uint;

			// remove old objects?
			if(_boxes)
			{
				for(i = 0; i < _boxes.length; ++i)
					_scene.removeDynamicEntity(_boxes[i]);
			}

			// reset array
			_boxes = new Vector.<DynamicEntity>();

			// box shape
			var boxShape:AWPBoxShape = new AWPBoxShape(200, 200, 200);

			// box material
			var boxMaterial:ColorMaterial = DebugMaterialLibrary.instance.redMaterial;
			boxMaterial.lights = [_light];

			// sample box
			var boxMesh:Cube = new Cube(boxMaterial, 200, 200, 200);

			// create box array
			var numX:int = 4;
			var numY:int = 3;
			var numZ:int = 1;
			for(i = 0; i < numX; i++)
			{
				for(var j:int = 0; j < numZ; j++)
				{
					var x:Number = i*200;
					var z:Number = j*200;
					var terrainHeightAtXZ:Number = terrainMesh.getHeightAt(x, z);

					for(var k:int = 0; k < numY; k++)
					{
						var y:Number = 100 + terrainHeightAtXZ + k*200;

						// create boxes
						var box:DynamicEntity = new DynamicEntity(boxShape, boxMesh.clone() as ObjectContainer3D, 0.5);
						box.body.friction = 0.9;
						box.body.linearDamping = 0.03;
						box.body.angularDamping = 0.03;
						box.body.position = new Vector3D(x, y, z);
						_boxes.push(box);
						_scene.addDynamicEntity(box);
					}
				}
			}
		}

		private function rand(min:Number, max:Number):Number
		{
			return (max - min)*Math.random() + min;
		}
	}
}
