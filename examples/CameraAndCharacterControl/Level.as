package CameraAndCharacterControl
{

	import agt.core.PhysicsScene3D;
	import agt.debug.DebugMaterialLibrary;

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

		public function Level(scene:PhysicsScene3D, light:PointLight)
		{
			initTerrain(scene, light);
			initObjects(scene, light);
		}

		private function initTerrain(scene:PhysicsScene3D, light:PointLight):void
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
			terrainMaterial.lights = [light];
			terrainMesh = new Elevation(terrainMaterial, heightMap, 15000, 2000, 15000, 60, 60);
			scene.addChild(terrainMesh);

			// add body
			var sceneShape:AWPBvhTriangleMeshShape = new AWPBvhTriangleMeshShape(terrainMesh);
			var sceneBody:AWPRigidBody = new AWPRigidBody(sceneShape, terrainMesh, 0);
			scene.addRigidBody(sceneBody);
		}

		private function initObjects(scene:PhysicsScene3D, light:PointLight):void
		{
			// box shape
			var boxShape:AWPBoxShape = new AWPBoxShape(200, 200, 200);

			// box material
			var material:ColorMaterial = DebugMaterialLibrary.instance.redMaterial;
			material.lights = [light];

			// create box array
			var mesh:Mesh;
			var body:AWPRigidBody;
			var numX:int = 6;
			var numY:int = 4;
			var numZ:int = 1;
			for(var i:int = 0; i < numX; i++)
			{
				for(var j:int = 0; j < numZ; j++)
				{
					var x:Number = i*200;
					var z:Number = j*200;
					var terrainHeightAtXZ:Number = terrainMesh.getHeightAt(x, z);

					for(var k:int = 0; k < numY; k++)
					{

						var y:Number = 75 + terrainHeightAtXZ + k*200;

						// create boxes
						mesh = new Cube(material, 200, 200, 200); // TODO: Create meshes and bodies in 1 step with AGT?
						scene.addChild(mesh);
						body = new AWPRigidBody(boxShape, mesh, 0.1);
						body.friction = .9;
						body.linearDamping = 0.05;
						body.angularDamping = 0.05;
						body.position = new Vector3D(x, y, z);
						scene.addRigidBody(body);
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
